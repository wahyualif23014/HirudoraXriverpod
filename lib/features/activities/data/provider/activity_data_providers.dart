// // lib/features/activities/data/providers/activity_data_providers.dart

// import 'package:hirudorax/features/activities/data/provider/activity_providers.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../datasources/activity_remote_datasource.dart'; // Interface
// import '../datasources/activity_supabase_datasource.dart'; // Implementasi
// import '../repositories/activity_repository.dart';
// import '../repositories/activity_repository_impl.dart';
// import '../../domain/entity/activity_entity.dart'; // <<< Pastikan ini diimport

// // Pastikan baris 'part' ini ADA dan NAMA FILE-nya SAMA PERSIS
// // dengan yang akan digenerate.
// part of 'activity_providers.dart';

// // Provider untuk SupabaseClient
// @Riverpod(keepAlive: true)
// SupabaseClient supabaseClient(SupabaseClientRef ref) {
//   return Supabase.instance.client;
// }

// // Provider untuk ActivityRemoteDataSource (interface)
// @Riverpod(keepAlive: true)
// ActivityRemoteDataSource activityRemoteDataSource(ActivityRemoteDataSourceRef ref) {
//   return ActivitySupabaseDataSourceImpl(ref.watch(supabaseClientProvider));
// }

// // Provider untuk ActivityRepository (interface dari domain layer)
// @Riverpod(keepAlive: true)
// ActivityRepository activityRepository(ActivityRepositoryRef ref) {
//   return ActivityRepositoryImpl(remoteDataSource: ref.watch(activityRemoteDataSourceProvider));
// }

// // >>> TAMBAHKAN PROVIDER INI DI SINI <<<
// // Provider untuk ringkasan aktivitas terbaru (untuk Dashboard)
// @Riverpod(keepAlive: true) // Gunakan AsyncValue<String> untuk menangani loading/error
// Future<String> recentActivitySummary(RecentActivitySummaryRef ref) async { // Perhatikan tipenya FutureProviderRef
//   final activityRepository = ref.watch(activityRepositoryProvider);

//   final result = await activityRepository.getActivities();

//   return result.fold(
//     (failure) {
//       print('Error fetching recent activities for summary: $failure');
//       return 'Failed to load activity summary.';
//     },
//     (activities) {
//       if (activities.isEmpty) {
//         return 'No activities logged yet.';
//       }

//       final today = DateTime.now();
//       final recentActivities = activities.where((activity) {
//         return activity.createdAt.year == today.year &&
//                activity.createdAt.month == today.month &&
//                activity.createdAt.day == today.day;
//       }).toList();

//       if (recentActivities.isEmpty) {
//         return 'No activities logged today.';
//       } else if (recentActivities.length == 1) {
//         return '1 new activity logged today.';
//       } else {
//         return '${recentActivities.length} new activities logged today.';
//       }
//     },
//   );
// }