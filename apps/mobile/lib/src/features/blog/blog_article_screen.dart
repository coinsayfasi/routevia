import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/i18n.dart';

class BlogArticleScreen extends StatefulWidget {
  const BlogArticleScreen({super.key, required this.url});

  final Uri url;

  @override
  State<BlogArticleScreen> createState() => _BlogArticleScreenState();
}

class _BlogArticleScreenState extends State<BlogArticleScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _isTrustedArticleUri(uri)) {
              return NavigationDecision.navigate;
            }
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  bool _isTrustedArticleUri(Uri uri) =>
      uri.scheme == 'https' && uri.host == 'gezi.tabserve.com.tr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Gezi Rehberi', 'Travel Guide')),
        actions: [
          IconButton(
            tooltip: context.tr('Paylaş', 'Share'),
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: widget.url.toString()),
            ),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: context.tr('Tarayıcıda aç', 'Open in browser'),
            onPressed: () =>
                launchUrl(widget.url, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_browser_outlined),
          ),
        ],
        bottom: _loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
