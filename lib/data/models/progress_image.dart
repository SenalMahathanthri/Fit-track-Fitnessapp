// lib/data/models/progress_image.dart
import 'package:equatable/equatable.dart';

enum ProgressImageType { front, side }

/// Model class for storing progress image information
class ProgressImage extends Equatable {
  final String id;
  final String imagePath;
  final DateTime date;
  final ProgressImageType type;
  final String notes;

  const ProgressImage({
    required this.id,
    required this.imagePath,
    required this.date,
    required this.type,
    this.notes = '',
  });

  /// Create from JSON
  factory ProgressImage.fromJson(Map<String, dynamic> json) {
    return ProgressImage(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      date: DateTime.parse(json['date'] as String),
      type: ProgressImageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProgressImageType.front,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'type': type.name,
      'notes': notes,
    };
  }

  /// Create a copy with optional changes
  ProgressImage copyWith({
    String? id,
    String? imagePath,
    DateTime? date,
    ProgressImageType? type,
    String? notes,
  }) {
    return ProgressImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, imagePath, date, type, notes];
}
