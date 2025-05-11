// widgets/subject_selector.dart
import 'package:flutter/material.dart';

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
  final List<String> allSubjects = ['Accounts', 'Law', 'QA', 'Economics'];
  late List<String> _selectedSubjects;

  @override
  void initState() {
    super.initState();
    _selectedSubjects = List.from(widget.selectedSubjects);
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
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allSubjects.map((subject) {
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