// lib/finance/domain/entity/budget_entity.dart
import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String? userId; // Opsional, jika nanti ada autentikasi
  final String name;
  final double allocatedAmount;
  final double spentAmount; // Akan di-update dari transaksi
  final DateTime startDate;
  final DateTime endDate;
  final String category; // Misal 'Makanan', 'Transportasi'

  const BudgetEntity({
    this.id = '',
    this.userId,
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0, // Default 0
    required this.startDate,
    required this.endDate,
    required this.category,
  });

  factory BudgetEntity.fromJson(Map<String, dynamic> json) {
    return BudgetEntity(
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'allocated_amount': allocatedAmount,
      'spent_amount': spentAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'category': category,
      // 'user_id': userId, // Aktifkan jika menggunakan user_id
    };
  }

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? allocatedAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, allocatedAmount, spentAmount, startDate, endDate, category];
}