import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/main_layout.dart';

final appRouter = GoRouter(
  initialLocation: LoginPage.routePath,
  routes: [
    GoRoute(
      path: LoginPage.routePath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: MainLayout.routePath,
      builder: (context, state) => const MainLayout(),
    ),
  ],
);

class SmartBugdetApp extends StatelessWidget {
  const SmartBugdetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartBudget+',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme(),
    );
  }
}
