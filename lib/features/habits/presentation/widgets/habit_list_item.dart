// lib/features/habits/presentation/widgets/habit_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/app/routes/routes.dart';
import 'package:intl/intl.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/app_theme.dart'; // Untuk AppTextStyles
import '../../domain/entities/habit_entity.dart'; // Import HabitEntity
import '../../data/providers/habit_providers.dart'; // Untuk habitIsCompletedTodayProvider

class HabitListItem extends ConsumerWidget {
  final HabitEntity habit;
  final ValueChanged<bool> onToggleComplete; // Callback saat status selesai diubah
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitListItem({
    super.key,
    required this.habit,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch status completion hari ini untuk habit ini
    final isCompletedToday = ref.watch(habitIsCompletedTodayProvider(habit.id));

    // Icon dan warna berdasarkan status completion
    IconData iconData = isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
    Color iconColor = isCompletedToday ? AppColors.accentGreen : AppColors.secondaryText;
    Color nameColor = isCompletedToday ? AppColors.secondaryText : AppColors.primaryText;
    TextDecoration nameDecoration = isCompletedToday ? TextDecoration.lineThrough : TextDecoration.none;


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
          // Mengonversi angka hari menjadi nama hari
          final days = habit.daysOfWeek.map((dayIndex) {
            // DateTime(2023, 1, 2) adalah Senin, jadi index 0 = Senin, index 1 = Selasa dst.
            // DayIndex 1=Senin, jadi (dayIndex - 1)
            return DateFormat.E('id_ID').format(DateTime(2023, 1, 2).add(Duration(days: dayIndex - 1)));
          }).join(', ');
          frequencyText = 'Hari: $days';
        } else {
          frequencyText = 'Hari Tertentu';
        }
        break;
    }

    String? reminderText;
    if (habit.reminderTime != null) {
      reminderText = DateFormat.jm().format(habit.reminderTime!); // Format waktu (e.g., 5:30 PM)
    }

    return Slidable(
      key: ValueKey(habit.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: BorderRadius.circular(15),
          ),
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
      child: InkWell( // Bungkus dengan InkWell untuk efek tap
        onTap: () {
          // Navigasi ke detail kebiasaan
          context.push(AppRoutes.habitDetailPath(habit.id), extra: habit);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0), // Slidable will add horizontal margin
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
              // Checkbox / Completion Icon
              GestureDetector(
                onTap: () => onToggleComplete(!isCompletedToday), // Toggle status completion
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: nameColor,
                            fontWeight: FontWeight.bold,
                            decoration: nameDecoration,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (habit.description != null && habit.description!.isNotEmpty)
                      Text(
                        habit.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      frequencyText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.tertiaryText),
                    ),
                    if (habit.targetValue > 1) // Tampilkan target jika lebih dari 1
                      Text(
                        'Target: ${habit.targetValue} ${habit.unit ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accentPink, fontWeight: FontWeight.w500),
                      ),
                    if (reminderText != null)
                      Text(
                        'Pengingat: $reminderText',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accentBlue.withOpacity(0.8), fontWeight: FontWeight.w500),
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
}