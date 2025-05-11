class Chapter {
  final String id;
  final String name;
  final String description;
  final String courseId;

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.courseId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json, String id) {
    return Chapter(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      courseId: json['course_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'course_id': courseId,
    };
  }
}