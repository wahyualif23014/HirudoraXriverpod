// lib/features/activities/data/provider/activity_remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_model.dart'; // Import ActivityModel

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getActivities();
  Future<ActivityModel> getActivityById(String id);
  Future<ActivityModel> addActivity(ActivityModel activity);
  Future<ActivityModel> updateActivity(ActivityModel activity);
  Future<void> deleteActivity(String id);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient supabaseClient; // Inject SupabaseClient

  ActivityRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      final response = await supabaseClient
          .from('activities') // Nama tabel di Supabase
          .select()
          .order('date', ascending: false); // Contoh: urutkan berdasarkan tanggal

      if (response == null) {
        throw Exception('No data received from Supabase');
      }

      // Pastikan response adalah List<Map<String, dynamic>>
      if (response is! List) {
        throw Exception('Invalid response format from Supabase');
      }

      return (response as List)
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  @override
  Future<ActivityModel> getActivityById(String id) async {
    try {
      final response = await supabaseClient
          .from('activities')
          .select()
          .eq('id', id)
          .single(); // Ambil satu record

      if (response == null) {
        throw Exception('Activity not found');
      }

      return ActivityModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get activity by ID: $e');
    }
  }

  @override
  Future<ActivityModel> addActivity(ActivityModel activity) async {
    try {
      final response = await supabaseClient
          .from('activities')
          .insert(activity.toJson()) // Menggunakan toJson dari ActivityModel
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to add activity');
      }

      return ActivityModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  @override
  Future<ActivityModel> updateActivity(ActivityModel activity) async {
    try {
      final response = await supabaseClient
          .from('activities')
          .update(activity.toJson()) // Menggunakan toJson
          .eq('id', activity.id)
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to update activity');
      }

      return ActivityModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    try {
      await supabaseClient
          .from('activities')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }
}