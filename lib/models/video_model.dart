class Video {
  final String id;
  final String name;
  final String description;
  final String link;
  final String courseId;
  final String chapterId;
  final int order;

  Video({
    required this.id,
    required this.name,
    required this.description,
    required this.link,
    required this.courseId,
    required this.chapterId,
    required this.order,
  });

  factory Video.fromJson(Map<String, dynamic> json, String id) {
    return Video(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      courseId: json['course_id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'link': link,
      'course_id': courseId,
      'chapter_id': chapterId,
      'order': order,
    };
  }

  Video copyWith({
    String? name,
    String? description,
    String? link,
    String? chapterId,
    int? order,
  }) {
    return Video(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      link: link ?? this.link,
      courseId: courseId,
      chapterId: chapterId ?? this.chapterId,
      order: order ?? this.order,
    );
  }
}