// models/student_model.dart
class Student {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final List<String> subjects;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.subjects,
  });

  factory Student.fromJson(Map<String, dynamic> json, String id) {
    return Student(
      id: id,
      name: json['name'] ?? '',
      studentId: json['student_id'] ?? '',
      email: json['email'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student_id': studentId,
      'email': email,
      'subjects': subjects,
    };
  }

  Student copyWith({
    String? name,
    String? studentId,
    String? email,
    List<String>? subjects,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      subjects: subjects ?? this.subjects,
    );
  }
}
