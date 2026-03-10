import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nivvesh/banks/screens/bank_inappWebView.dart';
import 'package:nivvesh/banks/screens/bank_webview.dart';
import 'package:nivvesh/login/api_service.dart';
import 'package:nivvesh/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final timestampStr = prefs.getString('loginTimestamp');

    if (phoneNumber != null && timestampStr != null) {
      final loginTime = DateTime.tryParse(timestampStr);
      if (loginTime != null) {
        final now = DateTime.now();
        final difference = now.difference(loginTime);

        if (difference.inDays > 0) {
          // Session expired — clear old data and go to Login
          await prefs.remove('phoneNumber');
          await prefs.remove('loginTimestamp');

          FlutterNativeSplash.remove();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          return;
        }

        // Still valid — proceed with API relogin
        final response = await ApiService.relogin();
        if (response?.redirectUrl != null) {
          FlutterNativeSplash.remove();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InAppWebViewScreen(
                url: response!.redirectUrl,
                title: '',
              ),
            ),
          );
          return;
        }
      }
    }

    FlutterNativeSplash.remove();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Optional: you can show splash or loader here
    return const Scaffold(
      // backgroundColor: Color(0xff1c1c1e),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
