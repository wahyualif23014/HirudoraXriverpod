// lib/features/activities/data/datasources/activity_supabase_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'activity_remote_datasource.dart'; // Import interface
import '../models/activity_model.dart';

class ActivitySupabaseDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient supabaseClient; // SupabaseClient akan diinject

  ActivitySupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from('activities')
          .select('*')
          .order('created_at', ascending: false);

      return response
          .map((json) => ActivityModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase error getting activities: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  @override
  Future<ActivityModel> getActivityById(String id) async {
    try {
      final Map<String, dynamic>? response = await supabaseClient
          .from('activities')
          .select('*')
          .eq('id', id)
          .single();

      if (response == null) {
        throw Exception('Activity with ID $id not found.');
      }

      return ActivityModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error getting activity by ID: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to get activity by ID: $e');
    }
  }

  @override
  Future<ActivityModel> addActivity(ActivityModel activity) async {
    try {
      final Map<String, dynamic> dataToInsert = activity.toJson();
      final List<Map<String, dynamic>> response = await supabaseClient
          .from('activities')
          .insert(dataToInsert)
          .select('*');

      if (response.isEmpty) {
        throw Exception('Failed to add activity: No data returned from insert.');
      }

      return ActivityModel.fromJson(response.first);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error adding activity: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  @override
  Future<ActivityModel> updateActivity(ActivityModel activity) async {
    try {
      final Map<String, dynamic> dataToUpdate = activity.toJson();
      dataToUpdate['updated_at'] = DateTime.now().toIso8601String();

      final List<Map<String, dynamic>> response = await supabaseClient
          .from('activities')
          .update(dataToUpdate)
          .eq('id', activity.id)
          .select('*');

      if (response.isEmpty) {
        throw Exception('Failed to update activity: No data returned or activity not found.');
      }

      return ActivityModel.fromJson(response.first);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error updating activity: ${e.message} (Code: ${e.code})');
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
      throw Exception('Supabase error deleting activity: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }
}