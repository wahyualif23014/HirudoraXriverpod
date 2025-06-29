// lib/features/finance/presentation/pages/finance_overview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <-- Impor package baru
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_scaffold.dart';
// GlassContainer tidak lagi digunakan, bisa dihapus jika tidak ada widget lain yang memakai
// import '../../../../core/widgets/glass_container.dart'; 
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../app/routes/routes.dart';

import '../../domain/entity/transaction_entity.dart';
import '../../data/providers/finance_providers.dart';

class FinanceOverviewPage extends ConsumerWidget {
  const FinanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime currentMonth = DateTime.now();
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);

    Future<void> _refreshData() async {
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(monthlyFinanceSummaryProvider(currentMonth));
    }

    return AppScaffold(
      title: '',
      appBarColor: AppColors.primaryBackground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryText),
        onPressed: () => context.go(AppRoutes.homePath),
        tooltip: 'Kembali ke Beranda',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primaryText),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Halaman Laporan Keuangan (Coming Soon)!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                backgroundColor: AppColors.accentBlue,
              ),
            );
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Header Halaman
          const SizedBox(height: 60),
          // 2. Aksi Cepat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Keungan saya',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickFinanceActions(context),
          const SizedBox(height: 32),

          // 3. Header Transaksi Terbaru
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terbaru',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                TextButton(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Halaman Semua Transaksi (Coming Soon)!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                         backgroundColor: AppColors.accentBlue,
                       ),
                     );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Daftar Transaksi
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.accentBlue,
              backgroundColor: AppColors.secondaryBackground,
              child: transactionsAsyncValue.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                         Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                          child: Center(
                            child: Text(
                              'Belum ada transaksi',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  final latestTransactions = transactions..sort((a, b) => b.date.compareTo(a.date));
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16), // Padding untuk daftar
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: latestTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = latestTransactions[index];
                      return _TransactionListItem(
                        transaction: transaction,
                        onDelete: () async {
                            final confirmed = await _showConfirmDeleteDialog(context);
                            if (confirmed) {
                              final notifier = ref.read(transactionNotifierProvider.notifier);
                              try {
                                await notifier.deleteTransaction(transaction.id, transaction.budgetId, transaction.amount, transaction.type);
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Transaksi berhasil dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
                                    );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal menghapus: ${e.toString().split(':')[0]}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
                                    );
                                }
                              }
                            }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                error: (error, stack) => Center(
                  child: Text('Gagal memuat transaksi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Aksi Cepat
  Widget _buildQuickFinanceActions(BuildContext context) {
    return SizedBox(
      height: 90, 
      // Beri tinggi tetap agar konsisten
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildActionChip(
            context,
            icon: Icons.add_circle_rounded,
            label: 'Tambah',
            color: AppColors.accentBlue,
            onTap: () => context.go(AppRoutes.addTransactionPath),
          ),
          const SizedBox(width: 12),
          _buildActionChip(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Anggaran',
            color: AppColors.accentPurple,
            onTap: () => context.go(AppRoutes.budgetManagementPath),
          ),
          const SizedBox(width: 12),
          _buildActionChip(
            context,
            icon: Icons.military_tech_rounded,
            label: 'Tujuan',
            color: AppColors.accentGreen,
            onTap: () => context.go(AppRoutes.financialGoalsPath),
          ),
        ],
      ),
    );
  }

  // Helper untuk Action Chip (UI Baru)
  Widget _buildActionChip(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return AspectRatio(
      aspectRatio: 1, // Membuat chip menjadi persegi
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk Konfirmasi Dialog Hapus
  Future<bool> _showConfirmDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text('Aksi ini tidak dapat dibatalkan.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
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
}

// Widget Item Transaksi dengan Swipe-to-Delete (UI Baru)
class _TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == 'expense';
    final Color amountColor = isExpense ? AppColors.error : AppColors.accentGreen;
    final IconData iconData = isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Hapus',
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: amountColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? 'Tanpa Deskripsi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'}Rp${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(transaction.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}