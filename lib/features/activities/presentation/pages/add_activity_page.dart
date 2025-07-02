// lib/features/activities/presentation/pages/add_activity_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; 

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../presentation/pages/activity_list_notifier.dart'; 

class AddActivityPage extends ConsumerStatefulWidget {
  const AddActivityPage({super.key});

  @override
  ConsumerState<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends ConsumerState<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  int _selectedPriority = 3; // Default Low
  List<String> _selectedTags = [];

  // List pilihan prioritas dan tag (bisa disesuaikan atau diambil dari provider/API)
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];
  final List<String> _tagOptions = ['Work', 'Personal', 'Study', 'Health', 'Shopping'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith( 
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentOrange, 
              onPrimary: AppColors.primaryText,
              onSurface: AppColors.primaryText,
              surface: AppColors.secondaryBackground,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryText,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Dapatkan notifier dari provider
      final activityNotifier = ref.read(activityListNotifierProvider.notifier);

      try {
        await activityNotifier.addActivity(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _selectedPriority,
          tags: _selectedTags,
          dueDate: _selectedDueDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktivitas berhasil ditambahkan!')),
          );
          context.pop(); 
        }
      } catch (e) {
        // Try cacht
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan aktivitas: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      const SizedBox(height: 15),
      title: 'Tambah Aktivitas Baru',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassContainer(
                borderRadius: 15,
                padding: const EdgeInsets.all(20),
                linearGradientColors: [
                  AppColors.secondaryBackground.withOpacity(0.2),
                  AppColors.secondaryBackground.withOpacity(0.1),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Aktivitas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      labelText: 'Judul Aktivitas',
                      hintText: 'Contoh: Rapat Harian Tim',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      labelText: 'Deskripsi (Opsional)',
                      hintText: 'Tambahkan detail aktivitas...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePickerField(context),
                    const SizedBox(height: 16),
                    _buildPriorityDropdown(),
                    const SizedBox(height: 16),
                    _buildTagsSelection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: AppColors.primaryText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Simpan Aktivitas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText
                          ),
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
    );
  }

  // --- Reusable Widget for Text Field (Consistent Theme) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: AppColors.secondaryText),
        hintStyle: TextStyle(color: AppColors.tertiaryText),
        filled: true,
        fillColor: AppColors.secondaryBackground.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentOrange.withOpacity(0.5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.7), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  // --- Reusable Widget for Date Picker Field ---
  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDueDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Jatuh Tempo (Opsional)',
          labelStyle: TextStyle(color: AppColors.secondaryText),
          filled: true,
          fillColor: AppColors.secondaryBackground.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.accentOrange.withOpacity(0.5), width: 2),
          ),
          suffixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.tertiaryText),
        ),
        child: Text(
          _selectedDueDate == null
              ? 'Pilih tanggal'
              : DateFormat('dd MMMM yyyy').format(_selectedDueDate!),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _selectedDueDate == null ? AppColors.tertiaryText : AppColors.primaryText,
          ),
        ),
      ),
    );
  }

  // --- Reusable Widget for Priority Dropdown ---
  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Prioritas',
        labelStyle: TextStyle(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.secondaryBackground.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentOrange.withOpacity(0.5), width: 2),
        ),
      ),
      dropdownColor: AppColors.secondaryBackground, // Warna dropdown 
      style: TextStyle(color: AppColors.primaryText), // Warna teks item dropdown
      items: List.generate(_priorityOptions.length, (index) {
        return DropdownMenuItem(
          value: index + 1, 
          child: Text(
            _priorityOptions[index],
            style: TextStyle(
              color: index == 0 ? Colors.redAccent : (index == 1 ? Colors.orangeAccent : Colors.lightGreen),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  // --- Reusable Widget for Tags Selection ---
  Widget _buildTagsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Opsional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _tagOptions.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.accentOrange.withOpacity(0.5),
              backgroundColor: AppColors.secondaryBackground.withOpacity(0.4),
              labelStyle: TextStyle(color: isSelected ? AppColors.primaryText : AppColors.secondaryText),
              checkmarkColor: AppColors.primaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.accentBlue.withOpacity(0.3)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}