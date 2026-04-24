import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_page.dart';

final appRouter = GoRouter(
  initialLocation: LoginPage.routePath,
  routes: [
    GoRoute(
      path: LoginPage.routePath,
      builder: (context, state) => const LoginPage(),
    ),
  ],
);

class SmartBugdetApp extends StatelessWidget {
  const SmartBugdetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartBugdet',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    );
  }
}
