// lib/finance/data/models/transaction_model.dart
import '../../domain/entity/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    super.userId,
    required super.amount,
    required super.type,
    super.description,
    required super.date,
    super.budgetId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['created_at'] as String),
      budgetId: json['budget_id'] as String? ?? '',
    );
  }

  // Tambahkan metode ini
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      amount: amount,
      type: type,
      description: description,
      date: date,
      budgetId: budgetId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      type: entity.type,
      description: entity.description,
      date: entity.date,
      budgetId: entity.budgetId,
    );
  }
}