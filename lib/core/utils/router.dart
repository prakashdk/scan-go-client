// lib/core/utils/router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/landing_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/profile_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/cart/cart_bill_page.dart';
import '../../features/cart/cart_page.dart';
import '../../features/cart/carts_list_page.dart';
import '../../features/home/home_page.dart';
import '../../features/home/main_shell.dart';
import '../../features/orders/order_bill_page.dart';
import '../../features/orders/orders_page.dart';
import '../../features/scan/scan_store_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final loc = state.uri.toString();

      // Still initialising
      if (auth.status == AuthStatus.unknown && loc != '/') {
        // Allow public routes
        if (loc == '/' || loc == '/login' || loc == '/register') return null;
        return '/';
      }
      return null;
    },
    routes: [
      // Public
      GoRoute(
        path: '/',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const RegisterPage(),
      ),

      // Cart detail (no bottom nav — immersive scanning experience)
      GoRoute(
        path: '/cart/:cartId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            CartPage(cartId: state.pathParameters['cartId']!),
      ),
      GoRoute(
        path: '/cart/:cartId/bill',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            CartBillPage(cartId: state.pathParameters['cartId']!),
      ),
      GoRoute(
        path: '/orders/:orderId/bill',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            OrderBillPage(orderId: state.pathParameters['orderId']!),
      ),

      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/scan-store',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (_, __) => const ScanStorePage(),
          ),
          GoRoute(
            path: '/carts',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (_, __) => const CartsListPage(),
          ),
          GoRoute(
            path: '/orders',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (_, __) => const OrdersPage(),
          ),
          GoRoute(
            path: '/profile',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
