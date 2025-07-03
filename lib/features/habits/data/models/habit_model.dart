// lib/features/habits/data/models/habit_model.dart
import '../../domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  const HabitModel({
    super.id,
    super.userId, 
    required super.name,
    super.description,
    super.frequency,
    super.daysOfWeek,
    super.targetValue,
    super.unit,
    super.reminderTime,
    required super.createdAt,
    super.isArchived,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == json['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      daysOfWeek: List<int>.from(json['days_of_week'] as List? ?? []),
      targetValue: json['target_value'] as int? ?? 1,
      unit: json['unit'] as String?,
      reminderTime: json['reminder_time'] != null ? DateTime.parse(json['reminder_time'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId, 
      name: entity.name,
      description: entity.description,
      frequency: entity.frequency,
      daysOfWeek: entity.daysOfWeek,
      targetValue: entity.targetValue,
      unit: entity.unit,
      reminderTime: entity.reminderTime,
      createdAt: entity.createdAt,
      isArchived: entity.isArchived,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'user_id': userId, 
      'name': name,
      'description': description,
      'frequency': frequency.toString().split('.').last,
      'days_of_week': daysOfWeek,
      'target_value': targetValue,
      'unit': unit,
      'reminder_time': reminderTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived,
    };
  }

  @override
  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId, 
      name: name,
      description: description,
      frequency: frequency,
      daysOfWeek: daysOfWeek,
      targetValue: targetValue,
      unit: unit,
      reminderTime: reminderTime,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }
}

class HabitCompletionModel extends HabitCompletionEntity {
  const HabitCompletionModel({
    super.id,
    required super.habitId,
    super.userId,
    required super.completionDate,
    super.actualValue,
    required super.completedAt,
  });

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String?, 
      completionDate: DateTime.parse(json['completion_date'] as String),
      actualValue: json['actual_value'] as int? ?? 1,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  factory HabitCompletionModel.fromEntity(HabitCompletionEntity entity) {
    return HabitCompletionModel(
      id: entity.id,
      habitId: entity.habitId,
      userId: entity.userId, 
      completionDate: entity.completionDate,
      actualValue: entity.actualValue,
      completedAt: entity.completedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'habit_id': habitId,
      'user_id': userId,
      'completion_date': completionDate.toIso8601String().split('T').first,
      'actual_value': actualValue,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  @override
  HabitCompletionEntity toEntity() {
    return HabitCompletionEntity(
      id: id,
      habitId: habitId,
      userId: userId, 
      completionDate: completionDate,
      actualValue: actualValue,
      completedAt: completedAt,
    );
  }
}