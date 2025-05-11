// screens/manage_videos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/video_card.dart';
import '../widgets/loading_widget.dart';

class ManageVideosScreen extends StatefulWidget {
  final Course course;

  const ManageVideosScreen({super.key, required this.course});

  @override
  _ManageVideosScreenState createState() => _ManageVideosScreenState();
}

class _ManageVideosScreenState extends State<ManageVideosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  bool _isEditing = false;
  String? _currentVideoId;

  @override
  void initState() {
    super.initState();
    // Set current course in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false)
          .setCurrentCourse(widget.course.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _linkController.clear();
    setState(() {
      _isEditing = false;
      _currentVideoId = null;
    });
  }

  void _setupForEdit(Video video) {
    _nameController.text = video.name;
    _descriptionController.text = video.description;
    _linkController.text = video.link;
    setState(() {
      _isEditing = true;
      _currentVideoId = video.id;
    });
  }

  Future<void> _saveVideo() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<VideoProvider>(context, listen: false);

      if (_isEditing && _currentVideoId != null) {
        final updatedVideo = Video(
          id: _currentVideoId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          link: _linkController.text.trim(),
          courseId: widget.course.id,
        );
        await provider.updateVideo(updatedVideo);
      } else {
        final newVideo = Video(
          id: '', // will be set by Firebase
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          link: _linkController.text.trim(),
          courseId: widget.course.id,
        );
        await provider.addVideo(newVideo);
      }

      _resetForm();
    }
  }

  Future<void> _confirmDelete(Video video) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${video.name}?'),
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
      await Provider.of<VideoProvider>(context, listen: false)
          .deleteVideo(video);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
            'Manage Videos: ${widget.course.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF3E64FF),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.videos.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null && provider.videos.isEmpty) {
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
                                _isEditing ? Icons.edit : Icons.video_library,
                                color: const Color(0xFF3E64FF),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditing ? 'Edit Video' : 'Add New Video',
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
                            label: 'Video Name',
                            hint: 'Enter video name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a video name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Description',
                            hint: 'Enter video description',
                            controller: _descriptionController,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Video Link',
                            hint: 'Enter Google Drive link',
                            controller: _linkController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a video link';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: _isEditing ? 'Update Video' : 'Add Video',
                                  onPressed: _saveVideo,
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
                          if (provider.error != null && provider.videos.isNotEmpty)
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.video_collection, color: Color(0xFF3E64FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Video List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E64FF),
                        ),
                      ),
                      const Spacer(),
                      if (provider.videos.isNotEmpty)
                        Chip(
                          backgroundColor: const Color(0xFF3E64FF).withOpacity(0.1),
                          label: Text(
                            '${provider.videos.length} ${provider.videos.length == 1 ? 'Video' : 'Videos'}',
                            style: const TextStyle(color: Color(0xFF3E64FF)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.videos.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.videocam_off_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No videos available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first video to get started!',
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.videos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final video = provider.videos[index];
                      return VideoCard(
                        video: video,
                        onEdit: () => _setupForEdit(video),
                        onDelete: () => _confirmDelete(video),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}