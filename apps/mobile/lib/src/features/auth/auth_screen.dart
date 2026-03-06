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
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _otpSent = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) async {
      if (event.session != null && mounted) {
        final repo = ref.read(repositoryProvider);
        await repo.ensureProfile();
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
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gecerli bir e-posta gir.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(repositoryProvider).signInWithOtp(email);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('Giris baglantisi / kod e-postasi gonderildi.'),
          ),
        );
        setState(() => _otpSent = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gecerli bir e-posta gir.')));
      return;
    }
    if (code.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('6 haneli kodu gir.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(repositoryProvider)
          .verifyEmailOtp(email: email, code: code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kod dogrulanamadi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                const Text(
                  'Giris Yap',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'E-postana gelen 6 haneli kodu girerek devam et.'
                      : 'E-posta adresinle kod al, hizli ve guvenli sekilde giris yap.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          _StepBadge(index: 1, active: true, done: _otpSent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'E-posta adresini gir',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _sendOtp,
                          icon: const Icon(Icons.mark_email_read_outlined),
                          label: Text(
                            _loading ? 'Gonderiliyor...' : 'Kodu Gonder',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const _StepBadge(
                              index: 2,
                              active: true,
                              done: false,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '6 haneli kodu dogrula',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Kod',
                            prefixIcon: const Icon(Icons.pin_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _verifyOtp,
                            icon: const Icon(Icons.verified_user_outlined),
                            label: Text(
                              _loading ? 'Dogrulaniyor...' : 'Kodu Dogrula',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0B3B68),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _loading ? null : _sendOtp,
                          child: const Text('Kodu tekrar gonder'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                    child: const Text('Misafir devam et (sinirli)'),
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

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.index,
    required this.active,
    required this.done,
  });

  final int index;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF15803D)
            : (active ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '$index',
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
