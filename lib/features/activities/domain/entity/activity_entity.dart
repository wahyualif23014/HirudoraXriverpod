// lib/features/activities/domain/entity/activity_entity.dart

import 'package:equatable/equatable.dart'; 

class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final String description; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;    
  final int priority;         
  final List<String> tags;    
  final DateTime? dueDate;  

  const ActivityEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false, 
    this.priority = 3,       
    this.tags = const [],     
    this.dueDate,
  });

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