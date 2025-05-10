import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int durationMinutes;
  final String intensityLevel;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;

  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.exercises,
    required this.durationMinutes,
    required this.intensityLevel,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
  });

  // Create a factory constructor for creating a Workout from Firestore data
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      exercises: (data['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      durationMinutes: data['durationMinutes'] as int,
      intensityLevel: data['intensityLevel'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  // Convert workout to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'durationMinutes': durationMinutes,
      'intensityLevel': intensityLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isCompleted': isCompleted,
    };
  }

  // Create a copy of the workout with updated fields
  Workout copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<Exercise>? exercises,
    int? durationMinutes,
    String? intensityLevel,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensityLevel: intensityLevel ?? this.intensityLevel,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Exercise {
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double? weightKg;
  final String? notes;
  final bool isCompleted;

  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.notes,
    this.isCompleted = false,
  });

  // Create from Map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      weightKg: map['weightKg'] != null ? (map['weightKg'] as num).toDouble() : null,
      notes: map['notes'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create a copy of the exercise with updated fields
  Exercise copyWith({
    String? name,
    String? muscleGroup,
    int? sets,
    int? reps,
    double? weightKg,
    String? notes,
    bool? isCompleted,
  }) {
    return Exercise(
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
} 