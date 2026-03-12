import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:nivvesh/banks/screens/bank_webview.dart';
import 'package:nivvesh/startup_page.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // await setupServiceLocator();
  runApp(const MyApp());
  // Wait until first frame is rendered to remove splash
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nivvesh',
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      // initialRoute: RouteGenerator.homeScreen,
      // onGenerateRoute: RouteGenerator.generateRoute,
      home: StartupPage(),
      // WebViewScreen(
      //   url: 'https://nivvesh.fixerra.in',
      //   title: '',
      // ),
    );
  }
}
