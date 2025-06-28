// lib/features/finance/presentation/pages/finance_overview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang dan tanggal

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';     // <--- Perbaikan path impor
import '../../../../app/themes/app_theme.dart'; // <--- Perbaikan path impor (mengganti app_theme.dart)
import '../../../../app/routes/routes.dart';

import '../../domain/entity/transaction_entity.dart';
import '../../data/providers/finance_providers.dart';

class FinanceOverviewPage extends ConsumerWidget {
  const FinanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime currentMonth = DateTime.now();
    final monthlySummaryAsyncValue = ref.watch(monthlyFinanceSummaryProvider(currentMonth));
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);
    final transactionNotifierState = ref.watch(transactionNotifierProvider);

    return AppScaffold(
      title: 'Keuangan Saya',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryText),
        onPressed: () {
          context.go(AppRoutes.homePath); // Kembali ke halaman utama/dashboard
        },
        tooltip: 'Kembali ke Beranda',
      ),
      // --- Akhir Perbaikan ---
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primaryText),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Laporan Keuangan (Coming Soon)!')),
            );
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMonthlySummaryCard(context, monthlySummaryAsyncValue),
          const SizedBox(height: 24),

          Text(
            'Aksi Cepat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          _buildQuickFinanceActions(context),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Semua Transaksi (Coming Soon)!')),
                  );
                },
                child: Text(
                  'Lihat Semua',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accentBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          transactionsAsyncValue.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada transaksi. Tambahkan yang pertama!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final latestTransactions = transactions..sort((a, b) => b.date.compareTo(a.date));
              final displayTransactions = latestTransactions.take(5).toList(); 

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = displayTransactions[index];
                  return _TransactionListItem(
                    transaction: transaction,
                    onDelete: (id, budgetId, amount, type) async {
                      final confirmed = await _showConfirmDeleteDialog(context);
                      if (confirmed) {
                        await ref.read(transactionNotifierProvider.notifier).deleteTransaction(id, budgetId, amount, type);
                        if (ref.read(transactionNotifierProvider) is AsyncData) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaksi dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
                          );
                        } else if (ref.read(transactionNotifierProvider) is AsyncError) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menghapus: ${(ref.read(transactionNotifierProvider) as AsyncError).error}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
            error: (error, stack) => Center(
              child: Text(
                'Gagal memuat transaksi: $error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
          ),
          SizedBox(height: transactionNotifierState.isLoading ? 16 : 0),
          if (transactionNotifierState.isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(BuildContext context, AsyncValue<Map<String, double>> monthlySummaryAsyncValue) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      linearGradientColors: [
        AppColors.glassBackgroundStart.withOpacity(0.15),
        AppColors.glassBackgroundEnd.withOpacity(0.1),
      ],
      customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.2), width: 1),
      child: monthlySummaryAsyncValue.when(
        data: (summary) {
          final double totalIncome = summary['income'] ?? 0.0;
          final double totalExpense = summary['expense'] ?? 0.0;
          final double netBalance = summary['net'] ?? 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Bulan Ini (${DateFormat('MMMM yyyy').format(DateTime.now())})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(context, 'Pemasukan', totalIncome, AppColors.accentGreen),
              _buildSummaryRow(context, 'Pengeluaran', totalExpense, AppColors.error),
              const Divider(height: 20, color: AppColors.secondaryText),
              _buildSummaryRow(context, 'Saldo Bersih', netBalance, netBalance >= 0 ? AppColors.accentBlue : AppColors.error),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (error, stack) => Center(child: Text('Gagal memuat ringkasan: $error', style: TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(amount)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFinanceActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionChip(
          context,
          icon: Icons.add_circle_rounded,
          label: 'Tambah',
          color: AppColors.accentBlue,
          onTap: () => context.go(AppRoutes.addTransactionPath),
        ),
        _buildActionChip(
          context,
          icon: Icons.calendar_today_rounded,
          label: 'Anggaran',
          color: AppColors.accentPurple,
          onTap: () => context.go(AppRoutes.budgetManagementPath),
        ),
        _buildActionChip(
          context,
          icon: Icons.military_tech_rounded,
          label: 'Tujuan',
          color: AppColors.accentGreen,
          onTap: () => context.go(AppRoutes.financialGoalsPath),
        ),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        linearGradientColors: [
          color.withOpacity(0.2),
          color.withOpacity(0.05),
        ],
        customBorder: Border.all(color: color.withOpacity(0.3), width: 1),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryText)),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        title: Text('Hapus Transaksi?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Hapus', style: TextStyle(color: AppColors.primaryText)),
          ),
        ],
      ),
    ) ?? false;
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final Function(String id, String budgetId, double amount, String type) onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == 'expense';
    final Color amountColor = isExpense ? AppColors.error : AppColors.accentGreen;
    final IconData icon = isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return GlassContainer(
      borderRadius: 15,
      // margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      linearGradientColors: [
        (isExpense ? AppColors.error : AppColors.accentGreen).withOpacity(0.05),
        AppColors.glassBackgroundEnd.withOpacity(0.02),
      ],
      customBorder: Border.all(color: (isExpense ? AppColors.error : AppColors.accentGreen).withOpacity(0.1), width: 1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: amountColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date), // Perbaiki format tanggal
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'} Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor),
              ),
              if (transaction.budgetId.isNotEmpty)
                Text(
                  'Budget: ${transaction.budgetId.substring(0, 4)}...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.tertiaryText.withOpacity(0.7)),
            onPressed: () => onDelete(transaction.id!, transaction.budgetId, transaction.amount, transaction.type),
            tooltip: 'Hapus Transaksi',
          ),
        ],
      ),
    );
  }
}