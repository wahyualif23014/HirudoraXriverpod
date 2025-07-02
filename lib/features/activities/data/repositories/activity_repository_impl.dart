// lib/features/activities/data/repositories/activity_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:hirudorax/features/activities/data/repositories/activity_repository.dart';
import '../../domain/entity/activity_entity.dart';
import '../datasources/activity_remote_datasource.dart'; 
import '../models/activity_model.dart'; 

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<ActivityEntity>>> getActivities() async {
    try {
      final List<ActivityModel> activityModels = await remoteDataSource.getActivities();
      return Right(activityModels.map((model) => model as ActivityEntity).toList());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> getActivityById(String id) async {
    try {
      final ActivityModel activityModel = await remoteDataSource.getActivityById(id);
      return Right(activityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> addActivity(ActivityEntity activity) async {
    try {
      final ActivityModel activityModel = ActivityModel.fromEntity(activity);
      final ActivityModel newActivityModel = await remoteDataSource.addActivity(activityModel);
      return Right(newActivityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ActivityEntity>> updateActivity(ActivityEntity activity) async {
    try {
      final ActivityModel activityModel = ActivityModel.fromEntity(activity);
      final ActivityModel updatedActivityModel = await remoteDataSource.updateActivity(activityModel);
      return Right(updatedActivityModel as ActivityEntity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteActivity(String id) async {
    try {
      await remoteDataSource.deleteActivity(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}