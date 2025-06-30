  // lib/features/activities/data/providers/activity_providers.dart
  // Ini adalah file INDUK yang akan di-generate oleh build_runner

  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:hirudorax/features/activities/data/repositories/activity_repository.dart';
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  // Pastikan import-import ini benar sesuai lokasi Anda
  import '../datasources/activity_remote_datasource.dart'; // Interface
  import '../datasources/activity_supabase_datasource.dart'; // Implementasi
  import '../repositories/activity_repository_impl.dart';
  // Penting untuk ActivityEntity

  // Ini adalah baris PART yang benar untuk file INDUK
  part 'activity_providers.g.dart'; // <<< PASTIKAN INI ADA DAN BENAR

  // Provider untuk SupabaseClient
  @Riverpod(keepAlive: true)
  SupabaseClient supabaseClient(SupabaseClientRef ref) { // Gunakan SupabaseClientRef atau Ref (Ref lebih modern)
    return Supabase.instance.client;
  }

  // Provider untuk ActivityRemoteDataSource (interface)
  @Riverpod(keepAlive: true)
  ActivityRemoteDataSource activityRemoteDataSource(ActivityRemoteDataSourceRef ref) {
    return ActivitySupabaseDataSourceImpl(ref.watch(supabaseClientProvider));
  }

  // Provider untuk ActivityRepository (interface dari domain layer)
  @Riverpod(keepAlive: true)
  ActivityRepository activityRepository(ActivityRepositoryRef ref) {
    return ActivityRepositoryImpl(remoteDataSource: ref.watch(activityRemoteDataSourceProvider));
  }

  // Provider untuk ringkasan aktivitas terbaru (untuk Dashboard)
  @Riverpod(keepAlive: true)
  Future<String> recentActivitySummary(Ref ref) async { // Atau FutureProviderRef
    final activityRepository = ref.watch(activityRepositoryProvider);

    final result = await activityRepository.getActivities();

    return result.fold(
      (failure) {
        print('Error fetching recent activities for summary: $failure');
        return 'Failed to load activity summary.';
      },
      (activities) {
        if (activities.isEmpty) {
          return 'No activities logged yet.';
        }

        final today = DateTime.now();
        final recentActivities = activities.where((activity) {
          return activity.createdAt.year == today.year &&
                activity.createdAt.month == today.month &&
                activity.createdAt.day == today.day;
        }).toList();

        if (recentActivities.isEmpty) {
          return 'No activities logged today.';
        } else if (recentActivities.length == 1) {
          return '1 new activity logged today.';
        } else {
          return '${recentActivities.length} new activities logged today.';
        }
      },
    );
  }