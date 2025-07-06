// lib/features/activities/presentation/pages/add_activity_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/activity_entity.dart'; // <- Pastikan import entity


import '../../../../core/widgets/app_scaffold.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';
import './activity_list_notifier.dart';

class AddActivityPage extends ConsumerStatefulWidget {
  // <-- PERUBAHAN 1: Tambahkan properti untuk menampung data yang akan diedit
  final ActivityEntity? editingActivity;

  const AddActivityPage({
    super.key,
    this.editingActivity, // Jadikan opsional di constructor
  });


  @override
  ConsumerState<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends ConsumerState<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDueDate;
  int _selectedPriority = 3; // Default Low
  List<String> _selectedTags = [];

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];
  final List<String> _tagOptions = ['Work', 'Personal', 'Study', 'Health', 'Shopping'];

  // <-- PERUBAHAN 2: Tambahkan getter untuk mempermudah pengecekan mode edit
  bool get isEditing => widget.editingActivity != null;

  @override
  void initState() {
    super.initState();
    // <-- PERUBAHAN 3: Jika ini mode edit, isi semua field dengan data yang ada
    if (isEditing) {
      final activity = widget.editingActivity!;
      _titleController.text = activity.title;
      _descriptionController.text = activity.description;
      _selectedDueDate = activity.dueDate;
      _selectedPriority = activity.priority;
      _selectedTags = List.from(activity.tags); // Buat salinan agar tidak memodifikasi state asli
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // <-- PERUBAHAN 4: Ubah nama fungsi menjadi _saveActivity untuk menangani kedua kasus
  void _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final activityNotifier = ref.read(activityListNotifierProvider.notifier);
    try {
      if (isEditing) {
        // --- LOGIKA UNTUK UPDATE ---
        final updatedActivity = widget.editingActivity!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          tags: _selectedTags,
          dueDate: _selectedDueDate,
        );
        // Panggil fungsi update dari notifier (yang akan kita pastikan ada)
        await activityNotifier.updateActivity(updatedActivity);
        
      } else {
        // --- LOGIKA UNTUK ADD (TETAP SAMA) ---
        await activityNotifier.addActivity(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          tags: _selectedTags,
          dueDate: _selectedDueDate,
        );
      }

      if (mounted) {
        // Pesan dinamis sesuai mode
        final message = isEditing ? 'Aktivitas berhasil diperbarui!' : 'Aktivitas berhasil ditambahkan!';
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.accentGreen));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      const SizedBox(height: 5),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primaryBackground.withOpacity(0.85),
                  centerTitle: true,
                  // <-- PERUBAHAN 5: Judul dinamis sesuai mode
                  title: Text(
                    isEditing ? 'Edit Aktivitas' : 'Aktivitas Baru',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
                    onPressed: () => context.pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tidak ada perubahan di dalam form, semua helper widget tetap sama
                          _buildTextField(
                            controller: _titleController,
                            labelText: 'Judul Aktivitas',
                            validator: (v) => (v == null || v.isEmpty) ? 'Judul tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _descriptionController,
                            labelText: 'Deskripsi (Opsional)',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          Text('Detail', style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 12),
                          _buildDatePickerField(context),
                          const SizedBox(height: 20),
                          _buildPriorityDropdown(),
                          const SizedBox(height: 24),
                          Text('Tags (Opsional)', style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 12),
                          _buildTagsSelection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Panggil helper untuk tombol
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(top: BorderSide(color: AppColors.tertiaryText.withOpacity(0.2), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          // <-- PERUBAHAN 6: Panggil fungsi _saveActivity yang sudah pintar
          onPressed: _saveActivity,
          icon: const Icon(Icons.check_rounded, color: Colors.white),
          // <-- PERUBAHAN 7: Teks tombol dinamis
          label: Text(
            isEditing ? 'Simpan Perubahan' : 'Simpan Aktivitas',
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentOrange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // --- Semua helper widget di bawah ini tidak perlu diubah ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.secondaryBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.accentOrange, width: 2)),
      ),
      validator: validator,
    );
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
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentOrange,
              onPrimary: AppColors.primaryText,
              surface: AppColors.secondaryBackground,
              onSurface: AppColors.primaryText,
            ),
            dialogBackgroundColor: AppColors.primaryBackground,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDueDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.secondaryBackground,
          labelText: 'Tanggal Jatuh Tempo',
          labelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondaryText),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.accentOrange, width: 2)),
          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.tertiaryText),
        ),
        child: Text(
          _selectedDueDate == null ? 'Tidak diatur' : DateFormat('dd MMMM yyyy').format(_selectedDueDate!),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Prioritas',
        filled: true,
        fillColor: AppColors.secondaryBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.accentOrange, width: 2)),
      ),
      dropdownColor: AppColors.secondaryBackground,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
      items: _priorityOptions.map((String value) {
        return DropdownMenuItem<int>(
          value: _priorityOptions.indexOf(value) + 1,
          child: Text(value),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedPriority = newValue!;
        });
      },
    );
  }

  Widget _buildTagsSelection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _tagOptions.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (bool selected) {
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
          labelStyle: TextStyle(color: isSelected ? AppColors.primaryText : AppColors.secondaryText, fontWeight: FontWeight.w500),
          checkmarkColor: AppColors.primaryText,
          side: BorderSide(color: isSelected ? AppColors.accentOrange : AppColors.tertiaryText.withOpacity(0.3)),
        );
      }).toList(),
    );
  }
}