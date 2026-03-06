import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  bool get _isValidUrl {
    final u = url;
    if (u == null || u.isEmpty) return false;
    return u.startsWith('http://') || u.startsWith('https://');
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _isValidUrl
        ? CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _fallback(),
          )
        : _fallback();

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}
