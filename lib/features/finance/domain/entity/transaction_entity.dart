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
    required this.category, // Wajib diisi sekarang
    required this.date,
    this.budgetId,
    this.createdAt, // Default null untuk yang baru, akan diisi dari DB
  });

  // Method to create a copy with changed values
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

  // Method to convert to JSON format for Supabase
  // Perhatikan: `date` di sini akan menjadi `created_at` di Supabase
  // Jika Anda menambahkan kolom `transaction_date` di Supabase,
  // Anda harus membuat `transaction_date` terpisah di sini dan di model.
  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak perlu disertakan saat INSERT (Supabase akan generate)
      // 'id': id, // Hanya jika Anda melakukan UPDATE
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category, // Pastikan ini ada di tabel Supabase
      'description': description,
      'created_at': date.toIso8601String(), // Mengirim tanggal transaksi ke kolom 'created_at'
      'budget_id': budgetId == null || budgetId!.isEmpty ? null : budgetId, // Mengirim null jika kosong
    };
  }

  @override
  List<Object?> get props => [id, userId, amount, type, description, category, date, budgetId, createdAt];
}