import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class FlutterArcadeApp extends StatelessWidget {
  const FlutterArcadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FlutterArcade',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
