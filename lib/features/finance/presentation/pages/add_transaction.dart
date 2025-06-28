// lib/features/finance/presentation/pages/budget_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart'; // Menggunakan text_styles

import '../../../finance/domain/entity/budget_entity.dart'; // Impor BudgetEntity
import '../../data/providers/finance_providers.dart'; // Impor finance_providers

class AddTransaction extends ConsumerStatefulWidget {
  const AddTransaction({super.key});

  @override
  ConsumerState<AddTransaction> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  BudgetEntity? _editingBudget;

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan form tambah/edit budget (modal bottom sheet)
  void _showBudgetForm({BudgetEntity? budget}) {
    setState(() {
      _editingBudget = budget;
      if (budget != null) {
        _categoryController.text = budget.category;
        _limitController.text = budget.limit.toString();
      } else {
        _categoryController.clear();
        _limitController.clear();
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassContainer(
            borderRadius: 30,
            blur: 20,
            opacity: 0.2,
            linearGradientColors: [
              AppColors.glassBackgroundStart.withOpacity(0.3),
              AppColors.glassBackgroundEnd.withOpacity(0.2),
            ],
            customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.3), width: 1.5),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      budget == null ? 'Tambah Anggaran Baru' : 'Edit Anggaran',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _categoryController,
                      style: const TextStyle(color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _limitController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Batas Anggaran (Rp)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Batas anggaran tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Masukkan jumlah yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBackground.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: AppColors.primaryText.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Batal', style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveBudget();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: AppColors.primaryText.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              budget == null ? 'Tambah' : 'Simpan',
                              style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk menyimpan budget (tambah atau update)
  void _saveBudget() async {
    final budgetNotifier = ref.read(budgetNotifierProvider.notifier);
    final newBudget = BudgetEntity(
      id: _editingBudget?.id, // Pertahankan ID jika sedang mengedit
      category: _categoryController.text,
      limit: double.parse(_limitController.text),
      spent: _editingBudget?.spent ?? 0.0, // Pertahankan spent jika sedang mengedit
    );

    if (_editingBudget == null) {
      await budgetNotifier.addBudget(newBudget);
    } else {
      await budgetNotifier.updateBudget(newBudget);
    }

    if (mounted) {
      final budgetActionState = ref.read(budgetNotifierProvider);
      budgetActionState.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingBudget == null ? 'Anggaran berhasil ditambahkan!' : 'Anggaran berhasil diperbarui!',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
              ),
              backgroundColor: AppColors.accentGreen,
            ),
          );
          Navigator.pop(context);
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan anggaran: $error',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    }
  }

  // Fungsi untuk menghapus budget
  void _deleteBudget(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Anggaran?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text(
          'Yakin ingin menghapus anggaran ini? Ini tidak akan menghapus transaksi terkait.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondaryText),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final budgetNotifier = ref.read(budgetNotifierProvider.notifier);
              try {
                await budgetNotifier.deleteBudget(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Anggaran berhasil dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                  Navigator.pop(context); // Tutup dialog
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus anggaran: $error', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  Navigator.pop(context); // Tutup dialog
                }
              }
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
  Widget build(BuildContext context) {
    final budgetsAsyncValue = ref.watch(budgetsStreamProvider);
    final budgetActionState = ref.watch(budgetNotifierProvider);

    return AppScaffold(
      title: 'Manajemen Anggaran', // Judul AppBar
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Ringkasan Anggaran Bulan Ini ---
            _buildBudgetSummaryCard(budgetsAsyncValue),
            const SizedBox(height: 30),

            // --- Judul Kategori Anggaran ---
            Text(
              'Kategori Anggaran',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 15),

            // --- Daftar Kategori Anggaran (Real-time dari Firebase) ---
            Expanded(
              child: budgetsAsyncValue.when(
                data: (budgets) {
                  if (budgets.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada anggaran. Tambahkan yang pertama!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      return _BudgetCategoryItem(
                        budget: budget,
                        onEdit: () => _showBudgetForm(budget: budget),
                        onDelete: () => _deleteBudget(budget.id!),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                error: (error, stack) => Center(
                  child: Text(
                    'Gagal memuat anggaran: $error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: budgetActionState.isLoading ? null : () => _showBudgetForm(), // Nonaktifkan saat loading
        backgroundColor: AppColors.accentBlue.withOpacity(0.8),
        child: budgetActionState.isLoading
            ? CircularProgressIndicator(color: AppColors.primaryText)
            : const Icon(Icons.add_rounded, color: AppColors.primaryText, size: 30),
        tooltip: 'Tambah Anggaran Baru',
      ),
    );
  }

  // Widget untuk Kartu Ringkasan Anggaran Bulan Ini
  Widget _buildBudgetSummaryCard(AsyncValue<List<BudgetEntity>> budgetsAsyncValue) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      linearGradientColors: [
        AppColors.glassBackgroundStart.withOpacity(0.15),
        AppColors.glassBackgroundEnd.withOpacity(0.1),
      ],
      customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.2), width: 1),
      child: budgetsAsyncValue.when(
        data: (budgets) {
          final double totalLimit = budgets.fold(0.0, (sum, budget) => sum + budget.limit);
          final double totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spent);
          final double remaining = totalLimit - totalSpent;
          final double percentageUsed = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
          Color progressBarColor = AppColors.accentGreen;
          if (percentageUsed > 0.8) {
            progressBarColor = AppColors.error;
          } else if (percentageUsed > 0.5) {
            progressBarColor = AppColors.accentOrange;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Anggaran Bulan Ini',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Total Anggaran', totalLimit, AppColors.accentBlue),
              _buildSummaryRow('Terpakai', totalSpent, progressBarColor),
              _buildSummaryRow('Sisa', remaining, remaining >= 0 ? AppColors.accentGreen : AppColors.error),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentageUsed,
                  backgroundColor: AppColors.secondaryBackground.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(percentageUsed * 100).toStringAsFixed(1)}% Terpakai',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: progressBarColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (error, stack) => Center(child: Text('Gagal memuat ringkasan: $error', style: TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
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
}

// Widget terpisah untuk menampilkan item kategori anggaran
class _BudgetCategoryItem extends StatelessWidget {
  final BudgetEntity budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCategoryItem({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double percentageSpent = budget.limit > 0 ? (budget.spent / budget.limit) : 0.0;
    Color progressColor = AppColors.accentGreen;
    if (percentageSpent > 0.8) {
      progressColor = AppColors.error;
    } else if (percentageSpent > 0.5) {
      progressColor = AppColors.accentOrange;
    }

    return GlassContainer(
      borderRadius: 15,
      padding: const EdgeInsets.all(16.0),
      linearGradientColors: [
        AppColors.glassBackgroundStart.withOpacity(0.1),
        AppColors.glassBackgroundEnd.withOpacity(0.05),
      ],
      customBorder: Border.all(color: AppColors.glassBackgroundStart.withOpacity(0.15), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  budget.category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.accentBlue),
                    onPressed: onEdit,
                    tooltip: 'Edit Anggaran',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: onDelete,
                    tooltip: 'Hapus Anggaran',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Limit: Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(budget.limit)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            'Terpakai: Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(budget.spent)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: progressColor),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentageSpent,
              backgroundColor: AppColors.secondaryBackground.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${(percentageSpent * 100).toStringAsFixed(1)}% Terpakai',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: progressColor.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}