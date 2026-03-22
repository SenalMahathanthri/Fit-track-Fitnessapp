// lib/views/client/progress_tracking_controller.dart
import 'package:get/get.dart';
import '../../core/services/storage/local_storage_service.dart';
import '../../data/models/progress_image.dart';

class ProgressTrackingController extends GetxController {
  final ProgressImageStorage _storage = ProgressImageStorage();
  final RxList<ProgressImage> progressImages = <ProgressImage>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadImages();
  }

  Future<void> _loadImages() async {
    isLoading.value = true;
    try {
      await _storage.initialize();
      final images = await _storage.getAllImages();
      progressImages.assignAll(images);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load progress images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProgressImage(
    String imagePath,
    ProgressImageType type,
  ) async {
    isLoading.value = true;
    try {
      final savedImage = await _storage.saveImage(imagePath, type);
      if (savedImage != null) {
        await _loadImages(); // Reload all images to ensure proper sorting
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save progress image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProgressImage(String id) async {
    isLoading.value = true;
    try {
      final success = await _storage.deleteImage(id);
      if (success) {
        // Remove from local list
        progressImages.removeWhere((image) => image.id == id);
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete progress image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateImageNotes(String id, String notes) async {
    try {
      final success = await _storage.updateImageMetadata(id, notes: notes);
      if (success) {
        // Update local list
        final index = progressImages.indexWhere((image) => image.id == id);
        if (index != -1) {
          progressImages[index] = progressImages[index].copyWith(notes: notes);
        }
      } else {
        throw Exception('Failed to update image notes');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update image notes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Map<String, int> getMonthlyProgressCount() {
    try {
      // Group images by month and count them
      final Map<String, int> monthlyCount = {};

      for (var image in progressImages) {
        final month = '${image.date.month}/${image.date.year}';
        monthlyCount[month] = (monthlyCount[month] ?? 0) + 1;
      }

      return monthlyCount;
    } catch (e) {
      return {};
    }
  }
}
