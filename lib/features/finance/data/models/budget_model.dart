// lib/finance/data/models/budget_model.dart
import '../../domain/entity/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    super.id,
    super.userId,
    required super.name,
    required super.allocatedAmount,
    super.spentAmount,
    required super.startDate,
    required super.endDate,
    required super.category,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      category: json['category'] as String,
    );
  }

  // Tambahkan metode ini
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      userId: userId,
      name: name,
      allocatedAmount: allocatedAmount,
      spentAmount: spentAmount,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      allocatedAmount: entity.allocatedAmount,
      spentAmount: entity.spentAmount,
      startDate: entity.startDate,
      endDate: entity.endDate,
      category: entity.category,
    );
  }
}