enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TaskStatus status;
  TaskPriority priority;
  String? blockedBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.blockedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'blockedBy': blockedBy,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      priority: map['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.name == map['priority'],
            )
          : TaskPriority.medium,
      blockedBy: map['blockedBy'],
    );
  }
}