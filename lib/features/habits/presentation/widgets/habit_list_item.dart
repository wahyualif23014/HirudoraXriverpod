// lib/features/habits/presentation/widgets/habit_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/widgets/glass_container.dart'; // Impor GlassContainer
import '../../../../app/themes/colors.dart';
// import '../../../../app/routes/routes.dart';
import '../../domain/entities/habit_entity.dart';
import '../../data/providers/habit_providers.dart';

class HabitListItem extends ConsumerWidget {
  final HabitEntity habit;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Callback untuk navigasi

  const HabitListItem({
    super.key,
    required this.habit,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch status completion hari ini untuk habit ini
    final isCompletedToday = ref.watch(habitIsCompletedTodayProvider(habit.id));

    // Logika untuk menentukan tampilan berdasarkan status completion (tidak berubah)
    final iconData = isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
    final iconColor = isCompletedToday ? AppColors.accentGreen : AppColors.secondaryText;
    final nameColor = isCompletedToday ? AppColors.secondaryText : AppColors.primaryText;
    final nameDecoration = isCompletedToday ? TextDecoration.lineThrough : TextDecoration.none;

    // Logika untuk menampilkan teks frekuensi (tidak berubah)
    String frequencyText;
    switch (habit.frequency) {
        case HabitFrequency.daily:
            frequencyText = 'Setiap Hari';
            break;
        case HabitFrequency.weekly:
            frequencyText = 'Setiap Minggu';
            break;
        case HabitFrequency.custom:
            if (habit.daysOfWeek.isNotEmpty) {
                final days = habit.daysOfWeek.map((dayIndex) {
                    return DateFormat.E('id_ID').format(DateTime(2023, 1, 2).add(Duration(days: dayIndex - 1)));
                }).join(', ');
                frequencyText = 'Hari: $days';
            } else {
                frequencyText = 'Hari Tertentu';
            }
            break;
    }

    return Slidable(
      key: ValueKey(habit.id),

      // --- AKSI GESER KE KANAN (START) ---
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25, // Seberapa lebar area aksi
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),

      // --- AKSI GESER KE KIRI (END) ---
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
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

      // --- KONTEN UTAMA DENGAN EFEK KACA ---
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: GlassContainer(
          borderRadius: 15,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onToggleComplete(!isCompletedToday),
                child: Container(
                  color: Colors.transparent, 
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(iconData, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(width: 12),

              // Detail Teks Kebiasaan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: nameColor,
                        fontWeight: FontWeight.bold,
                        decoration: nameDecoration,
                        decorationColor: AppColors.secondaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      frequencyText,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (habit.targetValue > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Target: ${habit.targetValue} ${habit.unit ?? ""}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentPink, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),

              // Icon 'Chevron' untuk indikasi bisa di-tap
              const Icon(Icons.chevron_right_rounded, color: AppColors.tertiaryText, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}