// lib/features/habits/data/repositories/habit_repository_impl.dart
import 'package:hirudorax/features/habits/data/repositories/habit_repository.dart';

import '../../domain/repositories/habits_repository.dart';
import '../../domain/entities/habit_entity.dart';
import '../../data/datasource/habit_remote_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl(this.remoteDataSource);

  // --- Implementasi Metode Habits ---

  @override
  Stream<List<HabitEntity>> getHabitsStream({String? userId}) {
    return remoteDataSource.getHabitsStream(userId: userId).map(
        (models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<HabitEntity>> getHabits({String? userId}) async {
    final models = await remoteDataSource.getHabits(userId: userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HabitEntity> addHabit(HabitEntity habit) async {
    final model = HabitModel.fromEntity(habit);
    final newModel = await remoteDataSource.addHabit(model);
    return newModel.toEntity();
  }

  @override
  Future<HabitEntity> updateHabit(HabitEntity habit) async {
    final model = HabitModel.fromEntity(habit);
    final updatedModel = await remoteDataSource.updateHabit(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    // Logika bisnis yang menggantikan use case:
    // Saat habit dihapus, kita juga ingin menghapus semua completion terkait.
    // Ini adalah contoh bagaimana repository bisa mengorkestrasi beberapa operasi data source.
    await remoteDataSource.deleteHabitCompletionsByHabitId(habitId);
    await remoteDataSource.deleteHabit(habitId);
  }

  // --- Implementasi Metode Habit Completions ---

  @override
  Stream<List<HabitCompletionEntity>> getHabitCompletionsStream({String? userId, String? habitId}) {
    return remoteDataSource.getHabitCompletionsStream(userId: userId, habitId: habitId).map(
        (models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<HabitCompletionEntity>> getHabitCompletions({String? userId, String? habitId}) async {
    final models = await remoteDataSource.getHabitCompletions(userId: userId, habitId: habitId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HabitCompletionEntity> addHabitCompletion(HabitCompletionEntity completion) async {
    final model = HabitCompletionModel.fromEntity(completion);
    final newModel = await remoteDataSource.addHabitCompletion(model);
    return newModel.toEntity();
  }

  @override
  Future<HabitCompletionEntity> updateHabitCompletion(HabitCompletionEntity completion) async {
    final model = HabitCompletionModel.fromEntity(completion);
    final updatedModel = await remoteDataSource.updateHabitCompletion(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteHabitCompletion(String completionId) async {
    await remoteDataSource.deleteHabitCompletion(completionId);
  }
}