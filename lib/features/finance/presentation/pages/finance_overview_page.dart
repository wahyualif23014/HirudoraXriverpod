// lib/features/finance/presentation/pages/finance_overview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../app/routes/routes.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/budget_entity.dart';
import '../../data/providers/finance_providers.dart';

// =================================================================================
// BAGIAN 1: WIDGET UTAMA (HIGH-LEVEL LAYOUT)
// =================================================================================

class FinanceOverviewPage extends ConsumerWidget {
  const FinanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refreshData() async {
      final currentMonth = DateTime.now();
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(monthlyFinanceSummaryProvider(currentMonth));
      ref.invalidate(totalBalanceSupabaseProvider);
    }

    return AppScaffold(
      // --- AppBar ---
      const SizedBox(height: 5),
      title: 'Keuangan Saya',
      appBarColor: AppColors.primaryBackground,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.primaryText,
        ),
        onPressed: () => context.go(AppRoutes.homePath),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.bar_chart_rounded,
            color: AppColors.primaryText,
          ),
          onPressed: () {
            /* Fungsi SnackBar Anda */
          },
        ),
      ],
      // --- Body Utama ---
      body: RefreshIndicator(
        onRefresh: refreshData,
        color: AppColors.accentBlue,
        backgroundColor: AppColors.secondaryBackground,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: kToolbarHeight),
                  const _HeaderSection(),
                  const SizedBox(height: 28),
                  _QuickActionsSection(),
                  const SizedBox(height: 28),
                  _TransactionHeader(),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            const _TransactionListSection(),
          ],
        ),
      ),
    );
  }
}

// BAGIAN 2: KOMPONEN-KOMPONEN UI YANG DIEKSTRAK

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsyncValue = ref.watch(totalBalanceSupabaseProvider);

    return Column(
      children: [
        Text(
          '',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        totalBalanceAsyncValue.when(
          data: (totalBalance) {
            final balanceColor =
                totalBalance >= 0 ? AppColors.accentGreen : AppColors.error;
            return Column(
              children: [
                Text(
                  'Total Saldo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(totalBalance)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
          loading:
              () =>
                  const CircularProgressIndicator(color: AppColors.accentBlue),
          error:
              (error, stack) => Text(
                'Gagal memuat saldo',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buildActionChip({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
    }) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          // 1. Menggunakan ClipRRect untuk membatasi efek blur
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.1),
                      Colors.blueGrey.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          buildActionChip(
            icon: Icons.add_circle_rounded,
            label: 'Tambah',
            color: AppColors.accentBlue,
            onTap: () => context.go(AppRoutes.addTransactionPath),
          ),
          const SizedBox(width: 15),
          buildActionChip(
            icon: Icons.calendar_today_rounded,
            label: 'Anggaran',
            color: AppColors.accentPurple,
            onTap: () => context.go(AppRoutes.budgetManagementPath),
          ),
          const SizedBox(width: 15),
          buildActionChip(
            icon: Icons.military_tech_rounded,
            label: 'Tujuan',
            color: AppColors.accentGreen,
            onTap: () => context.go(AppRoutes.financialGoalsPath),
          ),
        ],
      ),
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transaksi Terbaru',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          TextButton(
            onPressed: () {
              /* Navigasi ke semua transaksi */
            },
            child: Text(
              'Lihat Semua',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// fungsi hapus belum yooo

class _TransactionListSection extends ConsumerWidget {
  const _TransactionListSection();
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);

    return transactionsAsyncValue.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Belum ada transaksi',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
          );
        }
        final latestTransactions = List<TransactionEntity>.from(transactions)
          ..sort((a, b) => b.date.compareTo(a.date));

        return SliverList.builder(
          itemCount: latestTransactions.length,
          itemBuilder: (context, index) {
            final transaction = latestTransactions[index];
            return _TransactionListItem(
              transaction: transaction,
              onEdit:
                  () => context.push(
                    AppRoutes.addTransactionPath,
                    extra: transaction,
                  ),
              onDelete: () async {
                // ... Logika hapus Anda tetap di sini ...
              },
            );
          },
        );
      },
      loading:
          () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            ),
          ),
      error:
          (error, stack) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Gagal memuat transaksi',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
    );
  }
}

// =================================================================================
// BAGIAN 3: WIDGET ITEM TRANSAKSI YANG DIUBAH TOTAL
// =================================================================================

class _TransactionListItem extends ConsumerWidget {
  final TransactionEntity transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TransactionListItem({
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? AppColors.error : AppColors.accentGreen;
    final iconData =
        isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    // Anda bisa tambahkan lagi logika untuk budget provider di sini jika perlu

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Slidable(
        key: ValueKey(transaction.id),
        // --- Perubahan Utama: Aksi Geser Kaca ---
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            _GlassSlidableAction(
              color: AppColors.error,
              icon: Icons.delete_rounded,
              label: '',
              onPressed: onDelete,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            _GlassSlidableAction(
              color: AppColors.accentBlue,
              icon: Icons.edit_rounded,
              label: '',
              onPressed: onEdit,
            ),
          ],
        ),
        // --- Perubahan Utama: Latar Belakang Kaca ---
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: amountColor.withOpacity(0.15),
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
                          transaction.category,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (transaction.description != null &&
                            transaction.description!.isNotEmpty)
                          Text(
                            transaction.description!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${isExpense ? '-' : '+'}Rp${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGET BARU: Aksi Geser Kaca yang Dapat Digunakan Kembali
class _GlassSlidableAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GlassSlidableAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.5), color.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
