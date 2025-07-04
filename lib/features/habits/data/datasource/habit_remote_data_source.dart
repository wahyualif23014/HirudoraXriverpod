// lib/features/habits/data/datasources/habit_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart'; // Import HabitModel dan HabitCompletionModel

abstract class HabitRemoteDataSource {
  // Metode untuk Habits
  Stream<List<HabitModel>> getHabitsStream({String? userId});
  Future<List<HabitModel>> getHabits({String? userId});
  Future<HabitModel> addHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String habitId);

  // Metode untuk Habit Completions
  Stream<List<HabitCompletionModel>> getHabitCompletionsStream({String? userId, String? habitId});
  Future<List<HabitCompletionModel>> getHabitCompletions({String? userId, String? habitId});
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion);
  Future<HabitCompletionModel> updateHabitCompletion(HabitCompletionModel completion);
  Future<void> deleteHabitCompletion(String completionId);
  Future<void> deleteHabitCompletionsByHabitId(String habitId); 
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final SupabaseClient supabaseClient;

  HabitRemoteDataSourceImpl(this.supabaseClient);

  // --- Implementasi Metode Habits ---

  @override
  Stream<List<HabitModel>> getHabitsStream({String? userId}) {
    var queryBuilder = supabaseClient.from('habits').select('*');

    // Terapkan filter jika userId disediakan
    if (userId != null) {
      queryBuilder = queryBuilder.eq('user_id', userId);
    }

    // Supabase Flutter does not support .stream; use real-time subscription instead
    final stream = supabaseClient
        .from('habits')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => HabitModel.fromJson(json)).toList());
    return stream;
  }

  @override
  Future<List<HabitModel>> getHabits({String? userId}) async {
    var queryBuilder = supabaseClient.from('habits').select('*');
    if (userId != null) {
      queryBuilder = queryBuilder.eq('user_id', userId);
    }

    final response = await queryBuilder.order('created_at', ascending: false);
    return response.map((json) => HabitModel.fromJson(json)).toList();
  }

  @override
  Future<HabitModel> addHabit(HabitModel habit) async {
    final response = await supabaseClient
        .from('habits')
        .insert(habit.toJson())
        .select() 
        .single(); 

    return HabitModel.fromJson(response);
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    final response = await supabaseClient
        .from('habits')
        .update(habit.toJson())
        .eq('id', habit.id)
        .select()
        .single();

    return HabitModel.fromJson(response);
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await supabaseClient
        .from('habits')
        .delete()
        .eq('id', habitId);
  }

  // --- Implementasi Metode Habit Completions ---

  @override
  Stream<List<HabitCompletionModel>> getHabitCompletionsStream({String? userId, String? habitId}) {
    var queryBuilder = supabaseClient.from('habit_completions').select('*');
    if (habitId != null) {
      queryBuilder = queryBuilder.eq('habit_id', habitId);
    }
    if (userId != null) {
      queryBuilder = queryBuilder.eq('user_id', userId);
    }

    final stream = supabaseClient
        .from('habit_completions')
        .stream(primaryKey: ['id'])
        .order('completion_date', ascending: false)
        .order('completed_at', ascending: false)
        .map((data) => data.map((json) => HabitCompletionModel.fromJson(json)).toList());
    return stream;
  }

  @override
  Future<List<HabitCompletionModel>> getHabitCompletions({String? userId, String? habitId}) async {
    var queryBuilder = supabaseClient.from('habit_completions').select('*');

    // Terapkan filter jika habitId disediakan
    if (habitId != null) {
      queryBuilder = queryBuilder.eq('habit_id', habitId);
    }
    // Terapkan filter jika userId disediakan
    if (userId != null) {
      queryBuilder = queryBuilder.eq('user_id', userId);
    }

    // Lanjutkan dengan order dan fetch data
    final response = await queryBuilder
        .order('completion_date', ascending: false)
        .order('completed_at', ascending: false);
    return response.map((json) => HabitCompletionModel.fromJson(json)).toList();
  }

  @override
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion) async {
    final response = await supabaseClient
        .from('habit_completions')
        .insert(completion.toJson())
        .select()
        .single();

    return HabitCompletionModel.fromJson(response);
  }

  @override
  Future<HabitCompletionModel> updateHabitCompletion(HabitCompletionModel completion) async {
    final response = await supabaseClient
        .from('habit_completions')
        .update(completion.toJson())
        .eq('id', completion.id)
        .select()
        .single();

    return HabitCompletionModel.fromJson(response);
  }

  @override
  Future<void> deleteHabitCompletion(String completionId) async {
    await supabaseClient
        .from('habit_completions')
        .delete()
        .eq('id', completionId);
  }

  @override
  Future<void> deleteHabitCompletionsByHabitId(String habitId) async {
    await supabaseClient
        .from('habit_completions')
        .delete()
        .eq('habit_id', habitId);
  }
}