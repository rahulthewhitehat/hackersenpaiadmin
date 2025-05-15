import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ChapterDialog extends StatefulWidget {
  final String courseId;
  final Function(Chapter) onSave;
  final Chapter? chapter; // Optional chapter for editing

  const ChapterDialog({
    super.key,
    required this.courseId,
    required this.onSave,
    this.chapter,
  });

  @override
  _ChapterDialogState createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<ChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _isLoading = true;
      });

      final newChapter = Chapter(
        id: widget.chapter?.id ?? '', // Empty if new, existing ID if editing
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        courseId: widget.courseId,
        order: widget.chapter?.order ?? 0, // Will be set in provider/service
      );

      widget.onSave(newChapter);
      Navigator.of(context).pop(newChapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder, color: Color(0xFF3E64FF)),
                  const SizedBox(width: 8),
                  Text(
                    widget.chapter == null ? 'Create New Chapter' : 'Edit Chapter',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E64FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 24),
              CustomButton(
                label: widget.chapter == null ? 'Create Chapter' : 'Update Chapter',
                onPressed: _saveChapter,
                isLoading: _isLoading,
                color: const Color(0xFF3E64FF),
                icon: widget.chapter == null ? Icons.add : Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}