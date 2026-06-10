import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_cache_manager.dart';

// ── Preset sizes ──────────────────────────────────────────────────────────────
// Use these everywhere instead of raw URLs so transforms stay consistent.
enum ImageSize {
  thumbnail(width: 400, quality: 72),   // card list, avatar (2× for ~200dp slots)
  card(width: 900, quality: 82),        // home cards, map cards (2× for ~390-450dp slots)
  detail(width: 1400, quality: 88),     // place detail hero (covers 3× ~450dp)
  fullscreen(width: 1920, quality: 90); // full-screen viewer

  const ImageSize({required this.width, required this.quality});
  final int width;
  final int quality;
}

// ── URL transform helper ───────────────────────────────────────────────────────
/// Converts a Supabase Storage public/signed URL to a Supabase Image
/// Transformation URL.
///
/// Works for:
///  - Public object URLs  (/storage/v1/object/public/...)
///  - Signed object URLs  (/storage/v1/object/sign/...)
///
/// Leaves non-Supabase URLs (Pexels, external CDN, etc.) untouched.
String optimizeStorageUrl(
  String? url, {
  ImageSize size = ImageSize.card,
}) {
  if (url == null || url.isEmpty) return url ?? '';
  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  // Only touch Supabase Storage URLs
  if (!uri.path.contains('/storage/v1/object/')) return url;

  // /storage/v1/object/public/... → /storage/v1/render/image/public/...
  // /storage/v1/object/sign/...   → /storage/v1/render/image/sign/...
  final transformedPath =
      uri.path.replaceFirst('/storage/v1/object/', '/storage/v1/render/image/');

  final newParams = Map<String, String>.from(uri.queryParameters)
    ..['width'] = size.width.toString()
    ..['quality'] = size.quality.toString();

  return uri.replace(path: transformedPath, queryParameters: newParams).toString();
}

// ── StorageImage widget ────────────────────────────────────────────────────────
/// Drop-in replacement for [CachedNetworkImage] that automatically applies
/// Supabase image transforms and sensible cache settings.
class StorageImage extends StatelessWidget {
  const StorageImage({
    super.key,
    required this.url,
    this.size = ImageSize.card,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.placeholder,
    this.borderRadius,
  });

  final String? url;
  final ImageSize size;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final optimized = optimizeStorageUrl(url, size: size);

    Widget image;
    if (optimized.isEmpty) {
      image = errorWidget ?? _defaultError();
    } else {
      image = CachedNetworkImage(
        imageUrl: optimized,
        fit: fit,
        width: width,
        height: height,
        cacheManager: AppCacheManager.instance,
        maxWidthDiskCache: size.width * 2,
        placeholder: (ctx, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (ctx, url, err) => errorWidget ?? _defaultError(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _defaultPlaceholder() => Container(
        color: const Color(0xFFEEF2F6),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  Widget _defaultError() => Container(
        color: const Color(0xFFEEF2F6),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0BEC5)),
        ),
      );
}
