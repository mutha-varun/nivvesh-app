import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/mobile/data/providers/auth_state_provider.dart';
import 'package:nivvesh/mobile/presentation/home/pages/investment_page.dart';
import 'package:nivvesh/mobile/presentation/auth/pages/login_page.dart';
import 'package:nivvesh/mobile/presentation/home/pages/homepage.dart';
import 'package:nivvesh/mobile/presentation/spend/pages/spend_page.dart';
import 'package:nivvesh/webview/screens/bank_inappWebView.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.asData?.value ?? false;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToHome = state.matchedLocation == '/home';

      final isOnSplash = state.matchedLocation == '/splash';

      if (isLoading) {
        return isOnSplash ? null : '/splash';
      }

      if (!isLoggedIn) {
        if (isOnSplash) return '/login';
        return isGoingToLogin ? null : '/login';
      }

      if (isOnSplash || isGoingToLogin) {
        return '/home';
      }

      if (isGoingToHome) return null;

      return '/home';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/investment',
        builder: (context, state) => const InvestmentPage(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceSheet(),
      ),
      GoRoute(
        path: '/bank',
        builder: (context, state) => const InAppWebViewScreen(
          url: 'https://nivvesh.fixerra.in/',
          title: 'Bank',
        ),
      ),

      
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}