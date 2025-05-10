import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/health_data_model.dart';
import '../models/recommendation_model.dart';

class FirestoreHelper {
  static Map<String, dynamic> userToMap(User user) {
    final base = {
      'id': user.id,
      'name': user.name,
      'age': user.age,
      'gender': user.gender,
      'height': user.height,
      'weight': user.weight,
      'healthGoal': user.healthGoal,
      'joinDate': user.joinDate,
      'userType': _getUserType(user),
    };

    if (user is Beginner) {
      base.addAll({
        'motivationLevel': user.motivationLevel,
        'learningPreferences': user.learningPreferences,
        'hasPreviousInjury': user.hasPreviousInjury,
      });
    }
    else if (user is WeightMgmtUser) {
      base.addAll({
        'targetWeight': user.targetWeight,
        'dietPreference': user.dietPreference,
        'weeklyGoal': user.weeklyGoal,
        'dietaryRestrictions': user.dietaryRestrictions,
      });
    }
    return base;
  }

  static String _getUserType(User user) {
    if (user is Beginner) return 'beginner';
    if (user is WeightMgmtUser) return 'weightManagement';
    if (user is FitnessUser) return 'fitness';
    if (user is Elder) return 'elder';
    if (user is BusyUser) return 'busy';
    throw Exception('Unknown user type');
  }

  static Future<User?> getUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return _userFromMap(doc.data()!);
    } catch (e) {
      throw 'Failed to load user data';
    }
  }

  static User _userFromMap(Map<String, dynamic> data) {
    switch (data['userType']) {
      case 'beginner':
        return Beginner(
          id: data['id'],
          name: data['name'],
          age: data['age'],
          gender: data['gender'],
          height: data['height'],
          weight: data['weight'],
          healthGoal: data['healthGoal'],
          joinDate: data['joinDate'].toDate(),
          motivationLevel: data['motivationLevel'],
          learningPreferences: List<String>.from(data['learningPreferences']),
          hasPreviousInjury: data['hasPreviousInjury'],
        );
      case 'weightManagement':
        return WeightMgmtUser(
          id: data['id'],
          name: data['name'],
          age: data['age'],
          gender: data['gender'],
          height: data['height'],
          weight: data['weight'],
          healthGoal: data['healthGoal'],
          joinDate: data['joinDate'].toDate(),
          targetWeight: data['targetWeight'],
          dietPreference: data['dietPreference'],
          weeklyGoal: data['weeklyGoal'],
          dietaryRestrictions: List<String>.from(data['dietaryRestrictions']),
        );
    // Add other user types...
      default:
        throw Exception('Unknown user type');
    }
  }

  static Map<String, dynamic> healthDataToMap(HealthDataPoint data) {
    return {
      'userId': data.userId,
      'date': Timestamp.fromDate(data.date),
      'value': data.value,
      'metric': data.metric,
      'category': data.category,
      'notes': data.notes,
    };
  }

  static Map<String, dynamic> recommendationToMap(Recommendation rec) {
    final base = {
      'planName': rec.planName,
      'generatedAt': FieldValue.serverTimestamp(),
    };

    if (rec is DietPlan) {
      base.addAll({
        'type': 'diet',
        'targetCalories': rec.targetCalories,
        'dietType': rec.dietType,
      });
    }
    else if (rec is ExercisePlan) {
      base.addAll({
        'type': 'exercise',
        'duration': rec.durationPerSession,
        'frequency': rec.frequencyPerWeek,
      });
    }
    return base;
  }
}