// lib/features/activities/presentation/pages/activity_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

import '../../../../app/themes/colors.dart';
import '../../../../core/widgets/glass_container.dart'; // Untuk konsistensi tema
import './activity_list_notifier.dart'; // Import ActivityListNotifier
import '../../domain/entity/activity_entity.dart'; // Import ActivityEntity (jika belum)

class ActivityListPage extends ConsumerWidget {
  const ActivityListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state dari ActivityListNotifier
    final activityListAsyncValue = ref.watch(activityListNotifierProvider);

    return activityListAsyncValue.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Text(
              'Belum ada aktivitas yang dicatat. Mari tambahkan satu!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          );
        }

        // Tampilkan daftar aktivitas menggunakan ListView
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              // Gunakan GlassContainer untuk konsistensi UI
              child: GlassContainer(
                borderRadius: 15,
                padding: const EdgeInsets.all(16),
                linearGradientColors: [
                  AppColors.secondaryBackground.withOpacity(0.2),
                  AppColors.secondaryBackground.withOpacity(0.1),
                ],
                customBorder: Border.all(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
                child: Row(
                  children: [
                    // Checkbox untuk menandai selesai
                    Checkbox(
                      value: activity.isCompleted,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          ref.read(activityListNotifierProvider.notifier)
                             .toggleActivityCompletion(activity);
                        }
                      },
                      activeColor: AppColors.accentGreen, // Warna saat dicentang
                      checkColor: AppColors.primaryText,
                      side: BorderSide(color: AppColors.tertiaryText), // Warna border saat belum dicentang
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
                              decoration: activity.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.tertiaryText),
                                const SizedBox(width: 4),
                                Text(
                                  activity.dueDate != null
                                      ? DateFormat('dd MMM yyyy').format(activity.dueDate!)
                                      : 'No due date',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.flag_rounded, size: 16, color: _getPriorityColor(activity.priority)),
                                const SizedBox(width: 4),
                                Text(
                                  _getPriorityText(activity.priority),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getPriorityColor(activity.priority)),
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
                                children: activity.tags.map((tag) => Chip(
                                  label: Text(tag, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryText)),
                                  backgroundColor: AppColors.accentBlue.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                )).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Tombol hapus
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: AppColors.error),
                      onPressed: () {
                        // Tampilkan konfirmasi dialog sebelum menghapus
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.secondaryBackground,
                            title: Text('Hapus Aktivitas?', style: TextStyle(color: AppColors.primaryText)),
                            content: Text('Anda yakin ingin menghapus aktivitas "${activity.title}"?', style: TextStyle(color: AppColors.secondaryText)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Batal', style: TextStyle(color: AppColors.accentBlue)),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(activityListNotifierProvider.notifier)
                                     .deleteActivity(activity.id);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Tombol Edit (opsional, bisa ke activity_detail_page)
                    // IconButton(
                    //   icon: Icon(Icons.edit_rounded, color: AppColors.accentPurple),
                    //   onPressed: () {
                    //     // Navigasi ke halaman edit detail
                    //     context.go('${AppRoutes.activitiesHubPath}/${activity.id}');
                    //   },
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
      error: (error, stack) => Center(
        child: Text(
          'Error loading activities: ${error.toString().split(':')[0]}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper untuk mendapatkan warna prioritas
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.redAccent;
      case 2: return Colors.orangeAccent;
      case 3: return Colors.lightGreen;
      default: return AppColors.tertiaryText;
    }
  }

  // Helper untuk mendapatkan teks prioritas
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'Low';
      default: return 'Unknown';
    }
  }
}