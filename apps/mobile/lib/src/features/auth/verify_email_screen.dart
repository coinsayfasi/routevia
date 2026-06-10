import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n.dart';
import '../../data/providers.dart';

/// Shown after signup when email confirmation is enabled. The user enters the
/// 6-digit code emailed to them (Supabase `{{ .Token }}`), which we verify with
/// `verifyOTP(type: signup)`. On success the session is created and we continue
/// to onboarding (or home if already completed).
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _codeLength = 6;
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length < _codeLength || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final repo = ref.read(repositoryProvider);
      await repo.verifyEmailOtp(email: widget.email, code: code);
      // Mirror the auth screen's post-login routing.
      try {
        await repo.ensureProfile();
        final profile = await repo.getMyProfile();
        final completed = (profile?['onboarding_completed'] as bool?) ?? false;
        if (mounted) context.go(completed ? '/home' : '/onboarding');
      } catch (_) {
        if (mounted) context.go('/home');
      }
    } catch (_) {
      if (mounted) {
        _snack(context.tr(
            'Kod geçersiz veya süresi dolmuş.', 'Invalid or expired code.'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    try {
      await ref.read(repositoryProvider).resendSignupConfirmation(widget.email);
      _startCooldown();
      if (mounted) {
        _snack(context.tr('Yeni kod gönderildi.', 'A new code was sent.'));
      }
    } catch (_) {
      if (mounted) {
        _snack(context.tr(
            'Kod gönderilemedi, tekrar dene.', 'Could not send code, try again.'));
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0x55D7E5FF), width: 1),
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 40, color: Color(0xFF7DD3FC)),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('E-postanı doğrula', 'Verify your email'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr(
                    '${widget.email} adresine gönderdiğimiz doğrulama kodunu gir',
                    'Enter the verification code we sent to ${widget.email}',
                  ),
                  style: const TextStyle(color: Color(0xFFB6C6DE), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: _codeLength,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: const TextStyle(color: Color(0x559FB6D6)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0x33D6E4F5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF00C2A8)),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.length == _codeLength) _verify();
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2A8),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _loading ? null : _verify,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            context.tr('Doğrula', 'Verify'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF06251F),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _cooldown > 0 ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? context.tr('Tekrar gönder ($_cooldown sn)',
                            'Resend in ${_cooldown}s')
                        : context.tr('Kodu tekrar gönder', 'Resend code'),
                    style: TextStyle(
                      color: _cooldown > 0
                          ? const Color(0x669FB6D6)
                          : const Color(0xFF7DD3FC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/auth'),
                  child: Text(
                    context.tr('Girişe dön', 'Back to login'),
                    style: const TextStyle(color: Color(0xFFB6C6DE)),
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
