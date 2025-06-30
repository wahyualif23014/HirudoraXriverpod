// lib/features/activities/presentation/pages/activities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/routes/routes.dart';

// Import ActivityListPage
import 'activity_list_page.dart'; // Sesuaikan path jika berbeda

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      const SizedBox(height: 15),
      title: 'Aktivitas Saya',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Aktivitas Harian',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              borderRadius: 15,
              padding: const EdgeInsets.all(20),
              linearGradientColors: [
                AppColors.accentOrange.withOpacity(0.2),
                AppColors.secondaryBackground.withOpacity(0.1),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catat aktivitas harian Anda untuk melihat progress.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.addActivityPath);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Aktivitas Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mengganti placeholder dengan ActivityListPage
            Expanded(
              child: ActivityListPage(), // <--- INI PENTING
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(AppRoutes.addActivityPath);
        },
        child: Icon(Icons.add_rounded),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }
}