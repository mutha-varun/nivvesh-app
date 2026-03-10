// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// Future<NavigationDecision> handleNavigationRequest(
//     BuildContext context, NavigationRequest request) async {
//   final rawUrl = request.url.trim();
//   if (rawUrl.isEmpty) return NavigationDecision.navigate;

//   final lower = rawUrl.toLowerCase();

//   // External schemes we want to handle outside WebView
//   final isCustomScheme = lower.startsWith('upi://') ||
//       lower.startsWith('intent://') ||
//       lower.startsWith('gpay://') ||
//       lower.startsWith('phonepe://') ||
//       lower.startsWith('paytmmp://') ||
//       lower.startsWith('tez://') || // old Google Pay alias
//       lower.startsWith('paytm://');

//   if (!isCustomScheme) return NavigationDecision.navigate;

//   String urlToOpen = rawUrl;

//   try {
//     // Handle Android 'intent://' links by converting to scheme://
//     if (lower.startsWith('intent://')) {
//       final schemeMatch =
//           RegExp(r'scheme=([a-zA-Z0-9+.-]+);').firstMatch(rawUrl);
//       final scheme = schemeMatch != null ? schemeMatch.group(1) : 'upi';
//       urlToOpen =
//           rawUrl.replaceFirst('intent://', '$scheme://').split('#Intent')[0];
//     }

//     final uri = Uri.parse(urlToOpen);

//     // Directly try to open the app
//     final canOpen = await canLaunchUrl(uri);
//     if (canOpen) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       // No compatible app found → show message only
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text('Error'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('URL: $urlToOpen'),
//                 const SizedBox(height: 8),
//                 Text(
//                     'Parsed scheme: ${Uri.tryParse(urlToOpen)?.scheme ?? 'invalid uri'}'),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   } catch (e, st) {
//     debugPrint('Error opening external URL: $e\n$st');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Unable to open payment link.')),
//     );
//   }

//   // Always prevent WebView from loading custom scheme URLs
//   return NavigationDecision.prevent;
// }
