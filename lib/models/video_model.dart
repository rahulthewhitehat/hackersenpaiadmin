// models/video_model.dart
class Video {
  final String id;
  final String name;
  final String description;
  final String link;
  final String courseId;

  Video({
    required this.id,
    required this.name,
    required this.description,
    required this.link,
    required this.courseId,
  });

  factory Video.fromJson(Map<String, dynamic> json, String id) {
    return Video(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      courseId: json['course_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'link': link,
      'course_id': courseId,
    };
  }

  Video copyWith({
    String? name,
    String? description,
    String? link,
  }) {
    return Video(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      link: link ?? this.link,
      courseId: courseId,
    );
  }
}