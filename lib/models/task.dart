import '../constants/priority_enum.dart';

class Task {
  int? id;
  String name;
  bool isCompleted;
  Priority priority;

  Task({
    this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = Priority.medium,
  });

  // Convert Task to JSON for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.displayName,
    };
  }

  // Create Task from database map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1,
      priority: PriorityExtension.fromString(map['priority']),
    );
  }
}
