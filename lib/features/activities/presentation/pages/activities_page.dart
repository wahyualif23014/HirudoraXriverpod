// lib/features/activities/presentation/pages/activities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Pastikan GoRouter diimpor

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart'; // Untuk AppTextStyles
import '../../../../app/routes/routes.dart';

import 'activity_list_page.dart'; // Pastikan path ini benar

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      const SizedBox(height: 15),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.primaryText,
        ), // Icon panah back
        onPressed: () {
          context.go(AppRoutes.homePath);
        },
      ),
      title: 'Aktivitas Saya',
      body: CustomScrollView(
        // Menggunakan CustomScrollView untuk tata letak yang benar
        slivers: [
          // Bagian informasi/summary di atas daftar
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            sliver: SliverToBoxAdapter(
              child: GlassContainer(
                borderRadius: 15,
                padding: const EdgeInsets.all(20),
                blur: 10,
                opacity: 0.15,
                linearGradientColors: [
                  AppColors.accentOrange.withOpacity(0.2),
                  AppColors.secondaryBackground.withOpacity(0.1),
                ],
                customBorder: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                  width: 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Catat aktivitas harian Anda untuk melihat progress dan memastikan semua selesai tepat waktu.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          AppRoutes.addActivityPath,
                        ); // Navigasi menggunakan GoRouter
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryText,
                      ),
                      label: Text(
                        'Tambah Aktivitas Baru',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange.withOpacity(
                          0.7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: AppColors.primaryText.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Judul "Daftar Aktivitas" sebelum daftar aktual
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 15.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Daftar Aktivitas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          ActivityListPage().build(context, ref),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(AppRoutes.addActivityPath);
        },
        child: const Icon(Icons.add_rounded, color: AppColors.primaryText),
        backgroundColor: AppColors.accentOrange,
        tooltip: 'Tambah Aktivitas Baru',
      ),
    );
  }
}
