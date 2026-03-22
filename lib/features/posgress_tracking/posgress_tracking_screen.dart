// lib/views/client/progress_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/models/progress_image.dart';
import 'image_view_screen.dart';
import 'progress_image_view.dart';
import 'progress_tracking_controller.dart';
import 'sliver_app_bar_delegate.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late ProgressTrackingController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProgressTrackingController());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Track Your Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.blueGradient,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visualize Your Journey',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            delegate: SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All Photos'),
                  Tab(text: 'Front'),
                  Tab(text: 'Side'),
                ],
              ),
            ),
            pinned: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllPhotosTab(),
                  _buildFilteredPhotosTab(ProgressImageType.front),
                  _buildFilteredPhotosTab(ProgressImageType.side),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCaptureOptions,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture'),
      ),
    );
  }

  Widget _buildAllPhotosTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.progressImages.isEmpty) {
        return _buildEmptyState();
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress Timeline', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Track your body changes over time',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),

            _buildProgressChart(),

            const SizedBox(height: 24),

            Text(
              'All Photos (${_controller.progressImages.length})',
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),

            Expanded(child: _buildImageGrid(_controller.progressImages)),
          ],
        ),
      );
    });
  }

  Widget _buildFilteredPhotosTab(ProgressImageType type) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredImages =
          _controller.progressImages
              .where((image) => image.type == type)
              .toList();

      if (filteredImages.isEmpty) {
        return _buildEmptyStateForType(type);
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${type == ProgressImageType.front ? 'Front' : 'Side'} View Progress',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Compare your ${type == ProgressImageType.front ? 'front' : 'side'} view progress over time',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),

            if (filteredImages.length >= 2)
              _buildComparisonView(filteredImages),

            const SizedBox(height: 24),

            Text(
              '${type == ProgressImageType.front ? 'Front' : 'Side'} Photos (${filteredImages.length})',
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),

            Expanded(child: _buildImageGrid(filteredImages)),
          ],
        ),
      );
    });
  }

  Widget _buildProgressChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        // Group images by month
        final groupedData = _controller.getMonthlyProgressCount();
        if (groupedData.isEmpty) {
          return const Center(
            child: Text('Not enough data to show progress chart'),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              groupedData.entries.map((entry) {
                // Find the maximum value for scaling
                final maxValue = groupedData.values.reduce(
                  (a, b) => a > b ? a : b,
                );
                // Calculate height based on percentage of max (minimum 5 pixels)
                final height =
                    maxValue > 0 ? 60 * (entry.value / maxValue) : 5.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: height,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.key, style: AppTextStyles.bodySmall),
                  ],
                );
              }).toList(),
        );
      }),
    );
  }

  Widget _buildComparisonView(List<ProgressImage> images) {
    // Sort by date, newest first
    final sortedImages = List<ProgressImage>.from(images)
      ..sort((a, b) => b.date.compareTo(a.date));

    final latest = sortedImages.first;
    final oldest = sortedImages.last;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Before', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ProgressImageView(
                    imagePath: oldest.imagePath,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(oldest.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text('Now', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ProgressImageView(
                    imagePath: latest.imagePath,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(latest.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<ProgressImage> images) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () => _viewImage(image),
          child: Hero(
            tag: 'progress_image_${image.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProgressImageView(
                    imagePath: image.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Text(
                        DateFormat('MMM d').format(image.date),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        image.type == ProgressImageType.front
                            ? Icons.person
                            : Icons.person_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text('No Progress Photos Yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Take your first progress photo to start tracking your fitness journey',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCaptureOptions,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Take First Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForType(ProgressImageType type) {
    final typeText = type == ProgressImageType.front ? 'Front' : 'Side';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == ProgressImageType.front
                ? Icons.person_outlined
                : Icons.person_outline,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text('No $typeText View Photos Yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Take your first $typeText view photo to start tracking',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _captureImage(type),
            icon: const Icon(Icons.add_a_photo),
            label: Text('Take $typeText Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCaptureOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Front View Photo'),
                leading: const Icon(Icons.person, color: AppColors.primaryBlue),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ProgressImageType.front);
                },
              ),
              ListTile(
                title: const Text('Side View Photo'),
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.secondaryPurple,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ProgressImageType.side);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureImage(ProgressImageType type) async {
    final cameraPermission = await Permission.camera.request();

    if (cameraPermission.isDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is required to take progress photos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (cameraPermission.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Denied',
        'Please enable camera permission from app settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () {
            openAppSettings();
          },
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90, // Optimize image quality while reducing size
      );

      if (pickedFile != null) {
        await _controller.saveProgressImage(pickedFile.path, type);

        // Show success message
        Get.snackbar(
          'Success',
          'Progress photo saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save progress photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _viewImage(ProgressImage image) {
    Get.to(() => ImageViewScreen(image: image));
  }
}
