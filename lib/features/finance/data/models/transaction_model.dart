// lib/finance/data/models/transaction_model.dart
import '../../domain/entity/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    super.userId,
    required super.amount,
    required super.type,
    required super.category, 
    super.description,
    required super.date,
    super.budgetId,
    super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      // --- PERBAIKAN DI SINI ---
      category: json['category'] as String? ?? 'Uncategorized', // <--- Handle NULL: jika null, gunakan 'Uncategorized'
      description: json['description'] as String?,
      date: DateTime.parse(json['created_at'] as String),
      budgetId: json['budget_id'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  @override
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date,
      budgetId: budgetId,
      createdAt: createdAt,
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
      category: entity.category,
      description: entity.description,
      date: entity.date,
      budgetId: entity.budgetId,
      createdAt: entity.createdAt,
    );
  }
}