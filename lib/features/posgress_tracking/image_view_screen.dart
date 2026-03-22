// lib/views/client/image_view_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/models/progress_image.dart';
import 'progress_image_view.dart';
import 'progress_tracking_controller.dart';

class ImageViewScreen extends StatefulWidget {
  final ProgressImage image;

  const ImageViewScreen({super.key, required this.image});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  late TextEditingController _notesController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.image.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressTrackingController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _showControls
              ? AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  DateFormat('MMMM d, yyyy').format(widget.image.date),
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  // Removed share button as requested
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _confirmDelete(context, controller),
                  ),
                ],
              )
              : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'progress_image_${widget.image.id}',
                  child: ProgressImageView(
                    imagePath: widget.image.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (_showControls)
              Container(
                color: Colors.black.withOpacity(0.8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.image.type.name.capitalize} View',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(widget.image.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this photo...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      onChanged:
                          (value) => controller.updateImageNotes(
                            widget.image.id,
                            value,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProgressTrackingController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Image'),
            content: const Text(
              'Are you sure you want to delete this progress photo? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.deleteProgressImage(widget.image.id).then((_) {
                    Get.back(); // Return to previous screen
                  });
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
