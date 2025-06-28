// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart'; 
import '../../../../core/widgets/glass_container.dart'; 
import '../../../../app/themes/colors.dart'; // Warna tema Anda
import '../../../../app/routes/routes.dart'; // Rute aplikasi Anda

final totalBalanceProvider = StateProvider<double>((ref) => 1250000.0); // Contoh saldo
final recentActivityProvider = StateProvider<String>((ref) => '2 new activities logged today');
final nextHabitProvider = StateProvider<String>((ref) => 'Workout - 30 mins');

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double totalBalance = ref.watch(totalBalanceProvider);
    final String recentActivity = ref.watch(recentActivityProvider);
    final String nextHabit = ref.watch(nextHabitProvider);

    return AppScaffold(
      title: 'Hi, Hirudorax!',
      // Anda bisa menambahkan actions seperti tombol profil atau notifikasi
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded, color: AppColors.primaryText),
          onPressed: () {
            // Arahkan ke halaman notifikasi atau buka dialog
            context.go(AppRoutes.notificationSettingsPath); // Contoh navigasi
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0).copyWith(top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 20),
        children: [
          // --- Bagian Saldo/Ringkasan Keuangan Utama ---
          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            gradientBegin: Alignment.bottomLeft,
            gradientEnd: Alignment.topRight,
            linearGradientColors: [
              AppColors.accentBlue.withOpacity(0.3),
              AppColors.accentPurple.withOpacity(0.2),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${totalBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.financeHubPath);
                    },
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: const Text('View Finance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue.withOpacity(0.8), // Tombol dengan warna semangat
                      foregroundColor: AppColors.primaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Bagian Quick Actions (Aksi Cepat) ---
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll GridView
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.add_rounded,
                label: 'Add Transaction',
                color: AppColors.accentGreen,
                onTap: () => context.go(AppRoutes.addTransactionPath),
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.add_task_rounded,
                label: 'Add Activity',
                color: AppColors.accentOrange,
                onTap: () => context.go(AppRoutes.addActivityPath),
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.repeat_one_on_rounded,
                label: 'New Habit',
                color: AppColors.accentPurple,
                onTap: () => context.go(AppRoutes.addHabitPath),
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.flag_rounded,
                label: 'Set Goal',
                color: AppColors.accentPink,
                onTap: () => context.go(AppRoutes.addGoalPath),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Bagian Pemantauan Fitur Lainnya (List Kotak Glassmorphism) ---
          Text(
            'Your Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          _buildFeatureOverviewCard(
            context,
            title: 'Activities Progress',
            subtitle: recentActivity,
            icon: Icons.run_circle_rounded,
            iconColor: AppColors.accentOrange,
            onTap: () => context.go(AppRoutes.activitiesHubPath),
          ),
          const SizedBox(height: 16),
          _buildFeatureOverviewCard(
            context,
            title: 'Next Habit',
            subtitle: nextHabit,
            icon: Icons.access_time_rounded,
            iconColor: AppColors.accentPurple,
            onTap: () => context.go(AppRoutes.habitsHubPath),
          ),
          const SizedBox(height: 16),
          _buildFeatureOverviewCard(
            context,
            title: 'Financial Goals',
            subtitle: 'Saving for new gadget: 60% done!',
            icon: Icons.savings_rounded,
            iconColor: AppColors.accentGreen,
            onTap: () => context.go(AppRoutes.financialGoalsPath),
          ),
          // Tambahkan lebih banyak kartu pemantauan sesuai kebutuhan Anda
        ],
      ),
    );
  }

  // --- Reusable Widget untuk Tombol Aksi Cepat ---
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 15,
      blur: 10,
      opacity: 0.15,
      linearGradientColors: [
        color.withOpacity(0.2),
        color.withOpacity(0.1),
      ],
      customBorder: Border.all(color: color.withOpacity(0.3), width: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Widget untuk Kartu Gambaran Umum Fitur ---
  Widget _buildFeatureOverviewCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      linearGradientColors: [
        iconColor.withOpacity(0.2),
        AppColors.secondaryBackground.withOpacity(0.1),
      ],
      customBorder: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.tertiaryText, size: 20),
          ],
        ),
      ),
    );
  }
}