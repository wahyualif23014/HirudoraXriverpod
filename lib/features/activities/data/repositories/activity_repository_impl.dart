// lib/features/activities/data/repositories/activity_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:hirudorax/features/activities/data/repositories/activity_repository.dart';
import '../../domain/entity/activity_entity.dart'; // Import interface repository
import '../datasources/activity_remote_datasource.dart'; // Import data source
import '../models/activity_model.dart'; // Import ActivityModel

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource; // Data source akan diinject

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<ActivityEntity>>> getActivities() async {
    try {
      final List<ActivityModel> activityModels = await remoteDataSource.getActivities();
      // Konversi List<ActivityModel> menjadi List<ActivityEntity>
      return Right(activityModels.map((model) => model as ActivityEntity).toList());
    } on Exception catch (e) {
      // Tangani exception dari data source
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> getActivityById(String id) async {
    try {
      final ActivityModel activityModel = await remoteDataSource.getActivityById(id);
      // Konversi ActivityModel menjadi ActivityEntity
      return Right(activityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> addActivity(ActivityEntity activity) async {
    try {
      // Konversi ActivityEntity menjadi ActivityModel sebelum dikirim ke data source
      final ActivityModel activityModel = ActivityModel.fromEntity(activity);
      final ActivityModel newActivityModel = await remoteDataSource.addActivity(activityModel);
      // Konversi kembali hasilnya ke ActivityEntity
      return Right(newActivityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> updateActivity(ActivityEntity activity) async {
    try {
      // Konversi ActivityEntity menjadi ActivityModel sebelum dikirim ke data source
      final ActivityModel activityModel = ActivityModel.fromEntity(activity);
      final ActivityModel updatedActivityModel = await remoteDataSource.updateActivity(activityModel);
      // Konversi kembali hasilnya ke ActivityEntity
      return Right(updatedActivityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteActivity(String id) async {
    try {
      await remoteDataSource.deleteActivity(id);
      return const Right(null); // Mengembalikan Right(null) untuk operasi void
    } on Exception catch (e) {
      return Left(e);
    }
  }
}