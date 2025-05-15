class Student {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final Map<String, String> subjects; // Changed from List<String> to Map<String, String>

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.subjects,
  });

  factory Student.fromJson(Map<String, dynamic> json, String id) {
    // Convert the subjects field from Firestore to a Map<String, String>
    Map<String, String> subjectsMap = {};
    if (json['subjects'] != null) {
      final subjectsData = json['subjects'] as Map<String, dynamic>;
      subjectsData.forEach((key, value) {
        subjectsMap[key] = value.toString();
      });
    }

    return Student(
      id: id,
      name: json['name'] ?? '',
      studentId: json['student_id'] ?? '',
      email: json['email'] ?? '',
      subjects: subjectsMap,
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
    Map<String, String>? subjects,
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