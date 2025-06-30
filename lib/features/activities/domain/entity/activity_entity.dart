// lib/features/activities/domain/entity/activity_entity.dart

import 'package:equatable/equatable.dart'; // Untuk perbandingan objek yang mudah dan konsisten

class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final String description; // Bisa kosong
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;     // Untuk to-do list
  final int priority;         // Misalnya: 1 (High), 2 (Medium), 3 (Low)
  final List<String> tags;    // Misalnya: ['Work', 'Personal', 'Shopping']
  final DateTime? dueDate;    // Tanggal jatuh tempo (opsional)

  const ActivityEntity({
    required this.id,
    required this.title,
    this.description = '', // Default value
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false, // Default value
    this.priority = 3,        // Default ke Low
    this.tags = const [],     // Default ke list kosong
    this.dueDate,
  });

  // Digunakan oleh Equatable untuk membandingkan objek berdasarkan propertinya
  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        updatedAt,
        isCompleted,
        priority,
        tags,
        dueDate,
      ];

  // Optional: copyWith method untuk membuat instance baru dengan properti yang diubah
  ActivityEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    int? priority,
    List<String>? tags,
    DateTime? dueDate,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}