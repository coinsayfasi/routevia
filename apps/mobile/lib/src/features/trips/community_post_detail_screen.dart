import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/community_post_models.dart';

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  const CommunityPostDetailScreen({
    super.key,
    required this.postId,
    this.initialPost,
  });

  final String postId;
  final CommunityPostModel? initialPost;

  @override
  ConsumerState<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState
    extends ConsumerState<CommunityPostDetailScreen> {
  bool _loading = true;
  String? _error;
  CommunityPostModel? _post;
  bool _authorBlocked = false;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await ref
          .read(repositoryProvider)
          .getCommunityPostById(widget.postId);
      final blocked = post == null
          ? false
          : await ref.read(repositoryProvider).isUserBlocked(post.userId);
      if (!mounted) return;
      setState(() {
        _post = post ?? _post;
        _authorBlocked = blocked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _reportPost() async {
    final post = _post;
    if (post == null) return;
    final reasonCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('İçeriği bildir', 'Report content')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: context.tr('Sebep', 'Reason'),
                hintText: context.tr(
                  'Örnek: spam, telif, uygunsuz içerik',
                  'Example: spam, copyright, abusive content',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: detailsCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.tr('Açıklama', 'Details'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('Bildir', 'Report')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(repositoryProvider)
        .reportCommunityPost(
          postId: post.id,
          reason: reasonCtrl.text.trim().isEmpty
              ? 'inappropriate content'
              : reasonCtrl.text.trim(),
          details: detailsCtrl.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'İçerik inceleme için bildirildi.',
            'Content was reported for review.',
          ),
        ),
      ),
    );
  }

  Future<void> _sharePost() async {
    final post = _post;
    if (post == null) return;
    final deepLink = 'https://routevia.app/community-post/${post.id}';
    final storeUrl = Platform.isIOS
        ? AppConstants.appStoreUrl
        : AppConstants.playStoreUrl;
    final text = '${post.title}\n$deepLink\n\nRoutevia ile keşfet: $storeUrl';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _toggleAuthorBlock() async {
    final post = _post;
    if (post == null) return;
    final next = await ref
        .read(repositoryProvider)
        .toggleUserBlock(post.userId);
    if (!mounted) return;
    setState(() => _authorBlocked = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next
              ? context.tr(
                  'Yazar gizlendi. Bu yazara ait içerikler akışında görünmez.',
                  'Author blocked. Their posts will be hidden from your feed.',
                )
              : context.tr('Yazar engeli kaldırıldı.', 'Author block removed.'),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF166534);
      case 'pending':
        return const Color(0xFFB45309);
      case 'rejected':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFF475569);
    }
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'approved':
        return context.tr('Yayında', 'Live');
      case 'pending':
        return context.tr('İncelemede', 'In review');
      case 'rejected':
        return context.tr('Revize gerekli', 'Needs revision');
      default:
        return context.tr('Taslak', 'Draft');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final canEdit =
        post != null && (post.isDraft || post.isRejected || post.isPending);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Topluluk Yazısı', 'Community Post')),
        actions: [
          if (post != null && post.isApproved)
            IconButton(
              onPressed: _sharePost,
              icon: const Icon(Icons.share_outlined),
              tooltip: context.tr('Paylaş', 'Share'),
            ),
          if (canEdit)
            IconButton(
              onPressed: () async {
                final changed = await context.push(
                  '/community-post-editor',
                  extra: post,
                );
                if (changed == true) _load();
              },
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.tr('Düzenle', 'Edit'),
            ),
          if (post != null && !canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _reportPost();
                } else if (value == 'block') {
                  _toggleAuthorBlock();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'report',
                  child: Text(context.tr('İçeriği bildir', 'Report content')),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Text(
                    _authorBlocked
                        ? context.tr('Yazarı tekrar göster', 'Unblock author')
                        : context.tr('Yazarı gizle', 'Block author'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFB42318)),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _load,
                      child: Text(context.tr('Tekrar Dene', 'Retry')),
                    ),
                  ],
                ),
              ),
            )
          : post == null
          ? Center(
              child: Text(context.tr('İçerik bulunamadı.', 'Post not found.')),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                children: [
                  if ((post.coverImageUrl ?? '').isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SafeNetworkImage(
                        url: post.coverImageUrl,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.auto_stories_outlined,
                        label: post.postType == 'guide'
                            ? context.tr('Mini Rehber', 'Guide')
                            : context.tr('Gezi Hikâyesi', 'Story'),
                      ),
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        label: context.tr(
                          '${post.estimatedReadMinutes} dk okuma',
                          '${post.estimatedReadMinutes} min read',
                        ),
                      ),
                      _MetaChip(
                        icon: Icons.location_on_outlined,
                        label: '${post.city}, ${post.country}',
                      ),
                      _MetaChip(
                        icon: Icons.verified_outlined,
                        label: _statusLabel(context, post.status),
                        foreground: _statusColor(post.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475569),
                      height: 1.55,
                    ),
                  ),
                  if ((post.submitterName ?? '').isNotEmpty ||
                      (post.relatedRouteTitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((post.submitterName ?? '').isNotEmpty)
                            Text(
                              context.tr(
                                'Yazan: ${post.submitterName}',
                                'By ${post.submitterName}',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if ((post.relatedRouteTitle ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              context.tr(
                                'Bağlı rota: ${post.relatedRouteTitle}',
                                'Related route: ${post.relatedRouteTitle}',
                              ),
                              style: const TextStyle(color: Color(0xFF475569)),
                            ),
                          ],
                          if ((post.adminNote ?? '').isNotEmpty &&
                              !post.isApproved) ...[
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                'Editör notu: ${post.adminNote}',
                                'Editor note: ${post.adminNote}',
                              ),
                              style: const TextStyle(color: Color(0xFFB45309)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    post.contentBody,
                    style: const TextStyle(fontSize: 16, height: 1.7),
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Color(0xFF075985),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (post.gallery.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      context.tr('Fotoğraf Galerisi', 'Photo Gallery'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.gallery.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final image = post.gallery[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SafeNetworkImage(
                              url: image.imageUrl,
                              width: 220,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.foreground = const Color(0xFF0F172A),
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
