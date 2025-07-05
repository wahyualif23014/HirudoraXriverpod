// lib/features/habits/data/datasources/habit_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';

abstract class HabitRemoteDataSource {
  Stream<List<HabitModel>> getHabitsStream({String? userId});
  Future<List<HabitModel>> getHabits({String? userId});
  Future<HabitModel> addHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String habitId); 

  Stream<List<HabitCompletionModel>> getHabitCompletionsStream({String? userId, String? habitId});
  Future<List<HabitCompletionModel>> getHabitCompletions({String? userId, String? habitId});
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion);
  Future<HabitCompletionModel> updateHabitCompletion(HabitCompletionModel completion);
  Future<void> deleteHabitCompletion(String completionId);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final SupabaseClient supabaseClient;

  HabitRemoteDataSourceImpl(this.supabaseClient);

  // Helper untuk menangani error
  Future<T> _handleError<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      print(e);
      // Lempar exception yang lebih umum atau spesifik domain
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Implementasi Metode Habits ---

  @override
  Stream<List<HabitModel>> getHabitsStream({String? userId}) {
    final streamBuilder = supabaseClient.from('habits').stream(primaryKey: ['id']);
    
    if (userId != null) {
      streamBuilder.eq('user_id', userId);
    }

    return streamBuilder
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => HabitModel.fromJson(json)).toList());
  }

  @override
  Future<List<HabitModel>> getHabits({String? userId}) => _handleError(() async {
    var query = supabaseClient.from('habits').select('*');
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final data = await query.order('created_at', ascending: false);
    return data.map((json) => HabitModel.fromJson(json)).toList();
  });

  @override
  Future<HabitModel> addHabit(HabitModel habit) => _handleError(() async {
    final data = await supabaseClient.from('habits').insert(habit.toJson()).select().single();
    return HabitModel.fromJson(data);
  });

  @override
  Future<HabitModel> updateHabit(HabitModel habit) => _handleError(() async {
    final data = await supabaseClient.from('habits').update(habit.toJson()).eq('id', habit.id).select().single();
    return HabitModel.fromJson(data);
  });

  @override
  Future<void> deleteHabit(String habitId) => _handleError(() async {
    await supabaseClient.from('habits').delete().eq('id', habitId);
  });

  // --- Implementasi Metode Habit Completions ---

  @override
  Stream<List<HabitCompletionModel>> getHabitCompletionsStream({String? userId, String? habitId}) {
    final streamBuilder = supabaseClient.from('habit_completions').stream(primaryKey: ['id']);

    if (userId != null) {
      streamBuilder.eq('user_id', userId);
    }
    if (habitId != null) {
      streamBuilder.eq('habit_id', habitId);
    }
    
    return streamBuilder
        .order('completion_date', ascending: false)
        .map((data) => data.map((json) => HabitCompletionModel.fromJson(json)).toList());
  }

  @override
  Future<List<HabitCompletionModel>> getHabitCompletions({String? userId, String? habitId}) => _handleError(() async {
    var query = supabaseClient.from('habit_completions').select('*');
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (habitId != null) {
      query = query.eq('habit_id', habitId);
    }
    final data = await query.order('completion_date', ascending: false);
    return data.map((json) => HabitCompletionModel.fromJson(json)).toList();
  });

  @override
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion) => _handleError(() async {
    final data = await supabaseClient.from('habit_completions').insert(completion.toJson()).select().single();
    return HabitCompletionModel.fromJson(data);
  });

  @override
  Future<HabitCompletionModel> updateHabitCompletion(HabitCompletionModel completion) => _handleError(() async {
    final data = await supabaseClient.from('habit_completions').update(completion.toJson()).eq('id', completion.id).select().single();
    return HabitCompletionModel.fromJson(data);
  });

  @override
  Future<void> deleteHabitCompletion(String completionId) => _handleError(() async {
    await supabaseClient.from('habit_completions').delete().eq('id', completionId);
  });
}