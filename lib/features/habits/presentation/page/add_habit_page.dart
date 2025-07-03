// lib/features/habits/presentation/pages/add_habit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart';

import '../../domain/entities/habit_entity.dart';
import '../../data/providers/habit_providers.dart'; // Import providers habit

class AddHabitPage extends ConsumerStatefulWidget {
  final HabitEntity? editingHabit; // Untuk mode edit
  const AddHabitPage({super.key, this.editingHabit});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController(); // Untuk targetValue
  final TextEditingController _unitController = TextEditingController(); // Untuk unit

  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  List<int> _selectedDays = []; // 1=Senin, ..., 7=Minggu
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
      _targetValueController.text = '1'; // Default value for new habit
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

  // Helper untuk TextFormField yang konsisten (dari AddTransactionPage)
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLines = 1,
    void Function(String)? onChanged, // Added for amount formatting
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
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFrequency == HabitFrequency.custom && _selectedDays.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih setidaknya satu hari untuk kebiasaan kustom.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final habitNotifier = ref.read(habitNotifierProvider.notifier);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id; // Bisa null untuk anonim

    // Validasi tambahan jika user_id di DB NOT NULL, tapi kita set nullable
    // Jika userId di DB NOT NULL, maka baris ini harus diaktifkan:
    /*
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda harus login untuk menyimpan kebiasaan.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
        );
      }
      return;
    }
    */

    // Menggabungkan tanggal hari ini dengan waktu pengingat yang dipilih
    // Supabase TIME WITH TIME ZONE hanya menyimpan jam dan menit.
    // Kita mengirimkan DateTime penuh, tapi di Supabase kita hanya perlu mengekstrak jam/menit.
    DateTime? fullReminderDateTime;
    if (_selectedReminderTime != null) {
      final now = DateTime.now();
      fullReminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedReminderTime!.hour,
        _selectedReminderTime!.minute,
      );
    }

    final int targetValue = int.tryParse(_targetValueController.text) ?? 1;

    final habitToSave = HabitEntity(
      id: widget.editingHabit?.id ?? '',
      userId: currentUserId, // Bisa null jika tanpa login
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      frequency: _selectedFrequency,
      daysOfWeek: _selectedFrequency == HabitFrequency.custom ? _selectedDays.toSet().toList() : [], // toSet().toList() untuk menghilangkan duplikat dan menjaga urutan
      targetValue: targetValue,
      unit: _unitController.text.isEmpty ? null : _unitController.text,
      reminderTime: fullReminderDateTime,
      createdAt: widget.editingHabit?.createdAt ?? DateTime.now(), // Gunakan createdAt yang sudah ada atau yang baru
      isArchived: widget.editingHabit?.isArchived ?? false,
    );

    try {
      if (widget.editingHabit == null) {
        await habitNotifier.addHabit(habitToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kebiasaan berhasil ditambahkan!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
          );
        }
      } else {
        await habitNotifier.updateHabit(habitToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kebiasaan berhasil diperbarui!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.accentGreen),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context); // Kembali ke halaman sebelumnya (HabitsHubPage)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan kebiasaan: ${e.toString().split(':')[0]}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitActionState = ref.watch(habitNotifierProvider);

    return AppScaffold(
      const SizedBox(height: 5),
      title: widget.editingHabit == null ? 'Tambah Kebiasaan Baru' : 'Edit Kebiasaan',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.editingHabit == null ? 'Buat Kebiasaan Baru' : 'Perbarui Kebiasaan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Nama Kebiasaan (ex: Minum air, Olahraga)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kebiasaan tidak boleh kosong';
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

                // Target Value dan Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextFormField(
                        controller: _targetValueController,
                        labelText: 'Target (ex: 8, 30)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Target tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Masukkan angka > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: _buildTextFormField(
                        controller: _unitController,
                        labelText: 'Satuan (ex: gelas, menit)',
                        validator: (value) {
                          if (_targetValueController.text != '1' && (value == null || value.isEmpty)) {
                            return 'Satuan wajib jika target > 1';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Pemilih Frekuensi
                Text(
                  'Frekuensi',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  linearGradientColors: [
                    AppColors.glassBackgroundStart.withOpacity(0.1),
                    AppColors.glassBackgroundEnd.withOpacity(0.05),
                  ],
                  customBorder: Border.all(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
                  child: Column(
                    children: [
                      _buildFrequencyRadio(HabitFrequency.daily, 'Setiap Hari'),
                      _buildFrequencyRadio(HabitFrequency.weekly, 'Setiap Minggu (Terserah Hari)'),
                      _buildFrequencyRadio(HabitFrequency.custom, 'Hari Tertentu'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Pemilih Hari (hanya jika frequency custom)
                if (_selectedFrequency == HabitFrequency.custom) ...[
                  Text(
                    'Pilih Hari',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    linearGradientColors: [
                      AppColors.glassBackgroundStart.withOpacity(0.1),
                      AppColors.glassBackgroundEnd.withOpacity(0.05),
                    ],
                    customBorder: Border.all(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0, // Spasi antar baris chip
                      children: List.generate(7, (index) {
                        final dayIndex = (index + 1); // 1=Senin, ..., 7=Minggu
                        final dayName = DateFormat.E('id_ID').format(DateTime(2023, 1, 2).add(Duration(days: index))); // Senin 2 Jan 2023
                        final isSelected = _selectedDays.contains(dayIndex);
                        return ChoiceChip(
                          label: Text(dayName, style: TextStyle(color: isSelected ? AppColors.primaryText : AppColors.secondaryText)),
                          selected: isSelected,
                          selectedColor: AppColors.accentBlue.withOpacity(0.7),
                          backgroundColor: AppColors.secondaryBackground.withOpacity(0.3),
                          side: BorderSide(color: AppColors.tertiaryText.withOpacity(0.5)),
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
                  ),
                  const SizedBox(height: 15),
                ],

                // Pemilih Waktu Pengingat
                Text(
                  'Waktu Pengingat (Opsional)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
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
                    if (picked != null && picked != _selectedReminderTime) {
                      setState(() {
                        _selectedReminderTime = picked;
                      });
                    }
                  },
                  child: GlassContainer(
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    linearGradientColors: [
                      AppColors.glassBackgroundStart.withOpacity(0.1),
                      AppColors.glassBackgroundEnd.withOpacity(0.05),
                    ],
                    customBorder: Border.all(color: AppColors.tertiaryText.withOpacity(0.5), width: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedReminderTime == null
                              ? 'Pilih Waktu'
                              : _selectedReminderTime!.format(context),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                        ),
                        Icon(Icons.access_time_rounded, color: AppColors.secondaryText),
                      ],
                    ),
                  ),
                ),
                if (_selectedReminderTime != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedReminderTime = null;
                        });
                      },
                      child: Text('Hapus Waktu', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                    ),
                  ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: habitActionState.isLoading ? null : () => Navigator.pop(context),
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
                        onPressed: habitActionState.isLoading ? null : _saveHabit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: AppColors.primaryText.withOpacity(0.2)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: habitActionState.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryText,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.editingHabit == null ? 'Tambah Kebiasaan' : 'Simpan Perubahan',
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
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
  }

  // Widget _buildFrequencyRadio
  Widget _buildFrequencyRadio(HabitFrequency frequency, String label) {
    final bool isSelected = _selectedFrequency == frequency;
    return RadioListTile<HabitFrequency>(
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText)),
      value: frequency,
      groupValue: _selectedFrequency,
      onChanged: (HabitFrequency? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFrequency = newValue;
          });
        }
      },
      activeColor: AppColors.accentPurple, // Warna aktif radio button
      contentPadding: EdgeInsets.zero,
      dense: true,
      tileColor: isSelected ? AppColors.accentPurple.withOpacity(0.05) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bentuk tile radio
    );
  }
}