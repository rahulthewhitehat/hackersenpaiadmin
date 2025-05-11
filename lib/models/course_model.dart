class Course {
  final String id;
  final String name;

  Course({
    required this.id,
    required this.name,
  });

  factory Course.fromJson(Map<String, dynamic> json, String id) {
    return Course(
      id: id,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  Course copyWith({
    String? name,
  }) {
    return Course(
      id: id,
      name: id
    );
  }
}