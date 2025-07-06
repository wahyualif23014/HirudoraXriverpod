// lib/features/activities/presentation/widgets/activity_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../app/themes/colors.dart';
import '../../domain/entity/activity_entity.dart';

class ActivityListItem extends StatelessWidget {
  final ActivityEntity activity;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap; // <- TAMBAHKAN INI

  const ActivityListItem({
    super.key,
    required this.activity,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onTap, // <- TAMBAHKAN INI
  });

  // ... (fungsi _getPriorityColor tetap sama) ...
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return AppColors.error;
      case 2: return AppColors.accentOrange;
      case 3: return AppColors.accentGreen;
      default: return AppColors.tertiaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(activity.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.30,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: '',
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.30,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: '',
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
      child: InkWell( // <- BUNGKUS DENGAN INKWELL
        onTap: onTap, // <- GUNAKAN FUNGSI onTap
        borderRadius: BorderRadius.circular(15),
        child: GlassContainer(
          borderRadius: 15,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: activity.isCompleted,
                onChanged: (_) => onToggleComplete(),
                activeColor: AppColors.accentGreen,
                checkColor: AppColors.primaryText,
                side: BorderSide(color: AppColors.tertiaryText.withOpacity(0.8)),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                        decoration: activity.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: AppColors.tertiaryText,
                      ),
                    ),
                    if (activity.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          activity.description,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 14, color: _getPriorityColor(activity.priority)),
                          const SizedBox(width: 4),
                          if (activity.dueDate != null) ...[
                            Text(
                              DateFormat('dd MMM').format(activity.dueDate!),
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.tertiaryText),
                            ),
                            if (activity.tags.isNotEmpty)
                              const Text(' • ', style: TextStyle(color: AppColors.tertiaryText)),
                          ],
                          if(activity.tags.isNotEmpty)
                            Expanded(
                              child: Text(
                                activity.tags.join(', '),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.tertiaryText, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}