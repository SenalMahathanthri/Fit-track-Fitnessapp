// lib/core/services/storage/progress_image_storage.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;

import '../../../data/models/progress_image.dart';

/// A service that handles all operations related to storing and retrieving progress images.
/// This includes saving images to the filesystem, managing metadata in SharedPreferences,
/// and providing utility methods for image processing.
class ProgressImageStorage {
  static const String _storageKey = 'progress_tracking_images';
  static const String _imageDirName = 'progress_images';

  /// Singleton instance
  static final ProgressImageStorage _instance =
      ProgressImageStorage._internal();

  /// Factory constructor
  factory ProgressImageStorage() => _instance;

  /// Private constructor for singleton
  ProgressImageStorage._internal();

  /// Directory where images are stored
  Directory? _imageDirectory;

  /// Initialize the storage service
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _imageDirectory = Directory('${appDir.path}/$_imageDirName');

      // Ensure directory exists
      if (!await _imageDirectory!.exists()) {
        await _imageDirectory!.create(recursive: true);
      }

      // Verify permissions by writing a test file
      await _verifyStorageAccess();

      debugPrint('ProgressImageStorage initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ProgressImageStorage: $e');
      rethrow;
    }
  }

  /// Verify storage access by writing and reading a test file
  Future<void> _verifyStorageAccess() async {
    try {
      final testFile = File('${_imageDirectory!.path}/test_access.txt');
      await testFile.writeAsString('Storage access test');
      final content = await testFile.readAsString();
      await testFile.delete();

      if (content != 'Storage access test') {
        throw Exception('Storage verification failed: content mismatch');
      }
    } catch (e) {
      debugPrint('Storage access verification failed: $e');
      rethrow;
    }
  }

  /// Get all progress images from storage
  Future<List<ProgressImage>> getAllImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString(_storageKey);

      if (jsonData == null || jsonData.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonData);
      final List<ProgressImage> images = [];

      for (var item in decoded) {
        try {
          final image = ProgressImage.fromJson(item as Map<String, dynamic>);

          // Verify file exists
          final file = File(image.imagePath);
          if (await file.exists()) {
            images.add(image);
          } else {
            debugPrint('Image file not found: ${image.imagePath}');
            // Skip this image as the file is missing
          }
        } catch (e) {
          debugPrint('Error parsing image data: $e');
          // Continue to next image
        }
      }

      // Sort by date, newest first
      images.sort((a, b) => b.date.compareTo(a.date));
      return images;
    } catch (e) {
      debugPrint('Error loading progress images: $e');
      return [];
    }
  }

  /// Save a new progress image
  Future<ProgressImage?> saveImage(
    String sourcePath,
    ProgressImageType type,
  ) async {
    try {
      if (_imageDirectory == null) {
        await initialize();
      }

      // Generate a unique ID
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final String fileName = 'progress_${type.name}_${timestamp}_$id.jpg';
      final String destinationPath = '${_imageDirectory!.path}/$fileName';

      // Create source file reference
      final File sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source image file not found: $sourcePath');
      }

      // Process and optimize the image
      final optimizedImage = await _processImage(sourceFile);

      // Save the processed image
      final File destinationFile = File(destinationPath);
      await destinationFile.writeAsBytes(optimizedImage);

      // Verify the file was saved
      if (!await destinationFile.exists()) {
        throw Exception('Failed to save image to $destinationPath');
      }

      // Create the progress image object
      final progressImage = ProgressImage(
        id: id,
        imagePath: destinationPath,
        date: now,
        type: type,
        notes: '',
      );

      // Save metadata to shared preferences
      await _saveImageMetadata(progressImage);

      debugPrint('Image saved successfully to: $destinationPath');
      return progressImage;
    } catch (e) {
      debugPrint('Error saving progress image: $e');
      return null;
    }
  }

  /// Process image - resize, compress and optimize for storage
  Future<Uint8List> _processImage(File sourceFile) async {
    try {
      // Read the image file
      final bytes = await sourceFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if image is too large (maintain aspect ratio)
      img.Image resized;
      if (image.width > 1200 || image.height > 1200) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: 1200);
        } else {
          resized = img.copyResize(image, height: 1200);
        }
      } else {
        resized = image;
      }

      // Compress the image
      final compressed = img.encodeJpg(resized, quality: 85);
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('Error processing image: $e');
      // If processing fails, return the original image data
      return await sourceFile.readAsBytes();
    }
  }

  /// Save image metadata to SharedPreferences
  Future<void> _saveImageMetadata(ProgressImage image) async {
    try {
      // Get existing images
      final List<ProgressImage> images = await getAllImages();

      // Add the new image
      images.add(image);

      // Convert to JSON
      final List<Map<String, dynamic>> jsonList =
          images.map((img) => img.toJson()).toList();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving image metadata: $e');
      rethrow;
    }
  }

  /// Delete a progress image
  Future<bool> deleteImage(String id) async {
    try {
      // Get all images
      final List<ProgressImage> images = await getAllImages();

      // Find the image to delete
      final imageToDelete = images.firstWhere(
        (img) => img.id == id,
        orElse: () => throw Exception('Image not found with ID: $id'),
      );

      // Delete the file
      final file = File(imageToDelete.imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from the list
      images.removeWhere((img) => img.id == id);

      // Update SharedPreferences
      final jsonList = images.map((img) => img.toJson()).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      debugPrint('Progress image deleted: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting progress image: $e');
      return false;
    }
  }

  /// Update image metadata (notes, etc.)
  Future<bool> updateImageMetadata(String id, {String? notes}) async {
    try {
      // Get all images
      final List<ProgressImage> images = await getAllImages();

      // Find and update the image
      final index = images.indexWhere((img) => img.id == id);
      if (index == -1) {
        throw Exception('Image not found with ID: $id');
      }

      // Create updated image
      final updatedImage = ProgressImage(
        id: images[index].id,
        imagePath: images[index].imagePath,
        date: images[index].date,
        type: images[index].type,
        notes: notes ?? images[index].notes,
      );

      // Replace in list
      images[index] = updatedImage;

      // Save to SharedPreferences
      final jsonList = images.map((img) => img.toJson()).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      return true;
    } catch (e) {
      debugPrint('Error updating image metadata: $e');
      return false;
    }
  }

  /// Get images by type
  Future<List<ProgressImage>> getImagesByType(ProgressImageType type) async {
    final List<ProgressImage> allImages = await getAllImages();
    return allImages.where((img) => img.type == type).toList();
  }

  /// Get monthly statistics
  Future<Map<String, int>> getMonthlyImageCounts() async {
    final List<ProgressImage> allImages = await getAllImages();
    final Map<String, int> monthlyCounts = {};

    for (var image in allImages) {
      final String monthKey = DateFormat('MMM yyyy').format(image.date);
      monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
    }

    return monthlyCounts;
  }

  /// Clean up any temporary files
  Future<void> cleanTemporaryFiles() async {
    try {
      if (_imageDirectory == null) return;

      final tempFiles =
          await _imageDirectory!
              .list()
              .where((entity) => entity.path.contains('temp_'))
              .toList();

      for (var file in tempFiles) {
        if (file is File) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning temporary files: $e');
    }
  }
}
