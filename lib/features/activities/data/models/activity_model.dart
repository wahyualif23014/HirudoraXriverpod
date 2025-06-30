// File: lib/features/activities/data/models/activity_model.dart

import '../../domain/entity/activity_entity.dart'; // Import entity yang relevan

class ActivityModel extends Activity {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String status; 

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.status,
  }) : super(          // Memanggil constructor dari parent class (Activity entity)
           id: id,
           name: name,
           description: description,
           date: date,
           status: status,
         );

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String), // Sesuaikan format tanggal
      status: json['status'] as String,
    );
  }

  // Method untuk mengubah instance ke JSON (misalnya untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(), // Sesuaikan format tanggal
      'status': status,
    };
  }

  // Optional: CopyWith method untuk immutability
  ActivityModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? status,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}