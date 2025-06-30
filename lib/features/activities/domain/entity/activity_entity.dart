// File: lib/features/activities/domain/entities/activity.dart

import 'package:equatable/equatable.dart'; // Untuk perbandingan objek yang mudah

class Activity extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String status;

  const Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, description, date, status];
}