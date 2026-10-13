import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SupportWebView extends StatefulWidget {
  final String url;
  final String title;

  const SupportWebView({super.key, required this.url, required this.title});

  @override
  SupportWebViewState createState() => SupportWebViewState();
}

class SupportWebViewState extends State<SupportWebView> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // optional: enable android web contents debugging
    if (Platform.isAndroid) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // show linear progress while loading
            if (_progress < 1.0)
              LinearProgressIndicator(value: _progress, minHeight: 3),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useShouldOverrideUrlLoading: true,
                ),
                onWebViewCreated: (_) {},
                onLoadStart: (controller, uri) {
                  setState(() => _progress = 0.05);
                },
                onLoadStop: (controller, uri) async {
                  setState(() => _progress = 1.0);
                },
                onProgressChanged: (controller, progress) {
                  setState(() => _progress = progress / 100.0);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  // default behavior: allow navigation
                  // If you want to intercept and open certain schemes externally,
                  // implement logic here and return NavigationActionPolicy.CANCEL
                  final url = navigationAction.request.url?.toString() ?? '';
                  if (url.isEmpty) return NavigationActionPolicy.ALLOW;

                  // Example: you can intercept UPI / intent links here
                  // final lower = url.toLowerCase();
                  // if (lower.startsWith('upi://') || lower.startsWith('intent://')) {
                  //   // handle external launch logic...
                  //   return NavigationActionPolicy.CANCEL;
                  // }

                  return NavigationActionPolicy.ALLOW;
                },
                onConsoleMessage: (controller, consoleMsg) {
                  // helpful for debugging JS console logs
                  log('Console: ${consoleMsg.message}');
                },
                onReceivedError: (controller, uri, code) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading page: ${code.description}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
