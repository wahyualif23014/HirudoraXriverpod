// lib/features/finance/data/models/transaction_model.dart
import '../../../finance/domain/entity/transaction_entity.dart'; // Impor entity dari domain

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    required super.budgetId,
    required super.description,
    required super.amount,
    required super.date,
    required super.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id, // ID diambil dari key Firebase
      budgetId: json['budgetId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String), // Konversi String ISO 8601 ke DateTime
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'budgetId': budgetId,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(), // Konversi DateTime ke String ISO 8601
        'type': type,
      };

  // Konversi dari Entity ke Model (digunakan saat mengirim data ke database)
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      budgetId: entity.budgetId,
      description: entity.description,
      amount: entity.amount,
      date: entity.date,
      type: entity.type,
    );
  }
}