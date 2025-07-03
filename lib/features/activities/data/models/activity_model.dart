// lib/features/activities/data/models/activity_model.dart

import '../../domain/entity/activity_entity.dart'; 

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.title,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.isCompleted,
    super.priority,
    super.tags,
    super.dueDate,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String, 
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: (json['is_completed'] ?? false) as bool,
      createdAt: DateTime.parse(json['created_at'] as String), 
      priority: (json['priority'] ?? 3) as int,       
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(), 
      'updated_at': updatedAt.toIso8601String(), 
      'is_completed': isCompleted,
      'priority': priority,
      'tags': tags,
      'due_date': dueDate?.toIso8601String(), 
    };
  }

  @override
  ActivityModel copyWith({
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
    return ActivityModel(
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

  factory ActivityModel.fromEntity(ActivityEntity entity) {
    return ActivityModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      tags: entity.tags,
      dueDate: entity.dueDate,
    );
  }
}