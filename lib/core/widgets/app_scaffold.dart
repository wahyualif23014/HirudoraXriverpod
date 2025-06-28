// lib/core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../../app/themes/colors.dart'; 

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? appBarColor; // Untuk custom color AppBar glassmorphism

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Agar body bisa di belakang AppBar
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
              leading: leading,
              // Background AppBar akan secara otomatis transparan karena elevation 0
              // Kita bisa menambahkan GlassContainer di FlexibleSpace jika mau
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBackground, // Warna hitam gelap
              AppColors.secondaryBackground, // Warna abu-abu gelap
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}