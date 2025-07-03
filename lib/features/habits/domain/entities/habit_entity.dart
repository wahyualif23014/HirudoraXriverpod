// lib/features/habits/domain/entities/habit_entity.dart
import 'package:equatable/equatable.dart';

enum HabitFrequency {
  daily,
  weekly,
  custom,
}

enum HabitType {
  good,
  bad,
  neutral,
}

class HabitEntity extends Equatable {
  final String id;
  final String? userId; // <--- UBAH: Jadikan nullable, tidak lagi required di constructor
  final String name;
  final String? description;
  final HabitFrequency frequency;
  final List<int> daysOfWeek;
  final int targetValue;
  final String? unit;
  final DateTime? reminderTime;
  final DateTime createdAt;
  final bool isArchived;

  const HabitEntity({
    this.id = '',
    this.userId,
    required this.name,
    this.description,
    this.frequency = HabitFrequency.daily,
    this.daysOfWeek = const [],
    this.targetValue = 1,
    this.unit,
    this.reminderTime,
    required this.createdAt,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
        id, userId, name, description, frequency, daysOfWeek,
        targetValue, unit, reminderTime, createdAt, isArchived,
      ];

  HabitEntity copyWith({
    String? id, String? userId, String? name, String? description,
    HabitFrequency? frequency, List<int>? daysOfWeek, int? targetValue,
    String? unit, DateTime? reminderTime, DateTime? createdAt, bool? isArchived,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

// HabitCompletionEntity tetap sama
class HabitCompletionEntity extends Equatable {
  final String id;
  final String habitId;
  final String? userId; // <--- UBAH: Jadikan nullable juga
  final DateTime completionDate;
  final int actualValue;
  final DateTime completedAt;

  const HabitCompletionEntity({
    this.id = '',
    required this.habitId,
    this.userId, // <--- UBAH: Tidak lagi required
    required this.completionDate,
    this.actualValue = 1,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [id, habitId, userId, completionDate, actualValue, completedAt];

  HabitCompletionEntity copyWith({
    String? id, String? habitId, String? userId, DateTime? completionDate,
    int? actualValue, DateTime? completedAt,
  }) {
    return HabitCompletionEntity(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completionDate: completionDate ?? this.completionDate,
      actualValue: actualValue ?? this.actualValue,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}