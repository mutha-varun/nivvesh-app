import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/application/auth/auth_state_provider.dart';
import 'package:nivvesh/presentation/home/pages/investment_page.dart';
import 'package:nivvesh/presentation/auth/pages/login_page.dart';
import 'package:nivvesh/presentation/home/pages/homepage.dart';
import 'package:nivvesh/presentation/shell/coming_soon_page.dart';
import 'package:nivvesh/presentation/shell/main_shell.dart';
import 'package:nivvesh/presentation/shared/pages/splash_page.dart';
import 'package:nivvesh/presentation/transactions/pages/spend_page.dart';
import 'package:nivvesh/webview/screens/bank_inappWebView.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: _RouterNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.asData?.value ?? false;

      final isGoingToLogin = state.matchedLocation == '/login';

      final isOnSplash = state.matchedLocation == '/splash';

      if (isLoading) {
        return isOnSplash ? '/login' : null;
      }

      if (!isLoggedIn) {
        if (isOnSplash) return '/login';
        return isGoingToLogin ? null : '/login';
      }

      if (isOnSplash || isGoingToLogin) {
        return '/home';
      }

      return null;
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) =>
                    const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (context, state) =>
                    const ComingSoonPage(tabName: 'AI Insights'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journey',
                builder: (context, state) =>
                    const ComingSoonPage(tabName: 'Journey'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) =>
                    const ComingSoonPage(tabName: 'Alerts'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/investment',
        builder: (context, state) => const InvestmentPage(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceEntrySplash(),
      ),
      GoRoute(
        path: '/finance/sheet',
        builder: (context, state) => const HistoryPage(),
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, next) => notifyListeners());
  }
}
