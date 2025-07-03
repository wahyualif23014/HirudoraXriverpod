// lib/features/activities/domain/repositories/activity_repository.dart

import 'package:dartz/dartz.dart';
import '../../domain/entity/activity_entity.dart';

abstract class ActivityRepository {
  // daftar semua aktivitas
  Future<Either<Exception, List<ActivityEntity>>> getActivities();

  // aktivitas berdasarkan ID
  Future<Either<Exception, ActivityEntity>> getActivityById(String id);

  // Menambahkan aktivitas baru
  Future<Either<Exception, ActivityEntity>> addActivity(ActivityEntity activity);

  // Mengupdate aktivitas yang sudah ada
  Future<Either<Exception, ActivityEntity>> updateActivity(ActivityEntity activity);

  // Menghapus aktivitas berdasarkan ID
  Future<Either<Exception, void>> deleteActivity(String id);
}