import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;

  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalCalories = 2000; // Default before fetching user data
  double consumedCalories = 0;
  double protein = 0, carbs = 0, fats = 0;
  List<Map<String, dynamic>> recommendedFoods = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAllFoods();  // Fetching all food items
  }

  void fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      print("🔥 Full User Data from Firestore: $data");
      int age = data['age'];
      double weight = data['weight'];
      double height = data['height'];
      String gender = data['gender'];
      String activityLevel = data['activity_level'];
      bool hasDisease = data['has_disease'] ?? false;

      setState(() {
        totalCalories = calculateCalories(age, weight, height, gender, activityLevel, hasDisease);
      });
    }
  }

  double calculateCalories(int age, double weight, double height, String gender, String activity, bool hasDisease) {
    double bmr;

    if (gender == "Male") {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double activityFactor;
    switch (activity) {
      case "Sedentary":
        activityFactor = 1.2;
        break;
      case "Lightly Active":
        activityFactor = 1.375;
        break;
      case "Moderately Active":
        activityFactor = 1.55;
        break;
      case "Very Active":
        activityFactor = 1.725;
        break;
      case "Super Active":
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    double totalCalories = bmr * activityFactor;

    if (hasDisease) {
      totalCalories *= 0.9; // Reduce by 10% for disease-specific cases
    }

    return totalCalories;
  }

  /// ✅ **New function to fetch all food items without filters**
  Future<void> fetchAllFoods() async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .get();

  if (!userDoc.exists) return;

  Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

  List allergies = userData['allergies'] ?? [];
  List userDiseases = userData['diseases'] ?? [];
  String userDiet = userData['diet_preference'] ?? "Any";

  QuerySnapshot foodSnapshot = await FirebaseFirestore.instance
      .collection('food_recommendations')
      .where('diet_type', isEqualTo: userDiet)
      .get();
  print("User Diet Preference: '${userData['diet_preference']}'");

  print("Total foods fetched from Firestore: ${foodSnapshot.docs.length}");

  List<Map<String, dynamic>> filteredFoods = [];

  for (var doc in foodSnapshot.docs) {
    Map<String, dynamic> food = doc.data() as Map<String, dynamic>;

    String name = food['name'] != null ? food['name'].toString() : "Unknown Food";
    double calories = (food['calories'] is num) ? (food['calories'] as num).toDouble() : 0;
    double protein = (food['protein'] is num) ? (food['protein'] as num).toDouble() : 0;
    double carbs = (food['carbs'] is num) ? (food['carbs'] as num).toDouble() : 0;
    double fats = (food['fats'] is num) ? (food['fats'] as num).toDouble() : 0;

    List foodAllergens = food['allergens'] ?? [];
    List foodDiseases = food['disease_friendly'] ?? [];

    // ✅ Restriction: Skip foods containing allergens
    bool containsAllergen = allergies.any((allergy) => foodAllergens.contains(allergy));
    if (containsAllergen) continue;

    // ✅ Restriction: Skip foods not friendly for user's diseases
    bool isDiseaseFriendly = userDiseases.isEmpty || foodDiseases.any((disease) => userDiseases.contains(disease));
    if (!isDiseaseFriendly) continue;

    print("Adding $name to recommendations.");

    filteredFoods.add({
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    });
  }

  print("Final recommended foods count: ${filteredFoods.length}");

  setState(() {
    recommendedFoods = filteredFoods;
  });
}




  void logout() async {
    await AuthService().signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.green,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Daily Calorie Intake", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              // Calorie Chart
              Container(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(value: consumedCalories, color: Colors.green, radius: 50, showTitle: false),
                          PieChartSectionData(value: totalCalories - consumedCalories, color: Colors.grey[300], radius: 50, showTitle: false),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${consumedCalories.toStringAsFixed(0)} kcal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("of ${totalCalories.toStringAsFixed(0)} kcal", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Macronutrient Breakdown
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Macronutrient Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        macronutrientBox("Protein", protein, Colors.orange),
                        macronutrientBox("Carbs", carbs, Colors.blue),
                        macronutrientBox("Fats", fats, Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Recommended Food Section
              Text("Recommended Food Diet for Today", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              recommendedFoods.isEmpty
                  ? Center(child: Text("No recommendations available"))
                  : Column(
                      children: recommendedFoods.map((food) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(food['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "${food['calories']} kcal | Protein: ${food['protein']}g | Carbs: ${food['carbs']}g | Fats: ${food['fats']}g"),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget macronutrientBox(String name, double value, Color color) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text("${value.toStringAsFixed(1)} g", style: TextStyle(fontSize: 14, color: color)),
        ),
      ],
    );
  }
}
