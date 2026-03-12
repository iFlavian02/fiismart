import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder router — will be replaced with real routes per feature.
final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _PlaceholderHome(),
    ),
  ],
);

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FiiSmart',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
