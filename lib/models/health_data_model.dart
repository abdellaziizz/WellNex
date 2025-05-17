import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDataPoint {
  final String id;
  final String userId;
  final DateTime date;
  final double value;
  final String metric;
  final String? notes;
  final String category; // e.g., 'weight', 'sleep', 'hydration', 'steps', etc.

  HealthDataPoint({
    required this.id,
    required this.userId,
    required this.date,
    required this.value,
    required this.metric,
    required this.category,
    this.notes,
  });

  // Create from Firestore document
  factory HealthDataPoint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthDataPoint(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      value: (data['value'] as num).toDouble(),
      metric: data['metric'] as String,
      category: data['category'] as String,
      notes: data['notes'] as String?,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'value': value,
      'metric': metric,
      'category': category,
      'notes': notes,
    };
  }

  // Create a copy with updated fields
  HealthDataPoint copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? value,
    String? metric,
    String? category,
    String? notes,
  }) {
    return HealthDataPoint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      value: value ?? this.value,
      metric: metric ?? this.metric,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
