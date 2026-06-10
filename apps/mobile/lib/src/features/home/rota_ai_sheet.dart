import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/premium_gate.dart';
import '../../core/theme.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

// ── Sheet ────────────────────────────────────────────────────────────────────

class RotaAiSheet extends ConsumerStatefulWidget {
  const RotaAiSheet({
    super.key,
    required this.provinceSlug,
    required this.provinceName,
  });

  final String provinceSlug;
  final String provinceName;

  static Future<void> show(
    BuildContext context, {
    required String provinceSlug,
    required String provinceName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RotaAiSheet(
        provinceSlug: provinceSlug,
        provinceName: provinceName,
      ),
    );
  }

  @override
  ConsumerState<RotaAiSheet> createState() => _RotaAiSheetState();
}

class _RotaAiSheetState extends ConsumerState<RotaAiSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  int _remaining = 3; // optimistic, güncellenecek
  bool _isPro = false;

  static const _accent = Color(0xFF0B3B68);
  static const _aiColor = Color(0xFFF0F7FF);

  @override
  void initState() {
    super.initState();
    _isPro = isPro(ref);
    if (_isPro) _remaining = 999;
    // Karşılama mesajı
    _messages.add(_ChatMessage(
      text:
          '${widget.provinceName} hakkında ne merak ediyorsun? '
          'Gezilecek yerler, yeme-içme, konaklama, aktivite — her şeyi sorabilirsin! 🗺️',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/auth');
      return;
    }

    if (!_isPro && _remaining <= 0) {
      if (mounted) showPremiumGate(context, feature: 'Rota AI Sınırsız');
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Gemini için sohbet geçmişi (son 6 mesaj)
    final history = _messages
        .where((m) => m.text != _messages.first.text) // karşılama mesajını çıkar
        .take(_messages.length - 1) // yeni user mesajı hariç
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
        .toList();

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'travel_chat',
        body: {
          'message': text,
          'province_slug': widget.provinceSlug,
          'province_name': widget.provinceName,
          'history': history,
        },
      );

      final data = res.data as Map<String, dynamic>? ?? {};
      _handleResponse(data);
    } on FunctionException catch (e) {
      // Non-2xx response — parse error body
      Map<String, dynamic> errorData = {};
      try {
        final details = e.details;
        if (details is Map<String, dynamic>) {
          errorData = details;
        }
      } catch (_) {}

      if (errorData['error'] == 'daily_limit_reached') {
        if (mounted) {
          setState(() {
            _remaining = 0;
            _loading = false;
          });
          showPremiumGate(context, feature: 'Rota AI Sınırsız');
        }
        return;
      }

      final serverMsg = (errorData['message'] ?? errorData['error']) as String?;
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: serverMsg ?? 'Bir sorun oluştu, tekrar dene.',
            isUser: false,
          ));
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Bağlantı hatası, tekrar dene.',
            isUser: false,
          ));
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _handleResponse(Map<String, dynamic> data) {
    if (data['error'] == 'daily_limit_reached') {
      if (mounted) {
        setState(() {
          _remaining = 0;
          _loading = false;
        });
        showPremiumGate(context, feature: 'Rota AI Sınırsız');
      }
      return;
    }

    final reply = data['reply'] as String? ?? 'Bir sorun oluştu, tekrar dene.';
    final remaining = data['remaining'] as int? ?? _remaining;
    final isPro = data['is_pro'] as bool? ?? false;

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _remaining = remaining;
        _isPro = isPro;
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ─────────────────────────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RouteviaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B3B68), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rota AI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.provinceName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Kalan hak (sadece free kullanıcı)
                  if (!_isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _remaining > 0
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _remaining > 0
                            ? '$_remaining soru hakkı'
                            : 'Hak doldu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _remaining > 0
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  if (_isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 12,
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Pro',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // ── Mesajlar ───────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (_loading && i == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  final msg = _messages[i];
                  return _buildBubble(msg);
                },
              ),
            ),

            // ── Free limit uyarısı ─────────────────────────────────────────
            if (!_isPro && _remaining <= 1 && _remaining > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: GestureDetector(
                  onTap: () => showPremiumGate(
                    context,
                    feature: 'Rota AI Sınırsız',
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$_remaining soru hakkın kaldı. Sınırsız için Pro\'ya geç →',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Input ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, bottom + 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText:
                            '${widget.provinceName} hakkında sor...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _accent.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _loading ? null : _send,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _loading
                            ? const Color(0xFFCBD5E1)
                            : _accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B3B68), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? _accent : _aiColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: msg.isUser ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B3B68), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _aiColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 200),
                const SizedBox(width: 4),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animasyonlu yazıyor noktaları ────────────────────────────────────────────

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: const Color(0xFF64748B),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

