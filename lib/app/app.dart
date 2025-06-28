// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:go_router/go_router.dart'; 

import 'routes/app_router.dart';
import 'themes/app_theme.dart';  


class App extends ConsumerWidget { 
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final GoRouter router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Hirudorax', 
      theme: AppTheme.lightTheme, 
      routerConfig: router,
      debugShowCheckedModeBanner: false, 
    );
  }
}