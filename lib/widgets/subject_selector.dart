import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectSelector extends StatefulWidget {
  final List<String> selectedSubjects;
  final Function(List<String>) onChanged;

  const SubjectSelector({
    super.key,
    required this.selectedSubjects,
    required this.onChanged,
  });

  @override
  State<SubjectSelector> createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends State<SubjectSelector> {
  late List<String> _selectedSubjects;
  List<String> _availableSubjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedSubjects = List.from(widget.selectedSubjects);
    _fetchSubjectsFromFirestore();
  }

  Future<void> _fetchSubjectsFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get reference to the courses collection
      final coursesRef = FirebaseFirestore.instance.collection('courses');

      // Fetch all documents from the courses collection
      final querySnapshot = await coursesRef.get();

      // Extract subject names from the documents
      final subjects = querySnapshot.docs.map((doc) {
        // Assuming each document has a 'name' field for the subject
        // Adjust the field name if it's different in your Firestore structure
        return doc.data()['name'] as String;
      }).toList();

      // Update state with fetched subjects
      setState(() {
        _availableSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load subjects: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchSubjectsFromFirestore,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_availableSubjects.isEmpty)
                  const Center(
                    child: Text('No subjects available'),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableSubjects.map((subject) {
                      final isSelected = _selectedSubjects.contains(subject);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(subject),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSubjects.add(subject);
                            } else {
                              _selectedSubjects.remove(subject);
                            }
                            widget.onChanged(_selectedSubjects);
                          });
                        },
                        selectedColor: const Color(0xFF3E64FF).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3E64FF),
                      );
                    }).toList(),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}