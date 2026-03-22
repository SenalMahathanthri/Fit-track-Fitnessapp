// lib/views/client/widgets/progress_image_view.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ProgressImageView extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProgressImageView({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: FutureBuilder<bool>(
        future: _checkFileExists(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final fileExists = snapshot.data ?? false;
          if (!fileExists) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'Image not found',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return Image.file(
            File(imagePath),
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image: $error');
              return Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(height: 4),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _checkFileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking if file exists: $e');
      return false;
    }
  }
}
