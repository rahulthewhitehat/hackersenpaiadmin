import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../providers/student_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/student_card.dart';
import '../widgets/subject_selector.dart';
import '../widgets/loading_widget.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  _ManageStudentsScreenState createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Changed from List<String> to Map<String, String>
  Map<String, String> _selectedSubjects = {};
  bool _isEditing = false;
  String? _currentStudentId;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _studentIdController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedSubjects = {};
      _isEditing = false;
      _currentStudentId = null;
    });
  }

  void _setupForEdit(Student student) {
    _nameController.text = student.name;
    _studentIdController.text = student.studentId;
    _emailController.text = student.email;
    // We don't set password for security reasons
    setState(() {
      _selectedSubjects = Map<String, String>.from(student.subjects);
      _isEditing = true;
      _currentStudentId = student.id;
    });
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<StudentProvider>(context, listen: false);

      if (_isEditing && _currentStudentId != null) {
        final updatedStudent = Student(
          id: _currentStudentId!,
          name: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          email: _emailController.text.trim(),
          subjects: _selectedSubjects,
        );
        await provider.updateStudent(updatedStudent);
      } else {
        final newStudent = Student(
          id: '', // will be set by Firebase
          name: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          email: _emailController.text.trim(),
          subjects: _selectedSubjects,
        );
        await provider.addStudent(newStudent, _passwordController.text);
      }

      _resetForm();
    }
  }

  Future<void> _confirmDelete(Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${student.name}?'),
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
      await Provider.of<StudentProvider>(context, listen: false).deleteStudent(student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Students', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF3E64FF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.students.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null && provider.students.isEmpty) {
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
                // Add Student Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: const Color(0xFF3E64FF).withOpacity(0.2),
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
                                _isEditing ? Icons.edit : Icons.person_add,
                                color: const Color(0xFF3E64FF),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditing ? 'Edit Student' : 'Add New Student',
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
                            label: 'Name',
                            hint: 'Enter student name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Student ID',
                            hint: 'Enter student ID',
                            controller: _studentIdController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a student ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Email',
                            hint: 'Enter student email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (!_isEditing)
                            Column(
                              children: [
                                CustomTextField(
                                  label: 'Password',
                                  hint: 'Enter password',
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          SubjectSelector(
                            selectedSubjects: _selectedSubjects,
                            onChanged: (subjects) {
                              setState(() {
                                _selectedSubjects = subjects;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: _isEditing ? 'Update Student' : 'Add Student',
                                  onPressed: _saveStudent,
                                  isLoading: provider.isLoading,
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
                          if (provider.error != null && provider.students.isNotEmpty)
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
                // Student List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt, color: Color(0xFF3E64FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Student List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E64FF),
                        ),
                      ),
                      const Spacer(),
                      if (provider.students.isNotEmpty)
                        Chip(
                          label: Text
                            ('${provider.students.length} ${provider.students.length == 1 ? 'Student' : 'Students'}'
                          ),
                          backgroundColor: const Color(0xFF3E64FF).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFF3E64FF)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.students.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first student to get started!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.students.map(
                        (student) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: StudentCard(
                        student: student,
                        onEdit: () => _setupForEdit(student),
                        onDelete: () => _confirmDelete(student),
                        onResetId: () {
                          // Show a confirmation dialog for resetting ID
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('Reset Unique ID'),
                                content: const Text('This will remove the device-specific identifier. Are you sure?'),
                                actions: [
                                    TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                    onPressed: () {
                                    Navigator.pop(context);
                                    provider.resetStudentUniqueId(student.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                    content: Text('Unique ID has been reset'),
                                    duration: Duration(seconds: 2),
                                    ),);},
                                child: const Text('Reset'),),],),);},),
                          ))]));},
                          ));
                        }}