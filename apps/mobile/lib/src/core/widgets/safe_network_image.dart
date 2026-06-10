import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_cache_manager.dart';
import '../storage_image.dart';
export '../storage_image.dart' show ImageSize;

class SafeNetworkImage extends StatefulWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.imageSize = ImageSize.card,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  /// Controls Supabase image transform preset.
  /// - [ImageSize.thumbnail] for small list items / avatars
  /// - [ImageSize.card] (default) for cards and grids
  /// - [ImageSize.detail] for place detail hero images
  /// - [ImageSize.fullscreen] for full-screen viewers
  final ImageSize imageSize;

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  // When the transformed (render/image) URL fails, fall back to the raw URL.
  bool _useRawUrl = false;

  bool get _isValidUrl {
    final u = widget.url;
    if (u == null || u.isEmpty) return false;
    return u.startsWith('http://') || u.startsWith('https://');
  }

  String? get _activeUrl {
    if (!_isValidUrl) return null;
    if (_useRawUrl) return widget.url;
    return optimizeStorageUrl(widget.url, size: widget.imageSize);
  }

  Widget _fallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, size: 26),
    );
  }

  void _onTransformError() {
    // Transformed URL failed — try the raw URL once.
    if (!_useRawUrl && mounted) {
      setState(() => _useRawUrl = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _activeUrl;

    final child = url != null
        ? CachedNetworkImage(
            key: ValueKey('$url$_useRawUrl'),
            imageUrl: url,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            cacheManager: AppCacheManager.instance,
            placeholder: (context, url) => Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              if (!_useRawUrl) {
                // Transformed URL failed — retry with raw URL
                WidgetsBinding.instance.addPostFrameCallback((_) => _onTransformError());
              }
              return _fallback();
            },
          )
        : _fallback();

    if (widget.borderRadius == null) return child;
    return ClipRRect(borderRadius: widget.borderRadius!, child: child);
  }
}
