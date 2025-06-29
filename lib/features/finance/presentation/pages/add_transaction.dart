// lib/features/finance/presentation/pages/budget_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirudorax/features/finance/data/providers/finance_providers.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart'; // Menggunakan AppTextStyles

import '../../domain/entity/budget_entity.dart'; // Impor BudgetEntity

class AddTransaction extends ConsumerStatefulWidget { // Nama kelas sudah benar sebagai BudgetPage
  const AddTransaction({super.key});

  @override
  ConsumerState<AddTransaction> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _allocatedAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  BudgetEntity? _editingBudget;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _allocatedAmountController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan form tambah/edit budget (modal bottom sheet)
  void _showBudgetForm({BudgetEntity? budget}) {
    setState(() {
      _editingBudget = budget;
      if (budget != null) {
        _nameController.text = budget.name;
        _categoryController.text = budget.category;
        _allocatedAmountController.text = NumberFormat.decimalPattern('id_ID').format(budget.allocatedAmount); // Format angka untuk edit
        _startDate = budget.startDate;
        _endDate = budget.endDate;
      } else {
        _nameController.clear();
        _categoryController.clear();
        _allocatedAmountController.clear();
        _startDate = null;
        _endDate = null;
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
            child: SingleChildScrollView( // Tambahkan SingleChildScrollView
              padding: const EdgeInsets.all(24.0), // Padding dipindahkan ke sini
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
                    // TextFormField: Nama Anggaran
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: 'Nama Anggaran (ex: Anggaran Bulanan)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama Anggaran tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // TextFormField: Kategori
                    _buildTextFormField(
                      controller: _categoryController,
                      labelText: 'Kategori (ex: Makanan, Transportasi)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // TextFormField: Jumlah Anggaran
                    _buildTextFormField(
                      controller: _allocatedAmountController,
                      labelText: 'Jumlah Anggaran (Rp)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah anggaran tidak boleh kosong';
                        }
                        // Gunakan NumberFormat untuk parsing, lebih robust
                        try {
                          final parsed = NumberFormat.decimalPattern('id_ID').parse(value);
                          if (parsed <= 0) {
                            return 'Masukkan jumlah yang valid (lebih dari 0)';
                          }
                        } catch (_) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Input Tanggal Mulai
                    _buildDatePickerField(
                      context,
                      label: 'Tanggal Mulai',
                      selectedDate: _startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme( // Menggunakan Theme untuk DatePicker
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.accentBlue, // Warna header DatePicker
                                  onPrimary: AppColors.primaryText, // Warna teks di header
                                  surface: AppColors.secondaryBackground, // Warna background DatePicker
                                  onSurface: AppColors.primaryText, // Warna teks di DatePicker
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue, // Warna tombol (OK, Cancel)
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    // Input Tanggal Akhir
                    _buildDatePickerField(
                      context,
                      label: 'Tanggal Akhir',
                      selectedDate: _endDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2000), // Tidak boleh sebelum tanggal mulai
                          lastDate: DateTime(2101),
                          builder: (context, child) { // Menggunakan Theme untuk DatePicker
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.accentBlue,
                                  onPrimary: AppColors.primaryText,
                                  surface: AppColors.secondaryBackground,
                                  onSurface: AppColors.primaryText,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
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
                                // Validasi tambahan untuk tanggal
                                if (_startDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tanggal Mulai tidak boleh kosong', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                if (_endDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tanggal Akhir tidak boleh kosong', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                if (_endDate!.isBefore(_startDate!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tanggal Akhir tidak boleh sebelum Tanggal Mulai', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
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

  // Helper widget baru untuk TextFormField yang konsisten
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.secondaryBackground.withOpacity(0.3),
      ),
      validator: validator,
    );
  }

  // Helper widget untuk input tanggal
  Widget _buildDatePickerField(
    BuildContext context, {
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true, // Tidak bisa diketik langsung
      controller: TextEditingController(
        text: selectedDate == null ? '' : DateFormat('dd/MM/yyyy').format(selectedDate),
      ),
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.secondaryBackground.withOpacity(0.3),
      ),
      onTap: onTap,
      validator: (value) {
        if (selectedDate == null) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }


  // Fungsi untuk menyimpan budget (tambah atau update)
  void _saveBudget() async {
    final budgetNotifier = ref.read(budgetNotifierProvider.notifier);
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tanggal mulai dan akhir harus dipilih.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
      );
      return;
    }

    final BudgetEntity budgetToSave;
    if (_editingBudget == null) {
      budgetToSave = BudgetEntity(
        name: _nameController.text,
        category: _categoryController.text,
        allocatedAmount: NumberFormat.decimalPattern('id_ID').parse(_allocatedAmountController.text).toDouble(), // Parse dengan NumberFormat
        startDate: _startDate!,
        endDate: _endDate!,
        spentAmount: 0.0, // Default untuk budget baru
      );
      await budgetNotifier.addBudget(budgetToSave);
    } else {
      budgetToSave = _editingBudget!.copyWith(
        name: _nameController.text,
        category: _categoryController.text,
        allocatedAmount: NumberFormat.decimalPattern('id_ID').parse(_allocatedAmountController.text).toDouble(), // Parse dengan NumberFormat
        startDate: _startDate,
        endDate: _endDate,
        // spentAmount tidak diubah dari UI di sini, akan diubah oleh transaksi
      );
      await budgetNotifier.updateBudget(budgetToSave);
    }

    if (mounted) {
      final budgetActionState = ref.read(budgetNotifierProvider);
      budgetActionState.when(
        data: (_) {
          Navigator.pop(context); // Tutup bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingBudget == null ? 'Anggaran berhasil ditambahkan!' : 'Anggaran berhasil diperbarui!',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
              ),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        },
        loading: () { },
        error: (error, stack) {
          Navigator.pop(context); // Tutup bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan anggaran: ${error.toString().split(':')[0]}',
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
              await budgetNotifier.deleteBudget(id);
              if (mounted) {
                final budgetActionState = ref.read(budgetNotifierProvider);
                budgetActionState.when(
                  data: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Anggaran berhasil dihapus!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                    Navigator.pop(context); // Tutup dialog
                  },
                  loading: () {},
                  error: (error, stack) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus anggaran: ${error.toString().split(':')[0]}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    Navigator.pop(context); // Tutup dialog
                  },
                );
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

            // --- Daftar Kategori Anggaran (Real-time dari Supabase) ---
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _BudgetCategoryItem(
                          budget: budget,
                          onEdit: () => _showBudgetForm(budget: budget),
                          onDelete: () => _deleteBudget(budget.id),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                error: (error, stack) => Center(
                  child: Text(
                    'Gagal memuat anggaran: ${error.toString().split(':')[0]}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: budgetActionState.isLoading ? null : () => _showBudgetForm(),
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
          final double totalAllocated = budgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
          final double totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
          final double remaining = totalAllocated - totalSpent;
          final double percentageUsed = totalAllocated > 0 ? (totalSpent / totalAllocated).clamp(0.0, 1.0) : 0.0;
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
              _buildSummaryRow('Total Anggaran', totalAllocated, AppColors.accentBlue),
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
        error: (error, stack) => Center(child: Text('Gagal memuat ringkasan: ${error.toString().split(':')[0]}', style: TextStyle(color: AppColors.error))),
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
    final double percentageSpent = budget.allocatedAmount > 0 ? (budget.spentAmount / budget.allocatedAmount).clamp(0.0, 1.0) : 0.0;
    Color progressColor = AppColors.accentGreen;
    if (percentageSpent > 0.8) {
      progressColor = AppColors.error;
    } else if (percentageSpent > 0.5) {
      progressColor = AppColors.accentOrange;
    }

    final dateFormat = DateFormat('dd MMM yyyy'); // Menambahkan tahun ke format
    final String formattedStartDate = dateFormat.format(budget.startDate);
    final String formattedEndDate = dateFormat.format(budget.endDate);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name, // Menggunakan properti 'name'
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Kategori: ${budget.category}', // Menampilkan kategori
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                    ),
                    Text(
                      'Periode: $formattedStartDate - $formattedEndDate', // Menampilkan periode
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                    ),
                  ],
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
            'Dialokasikan: Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(budget.allocatedAmount)}', // Menggunakan allocatedAmount
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            'Terpakai: Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(budget.spentAmount)}', // Menggunakan spentAmount
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