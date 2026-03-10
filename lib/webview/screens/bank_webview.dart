// import 'package:flutter/material.dart';
// import 'package:nivvesh/banks/screens/navigation_req_helper.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// class WebViewScreen extends StatefulWidget {
//   final String url;
//   final String title;

//   const WebViewScreen({super.key, required this.url, required this.title});

//   @override
//   WebViewScreenState createState() => WebViewScreenState();
// }

// class WebViewScreenState extends State<WebViewScreen> {
//   late WebViewController _controller;
//   double _progress = 0.0;

//   // final String darkModeJS = '''
//   //   (function() {
//   //     document.body.style.backgroundColor = "#121212";
//   //      document.body.style.color = "#ffffff";
//   //     const all = document.querySelectorAll("*");
//   //     for (let el of all) {
//   //       if (el.style) {
//   //         el.style.backgroundColor = "#121212";
//   //         el.style.color = "#ffffff";
//   //       }
//   //     }
//   //   })();
//   // ''';

//   @override
//   void initState() {
//     super.initState();

//     // Create platform-specific creation params
//     late final PlatformWebViewControllerCreationParams params;
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       // iOS: allow inline playback and remove user gesture requirement
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else {
//       params = const PlatformWebViewControllerCreationParams();
//     }

//     // Create controller from the params so platform options apply
//     _controller = WebViewController.fromPlatformCreationParams(params);
//     _controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           // onProgress: (progress) {
//           //   setState(() {
//           //     _progress = progress / 100;
//           //   });
//           // },
//           onPageStarted: (url) {
//             setState(() {
//               _progress = 0.1;
//             });
//           },
//           onPageFinished: (url) async {
//             setState(() {
//               _progress = 0.0;
//               // _controller.runJavaScript(darkModeJS);
//             });
//             // Inject JavaScript to Allow Geolocation
//           },
//           onNavigationRequest: (request) =>
//               handleNavigationRequest(context, request),
//           onWebResourceError: (error) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text("Error loading page: ${error.description}")),
//             );
//           },
//         ),
//       );

//     // Platform-specific tweaks
//     if (_controller.platform is AndroidWebViewController) {
//       // Enable Android webview debugging (optional)
//       AndroidWebViewController.enableDebugging(true);

//       // Cast to Android controller and allow autoplay without user gesture
//       final androidController =
//           _controller.platform as AndroidWebViewController;
//       androidController.setMediaPlaybackRequiresUserGesture(false);

//       // You can also tweak other Android-specific settings if needed:
//       // androidController.setWebContentsDebuggingEnabled(true);
//     } else if (_controller.platform is WebKitWebViewController) {
//       // For iOS (WKWebView) we already set allowsInlineMediaPlayback and removed
//       // mediaTypesRequiringUserAction via the creation params above.
//       // Additional iOS-specific calls can be made on the WebKit controller:
//       // final webkitController = _controller.platform as WebKitWebViewController;
//       // webkitController.setAllowsInlineMediaPlayback(true); // already set
//     }
//     _controller.loadRequest(Uri.parse(widget.url));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         // appBar: AppBar(
//         //   title: Text(widget.title,
//         //       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//         //   centerTitle: true,
//         //   leading: IconButton(
//         //     icon: const Icon(Icons.arrow_back),
//         //     onPressed: () {
//         //       Navigator.pop(context);
//         //     },
//         //   ),
//         //   elevation: 0,
//         // ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Linear Progress Indicator
//               // _progress > 0.0
//               //     ? LinearProgressIndicator(
//               //         value: _progress,
//               //         minHeight: 4,
//               //         backgroundColor: Colors.grey[300],
//               //         valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
//               //       )
//               //     : const SizedBox(height: 4), // To maintain UI consistency

//               // WebView
//               Expanded(
//                 child: WebViewWidget(
//                   controller: _controller,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
