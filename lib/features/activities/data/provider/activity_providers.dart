  // lib/features/activities/data/providers/activity_providers.dart

  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:hirudorax/features/activities/data/repositories/activity_repository.dart';
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  import '../datasources/activity_remote_datasource.dart'; 
  import '../datasources/activity_supabase_datasource.dart'; 
  import '../repositories/activity_repository_impl.dart';

  part 'activity_providers.g.dart';

  @Riverpod(keepAlive: true)
  SupabaseClient supabaseClient(SupabaseClientRef ref) { 
    return Supabase.instance.client;
  }

  @Riverpod(keepAlive: true)
  ActivityRemoteDataSource activityRemoteDataSource(ActivityRemoteDataSourceRef ref) {
    return ActivitySupabaseDataSourceImpl(ref.watch(supabaseClientProvider));
  }

  @Riverpod(keepAlive: true)
  ActivityRepository activityRepository(ActivityRepositoryRef ref) {
    return ActivityRepositoryImpl(remoteDataSource: ref.watch(activityRemoteDataSourceProvider));
  }

  @Riverpod(keepAlive: true)
  Future<String> recentActivitySummary(Ref ref) async { 
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