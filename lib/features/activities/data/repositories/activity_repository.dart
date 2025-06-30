// lib/features/activities/domain/repositories/activity_repository.dart

import 'package:dartz/dartz.dart'; // Menggunakan Left (Failure/Exception) dan Right (Success)
import '../../domain/entity/activity_entity.dart'; // Import ActivityEntity

abstract class ActivityRepository {
  // Mengambil daftar semua aktivitas
  Future<Either<Exception, List<ActivityEntity>>> getActivities();

  // Mengambil aktivitas berdasarkan ID
  Future<Either<Exception, ActivityEntity>> getActivityById(String id);

  // Menambahkan aktivitas baru
  // Menerima ActivityEntity, akan diubah menjadi ActivityModel di impl
  Future<Either<Exception, ActivityEntity>> addActivity(ActivityEntity activity);

  // Mengupdate aktivitas yang sudah ada
  // Menerima ActivityEntity, akan diubah menjadi ActivityModel di impl
  Future<Either<Exception, ActivityEntity>> updateActivity(ActivityEntity activity);

  // Menghapus aktivitas berdasarkan ID
  Future<Either<Exception, void>> deleteActivity(String id);
}