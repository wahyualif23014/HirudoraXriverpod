// lib/features/habits/presentation/pages/habits_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart'; // Jika ingin pakai glassmorphism
import '../../../../app/themes/colors.dart';
import '../../../../app/routes/routes.dart'; // Untuk navigasi GoRouter

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      const SizedBox(height: 15),
      title: 'Kebiasaan Saya',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelacak Kebiasaan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              borderRadius: 15,
              padding: const EdgeInsets.all(20),
              linearGradientColors: [
                AppColors.accentPurple.withOpacity(0.2),
                AppColors.secondaryBackground.withOpacity(0.1),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda belum memiliki kebiasaan yang dilacak.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.addHabitPath); // Navigasi ke halaman tambah kebiasaan
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Kebiasaan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Di sini nanti akan tampil daftar kebiasaan dari provider
            Expanded(
              child: Center(
                child: Text(
                  'Daftar Kebiasaan Akan Tampil Di Sini',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.tertiaryText),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(AppRoutes.addHabitPath);
        },
        child: Icon(Icons.add_rounded),
        backgroundColor: AppColors.accentPurple,
      ),
    );
  }
}