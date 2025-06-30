// lib/features/finance/data/models/goal_model.dart
import '../../domain/entity/goals_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    super.userId,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.targetDate,
    required super.createdAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      targetDate: DateTime.parse(map['target_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper factory untuk membuat GoalModel baru tanpa ID untuk penambahan
  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate,
      createdAt: entity.createdAt,
    );
  }
}