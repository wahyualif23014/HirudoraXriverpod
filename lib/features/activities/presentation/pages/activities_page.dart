// lib/features/activities/presentation/pages/activities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/routes/routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../widgets/activity_list_item.dart'; // <- Impor widget baru
import 'activity_list_notifier.dart'; // <- Impor provider

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityListAsync = ref.watch(activityListNotifierProvider);

    return AppScaffold(
      const SizedBox(height: 5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80.0,
            backgroundColor: AppColors.primaryBackground.withOpacity(0.85),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primaryText,
              ),
              onPressed: () => context.go(AppRoutes.homePath),
              tooltip: 'Kembali ke Beranda',
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Text(
                'Aktivitas Saya',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(color: AppColors.primaryBackground),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildHeaderCard(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 10.0),
              child: Text(
                'Daftar Tugas',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          activityListAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildEmptyState(context),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ActivityListItem(
                      activity: activity,
                      onTap: () {
                        // TODO: Implement navigation or action when tapping the activity item
                        context.push(
                          AppRoutes.activityDetailPath(activity.id),
                          extra: activity,
                        );
                      },
                      onToggleComplete: () {
                        ref
                            .read(activityListNotifierProvider.notifier)
                            .toggleActivityCompletion(activity);
                      },
                      onEdit: () {
                        context.push(
                          AppRoutes.addActivityPath,
                          extra: activity,
                        );
                      },
                      onDelete: () {
                        ref
                            .read(activityListNotifierProvider.notifier)
                            .deleteActivity(activity.id);
                      },
                    );
                  },
                ),
              );
            },
            loading:
                () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
            error:
                (err, st) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addActivityPath),
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 30),
        tooltip: 'Tambah Aktivitas Baru',
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Tugasmu',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat semua tugas harian Anda di sini agar tidak ada yang terlewat dan tetap produktif.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          const Icon(
            Icons.check_box_outline_blank_rounded,
            color: AppColors.accentOrange,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Tugas',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk mencatat tugas pertamamu.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
