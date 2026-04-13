import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const InAppWebViewScreen({super.key, required this.url, required this.title});

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  String _convertIntentToScheme(String raw) {
    try {
      final schemeMatch = RegExp(r'scheme=([a-zA-Z0-9+.-]+);').firstMatch(raw);
      final scheme = schemeMatch != null ? schemeMatch.group(1) : 'upi';
      final converted =
          raw.replaceFirst('intent://', '$scheme://').split('#Intent')[0];
      return converted;
    } catch (e) {
      log('intent conversion error: $e');
      return raw;
    }
  }

  Future<bool> _openExternalUrl(String rawUrl) async {
    final uriString = rawUrl.trim();
    if (uriString.isEmpty) return false;

    String toOpen = uriString;
    final lower = uriString.toLowerCase();
    if (lower.startsWith('intent://')) {
      toOpen = _convertIntentToScheme(uriString);
    }

    final uri = Uri.tryParse(toOpen);
    if (uri == null) return false;

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      return launched;
    } catch (e, st) {
      log('openExternalUrl exception: $e\n$st');
      return false;
    }
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      NavigationAction action) async {
    final url = action.request.url.toString();
    if (url.isEmpty) return NavigationActionPolicy.ALLOW;

    final lower = url.toLowerCase();
    final isCustom = lower.startsWith('upi://') ||
        lower.startsWith('intent://') ||
        lower.startsWith('gpay://') ||
        lower.startsWith('phonepe://') ||
        lower.startsWith('paytmmp://') ||
        lower.startsWith('tez://') ||
        lower.startsWith('paytm://');

    if (!isCustom) return NavigationActionPolicy.ALLOW;

    final opened = await _openExternalUrl(url);

    if (!opened && mounted) {
      // keep UI minimal: use a snackbar instead of dialog (less intrusive)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment app not found.')),
      );
    }

    return NavigationActionPolicy.CANCEL;
  }

  Future<bool> _onWillPop() async {
    final controller = _webViewController;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // No AppBar — full-screen WebView like a mobile app
        body: SafeArea(
          // Remove SafeArea if you want truly edge-to-edge (status bar overlays)
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useOnDownloadStart: true,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, uri) {
              // no progress UI
            },
            onLoadStop: (controller, uri) {
              // no progress UI
            },
            onProgressChanged: (controller, p) {
              // no progress UI
            },
            shouldOverrideUrlLoading: (controller, action) async {
              return await _shouldOverrideUrlLoading(action);
            },
            onConsoleMessage: (controller, consoleMsg) {
              log('Console: ${consoleMsg.message}');
            },
            onLoadError: (controller, uri, code, message) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading page: $message')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
