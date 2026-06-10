import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/community_post_models.dart';
import '../../models/trip_models.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _communityScrollController = ScrollController();
  RealtimeChannel? _realtimeChannel;

  bool _loadingMine = true;
  bool _loadingCommunity = true;
  bool _loadingMoreCommunity = false;
  bool _isOfflineFallback = false;
  String? _mineError;
  String? _communityError;
  List<Map<String, dynamic>> _trips = const [];
  List<CommunityPostModel> _myPosts = const [];
  List<CommunityPostModel> _communityPosts = const [];
  bool _hasMoreCommunity = true;
  int _communityOffset = 0;
  String? _deletingTripId;
  String? _deletingPostId;

  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _communityScrollController.addListener(_onCommunityScroll);
    _loadMine();
    _loadCommunity(reset: true);
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _realtimeChannel = Supabase.instance.client
        .channel('community_posts_feed')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'community_posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'approved',
          ),
          callback: (_) {
            if (mounted) _loadCommunity(reset: true);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _tabController.dispose();
    _communityScrollController
      ..removeListener(_onCommunityScroll)
      ..dispose();
    super.dispose();
  }

  void _onCommunityScroll() {
    if (_communityScrollController.position.pixels <
        _communityScrollController.position.maxScrollExtent - 320) {
      return;
    }
    if (_loadingMoreCommunity || !_hasMoreCommunity) return;
    _loadCommunity();
  }

  Future<void> _loadMine() async {
    setState(() {
      _loadingMine = true;
      _mineError = null;
      _isOfflineFallback = false;
    });
    try {
      final repo = ref.read(repositoryProvider);
      final trips = await repo.listMyTrips();
      // Community posts are isolated: a failure here must NOT block My Routes.
      List<CommunityPostModel> posts = const [];
      try {
        posts = await repo.listMyCommunityPosts();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _myPosts = posts;
        _loadingMine = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Try local cache fallback
      try {
        final cached = await ref.read(localCacheProvider).readTripHistory();
        if (!mounted) return;
        if (cached.isNotEmpty) {
          setState(() {
            _trips = cached;
            _isOfflineFallback = true;
            _loadingMine = false;
          });
          return;
        }
      } catch (_) {}
      setState(() {
        _mineError = friendlyError(e);
        _loadingMine = false;
      });
    }
  }

  Future<void> _loadCommunity({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loadingCommunity = true;
        _communityError = null;
        _communityOffset = 0;
        _hasMoreCommunity = true;
      });
    } else {
      setState(() => _loadingMoreCommunity = true);
    }
    try {
      final items = await ref
          .read(repositoryProvider)
          .listCommunityFeed(
            limit: _pageSize,
            offset: reset ? 0 : _communityOffset,
          );
      if (!mounted) return;
      if (reset && items.isNotEmpty) {
        // Cache the first page for offline fallback
        final rawMaps = items
            .map((p) => {
                  'id': p.id,
                  'title': p.title,
                  'summary': p.summary,
                  'city': p.city,
                  'country': p.country,
                  'post_type': p.postType,
                  'status': p.status,
                  'estimated_read_minutes': p.estimatedReadMinutes,
                  'submitter_name': p.submitterName,
                  'cover_image_url': p.coverImageUrl,
                  'tags': p.tags,
                  'published_at': p.publishedAt?.toIso8601String(),
                  'created_at': p.createdAt?.toIso8601String(),
                })
            .toList();
        unawaited(ref.read(localCacheProvider).saveCommunityFeed(rawMaps));
      }
      setState(() {
        if (reset) {
          _communityPosts = items;
        } else {
          _communityPosts = [..._communityPosts, ...items];
        }
        _communityOffset = _communityPosts.length;
        _hasMoreCommunity = items.length == _pageSize;
        _loadingCommunity = false;
        _loadingMoreCommunity = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Offline fallback: show cached posts if available
      if (reset) {
        try {
          final cached = await ref.read(localCacheProvider).readCommunityFeed();
          if (!mounted) return;
          if (cached != null && cached.isNotEmpty) {
            final posts = cached
                .map((m) => CommunityPostModel.fromMap(m))
                .toList();
            setState(() {
              _communityPosts = posts;
              _communityOffset = posts.length;
              _hasMoreCommunity = false;
              _loadingCommunity = false;
            });
            return;
          }
        } catch (_) {}
      }
      setState(() {
        _communityError = friendlyError(e);
        _loadingCommunity = false;
        _loadingMoreCommunity = false;
      });
    }
  }

  Future<void> _shareTrip(String tripId) async {
    try {
      final token = await ref.read(repositoryProvider).createShareToken(tripId);
      if (!mounted) return;
      final shareUrl = '${AppConstants.supabaseUrl}/functions/v1/og_share?token=$token';
      await SharePlus.instance.share(
        ShareParams(
          text: 'Routevia\'da hazırladığım rotaya göz at! 🗺️\n$shareUrl',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(text: Platform.isIOS ? AppConstants.appStoreUrl : AppConstants.playStoreUrl),
      );
    }
  }

  Future<void> _openTrip(Map<String, dynamic> trip) async {
    final localPlan = trip['plan'];
    if (localPlan is Map) {
      if (!mounted) return;
      context.push(
        '/map',
        extra: TripPlan.fromMap(Map<String, dynamic>.from(localPlan)),
      );
      return;
    }

    final repo = ref.read(repositoryProvider);
    final remotePlan = await repo.getMyTripPlan(trip['id'] as String);
    if (!mounted) return;
    if (remotePlan != null) {
      context.push('/map', extra: remotePlan);
      return;
    }

    final cached = await repo.readCachedTrip();
    if (!mounted) return;
    if (cached != null && cached.tripId == trip['id']) {
      context.push('/map', extra: cached);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'Bu rota detayı cihazda yok. Yalnızca paylaşım bağlantısı kullanılabilir.',
            'Trip detail is not on this device. Only sharing is available.',
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTrip(Map<String, dynamic> trip) async {
    final isLocal = (trip['source'] as String?) == 'local';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr(
            isLocal ? 'Şablonu sil' : 'Rotayı sil',
            isLocal ? 'Delete template' : 'Delete trip',
          ),
        ),
        content: Text(
          context.tr(
            isLocal
                ? 'Bu şablon Gezilerim listesinden kaldırılacak. Bu işlem geri alınamaz.'
                : 'Bu rota hesabından silinecek. Bu işlem geri alınamaz.',
            isLocal
                ? 'This template will be removed from My Trips. This cannot be undone.'
                : 'This trip will be removed from your account. This cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('Son kez sil', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final tripId = trip['id']?.toString();
    if (tripId == null || tripId.isEmpty) return;
    setState(() => _deletingTripId = tripId);
    try {
      await ref
          .read(repositoryProvider)
          .deleteTrip(tripId: tripId, isLocal: isLocal);
      if (!mounted) return;
      setState(() {
        _trips = _trips.where((item) => item['id'] != tripId).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _deletingTripId = null);
    }
  }

  Future<void> _openPostEditor([CommunityPostModel? post]) async {
    final changed = await context.push('/community-post-editor', extra: post);
    if (changed == true) {
      await _loadMine();
      await _loadCommunity(reset: true);
    }
  }

  Future<void> _openPostDetail(CommunityPostModel post) async {
    final changed = await context.push('/community-post', extra: post);
    if (changed == true) {
      await _loadMine();
      await _loadCommunity(reset: true);
    }
  }

  Future<void> _deletePost(CommunityPostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Yazıyı sil', 'Delete post')),
        content: Text(
          context.tr(
            'Bu topluluk yazısı ve bağlı galeri görselleri silinecek. Bu işlem geri alınamaz.',
            'This community post and its gallery images will be deleted. This cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('Sil', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deletingPostId = post.id);
    try {
      await ref.read(repositoryProvider).deleteCommunityPost(post.id);
      if (!mounted) return;
      setState(() {
        _myPosts = _myPosts.where((item) => item.id != post.id).toList();
        _communityPosts = _communityPosts
            .where((item) => item.id != post.id)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _deletingPostId = null);
    }
  }

  String _tripTitle(Map<String, dynamic> t) {
    if (t['title'] is String && (t['title'] as String).isNotEmpty) {
      return t['title'] as String;
    }
    final province = (t['province'] as Map?) ?? const {};
    final provinceName = province['name'] as String? ?? context.tr('Rota', 'Route');
    final days = t['days'];
    final dayWord = context.isEnglish ? (days == 1 ? 'day' : 'days') : 'gün';
    return '$provinceName • $days $dayWord';
  }

  String _formatTripDate(String? raw) {
    final dt = DateTime.tryParse(raw ?? '');
    if (dt == null) {
      return context.tr('Bu cihazda saklandı', 'Stored on device');
    }
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '—';
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
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
        return context.tr('Revize', 'Needs revision');
      default:
        return context.tr('Taslak', 'Draft');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Gezilerim', 'My Trips')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.tr('Benim Gezilerim', 'My Trips')),
            Tab(text: context.tr('Topluluk', 'Community')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMineTab(context), _buildCommunityTab(context)],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _openPostEditor,
              icon: const Icon(Icons.edit_note_outlined),
              label: Text(context.tr('Yazı Oluştur', 'Create Post')),
            )
          : null,
    );
  }

  Widget _buildMineTab(BuildContext context) {
    if (_loadingMine) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_mineError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFB42318),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(_mineError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadMine,
                child: Text(context.tr('Tekrar Dene', 'Retry')),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMine,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'Gezilerini yazıya dönüştür',
                    'Turn your trips into stories',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Kaydettiğin rotaları, kendi gezi notlarını ve moderasyon bekleyen topluluk yazılarını buradan yönet.',
                    'Manage your saved routes, travel notes, and moderated community posts from here.',
                  ),
                  style: const TextStyle(color: Color(0xFFE2E8F0), height: 1.5),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _openPostEditor,
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: Text(context.tr('Yeni Yazı Başlat', 'Start New Post')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: context.tr('Rotalarım', 'My Routes'),
            subtitle: context.tr(
              'Kaydettiğin planlar ve şablonlar',
              'Saved plans and templates',
            ),
          ),
          const SizedBox(height: 10),
          if (_isOfflineFallback)
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFD600).withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 16,
                    color: Color(0xFF856404),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Çevrimdışı — önbellekten gösteriliyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _isOfflineFallback = false);
                      _loadMine();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Yenile',
                      style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              ),
            ),
          if (_trips.isEmpty)
            _EmptyPanel(
              icon: Icons.map_outlined,
              title: context.tr(
                'Henüz rota kaydın yok, ama topluluk alanı aktif.',
                'You have no saved trip yet, but community is active.',
              ),
              subtitle: context.tr(
                'Bir rota planladığında burada görünür. Aşağıdaki Benim Yazılarım bölümünden rota olmadan da topluluk yazısı oluşturabilirsin.',
                'Planned trips appear here. You can still create a community post from the My Posts section below without any route.',
              ),
            )
          else
            ..._trips.map(
              (trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TripCard(
                  trip: trip,
                  title: _tripTitle(trip),
                  formattedDate: _formatTripDate(trip['created_at'] as String?),
                  deleting: _deletingTripId == trip['id'],
                  onOpen: () => _openTrip(trip),
                  onShare: () => _shareTrip(trip['id'] as String),
                  onDelete: () => _deleteTrip(trip),
                ),
              ),
            ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: context.tr('Benim Yazılarım', 'My Posts'),
            subtitle: context.tr(
              'Taslak, incelemede ve yayındaki topluluk içeriklerin',
              'Your drafts, pending posts, and published community content',
            ),
          ),
          const SizedBox(height: 10),
          if (_myPosts.isEmpty)
            _EmptyPanel(
              icon: Icons.edit_note_outlined,
              title: context.tr(
                'Henüz topluluk yazın yok.',
                'You have no community posts yet.',
              ),
              subtitle: context.tr(
                'İlk gezi hikâyeni ya da mini rehberini oluştur. Onaylanınca Topluluk sekmesinde görünür.',
                'Create your first travel story or mini guide. After approval it appears in Community.',
              ),
              actionLabel: context.tr('Yazı Oluştur', 'Create Post'),
              onAction: _openPostEditor,
            )
          else
            ..._myPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MyPostCard(
                  post: post,
                  statusLabel: _statusLabel(context, post.status),
                  statusColor: _statusColor(post.status),
                  formattedDate: _formatDate(post.updatedAt ?? post.createdAt),
                  deleting: _deletingPostId == post.id,
                  onOpen: () => _openPostDetail(post),
                  onEdit: post.isApproved ? null : () => _openPostEditor(post),
                  onDelete: () => _deletePost(post),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab(BuildContext context) {
    if (_loadingCommunity) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_communityError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFB42318),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(_communityError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _loadCommunity(reset: true),
                child: Text(context.tr('Tekrar Dene', 'Retry')),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadCommunity(reset: true),
      child: ListView.builder(
        controller: _communityScrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        itemCount: _communityPosts.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Topluluk', 'Community'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      'Routevia gezginlerinin moderasyondan geçmiş kısa rehberleri ve gezi hikâyeleri. Hafif, ilham verici ve rota odaklı bir akış.',
                      'Moderated mini guides and travel stories from Routevia travelers. Lightweight, inspiring, and route-focused.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }
          if (_communityPosts.isEmpty && index == 1) {
            return _EmptyPanel(
              icon: Icons.public_outlined,
              title: context.tr(
                'Henüz yayına alınmış içerik yok.',
                'No public community posts yet.',
              ),
              subtitle: context.tr(
                'İlk onaylı içerikler geldikçe burada hafif bir keşif akışı oluşacak.',
                'As approved posts arrive, a lightweight inspiration feed appears here.',
              ),
            );
          }
          if (index == _communityPosts.length + 1) {
            if (_loadingMoreCommunity) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!_hasMoreCommunity && _communityPosts.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    context.tr(
                      'Şimdilik bu kadar. Yeni içerikler geldikçe burada görünür.',
                      'That is all for now. New posts appear here as they are approved.',
                    ),
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          final post = _communityPosts[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CommunityFeedCard(
              post: post,
              onTap: () => _openPostDetail(post),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: const Color(0xFF0F766E)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.title,
    required this.formattedDate,
    required this.deleting,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final Map<String, dynamic> trip;
  final String title;
  final String formattedDate;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isLocal = (trip['source'] as String?) == 'local';
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isLocal
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isLocal ? context.tr('Şablon', 'Template') : context.tr('Hesapta', 'Saved'),
                    style: TextStyle(
                      color: isLocal
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF166534),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: deleting ? null : onShare,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(context.tr('Paylaş', 'Share')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: deleting ? null : onDelete,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB42318),
                    ),
                    icon: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline, size: 18),
                    label: Text(context.tr('Sil', 'Delete')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  const _MyPostCard({
    required this.post,
    required this.statusLabel,
    required this.statusColor,
    required this.formattedDate,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CommunityPostModel post;
  final String statusLabel;
  final Color statusColor;
  final String formattedDate;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title.isEmpty ? context.tr('İsimsiz taslak', 'Untitled draft') : post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${post.city}, ${post.country} • $formattedDate',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Text(
              post.summary.isEmpty ? post.contentBody : post.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF334155), height: 1.5),
            ),
            if ((post.adminNote ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.adminNote!,
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit ?? onOpen,
                    icon: Icon(
                      onEdit == null
                          ? Icons.visibility_outlined
                          : Icons.edit_outlined,
                      size: 18,
                    ),
                    label: Text(onEdit == null ? context.tr('Görüntüle', 'View') : context.tr('Düzenle', 'Edit')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: deleting ? null : onDelete,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB42318),
                    ),
                    icon: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline, size: 18),
                    label: Text(context.tr('Sil', 'Delete')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeedCard extends StatelessWidget {
  const _CommunityFeedCard({required this.post, required this.onTap});

  final CommunityPostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((post.coverImageUrl ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SafeNetworkImage(
                  url: post.coverImageUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeedPill(
                        label: post.postType == 'guide'
                            ? context.tr('Mini Rehber', 'Mini Guide')
                            : context.tr('Hikâye', 'Story'),
                      ),
                      _FeedPill(
                        label: '${post.city}, ${post.country}',
                        icon: Icons.location_on_outlined,
                      ),
                      _FeedPill(
                        label: '${post.estimatedReadMinutes} ${context.tr('dk', 'min')}',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.submitterName ?? context.tr('Routevia gezgini', 'Routevia traveler'),
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedPill extends StatelessWidget {
  const _FeedPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
