import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) async {
      if (event.event == AuthChangeEvent.passwordRecovery) return;
      if (event.session != null && mounted) {
        final repo = ref.read(repositoryProvider);
        await repo.ensureProfile();
        // Refresh premium state so admin role is detected immediately
        ref.read(premiumStateProvider.notifier).refresh();
        final pendingCode = await ref
            .read(localCacheProvider)
            .getPendingReferralCode();
        final profile = await repo.getMyProfile();
        final completed = (profile?['onboarding_completed'] as bool?) ?? false;
        if (pendingCode != null && pendingCode.isNotEmpty) {
          await ref.read(localCacheProvider).setPendingReferralCode(null);
          if (mounted) context.go('/onboarding?ref=$pendingCode');
          return;
        }
        if (!completed) {
          if (mounted) context.go('/onboarding');
          return;
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
      return 'E-posta veya şifre hatalı.';
    }
    if (lower.contains('email rate limit') || lower.contains('security purposes')) {
      return 'Çok sık deneme yapıldı. Biraz bekle.';
    }
    if (lower.contains('invalid email')) return 'Geçersiz e-posta adresi.';
    if (lower.contains('email not confirmed')) {
      return 'E-posta doğrulanmamış. Şifreni sıfırlamayı dene.';
    }
    if (lower.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalı.';
    }
    if (lower.contains('user already registered')) {
      return 'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.';
    }
    if (lower.contains('error sending')) {
      return 'Mail gönderilemedi. Biraz sonra tekrar dene.';
    }
    return error.toString();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _snack('Geçerli bir e-posta gir.');
      return;
    }
    if (password.length < 6) {
      _snack('Şifre en az 6 karakter olmalı.');
      return;
    }
    if (_createAccount && password != confirm) {
      _snack('Şifre tekrarı eşleşmiyor.');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_createAccount) {
        await ref
            .read(repositoryProvider)
            .signUpWithPassword(email: email, password: password);
        if (!mounted) return;
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          _snack(
            '$email adresine doğrulama bağlantısı gönderildi. '
            'Mailine gel, bağlantıya tıkla ve geri dön.',
            duration: 8,
          );
          return;
        }
        _snack('Hesap oluşturuldu, oturum açılıyor...');
      } else {
        await ref
            .read(repositoryProvider)
            .signInWithPassword(email: email, password: password);
        if (!mounted) return;
        _snack('Giriş başarılı.');
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
      _snack('Önce e-posta adresini gir.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(repositoryProvider).resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() => _resetSent = true);
      _snack(
        '$email adresine şifre sıfırlama bağlantısı gönderildi.',
        duration: 6,
      );
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
                  _createAccount ? 'Hesap Oluştur' : 'Giriş Yap',
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
                      ? 'E-posta ve şifrenle hesap oluştur.'
                      : 'Hoş geldin. E-posta ve şifrenle devam et.',
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
                          labelText: 'E-posta',
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
                          labelText: 'Şifre',
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
                            labelText: 'Şifre Tekrarı',
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
                                  ? 'Mail gönderildi ✓'
                                  : 'Şifremi unuttum',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 14),
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
                                ? 'İşleniyor...'
                                : (_createAccount
                                      ? 'Hesap Oluştur'
                                      : 'Giriş Yap'),
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
                                ? 'Zaten hesabın var mı? Giriş yap'
                                : 'Hesabın yok mu? Kayıt ol',
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
                    child: const Text('Misafir devam et (sınırlı)'),
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
