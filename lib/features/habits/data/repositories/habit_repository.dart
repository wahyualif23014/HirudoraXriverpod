// lib/features/habits/domain/repositories/habit_repository.dart
import '../../domain/entities/habit_entity.dart'; // Import kedua entitas

abstract class HabitRepository {
  // Metode untuk Habits
  Stream<List<HabitEntity>> getHabitsStream({String? userId});
  Future<List<HabitEntity>> getHabits({String? userId});
  Future<HabitEntity> addHabit(HabitEntity habit);
  Future<HabitEntity> updateHabit(HabitEntity habit);
  Future<void> deleteHabit(String habitId);

  // Metode untuk Habit Completions
  Stream<List<HabitCompletionEntity>> getHabitCompletionsStream({String? userId, String? habitId});
  Future<List<HabitCompletionEntity>> getHabitCompletions({String? userId, String? habitId});
  Future<HabitCompletionEntity> addHabitCompletion(HabitCompletionEntity completion);
  Future<HabitCompletionEntity> updateHabitCompletion(HabitCompletionEntity completion);
  Future<void> deleteHabitCompletion(String completionId);
}