// lib/features/habits/presentation/pages/add_habit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';

import '../../domain/entities/habit_entity.dart';
import '../../data/providers/habit_providers.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  final HabitEntity? editingHabit; 
  const AddHabitPage({super.key, this.editingHabit});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  List<int> _selectedDays = [];
  TimeOfDay? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.editingHabit != null) {
      _nameController.text = widget.editingHabit!.name;
      _descriptionController.text = widget.editingHabit!.description ?? '';
      _targetValueController.text = widget.editingHabit!.targetValue.toString();
      _unitController.text = widget.editingHabit!.unit ?? '';
      _selectedFrequency = widget.editingHabit!.frequency;
      _selectedDays = List.from(widget.editingHabit!.daysOfWeek);
      if (widget.editingHabit!.reminderTime != null) {
        _selectedReminderTime = TimeOfDay.fromDateTime(widget.editingHabit!.reminderTime!);
      }
    } else {
      _targetValueController.text = '1'; 
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }
  
  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequency == HabitFrequency.custom && _selectedDays.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih setidaknya satu hari untuk kebiasaan kustom.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final habitNotifier = ref.read(habitNotifierProvider.notifier);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    DateTime? fullReminderDateTime;
    if (_selectedReminderTime != null) {
      final now = DateTime.now();
      fullReminderDateTime = DateTime(now.year, now.month, now.day, _selectedReminderTime!.hour, _selectedReminderTime!.minute);
    }

    final int targetValue = int.tryParse(_targetValueController.text) ?? 1;
    _selectedDays.sort(); 

    final habitToSave = HabitEntity(
      id: widget.editingHabit?.id ?? '',
      userId: currentUserId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      frequency: _selectedFrequency,
      daysOfWeek: _selectedFrequency == HabitFrequency.custom ? _selectedDays.toSet().toList() : [],
      targetValue: targetValue,
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      reminderTime: fullReminderDateTime,
      createdAt: widget.editingHabit?.createdAt ?? DateTime.now(),
      isArchived: widget.editingHabit?.isArchived ?? false,
    );

    try {
      if (widget.editingHabit == null) {
        await habitNotifier.addHabit(habitToSave);
      } else {
        await habitNotifier.updateHabit(habitToSave);
      }
      if (mounted) {
        // Pop dua kali jika halaman ini dibuka dari detail
        // Ini asumsi alur: Hub -> Detail -> Edit. Setelah edit, kembali ke Hub.
        // Jika alur bisa Hub -> Edit, maka logika navigasi perlu disesuaikan.
        context.go('/habits'); // Kembali ke root habit hub untuk refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editingHabit == null ? 'Kebiasaan berhasil ditambahkan!' : 'Kebiasaan berhasil diperbarui!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString().split(':')[0]}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      const SizedBox(height: 5), // Placeholder
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 0,
                  backgroundColor: AppColors.primaryBackground.withOpacity(0.8),
                  centerTitle: true,
                  title: Text(
                    widget.editingHabit == null ? 'Kebiasaan Baru' : 'Edit Kebiasaan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                   leading: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
                    onPressed: () => context.pop(),
                    tooltip: 'Batal',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: _buildFormContent(),
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // Widget terpisah untuk konten Form
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFormField(
            controller: _nameController,
            labelText: 'Nama Kebiasaan (ex: Olahraga)',
            validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _descriptionController,
            labelText: 'Deskripsi (Opsional)',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextFormField(
                  controller: _targetValueController,
                  labelText: 'Target (ex: 8)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Wajib diisi';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Angka > 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: _buildTextFormField(
                  controller: _unitController,
                  labelText: 'Satuan (ex: gelas, menit)',
                  validator: (value) {
                    if (_targetValueController.text != '1' && (value == null || value.isEmpty)) {
                      return 'Wajib jika target > 1';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Frekuensi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          _buildFrequencySection(),
          const SizedBox(height: 24),
          if (_selectedFrequency == HabitFrequency.custom) ...[
            Text('Pilih Hari', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            _buildDaysOfWeekSection(),
            const SizedBox(height: 24),
          ],
          Text('Waktu Pengingat (Opsional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          _buildReminderSection(),
        ],
      ),
    );
  }

  // Widget terpisah untuk pilihan Frekuensi
  Widget _buildFrequencySection() {
    return GlassContainer(
      borderRadius: 15,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: HabitFrequency.values
            .map((freq) => _buildFrequencyRadio(freq, _getFrequencyLabel(freq)))
            .toList(),
      ),
    );
  }

  // Widget terpisah untuk pilihan Hari
  Widget _buildDaysOfWeekSection() {
    return GlassContainer(
      borderRadius: 15,
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(7, (index) {
          final dayIndex = (index + 1); // 1=Senin, ..., 7=Minggu
          final dayName = DateFormat.E('id_ID').format(DateTime(2023, 1, 2).add(Duration(days: index)));
          final isSelected = _selectedDays.contains(dayIndex);
          return ChoiceChip(
            label: Text(dayName),
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.primaryText, fontWeight: FontWeight.w500),
            selected: isSelected,
            selectedColor: AppColors.accentPurple,
            backgroundColor: AppColors.primaryBackground,
            side: BorderSide(color: isSelected ? AppColors.accentPurple : AppColors.tertiaryText.withOpacity(0.5)),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedDays.add(dayIndex);
                } else {
                  _selectedDays.remove(dayIndex);
                }
              });
            },
          );
        }),
      ),
    );
  }

  // Widget terpisah untuk pilihan Reminder
  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _selectedReminderTime ?? TimeOfDay.now(),
              // ... (builder tema Anda bisa diletakkan di sini)
            );
            if (picked != null) setState(() => _selectedReminderTime = picked);
          },
          child: GlassContainer(
            borderRadius: 15,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedReminderTime == null ? 'Tidak diatur' : _selectedReminderTime!.format(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.access_time_rounded, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
        if (_selectedReminderTime != null)
          TextButton(
            onPressed: () => setState(() => _selectedReminderTime = null),
            child: Text('Hapus Pengingat', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }

  // Widget terpisah untuk Tombol Aksi "Sticky"
  Widget _buildActionButtons() {
    final habitActionState = ref.watch(habitNotifierProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(top: BorderSide(color: AppColors.tertiaryText.withOpacity(0.2), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: habitActionState.isLoading ? null : _saveHabit,
          icon: habitActionState.isLoading
              ? Container()
              : const Icon(Icons.check_rounded, color: Colors.white),
          label: habitActionState.isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(
                  widget.editingHabit == null ? 'Tambah Kebiasaan' : 'Simpan Perubahan',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
  
  // Helper Widgets (tidak berubah banyak, hanya styling)
  String _getFrequencyLabel(HabitFrequency freq) {
    switch (freq) {
      case HabitFrequency.daily: return 'Setiap Hari';
      case HabitFrequency.weekly: return 'Setiap Minggu';
      case HabitFrequency.custom: return 'Hari Tertentu';
    }
  }

  Widget _buildFrequencyRadio(HabitFrequency frequency, String label) {
    return RadioListTile<HabitFrequency>(
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText)),
      value: frequency,
      groupValue: _selectedFrequency,
      onChanged: (v) => setState(() => _selectedFrequency = v!),
      activeColor: AppColors.accentPurple,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.primaryText),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
          filled: true,
          fillColor: AppColors.secondaryBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.tertiaryText.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.accentBlue, width: 2)),
        ),
        validator: validator,
        maxLines: maxLines,
      );
  }
}