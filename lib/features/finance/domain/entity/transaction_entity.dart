// lib/features/finance/domain/entities/transaction_entity.dart
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String? id; // ID bisa null saat membuat transaksi baru
  final String budgetId; // ID budget yang terkait
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'income' atau 'expense'

  const TransactionEntity({
    this.id,
    required this.budgetId,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });

  @override
  List<Object?> get props => [id, budgetId, description, amount, date, type];

  TransactionEntity copyWith({
    String? id,
    String? budgetId,
    String? description,
    double? amount,
    DateTime? date,
    String? type,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}