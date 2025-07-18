// lib/features/activities/presentation/providers/activity_list_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirudorax/features/activities/data/provider/activity_providers.dart';
import 'package:uuid/uuid.dart'; 
import '../../domain/entity/activity_entity.dart';

class ActivityListNotifier extends AsyncNotifier<List<ActivityEntity>> {
  @override
  Future<List<ActivityEntity>> build() async {
    final activityRepository = ref.watch(activityRepositoryProvider);
    final result = await activityRepository.getActivities();
    return result.fold(
      (failure) {
        throw Exception('Failed to load activities: ${failure.toString()}');
      },
      (activities) => activities,
    );
  }

  Future<void> addActivity({
    required String title,
    String description = '',
    int priority = 3,
    List<String> tags = const [],
    DateTime? dueDate,
  }) async {
    state = const AsyncValue.loading(); 

    final activityRepository = ref.watch(activityRepositoryProvider);
    final uuid = const Uuid();
    final String newId = uuid.v4();

    final newActivity = ActivityEntity(
      id: newId,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: false,
      priority: priority,
      tags: tags,
      dueDate: dueDate,
    );

    final result = await activityRepository.addActivity(newActivity);

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) {
          throw Exception('Failed to add activity: ${failure.toString()}');
        },
        (addedActivity) async {
          final updatedResult = await activityRepository.getActivities();
          return updatedResult.fold(
            (failure) => throw Exception('Failed to refresh activities after add: ${failure.toString()}'),
            (updatedActivities) => updatedActivities,
          );
        },
      );
    });
  }

  // Method untuk menandai aktivitas sebagai selesai/belum selesai
  Future<void> toggleActivityCompletion(ActivityEntity activity) async {
    state = const AsyncValue.loading();

    final activityRepository = ref.watch(activityRepositoryProvider);
    final updatedActivity = activity.copyWith(
      isCompleted: !activity.isCompleted,
      updatedAt: DateTime.now(),
    );

    final result = await activityRepository.updateActivity(updatedActivity);

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) {
          throw Exception('Failed to toggle completion: ${failure.toString()}');
        },
        (updated) async {
          final updatedResult = await activityRepository.getActivities();
          return updatedResult.fold(
            (failure) => throw Exception('Failed to refresh activities after toggle: ${failure.toString()}'),
            (activities) => activities,
          );
        },
      );
    });
  }

  // Method untuk menghapus aktivitas
  Future<void> deleteActivity(String id) async {
    state = const AsyncValue.loading();

    final activityRepository = ref.watch(activityRepositoryProvider);
    final result = await activityRepository.deleteActivity(id);

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) {
          throw Exception('Failed to delete activity: ${failure.toString()}');
        },
        (_) async {
          final updatedResult = await activityRepository.getActivities();
          return updatedResult.fold(
            (failure) => throw Exception('Failed to refresh activities after delete: ${failure.toString()}'),
            (activities) => activities,
          );
        },
      );
    });
  }
  // --- TAMBAHKAN FUNGSI BARU DI SINI ---
  Future<void> updateActivity(ActivityEntity updatedActivity) async {
    final previousState = state.valueOrNull ?? [];

    // 1. Optimistic Update: Perbarui UI secara langsung
    state = AsyncData([
      for (final activity in previousState)
        if (activity.id == updatedActivity.id)
          updatedActivity.copyWith(updatedAt: DateTime.now()) // Pastikan updatedAt diperbarui
        else
          activity,
    ]);

    // 2. Lakukan operasi di background
    try {
      final activityRepository = ref.read(activityRepositoryProvider);
      // Kirim updatedActivity yang sudah memiliki updatedAt baru
      await activityRepository.updateActivity(state.value!.firstWhere((a) => a.id == updatedActivity.id));
    } catch (e) {
      // 3. Jika gagal, kembalikan state ke semula
      state = AsyncError<List<ActivityEntity>>(e, StackTrace.current).copyWithPrevious(AsyncData(previousState));
    }
  }
}

// Provider untuk ActivityListNotifier
final activityListNotifierProvider = AsyncNotifierProvider<ActivityListNotifier, List<ActivityEntity>>(() {
  return ActivityListNotifier();
});