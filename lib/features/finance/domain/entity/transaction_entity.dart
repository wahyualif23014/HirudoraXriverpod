// lib/finance/domain/entity/transaction_entity.dart
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id; // ID dari Supabase (UUID)
  final String? userId; // Opsional, jika nanti ada autentikasi
  final double amount;
  final String type; // 'income' atau 'expense'
  final String? description;
  final DateTime date;
  final String budgetId; // ID budget jika ada kaitannya

  const TransactionEntity({
    this.id = '', // Supabase akan generate ID, jadi default bisa kosong
    this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.budgetId = '', // Default kosong jika tidak terkait budget
  });

  // Contoh konversi dari JSON (dari Supabase)
  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['created_at'] as String), // Asumsi nama kolom di Supabase adalah 'created_at'
      budgetId: json['budget_id'] as String? ?? '', // Sesuaikan jika nama kolom berbeda
    );
  }

  // Contoh konversi ke JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': date.toIso8601String(),
      'budget_id': budgetId.isNotEmpty ? budgetId : null, // Kirim null jika kosong
      // 'user_id': userId, // Aktifkan jika menggunakan user_id dari autentikasi
    };
  }

  // Metode copyWith untuk membuat instance baru dengan properti yang diubah
  TransactionEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    String? budgetId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      budgetId: budgetId ?? this.budgetId,
    );
  }

  @override
  List<Object?> get props => [id, userId, amount, type, description, date, budgetId];
}