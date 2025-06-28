// lib/features/finance/data/models/budget_model.dart
import '../../domain/entity/budget_entity.dart'; // Impor entity dari domain

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    super.id,
    required super.category,
    required super.limit,
    required super.spent,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json, String id) {
    return BudgetModel(
      id: id, // ID diambil dari key Firebase
      category: json['category'] as String,
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'limit': limit,
        'spent': spent,
      };

  // Konversi dari Entity ke Model (digunakan saat mengirim data ke database)
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      category: entity.category,
      limit: entity.limit,
      spent: entity.spent,
    );
  }
}