// lib/features/habits/presentation/pages/habits_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/features/habits/data/providers/habit_providers.dart';
import 'package:hirudorax/features/habits/presentation/widgets/habit_list_item.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/routes/routes.dart';
import '../../../../app/themes/app_theme.dart'; // Impor AppTextStyles

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  // Dialog konfirmasi hapus, tidak ada perubahan
  Future<bool> _showConfirmDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppColors.secondaryBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Hapus Kebiasaan?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                content: Text(
                  'Yakin ingin menghapus kebiasaan ini? Semua catatan penyelesaian juga akan terhapus.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsyncValue = ref.watch(habitsStreamProvider);
    final dailyHabitSummary = ref.watch(dailyHabitSummaryProvider);

    Future<void> _refreshData() async {
      // Invalidate semua provider yang relevan
      ref.invalidate(habitsStreamProvider);
      ref.invalidate(dailyHabitSummaryProvider);
      ref.invalidate(habitCompletionsStreamProvider);
    }

    return AppScaffold(
      const SizedBox(height: 5), // Placeholder
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.accentPurple,
        backgroundColor: AppColors.primaryText,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 80.0, // Tinggi area header besar
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
                titlePadding: const EdgeInsets.only(
                  left: 60,
                  bottom: 16,
                ), 
                title: Text(
                  'The Habitts',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(color: AppColors.primaryBackground),
              ),
            ),

            // --- Kartu Ringkasan Harian ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _buildDailySummaryCard(context, dailyHabitSummary),
              ),
            ),

            // --- Judul "Daftar Kebiasaan" ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Daftar Kebiasaan',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),

            // --- Daftar Kebiasaan atau Tampilan Kosong ---
            habitsAsyncValue.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildEmptyState(
                        context,
                      ), 
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    80,
                  ), 
                  sliver: SliverList.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: HabitListItem(
                          habit: habit,
                          onToggleComplete: (bool completed) {
                            ref
                                .read(habitNotifierProvider.notifier)
                                .toggleHabitCompletion(habit.id, completed);
                          },
                          onTap: () {
                            context.pushNamed(
                              'habitDetail',
                              pathParameters: {'id': habit.id},
                            );
                          },
                          onEdit: () {
                            context.push(AppRoutes.addHabitPath, extra: habit);
                          },
                          onDelete: () async {
                            final confirmed = await _showConfirmDeleteDialog(
                              context,
                            );
                            if (confirmed) {
                              ref
                                  .read(habitNotifierProvider.notifier)
                                  .deleteHabit(habit.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading:
                  () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ),
              error:
                  (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Gagal memuat kebiasaan: $error',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addHabitPath),
        backgroundColor: AppColors.accentPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 30),
        tooltip: 'Tambah Kebiasaan Baru',
      ),
    );
  }

  // Widget untuk Kartu Ringkasan Harian 
  Widget _buildDailySummaryCard(
    BuildContext context,
    Map<String, int> summary,
  ) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Total Kebiasaan',
            summary['total']!,
            AppColors.accentPurple,
          ),
          _buildSummaryItem(
            context,
            'Selesai Hari Ini',
            summary['completedToday']!,
            AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  // Widget untuk item di dalam kartu ringkasan
  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // Widget untuk tampilan saat tidak ada kebiasaan
  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_objects_outlined,
            color: AppColors.accentPurple.withOpacity(0.8),
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'Mulai bangun kebiasaan baikmu!',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + di bawah untuk menambahkan kebiasaan pertamamu.',
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
