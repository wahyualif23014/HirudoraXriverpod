// lib/features/finance/domain/entities/budget_entity.dart
import 'package:equatable/equatable.dart'; // Pastikan equatable sudah di pubspec.yaml

class BudgetEntity extends Equatable {
  final String? id; // ID bisa null saat membuat budget baru
  final String category;
  final double limit;
  final double spent; // Jumlah yang sudah terpakai

  const BudgetEntity({
    this.id,
    required this.category,
    required this.limit,
    required this.spent,
  });

  // Digunakan untuk perbandingan objek (penting untuk Equatable)
  @override
  List<Object?> get props => [id, category, limit, spent];

  // Metode copyWith untuk memodifikasi entity tanpa mengubah aslinya (immutable)
  BudgetEntity copyWith({
    String? id,
    String? category,
    double? limit,
    double? spent,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}