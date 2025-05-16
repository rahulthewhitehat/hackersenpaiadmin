// widgets/student_card.dart
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import 'package:intl/intl.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetId; // New callback for reset ID functionality

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
    required this.onResetId, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: const Color(0xFF3E64FF).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF3E64FF).withOpacity(0.2),
                  radius: 24,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E64FF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student.studentId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Replace the edit and delete buttons with a popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Options',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                      case 'reset_id':
                        onResetId();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reset_id',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.orange),
                          SizedBox(width: 10),
                          Text('Reset ID'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (student.subjects.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Enrolled Subjects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: student.subjects.entries.map((entry) {
                  final subject = entry.key;
                  final expiryDate = entry.value;

                  return Tooltip(
                    message: 'Expires: ${_formatDate(expiryDate)}',
                    child: Chip(
                      label: Text(subject),
                      backgroundColor: _isExpiringSoon(expiryDate)
                          ? Colors.orange.withOpacity(0.2)
                          : const Color(0xFF3E64FF).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _isExpiringSoon(expiryDate)
                            ? Colors.orange[800]
                            : const Color(0xFF3E64FF),
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
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

  bool _isExpiringSoon(String dateStr) {
    if (dateStr.isEmpty) return false;

    try {
      final expiryDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;

      // Return true if expiry is within 30 days
      return difference <= 30 && difference >= 0;
    } catch (e) {
      return false;
    }
  }
}