// screens/manage_courses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/course_card.dart';
import '../widgets/loading_widget.dart';
import 'manage_videos_screen.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  _ManageCoursesScreenState createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isEditing = false;
  String? _currentCourseId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    setState(() {
      _isEditing = false;
      _currentCourseId = null;
    });
  }

  void _setupForEdit(Course course) {
    _nameController.text = course.name;
    setState(() {
      _isEditing = true;
      _currentCourseId = course.id;
    });
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CourseProvider>(context, listen: false);

      if (_isEditing && _currentCourseId != null) {
        final updatedCourse = Course(
          id: _currentCourseId!,
          name: _nameController.text.trim(),
        );
        await provider.updateCourse(updatedCourse);
      } else {
        final newCourse = Course(
          id: '', // will be set by Firebase
          name: _nameController.text.trim(),
        );
        await provider.addCourse(newCourse);
      }

      _resetForm();
    }
  }

  Future<void> _confirmDelete(Course course) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${course.name}? All associated videos will also be deleted.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF3E64FF))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await Provider.of<CourseProvider>(context, listen: false)
          .deleteCourse(course.id);
    }
  }

  void _navigateToManageVideos(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageVideosScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Courses', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        backgroundColor: const Color(0xFF3E64FF),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.courses.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null && provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Course Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: const Color(0xFF3E64FF).withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFF3E64FF).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isEditing ? Icons.edit : Icons.add_circle,
                                  color: const Color(0xFF3E64FF),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditing ? 'Edit Course' : 'Add New Course',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E64FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 24),
                            CustomTextField(
                              label: 'Course Name',
                              hint: 'Enter course name',
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a course name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    label: _isEditing ? 'Update Course' : 'Add Course',
                                    onPressed: _saveCourse,
                                    isLoading: provider.isLoading,
                                    color: const Color(0xFF3E64FF),
                                    icon: _isEditing ? Icons.save : Icons.add,
                                  ),
                                ),
                                if (_isEditing) ...[
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: _resetForm,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF3E64FF))),
                                  ),
                                ],
                              ],
                            ),
                            if (provider.error != null && provider.courses.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Error: ${provider.error}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Course List Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.list, color: Color(0xFF3E64FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E64FF),
                        ),
                      ),
                      const Spacer(),
                      if (provider.courses.isNotEmpty)
                        Chip(
                          backgroundColor: const Color(0xFF3E64FF).withOpacity(0.1),
                          label: Text(
                            '${provider.courses.length} ${provider.courses.length == 1 ? 'Course' : 'Courses'}',
                            style: const TextStyle(color: Color(0xFF3E64FF)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (provider.courses.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No courses found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first course to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.courses.map(
                        (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CourseCard(
                        course: course,
                        onEdit: () => _setupForEdit(course),
                        onDelete: () => _confirmDelete(course),
                        onManageVideos: () => _navigateToManageVideos(course),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}