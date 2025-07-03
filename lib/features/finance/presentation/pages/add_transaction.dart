// lib/features/finance/presentation/pages/add_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';

import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/budget_entity.dart';
import '../../data/providers/finance_providers.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final TransactionEntity? editingTransaction;
  const AddTransactionPage({super.key, this.editingTransaction});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedType;
  BudgetEntity? _selectedBudget;

  @override
  void initState() {
    super.initState();
    if (widget.editingTransaction != null) {
      _amountController.text = NumberFormat.decimalPattern('id_ID').format(widget.editingTransaction!.amount);
      _descriptionController.text = widget.editingTransaction!.description ?? '';
      _categoryController.text = widget.editingTransaction!.category;
      _selectedDate = widget.editingTransaction!.date;
      _selectedType = widget.editingTransaction!.type;

      // Delayed setState to ensure budgetsStreamProvider has loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final budgetsData = ref.read(budgetsStreamProvider).value;
        if (budgetsData != null) {
          final BudgetEntity? foundBudget = budgetsData.firstWhereOrNull((b) => b.id == widget.editingTransaction!.budgetId);
          if (foundBudget != null) {
            setState(() {
              _selectedBudget = foundBudget;
            });
          }
        }
      });
    } else {
      _selectedDate = DateTime.now();
      _selectedType = 'expense';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLines = 1,
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
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
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
      onChanged: (value) {
        if (keyboardType == TextInputType.number) {
          final cleanValue = value.replaceAll('.', '');
          if (cleanValue.isNotEmpty) {
            try {
              final double parsed = double.parse(cleanValue);
              final formatted = NumberFormat.decimalPattern('id_ID').format(parsed);
              controller.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            } catch (_) {
            }
          } else {
            controller.value = TextEditingValue.empty;
          }
        }
        onChanged?.call(value);
      },
      maxLines: maxLines,
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true,
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
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
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

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tanggal transaksi tidak boleh kosong', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
              backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (_selectedType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tipe transaksi (Pemasukan/Pengeluaran) tidak boleh kosong', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
              backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (_selectedType == 'expense' && _selectedBudget == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Untuk pengeluaran, Anda harus memilih anggaran.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
              backgroundColor: AppColors.error),
        );
      }
      return;
    }
    
    final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
    final double amount = NumberFormat.decimalPattern('id_ID').parse(_amountController.text).toDouble();

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    final transactionToSave = TransactionEntity(
      id: widget.editingTransaction?.id ?? '',
      userId: currentUserId,
      amount: amount,
      type: _selectedType!,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      category: _categoryController.text,
      date: _selectedDate!,
      budgetId: _selectedType == 'expense' && _selectedBudget != null ? _selectedBudget!.id : null,
      createdAt: widget.editingTransaction?.createdAt,
    );

    try {
      if (widget.editingTransaction == null) {
        await transactionNotifier.addTransaction(transactionToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Transaksi berhasil ditambahkan!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                backgroundColor: AppColors.accentGreen),
          );
        }
      } else {
        await transactionNotifier.updateTransaction(transactionToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Transaksi berhasil diperbarui!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
                backgroundColor: AppColors.accentGreen),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan transaksi: ${e.toString().split(':')[0]}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsyncValue = ref.watch(budgetsStreamProvider);
    final transactionActionState = ref.watch(transactionNotifierProvider);

    if (widget.editingTransaction == null && _selectedType == null) {
      _selectedType = 'expense';
    }

    return AppScaffold(
      const SizedBox(height: 10),
      title: widget.editingTransaction == null ? 'Tambah Transaksi Baru' : 'Edit Transaksi',
      body: LayoutBuilder( 
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48, 
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.editingTransaction != null) 
                        Text(
                          'Perbarui Transaksi',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
                        ),
                      const SizedBox(height: 60), 

                      Text(
                        'Tipe Transaksi',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        borderRadius: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        blur: 5, 
                        opacity: 0.1, 
                        linearGradientColors: [
                          AppColors.glassBackgroundStart.withOpacity(0.1),
                          AppColors.glassBackgroundEnd.withOpacity(0.05),
                        ],
                        customBorder: Border.all(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTypeChip(context, 'Pemasukan', 'income', Icons.arrow_downward),
                            const SizedBox(width: 8),
                            _buildTypeChip(context, 'Pengeluaran', 'expense', Icons.arrow_upward),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextFormField(
                        controller: _amountController,
                        labelText: 'Jumlah (Rp)',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          try {
                            final parsed = NumberFormat.decimalPattern('id_ID').parse(value);
                            if (parsed <= 0) {
                              return 'Jumlah harus lebih dari 0';
                            }
                          } catch (_) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildTextFormField(
                        controller: _descriptionController,
                        labelText: 'Deskripsi (Opsional)',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 15),

                      _buildTextFormField(
                        controller: _categoryController,
                        labelText: 'Kategori (ex: Gaji, Belanja, Transportasi)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kategori tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildDatePickerField(
                        context: context,
                        label: 'Tanggal Transaksi',
                        selectedDate: _selectedDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
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
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      if (_selectedType == 'expense') ...[
                        budgetsAsyncValue.when(
                          data: (budgets) {
                            final now = DateTime.now();
                            final activeBudgets = budgets.where((b) {
                              final bool isCurrentlyActive = (b.startDate.isBefore(now) || b.startDate.isAtSameMomentAs(now)) &&
                                  (b.endDate.isAfter(now) || b.endDate.isAtSameMomentAs(now));
                              final bool isEditingTransactionBudget = widget.editingTransaction != null && b.id == widget.editingTransaction!.budgetId;
                              return isCurrentlyActive || isEditingTransactionBudget;
                            }).toList();

                            activeBudgets.sort((a, b) => a.name.compareTo(b.name));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Anggaran',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<BudgetEntity>(
                                  value: _selectedBudget,
                                  decoration: InputDecoration(
                                    labelText: 'Pilih Anggaran',
                                    labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.secondaryBackground.withOpacity(0.3),
                                  ),
                                  dropdownColor: AppColors.secondaryBackground.withOpacity(0.9),
                                  style: const TextStyle(color: AppColors.primaryText),
                                  items: [
                                    const DropdownMenuItem<BudgetEntity>(
                                      value: null,
                                      child: Text('Tidak ada anggaran terkait', style: TextStyle(color: AppColors.primaryText)),
                                    ),
                                    ...activeBudgets.map((budget) {
                                      return DropdownMenuItem<BudgetEntity>(
                                        value: budget,
                                        child: Text(
                                          '${budget.name} (Sisa: Rp${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(budget.allocatedAmount - budget.spentAmount)})',
                                          style: const TextStyle(color: AppColors.primaryText),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (BudgetEntity? newValue) {
                                    setState(() {
                                      _selectedBudget = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (_selectedType == 'expense' && value == null) {
                                      return 'Anggaran harus dipilih untuk pengeluaran.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                              ],
                            );
                          },
                          loading: () => Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                          error: (error, stack) => Text('Gagal memuat anggaran: ${error.toString().split(':')[0]}', style: TextStyle(color: AppColors.error)),
                        ),
                      ],

                      const Spacer(), // Dorong tombol ke bawah

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0), // Padding vertikal untuk tombol
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: transactionActionState.isLoading ? null : () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryBackground.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(color: AppColors.primaryText.withOpacity(0.2)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text('Batal', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: transactionActionState.isLoading ? null : _saveTransaction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentBlue.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(color: AppColors.primaryText.withOpacity(0.2)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: transactionActionState.isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryText,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        widget.editingTransaction == null ? 'Tambah Transaksi' : 'Simpan Perubahan',
                                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String label, String type, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == 'income') {
              _selectedBudget = null;
            }
          });
        },
        child: GlassContainer(
          borderRadius: 10,
          padding: const EdgeInsets.symmetric(vertical: 12),
          blur: 5,
          opacity: 0.1,
          linearGradientColors: isSelected
              ? [
                  AppColors.accentBlue.withOpacity(0.3),
                  AppColors.accentBlue.withOpacity(0.1),
                ]
              : [
                  AppColors.glassBackgroundStart.withOpacity(0.1),
                  AppColors.glassBackgroundEnd.withOpacity(0.05),
                ],
          customBorder: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.tertiaryText.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.accentBlue : AppColors.secondaryText),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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