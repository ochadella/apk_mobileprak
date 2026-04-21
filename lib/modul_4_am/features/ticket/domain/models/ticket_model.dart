class TicketModel {
  final String id;
  final String title;
  final String status;
  final String date;
  final String category;
  final String priority;
  final String reporter;
  final String description;
  final String assignee;
  final List<Map<String, dynamic>> tracking;

  TicketModel({
    required this.id,
    required this.title,
    required this.status,
    required this.date,
    required this.category,
    required this.priority,
    required this.reporter,
    required this.description,
    required this.assignee,
    required this.tracking,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      reporter: map['reporter'] ?? '',
      description: map['description'] ?? '',
      assignee: map['assignee'] ?? 'Belum di-assign',
      tracking: List<Map<String, dynamic>>.from(map['tracking'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'date': date,
      'category': category,
      'priority': priority,
      'reporter': reporter,
      'description': description,
      'assignee': assignee,
      'tracking': tracking,
    };
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? status,
    String? date,
    String? category,
    String? priority,
    String? reporter,
    String? description,
    String? assignee,
    List<Map<String, dynamic>>? tracking,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      date: date ?? this.date,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      reporter: reporter ?? this.reporter,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      tracking: tracking ?? this.tracking,
    );
  }
}