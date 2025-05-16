class Chapter {
  final String id;
  final String name;
  final String description;
  final String courseId;
  final int order;

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.courseId,
    required this.order,
  });

  factory Chapter.fromJson(Map<String, dynamic> json, String id) {
    return Chapter(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      courseId: json['course_id'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'course_id': courseId,
      'order': order,
    };
  }
}