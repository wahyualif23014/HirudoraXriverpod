// lib/features/finance/domain/entity/transaction_entity.dart
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String? userId; 
  final double amount;
  final String type; // 'income' or 'expense'
  final String category; 
  final String? description;
  final DateTime date; 
  final String? budgetId; 
  final DateTime? createdAt; 

  const TransactionEntity({
    this.id = '', 
    this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.category, 
    required this.date,
    this.budgetId,
    this.createdAt,
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? category,
    String? description,
    DateTime? date,
    String? budgetId,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      budgetId: budgetId ?? this.budgetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak perlu disertakan saat INSERT (Supabase akan generate)
      // 'id': id, // Hanya jika Anda melakukan UPDATE
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category, 
      'description': description,
      'created_at': date.toIso8601String(), 
      'budget_id': budgetId == null || budgetId!.isEmpty ? null : budgetId,
    };
  }

  @override
  List<Object?> get props => [id, userId, amount, type, description, category, date, budgetId, createdAt];
}