// lib/features/habits/presentation/pages/habit_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../app/routes/routes.dart';

import '../../domain/entities/habit_entity.dart';
import '../../data/providers/habit_providers.dart';

class HabitDetailPage extends ConsumerWidget {
  final String habitId;
  const HabitDetailPage({super.key, required this.habitId});

  Future<bool> _showConfirmDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Kebiasaan?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text('Yakin ingin menghapus kebiasaan ini? Semua catatan penyelesaian juga akan terhapus.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text('Hapus', style: TextStyle(color: AppColors.primaryText)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsyncValue = ref.watch(habitsStreamProvider.select((habitsAsync) {
      return habitsAsync.when(
        data: (habits) => AsyncData(habits.firstWhereOrNull((h) => h.id == habitId)),
        loading: () => const AsyncLoading(),
        error: (e, st) => AsyncError(e, st),
      );
    }));

    final completionsAsyncValue = ref.watch(habitCompletionsStreamProvider.select((completionsAsync) {
      return completionsAsync.when(
        data: (completions) => AsyncData(completions.where((c) => c.habitId == habitId).toList()),
        loading: () => const AsyncLoading(),
        error: (e, st) => AsyncError(e, st),
      );
    }));

    return AppScaffold(
      const SizedBox(height: 5), 
      body: (habitAsyncValue as AsyncValue).when(
        data: (habit) {
          if (habit == null) {
            return Center(
              child: Text('Kebiasaan tidak ditemukan!', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // --- AppBar Dinamis ---
                    SliverAppBar(
                      pinned: true, 
                      floating: false,
                      elevation: 0,
                      // seperti nya ndek sini ora perlu
                      backgroundColor: AppColors.primaryBackground.withOpacity(0.8),  
                      centerTitle: true,
                      title: Text('Detail Kebiasaan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryText),
                        onPressed: () => context.pop(),
                        tooltip: 'Kembali',
                      ),
                    ),

                    // --- Konten Scrollable ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildHabitHeader(context, habit),
                            const SizedBox(height: 24),
                            _buildInfoSection(context, habit),
                            const SizedBox(height: 24),
                            _buildHistorySection(context, completionsAsyncValue as AsyncValue<dynamic>, habit),
                            const SizedBox(height: 24), 
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButtons(context, ref, habit),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
        error: (error, stack) => Center(
          child: Text('Gagal memuat detail: ${error.toString().split(':')[0]}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
        ),
      ),
    );
  }

  // Widget untuk Header Habit
  Widget _buildHabitHeader(BuildContext context, HabitEntity habit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        if (habit.description != null && habit.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              habit.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
            ),
          ),
      ],
    );
  }

  // Widget untuk Info Detail
  Widget _buildInfoSection(BuildContext context, HabitEntity habit) {
    String frequencyText = '';
     switch (habit.frequency) {
        case HabitFrequency.daily:
          frequencyText = 'Setiap Hari';
          break;
        case HabitFrequency.weekly:
          frequencyText = 'Setiap Minggu';
          break;
        case HabitFrequency.custom:
          if (habit.daysOfWeek.isNotEmpty) {
            final days = habit.daysOfWeek.map((dayIndex) {
              return DateFormat.E('id_ID').format(DateTime(2023, 1, 2).add(Duration(days: dayIndex - 1)));
            }).join(', ');
            frequencyText = 'Hari: $days';
          } else {
            frequencyText = 'Hari Tertentu';
          }
          break;
      }

    String? reminderText;
    if (habit.reminderTime != null) {
      reminderText = DateFormat.jm().format(habit.reminderTime!);
    }
    
    return _buildInfoCard(
      context,
      title: 'Detail Kebiasaan',
      children: [
        _buildInfoRow(context, 'Frekuensi', frequencyText),
        if (habit.targetValue > 1)
          _buildInfoRow(context, 'Target', '${habit.targetValue} ${habit.unit ?? ''}'),
        if (reminderText != null)
          _buildInfoRow(context, 'Pengingat', reminderText),
        _buildInfoRow(context, 'Dibuat Pada', DateFormat('dd MMMM yyyy', 'id_ID').format(habit.createdAt)),
      ],
    );
  }

  // Widget untuk Riwayat
  Widget _buildHistorySection(BuildContext context, AsyncValue completionsAsyncValue, HabitEntity habit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Penyelesaian',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        const SizedBox(height: 15),
        completionsAsyncValue.when(
          data: (completions) {
            final typedCompletions = completions.whereType<HabitCompletionEntity>().toList();

            if (typedCompletions.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada catatan penyelesaian.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                ),
              );
            }
            
            final groupedCompletions = groupBy<HabitCompletionEntity, String>(
              typedCompletions,
              (c) => DateFormat('yyyy-MM-dd').format(c.completedAt),
            );
            final sortedDates = groupedCompletions.keys.toList()..sort((a, b) => b.compareTo(a));

            return Column(
              children: sortedDates.map((dateKey) {
                final compsOnDate = groupedCompletions[dateKey]!;
                final displayDate = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(dateKey));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassContainer(
                     borderRadius: 15,
                    padding: const EdgeInsets.all(16),
                    linearGradientColors: [
                      AppColors.glassBackgroundStart.withOpacity(0.1),
                      AppColors.glassBackgroundEnd.withOpacity(0.05),
                    ],
                    customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.15), width: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayDate,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: AppColors.tertiaryText, height: 16),
                        ...compsOnDate.map((comp) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selesai pada ${DateFormat.jm().format(comp.completedAt)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                                ),
                                if (habit.targetValue > 1)
                                  Text(
                                    '${comp.actualValue} ${habit.unit ?? ''}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentGreen),
                                  ),
                                if (habit.targetValue == 1)
                                  Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 20),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
          error: (error, stack) => Text('Gagal memuat riwayat: ${error.toString().split(':')[0]}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
        ),
      ],
    );
  }
  
  // Widget untuk Tombol Aksi di Bawah
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, HabitEntity habit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), 
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(top: BorderSide(color: AppColors.tertiaryText.withOpacity(0.2), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.addHabitPath, extra: habit),
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primaryText),
                  label: Text('Edit', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue.withOpacity(0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await _showConfirmDeleteDialog(context);
                    if (confirmed) {
                      await ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
                      if (context.mounted) {
                        context.pop();
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kebiasaan berhasil dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_rounded, color: AppColors.primaryText),
                  label: Text('Hapus', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText)),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final updatedHabit = habit.copyWith(isArchived: !habit.isArchived);
                await ref.read(habitNotifierProvider.notifier).updateHabit(updatedHabit);
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(habit.isArchived ? 'Kebiasaan diaktifkan kembali!' : 'Kebiasaan diarsipkan!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                      backgroundColor: AppColors.accentOrange,
                    ),
                  );
                }
              },
              icon: Icon(habit.isArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: AppColors.primaryText),
              label: Text(habit.isArchived ? 'Aktifkan Kembali' : 'Arsipkan Kebiasaan', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiaryText.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget tidak berubah
  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
      return GlassContainer(
      borderRadius: 15,
      padding: const EdgeInsets.all(16),
      linearGradientColors: [
        AppColors.glassBackgroundStart.withOpacity(0.1),
        AppColors.glassBackgroundEnd.withOpacity(0.05),
      ],
      customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.15), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          ),
          const Divider(color: AppColors.tertiaryText, height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}



extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
