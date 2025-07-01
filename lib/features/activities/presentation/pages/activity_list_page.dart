// lib/features/activities/presentation/pages/activity_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

import '../../domain/entity/activity_entity.dart';
import './activity_list_notifier.dart';

class ActivityListPage extends ConsumerWidget {
  const ActivityListPage({super.key});

  void _deleteActivity(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Aktivitas?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text(
          'Anda yakin ingin menghapus aktivitas ini?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondaryText),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activityListNotifierProvider.notifier).deleteActivity(id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Aktivitas berhasil dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: AppColors.primaryText)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityListAsyncValue = ref.watch(activityListNotifierProvider);

    return activityListAsyncValue.when(
      data: (activities) {
        if (activities.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Belum ada aktivitas yang dicatat. Mari tambahkan satu!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Dismissible(
                  key: ValueKey(activity.id),
                  // ⭐ PERBAIKAN: Gunakan DismissDirection.endToStart dan atur 'background' saja untuk aksi delete
                  // Atau, gunakan DismissDirection.horizontal dan pastikan kedua background ada.
                  // Pilihan ini: Hanya izinkan swipe delete (kanan ke kiri)
                  direction: DismissDirection.endToStart, 
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _deleteActivity(context, ref, activity.id);
                      return false;
                    }
                    return false; // Untuk arah lain (meskipun tidak diizinkan oleh `direction`)
                  },
                  // ⭐ Gunakan `background` untuk aksi delete karena hanya ada satu arah swipe
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.error.withOpacity(0.8)], // Warna merah di kanan
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.centerRight, // Icon muncul di kanan
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: AppColors.primaryText, size: 28),
                  ),
                  // ⭐ secondaryBackground tidak perlu lagi jika direction: DismissDirection.endToStart
                  // Jika Anda ingin swipe kiri ke kanan (edit) kembali, ubah `direction` ke `horizontal`
                  // dan uncomment `background` sebelumnya, lalu ganti nama ini jadi `secondaryBackground`.
                  // secondaryBackground: Container(), // Dihapus karena tidak dibutuhkan dengan `direction: DismissDirection.endToStart`

                  child: _ActivityItem(
                    activity: activity,
                    onToggleCompletion: (bool? newValue) {
                      ref.read(activityListNotifierProvider.notifier).toggleActivityCompletion(activity);
                    },
                    onTap: () {
                      // onTap saat ini tidak melakukan apa-apa, sesuai permintaan
                    },
                  ),
                ),
              );
            },
            childCount: activities.length,
          ),
        );
      },
      loading: () => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
      ),
      error: (error, stack) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Error loading activities: ${error.toString().split(':')[0]}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Widget terpisah untuk menampilkan setiap item aktivitas
class _ActivityItem extends StatelessWidget {
  final ActivityEntity activity;
  final ValueChanged<bool?> onToggleCompletion;
  final VoidCallback onTap;

  const _ActivityItem({
    super.key,
    required this.activity,
    required this.onToggleCompletion,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 15,
        padding: const EdgeInsets.all(16),
        blur: 10,
        opacity: 0.1,
        linearGradientColors: [
          AppColors.glassBackgroundStart.withOpacity(0.15),
          AppColors.glassBackgroundEnd.withOpacity(0.1),
        ],
        customBorder:
            Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.2), width: 1),
        child: Row(
          children: [
            Checkbox(
              value: activity.isCompleted,
              onChanged: onToggleCompletion,
              activeColor: AppColors.accentGreen,
              checkColor: AppColors.primaryText,
              side: const BorderSide(color: AppColors.tertiaryText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.tertiaryText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        activity.description,
                        style: Theme.of(context)
                            .textTheme.bodySmall
                            ?.copyWith(color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 16, color: AppColors.tertiaryText),
                        const SizedBox(width: 4),
                        Text(
                          activity.dueDate != null
                              ? DateFormat('dd MMMEEEE').format(activity.dueDate!)
                              : 'No due date',
                          style: Theme.of(context)
                              .textTheme.bodySmall
                              ?.copyWith(color: AppColors.tertiaryText),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.flag_rounded,
                            size: 16, color: _getPriorityColor(activity.priority)),
                        const SizedBox(width: 4),
                        Text(
                          _getPriorityText(activity.priority),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getPriorityColor(activity.priority)),
                        ),
                      ],
                    ),
                  ),
                  if (activity.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: activity.tags
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: Theme.of(context)
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppColors.primaryText)),
                                  backgroundColor:
                                      AppColors.accentBlue.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}