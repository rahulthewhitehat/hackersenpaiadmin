import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/chapter_model.dart';
import '../providers/video_provider.dart';
import '../providers/chapter_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/video_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/chapter_dialog.dart';

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
  Chapter? _selectedChapter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false)
          .setCurrentCourse(widget.course.id);
      Provider.of<ChapterProvider>(context, listen: false)
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

    final chapterProvider = Provider.of<ChapterProvider>(context, listen: false);
    _selectedChapter = chapterProvider.chapters.firstWhere(
          (chapter) => chapter.id == video.chapterId,
      orElse: () => chapterProvider.chapters.first,
    );

    setState(() {
      _isEditing = true;
      _currentVideoId = video.id;
    });
  }

  Future<void> _saveVideo() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedChapter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or create a chapter first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final videoProvider = Provider.of<VideoProvider>(context, listen: false);

      if (_isEditing && _currentVideoId != null) {
        final updatedVideo = Video(
          id: _currentVideoId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          link: _linkController.text.trim(),
          courseId: widget.course.id,
          chapterId: _selectedChapter!.id,
        );
        await videoProvider.updateVideo(updatedVideo);
      } else {
        final newVideo = Video(
          id: '', // will be set by Firebase
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          link: _linkController.text.trim(),
          courseId: widget.course.id,
          chapterId: _selectedChapter!.id,
        );
        await videoProvider.addVideo(newVideo);
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

  Future<void> _showCreateChapterDialog() async {
    final result = await showDialog<Chapter>(
      context: context,
      builder: (context) => ChapterDialog(
        courseId: widget.course.id,
        onSave: (chapter) {
          Provider.of<ChapterProvider>(context, listen: false)
              .addChapter(chapter);
        },
      ),
    );

    if (result != null) {
      setState(() {
        _selectedChapter = result;
      });
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
      body: Consumer2<ChapterProvider, VideoProvider>(
        builder: (context, chapterProvider, videoProvider, child) {
          if (chapterProvider.isLoading && chapterProvider.chapters.isEmpty) {
            return const LoadingWidget();
          }

          if (chapterProvider.error != null && chapterProvider.chapters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${chapterProvider.error}',
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

                          // Improved Chapter Selection Section
                          // In the chapter selection part of your build method, replace with this:

// Improved Chapter Selection Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chapter',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.4),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: chapterProvider.chapters.isEmpty
                                          ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Text('No chapters available'),
                                      )
                                          : // In the DropdownButton part of your code, replace it with this:
                                      DropdownButton<Chapter>(
                                        isExpanded: true,
                                        value: _selectedChapter != null && chapterProvider.chapters.any((c) => c.id == _selectedChapter!.id)
                                            ? chapterProvider.chapters.firstWhere((c) => c.id == _selectedChapter!.id)
                                            : chapterProvider.chapters.isNotEmpty ? chapterProvider.chapters.first : null,
                                        underline: const SizedBox(),
                                        icon: const Icon(Icons.arrow_drop_down),
                                        hint: const Text('Select chapter'),
                                        items: chapterProvider.chapters.map((Chapter chapter) {
                                          return DropdownMenuItem<Chapter>(
                                            value: chapter,
                                            child: Text(
                                              chapter.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (Chapter? value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedChapter = value;
                                            });
                                            videoProvider.setCurrentChapter(value.id);
                                          }
                                        },
                                      )
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF3E64FF),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: _showCreateChapterDialog,
                                      icon: const Icon(Icons.add, color: Color(0xFF3E64FF)),
                                      tooltip: 'New Chapter',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

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
                                  isLoading: videoProvider.isLoading,
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
                          if (videoProvider.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Error: ${videoProvider.error}',
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

                // Improved Chapter Panel
                if (chapterProvider.chapters.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E64FF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.folder_open, color: Color(0xFF3E64FF), size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chapters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E64FF),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E64FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${chapterProvider.chapters.length} ${chapterProvider.chapters.length == 1 ? 'Chapter' : 'Chapters'}',
                                style: const TextStyle(
                                  color: Color(0xFF3E64FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Improved Chapter Selection Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: chapterProvider.chapters.map((chapter) {
                              final isSelected = _selectedChapter?.id == chapter.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(chapter.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedChapter = chapter;
                                      });
                                      videoProvider.setCurrentChapter(chapter.id);
                                    }
                                  },
                                  selectedColor: const Color(0xFF3E64FF),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF3E64FF),
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF3E64FF)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Videos section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E64FF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.video_collection, color: Color(0xFF3E64FF), size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Video List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E64FF),
                            ),
                          ),
                          const Spacer(),
                          if (_selectedChapter != null && videoProvider.videos.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E64FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${videoProvider.videos.length} ${videoProvider.videos.length == 1 ? 'Video' : 'Videos'}',
                                style: const TextStyle(
                                  color: Color(0xFF3E64FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_selectedChapter == null)
                        _buildEmptyState(
                          icon: Icons.folder_off_outlined,
                          title: 'No chapter selected',
                          message: 'Please select a chapter or create a new one to view videos',
                        )
                      else if (videoProvider.isLoading && videoProvider.videos.isEmpty)
                        const Center(child: LoadingWidget())
                      else if (videoProvider.videos.isEmpty)
                          _buildEmptyState(
                            icon: Icons.videocam_off_outlined,
                            title: 'No videos available',
                            message: 'Add your first video to this chapter!',
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: videoProvider.videos.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final video = videoProvider.videos[index];
                              return VideoCard(
                                video: video,
                                onEdit: () => _setupForEdit(video),
                                onDelete: () => _confirmDelete(video),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}