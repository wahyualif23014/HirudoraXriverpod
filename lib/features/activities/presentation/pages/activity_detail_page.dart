// lib/features/activities/presentation/pages/activity_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/app/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../app/themes/colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entity/activity_entity.dart';
import 'activity_list_notifier.dart';

class ActivityDetailPage extends ConsumerWidget {
  final String activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  // Helper untuk mendapatkan warna prioritas
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.accentOrange;
      case 3:
        return AppColors.accentGreen;
      default:
        return AppColors.tertiaryText;
    }
  }

  // Helper untuk mendapatkan teks prioritas
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  // Helper untuk dialog konfirmasi hapus
  void _showConfirmDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ActivityEntity activity,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Hapus Aktivitas?', style: AppTextStyles.titleLarge),
            content: Text(
              'Yakin ingin menghapus aktivitas "${activity.title}"?',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(activityListNotifierProvider.notifier)
                      .deleteActivity(activity.id);
                  context.go(
                    '/activities',
                  ); // Kembali ke halaman utama aktivitas
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(
      activityListNotifierProvider.select(
        (asyncData) => asyncData.whenData<ActivityEntity?>(
          (activities) =>
              activities.firstWhereOrNull((a) => a.id == activityId),
        ),
      ),
    );

    return AppScaffold(
      const SizedBox(height: 5),
      body: activityAsync.when(
        data: (activity) {
          if (activity == null) {
            return const Center(
              child: Text('Aktivitas tidak ditemukan. Mungkin sudah dihapus.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.primaryBackground.withOpacity(
                        0.85,
                      ),
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppColors.primaryText,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      title: Text(
                        'Detail Aktivitas',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildActivityHeader(context, ref, activity),
                            const SizedBox(height: 24),
                            _buildDetailsCard(context, activity),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButtons(context, ref, activity),
            ],
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange),
            ),
        error: (e, st) => Center(child: Text('Gagal memuat detail: $e')),
      ),
    );
  }

  Widget _buildActivityHeader(
    BuildContext context,
    WidgetRef ref,
    ActivityEntity activity,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (activity.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    activity.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Checkbox(
          value: activity.isCompleted,
          onChanged:
              (_) => ref
                  .read(activityListNotifierProvider.notifier)
                  .toggleActivityCompletion(activity),
          activeColor: AppColors.accentGreen,
          side: const BorderSide(color: AppColors.tertiaryText),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, ActivityEntity activity) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            icon: Icons.flag_rounded,
            iconColor: _getPriorityColor(activity.priority),
            label: 'Prioritas',
            value: _getPriorityText(activity.priority),
          ),
          if (activity.dueDate != null) ...[
            const Divider(color: AppColors.tertiaryText, height: 24),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.secondaryText,
              label: 'Jatuh Tempo',
              value: DateFormat('dd MMMM yyyy').format(activity.dueDate!),
            ),
          ],
          if (activity.tags.isNotEmpty) ...[
            const Divider(color: AppColors.tertiaryText, height: 24),
            _buildInfoRow(
              context,
              icon: Icons.label_rounded,
              iconColor: AppColors.secondaryText,
              label: 'Tags',
              value: activity.tags.join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ActivityEntity activity,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.tertiaryText.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke halaman 'add' tapi dengan membawa data 'activity'
                context.push(AppRoutes.addActivityPath, extra: activity);
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDeleteDialog(context, ref, activity),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Hapus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
