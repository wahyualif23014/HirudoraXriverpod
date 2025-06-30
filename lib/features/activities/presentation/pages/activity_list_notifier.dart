// lib/features/activities/presentation/providers/activity_list_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirudorax/features/activities/data/provider/activity_providers.dart';
import 'package:uuid/uuid.dart'; // Untuk menghasilkan ID unik
import '../../domain/entity/activity_entity.dart';
import '../../../activities/data/repositories/activity_repository.dart';
import '../../../activities/data/repositories/activity_repository_impl.dart'; // Untuk mengakses activityRepositoryProvider

// Menggunakan AsyncNotifier untuk state management yang lebih modern dengan Riverpod 2.0+
// Ini akan mengelola AsyncValue<List<ActivityEntity>>
class ActivityListNotifier extends AsyncNotifier<List<ActivityEntity>> {
  // Method 'build' akan dipanggil pertama kali saat notifier dibuat
  // dan akan menginisialisasi state dengan mengambil daftar aktivitas.
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

  // Method untuk menambahkan aktivitas baru
  Future<void> addActivity({
    required String title,
    String description = '',
    int priority = 3,
    List<String> tags = const [],
    DateTime? dueDate,
  }) async {
    state = const AsyncValue.loading(); // Set state ke loading

    final activityRepository = ref.watch(activityRepositoryProvider);
    final uuid = const Uuid(); // Buat instance Uuid
    final String newId = uuid.v4(); // Generate ID unik

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
          // Setelah berhasil, ambil ulang daftar aktivitas
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
      updatedAt: DateTime.now(), // Perbarui waktu update
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
        (_) async { // _ menandakan tidak ada nilai yang dikembalikan dari delete
          final updatedResult = await activityRepository.getActivities();
          return updatedResult.fold(
            (failure) => throw Exception('Failed to refresh activities after delete: ${failure.toString()}'),
            (activities) => activities,
          );
        },
      );
    });
  }
}

// Provider untuk ActivityListNotifier
final activityListNotifierProvider = AsyncNotifierProvider<ActivityListNotifier, List<ActivityEntity>>(() {
  return ActivityListNotifier();
});