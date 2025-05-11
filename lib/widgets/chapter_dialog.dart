import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import 'custom_text_field.dart';

class ChapterDialog extends StatefulWidget {
  final String courseId;
  final Chapter? chapter; // If provided, we're editing an existing chapter
  final Function(Chapter) onSave;

  const ChapterDialog({
    Key? key,
    required this.courseId,
    this.chapter,
    required this.onSave,
  }) : super(key: key);

  @override
  _ChapterDialogState createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<ChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If we're editing, fill the fields
    if (widget.chapter != null) {
      _nameController.text = widget.chapter!.name;
      _descriptionController.text = widget.chapter!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChapter() {
    if (_formKey.currentState!.validate()) {
      final chapter = Chapter(
        id: widget.chapter?.id ?? '', // Empty if new chapter
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        courseId: widget.courseId,
      );

      widget.onSave(chapter);
      Navigator.pop(context, chapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chapter != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Chapter' : 'Create New Chapter',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E64FF)),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Chapter Name',
                hint: 'Enter chapter name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a chapter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Enter chapter description',
                controller: _descriptionController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _saveChapter,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E64FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isEditing ? 'Update' : 'Create',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}