import 'dart:convert';

enum ProgressImageType { front, side }

class ProgressImage {
  final String id;
  final String imagePath;
  final DateTime date;
  final ProgressImageType type;
  final String notes;
  final Map<String, double>? measurements;

  ProgressImage({
    required this.id,
    required this.imagePath,
    required this.date,
    required this.type,
    this.notes = '',
    this.measurements,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'type': type.name,
      'notes': notes,
      'measurements': measurements,
    };
  }

  // Create from Map (for retrieval from storage)
  factory ProgressImage.fromMap(Map<String, dynamic> map) {
    return ProgressImage(
      id: map['id'],
      imagePath: map['imagePath'],
      date: DateTime.parse(map['date']),
      type: ProgressImageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProgressImageType.front,
      ),
      notes: map['notes'] ?? '',
      measurements:
          map['measurements'] != null
              ? Map<String, double>.from(map['measurements'])
              : null,
    );
  }

  // JSON serialization
  String toJson() => json.encode(toMap());
  factory ProgressImage.fromJson(String source) =>
      ProgressImage.fromMap(json.decode(source));

  // Copy with method for updating
  ProgressImage copyWith({
    String? id,
    String? imagePath,
    DateTime? date,
    ProgressImageType? type,
    String? notes,
    Map<String, double>? measurements,
  }) {
    return ProgressImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      measurements: measurements ?? this.measurements,
    );
  }
}
