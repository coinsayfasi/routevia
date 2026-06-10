import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/i18n.dart';
import '../../data/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _createAccount = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _resetSent = false;
  bool _verificationResent = false;

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) async {
      if (event.event == AuthChangeEvent.passwordRecovery) return;
      if (event.session != null && mounted) {
        try {
          final repo = ref.read(repositoryProvider);
          await repo.ensureProfile();
          final profile = await repo.getMyProfile();
          final completed = (profile?['onboarding_completed'] as bool?) ?? false;
          // Refresh premium state so admin role is detected immediately
          ref.read(premiumStateProvider.notifier).refresh();
          if (!completed) {
            if (mounted) context.go('/onboarding');
            return;
          }
        } catch (e) {
          debugPrint('[AuthScreen] post-login setup error: $e');
          // Profile setup failed — still navigate to home; session is valid
        }
        if (mounted) context.go('/home');
      }
    });

    if (Supabase.instance.client.auth.currentSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _friendlyAuthError(Object error) {
    final lower = error.toString().toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return context.tr('E-posta veya şifre hatalı.', 'Incorrect email or password.');
    }
    if (lower.contains('email rate limit') || lower.contains('security purposes')) {
      return context.tr(
        'Çok sık istek gönderildi. Birkaç saniye bekleyip tekrar dene.',
        'Too many requests. Wait a few seconds and try again.',
      );
    }
    if (lower.contains('invalid email')) return context.tr('Geçersiz e-posta adresi.', 'Invalid email address.');
    if (lower.contains('email not confirmed')) {
      return context.tr('E-posta doğrulanmamış. Şifreni sıfırlamayı dene.', 'Email is not verified. Try resetting your password.');
    }
    if (lower.contains('password should be at least')) {
      return context.tr('Şifre en az 6 karakter olmalı.', 'Password must be at least 6 characters.');
    }
    if (lower.contains('password') && (lower.contains('leaked') || lower.contains('pwned') || lower.contains('compromised'))) {
      return context.tr(
        'Bu şifre güvensiz. Daha önce veri ihlalinde ele geçirilmiş. Lütfen farklı bir şifre seç.',
        'This password is not secure. It has been found in a data breach. Please choose a different password.',
      );
    }
    if (lower.contains('user already registered')) {
      return context.tr('Bu e-posta zaten kayıtlı. Giriş yapmayı dene.', 'This email is already registered. Try signing in.');
    }
    if (lower.contains('error sending')) {
      return context.tr('Mail gönderilemedi. Biraz sonra tekrar dene.', 'Email could not be sent. Please try again later.');
    }
    if (lower.contains('otp') && (lower.contains('expired') || lower.contains('invalid'))) {
      return context.tr('Doğrulama bağlantısının süresi dolmuş. Yeniden kayıt olmayı veya maili tekrar göndermeyi dene.', 'Verification link has expired. Try signing up again or resend the email.');
    }
    if (lower.contains('timeout') || lower.contains('timed out') || lower.contains('connection')) {
      return context.tr('Bağlantı zaman aşımına uğradı. İnternet bağlantını kontrol edip tekrar dene.', 'Connection timed out. Check your internet connection and try again.');
    }
    if (lower.contains('token') && lower.contains('expired')) {
      return context.tr('Bağlantının süresi dolmuş. Lütfen tekrar dene.', 'The link has expired. Please try again.');
    }
    if (lower.contains('over_request_rate_limit') || lower.contains('over request rate limit')) {
      return context.tr('Çok fazla istek gönderildi. Biraz bekleyip tekrar dene.', 'Too many requests. Please wait and try again.');
    }
    if (lower.contains('user_already_exists') || lower.contains('already registered') || lower.contains('already exists')) {
      return context.tr('Bu e-posta zaten kayıtlı. Giriş yapmayı dene.', 'This email is already registered. Try signing in.');
    }
    if (lower.contains('signup_disabled') || lower.contains('signups not allowed')) {
      return context.tr('Şu an kayıt yapılamıyor. Daha sonra tekrar dene.', 'Signups are currently disabled. Please try again later.');
    }
    if (lower.contains('network') || lower.contains('socket') || lower.contains('unreachable')) {
      return context.tr('İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene.', 'No internet connection. Check your connection and try again.');
    }
    return context.tr('Bir hata oluştu. Lütfen tekrar dene.', 'Something went wrong. Please try again.');
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;
    if (email.isEmpty || !email.contains('@')) {
      _snack(context.tr('Geçerli bir e-posta gir.', 'Enter a valid email.'));
      return;
    }
    if (password.length < 6) {
      _snack(context.tr('Şifre en az 6 karakter olmalı.', 'Password must be at least 6 characters.'));
      return;
    }
    if (_createAccount && password != confirm) {
      _snack(context.tr('Şifre tekrarı eşleşmiyor.', 'Passwords do not match.'));
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(repositoryProvider);
      if (_createAccount) {
        await repo.signUpWithPassword(email: email, password: password);
        if (!mounted) return;
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          // Email confirmation enabled → Supabase sends a 6-digit code; take the
          // user to the verification screen to enter it (no magic link).
          context.go('/verify?email=${Uri.encodeComponent(email)}');
          return;
        }
        _snack(context.tr('Hesap oluşturuldu, oturum açılıyor...', 'Account created, signing you in...'));
      } else {
        await repo.signInWithPassword(email: email, password: password);
        if (!mounted) return;
        _snack(context.tr('Giriş başarılı.', 'Signed in successfully.'));
      }
    } catch (e) {
      if (!mounted) return;
      _snack(_friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack(context.tr('Önce e-posta adresini gir.', 'Enter your email first.'));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(repositoryProvider).resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() => _resetSent = true);
      _snack(
        context.tr(
          '$email adresine şifre sıfırlama bağlantısı gönderildi.',
          'A password reset link was sent to $email.',
        ),
        duration: 6,
      );
    } catch (e) {
      if (!mounted) return;
      _snack(_friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendVerification() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack(context.tr('Önce e-posta adresini gir.', 'Enter your email first.'));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(repositoryProvider).resendSignupConfirmation(email);
      if (!mounted) return;
      setState(() => _verificationResent = true);
      // A fresh 6-digit code was sent → go to the verification screen to enter it.
      context.go('/verify?email=${Uri.encodeComponent(email)}');
      return;
    } catch (e) {
      if (!mounted) return;
      _snack(_friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {int duration = 4}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF061126), Color(0xFF0B1F3A), Color(0xFF133E75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Logo
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Color(0xFF7DD3FC),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Routevia Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _createAccount ? context.tr('Hesap Oluştur', 'Create Account') : context.tr('Giriş Yap', 'Sign In'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _createAccount
                      ? context.tr('E-posta ve şifrenle hesap oluştur.', 'Create an account with your email and password.')
                      : context.tr('Hoş geldin. E-posta ve şifrenle devam et.', 'Welcome back. Continue with your email and password.'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),

                // Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD6E4F5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26061226),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: context.tr('E-posta', 'Email'),
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: context.tr('Şifre', 'Password'),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // Confirm password (signup only)
                      if (_createAccount) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: context.tr('Şifre Tekrarı', 'Confirm Password'),
                            prefixIcon:
                                const Icon(Icons.lock_person_outlined),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      // Forgot password (login mode only)
                      if (!_createAccount) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _resetPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0B3B68),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                            ),
                            child: Text(
                              _resetSent
                                  ? context.tr('Mail gönderildi ✓', 'Email sent ✓')
                                  : context.tr('Şifremi unuttum', 'Forgot password'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ] else ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _resendVerification,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0B3B68),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                            ),
                            child: Text(
                              _verificationResent
                                  ? context.tr(
                                      'Doğrulama maili gönderildi ✓',
                                      'Verification email sent ✓',
                                    )
                                  : context.tr(
                                      'Doğrulama mailini tekrar gönder',
                                      'Resend verification email',
                                    ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: Icon(
                            _createAccount
                                ? Icons.person_add_alt_1
                                : Icons.login,
                          ),
                          label: Text(
                            _loading
                                ? context.tr('İşleniyor...', 'Processing...')
                                : (_createAccount
                                      ? context.tr('Hesap Oluştur', 'Create Account')
                                      : context.tr('Giriş Yap', 'Sign In')),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0B3B68),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Toggle signup/login
                      Center(
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() {
                                  _createAccount = !_createAccount;
                                  _resetSent = false;
                                }),
                          child: Text(
                            _createAccount
                                ? context.tr('Zaten hesabın var mı? Giriş yap', 'Already have an account? Sign in')
                                : context.tr('Hesabın yok mu? Kayıt ol', 'No account yet? Sign up'),
                            style: const TextStyle(
                              color: Color(0xFF0B3B68),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Guest button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(context.tr('Misafir devam et (sınırlı)', 'Continue as guest (limited)')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
