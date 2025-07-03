// lib/features/habits/presentation/pages/habits_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/features/habits/data/providers/habit_providers.dart';
import 'package:hirudorax/features/habits/presentation/widgets/habit_list_item.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart'; // Jika ingin pakai glassmorphism
import '../../../../app/themes/colors.dart';
import '../../../../app/routes/routes.dart'; // Untuk navigasi GoRouter

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

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
    final habitsAsyncValue = ref.watch(habitsStreamProvider); // Stream semua habits
    final dailyHabitSummary = ref.watch(dailyHabitSummaryProvider); // Ringkasan harian

    Future<void> _refreshData() async {
      ref.invalidate(habitsStreamProvider);
      ref.invalidate(dailyHabitSummaryProvider);
      ref.invalidate(habitCompletionsStreamProvider); // Juga refresh completions
    }

    return AppScaffold(
      const SizedBox(height: 5),
      title: '',
      appBarColor: AppColors.primaryBackground,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded, // Mengubah ikon kembali agar konsisten
          color: AppColors.primaryText,
        ),
        onPressed: () => context.go(AppRoutes.homePath),
        tooltip: 'Kembali ke Beranda',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: AppColors.primaryText),
          onPressed: () => context.push(AppRoutes.addHabitPath), // Gunakan context.push untuk add
          tooltip: 'Tambah Kebiasaan Baru',
        ),
      ],
      body: RefreshIndicator( // Tambahkan RefreshIndicator
        onRefresh: _refreshData,
        color: AppColors.accentPurple,
        backgroundColor: AppColors.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebiasaan Saya',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 20),

              // Ringkasan Harian Kebiasaan
              _buildDailySummaryCard(context, dailyHabitSummary),
              const SizedBox(height: 30),

              Text(
                'Daftar Kebiasaan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: habitsAsyncValue.when(
                  data: (habits) {
                    if (habits.isEmpty) {
                      return ListView( // Gunakan ListView agar RefreshIndicator tetap berfungsi
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          GlassContainer( // Gunakan GlassContainer seperti contoh Anda
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(AppRoutes.addHabitPath); // Gunakan context.push
                                  },
                                  icon: const Icon(Icons.add_rounded, color: AppColors.primaryText),
                                  label: Text('Tambah Kebiasaan Baru', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryText)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentPurple.withOpacity(0.8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding( // Padding untuk teks "Belum ada kebiasaan" jika ada
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
                            child: Center(
                              child: Text(
                                'Mulai lacak kebiasaan Anda sekarang!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.tertiaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      itemCount: habits.length,
                      padding: const EdgeInsets.only(top: 0), // Atur padding
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0), // Padding vertikal antar item
                          child: HabitListItem( // Gunakan widget yang sudah kita pisahkan
                            habit: habit,
                            onToggleComplete: (bool completed) {
                              ref.read(habitNotifierProvider.notifier).toggleHabitCompletion(habit.id, completed);
                            },
                            onEdit: () {
                              context.push(AppRoutes.addHabitPath, extra: habit); // Kirim objek habit untuk edit
                            },
                            onDelete: () async {
                              final confirmed = await _showConfirmDeleteDialog(context);
                              if (confirmed) {
                                ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
                  error: (error, stack) => Center(
                    child: Text('Gagal memuat kebiasaan: ${error.toString().split(':')[0]}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton( // FAB untuk tambah kebiasaan
        onPressed: () {
          context.push(AppRoutes.addHabitPath); // Gunakan context.push
        },
        backgroundColor: AppColors.accentPurple.withOpacity(0.8),
        child: const Icon(Icons.add_rounded, color: AppColors.primaryText, size: 30),
        tooltip: 'Tambah Kebiasaan Baru',
      ),
    );
  }

  // Widget _buildDailySummaryCard
  Widget _buildDailySummaryCard(BuildContext context, Map<String, int> summary) {
    return GlassContainer( // Gunakan GlassContainer untuk konsistensi
      borderRadius: 15,
      padding: const EdgeInsets.all(20),
      linearGradientColors: [
        AppColors.glassBackgroundStart.withOpacity(0.15),
        AppColors.glassBackgroundEnd.withOpacity(0.1),
      ],
      customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.2), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Hari Ini',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(context, 'Total Kebiasaan', summary['total']!, AppColors.accentPurple),
              _buildSummaryItem(context, 'Selesai Hari Ini', summary['completedToday']!, AppColors.accentGreen),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildSummaryItem
  Widget _buildSummaryItem(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 5),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}