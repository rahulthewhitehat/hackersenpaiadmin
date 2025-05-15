import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubjectSelector extends StatefulWidget {
  final Map<String, String> selectedSubjects;
  final Function(Map<String, String>) onChanged;

  const SubjectSelector({
    Key? key,
    required this.selectedSubjects,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SubjectSelectorState createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends State<SubjectSelector> {

  List<String> _availableSubjects = [];

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    _availableSubjects = await fetchAvailableSubjects();
    setState(() {}); // Refresh UI
  }

  Future<List<String>> fetchAvailableSubjects() async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

    // Extracting document IDs as course names
    final subjects = snapshot.docs.map((doc) => doc.id).toList();

    return subjects;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSubjects.map((subject) {
            final isSelected = widget.selectedSubjects.containsKey(subject);
            final expiryDate = widget.selectedSubjects[subject] ?? '';

            return GestureDetector(
              onTap: () => _selectSubjectWithDate(subject, isSelected ? null : expiryDate),
              child: Chip(
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject),
                    if (isSelected && expiryDate.isNotEmpty)
                      Text(
                        'Expires: ${_formatDate(expiryDate)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                  ],
                ),
                backgroundColor: isSelected
                    ? const Color(0xFF3E64FF).withOpacity(0.2)
                    : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF3E64FF) : Colors.black87,
                ),
                deleteIcon: isSelected
                    ? const Icon(Icons.close, size: 16, color: Color(0xFF3E64FF))
                    : null,
                onDeleted: isSelected
                    ? () {
                  final updatedSubjects = Map<String, String>.from(widget.selectedSubjects);
                  updatedSubjects.remove(subject);
                  widget.onChanged(updatedSubjects);
                }
                    : null,
              ),
            );
          }).toList(),
        ),
        if (widget.selectedSubjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Subjects with Expiry Dates:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...widget.selectedSubjects.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          _formatDate(entry.value),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'No expiry';

    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _selectSubjectWithDate(String subject, String? currentDate) async {
    // If already selected, just remove it
    if (widget.selectedSubjects.containsKey(subject)) {
      final updatedSubjects = Map<String, String>.from(widget.selectedSubjects);
      updatedSubjects.remove(subject);
      widget.onChanged(updatedSubjects);
      return;
    }

    // Otherwise show date picker
    final DateTime initialDate = DateTime.now().add(const Duration(days: 365));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3E64FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final newExpiryDate = pickedDate.toIso8601String();
      final updatedSubjects = Map<String, String>.from(widget.selectedSubjects);
      updatedSubjects[subject] = newExpiryDate;
      widget.onChanged(updatedSubjects);
    }
  }
}