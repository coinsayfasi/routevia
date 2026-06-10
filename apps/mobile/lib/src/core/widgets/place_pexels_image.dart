import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/providers.dart';
import '../app_cache_manager.dart';

/// Lazily loads a place image (Wikidata → Wikipedia → Pexels).
/// - Caches resolved URL in Hive for instant subsequent loads.
/// - Cancels in-flight requests on rapid widget updates (iOS memory safe).
/// - Calls [onLoaded] with the photographer/credit string when available.
class PlacePexelsImage extends ConsumerStatefulWidget {
  const PlacePexelsImage({
    super.key,
    required this.placeName,
    required this.provinceName,
    required this.category,
    required this.fallbackWidget,
    this.fit = BoxFit.cover,
    this.onLoaded,
  });

  final String placeName;
  final String provinceName;
  final String category;
  final Widget fallbackWidget;
  final BoxFit fit;
  final void Function(String url, String? credit)? onLoaded;

  @override
  ConsumerState<PlacePexelsImage> createState() => _PlacePexelsImageState();
}

class _PlacePexelsImageState extends ConsumerState<PlacePexelsImage> {
  String? _imageUrl;
  bool _loading = true;
  // Incremented on each new load — lets in-flight futures detect staleness.
  int _loadGeneration = 0;

  static const _imgBox = 'place_img_cache';

  String get _cacheKey {
    final slug = widget.placeName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return slug.isEmpty ? 'unknown' : slug.substring(0, slug.length.clamp(0, 80));
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(PlacePexelsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeName != widget.placeName ||
        oldWidget.provinceName != widget.provinceName) {
      _loadGeneration++; // invalidate previous in-flight request
      setState(() {
        _imageUrl = null;
        _loading = true;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final generation = _loadGeneration;

    // 1. Hive local cache — instant if seen before
    try {
      final box = await Hive.openBox<String>(_imgBox);
      if (!mounted || generation != _loadGeneration) return;
      final cached = box.get(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _imageUrl = cached;
          _loading = false;
        });
        widget.onLoaded?.call(cached, null);
        return;
      }
    } catch (_) {}

    // 2. Edge function (Wikidata → Wikipedia → Pexels)
    try {
      final result = await ref.read(repositoryProvider).getPlaceImage(
            placeName: widget.placeName,
            provinceName: widget.provinceName,
            category: widget.category,
          );
      if (!mounted || generation != _loadGeneration) return;

      final url = result?['image_url'] as String?;
      final credit = result?['photographer'] as String?;

      if (url != null && url.isNotEmpty) {
        try {
          final box = await Hive.openBox<String>(_imgBox);
          await box.put(_cacheKey, url);
        } catch (_) {}
        widget.onLoaded?.call(url, credit);
      }

      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _imageUrl = url;
        _loading = false;
      });
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return widget.fallbackWidget;
    if (_imageUrl == null || _imageUrl!.isEmpty) return widget.fallbackWidget;
    return CachedNetworkImage(
      imageUrl: _imageUrl!,
      fit: widget.fit,
      cacheManager: AppCacheManager.instance,
      placeholder: (_, _) => widget.fallbackWidget,
      errorWidget: (_, _, _) => widget.fallbackWidget,
    );
  }
}
