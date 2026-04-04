import 'package:flutter/material.dart';
import 'package:indigo_insights/router.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_theme.dart';
import 'package:indigo_insights/theme/schemes/dark_scheme.dart';

void main() async {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Indigo Insights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(darkScheme, darkStyles),
      routerConfig: appRouter,
    );
  }
}
