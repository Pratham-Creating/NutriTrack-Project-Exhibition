import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieService {
  final String userId;
  CalorieService({required this.userId});

  Future<Map<String, dynamic>> calculateDailyNeeds() async {
    try {
      DocumentSnapshot userDoc = 
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      double weight = userData['weight']; // kg
      double height = userData['height']; // cm
      int age = userData['age'];
      String gender = userData['gender']; // "Male" or "Female"
      String activityLevel = userData['activity_level'];
      List<String> diseases = List<String>.from(userData['diseases'] ?? []);

      // Step 1: Calculate BMR (Mifflin-St Jeor Equation)
      double bmr = (gender == "Male")
          ? (10 * weight) + (6.25 * height) - (5 * age) + 5
          : (10 * weight) + (6.25 * height) - (5 * age) - 161;

      // Step 2: Apply Activity Level Factor
      Map<String, double> activityFactors = {
        "Sedentary": 1.2,
        "Lightly Active": 1.375,
        "Moderately Active": 1.55,
        "Very Active": 1.725,
        "Super Active": 1.9,
      };
      double dailyCalories = bmr * (activityFactors[activityLevel] ?? 1.2);

      // Step 3: Adjust Calories for Diseases
      if (diseases.contains("Diabetes")) {
        dailyCalories *= 0.9; // Reduce 10% calories
      } else if (diseases.contains("Heart Disease")) {
        dailyCalories *= 0.95; // Reduce 5% calories
      } else if (diseases.contains("Kidney Disease")) {
        dailyCalories *= 0.85; // Reduce 15% calories
      }

      // Step 4: Macronutrient Breakdown
      double protein = dailyCalories * 0.20 / 4; // 1g Protein = 4 kcal
      double carbs = dailyCalories * 0.50 / 4;   // 1g Carbs = 4 kcal
      double fats = dailyCalories * 0.30 / 9;    // 1g Fats = 9 kcal

      return {
        'calories': dailyCalories.round(),
        'protein': protein.round(),
        'carbs': carbs.round(),
        'fats': fats.round(),
      };
    } catch (e) {
      print("Error calculating daily needs: $e");
      return {};
    }
  }
}
