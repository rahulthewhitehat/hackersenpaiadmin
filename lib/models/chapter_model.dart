class Chapter {
  final String id;
  final String name;
  final String description;
  final String courseId;
  final int order; // Added order field

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.courseId,
    required this.order, // New required parameter
  });

  factory Chapter.fromJson(Map<String, dynamic> json, String id) {
    return Chapter(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      courseId: json['course_id'] ?? '',
      order: json['order'] ?? 0, // Default to 0 if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'course_id': courseId,
      'order': order, // Include order in JSON
    };
  }
}