import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/calorie_chart.dart';

class LoggedFoodPage extends StatefulWidget {
  final String userId;

  const LoggedFoodPage({required this.userId});

  @override
  _LoggedFoodPageState createState() => _LoggedFoodPageState();
}

class _LoggedFoodPageState extends State<LoggedFoodPage> {
  List<Map<String, dynamic>> loggedFoods = [];
  double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFats = 0;
  double allowedCalories = 2000;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  String selectedCategory = 'Other';

  bool showManualLogger = false;

  @override
  void initState() {
    super.initState();
    fetchLoggedFoods();
    fetchUserCalorieLimit();
  }

  Future<void> fetchLoggedFoods() async {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('logged_foods')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('timestamp', descending: true)
        .get();

    double calories = 0, protein = 0, carbs = 0, fats = 0;
    final List<Map<String, dynamic>> foods = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      foods.add({...data, 'id': doc.id});
      calories += (data['calories'] ?? 0).toDouble();
      protein += (data['protein'] ?? 0).toDouble();
      carbs += (data['carbs'] ?? 0).toDouble();
      fats += (data['fats'] ?? 0).toDouble();
    }

    setState(() {
      loggedFoods = foods;
      totalCalories = calories;
      totalProtein = protein;
      totalCarbs = carbs;
      totalFats = fats;
    });
  }

  Future<void> fetchUserCalorieLimit() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data()!;
      int age = userData['age'];
      double weight = userData['weight'];
      double height = userData['height'];
      String gender = userData['gender'];
      String activity = userData['activity_level'];
      bool hasDisease = userData['has_disease'] ?? false;

      setState(() {
        allowedCalories = calculateCalories(age, weight, height, gender, activity, hasDisease);
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
      case "Sedentary": activityFactor = 1.2; break;
      case "Lightly Active": activityFactor = 1.375; break;
      case "Moderately Active": activityFactor = 1.55; break;
      case "Very Active": activityFactor = 1.725; break;
      case "Super Active": activityFactor = 1.9; break;
      default: activityFactor = 1.2;
    }

    double total = bmr * activityFactor;
    if (hasDisease) total *= 0.9;
    return total;
  }

  Future<void> addManualFood() async {
    final name = nameController.text.trim();
    final double calories = double.tryParse(caloriesController.text) ?? 0;
    final double protein = double.tryParse(proteinController.text) ?? 0;
    final double carbs = double.tryParse(carbsController.text) ?? 0;
    final double fats = double.tryParse(fatsController.text) ?? 0;

    if (name.isEmpty || calories == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid data")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('logged_foods')
        .add({
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'category': selectedCategory,
      'timestamp': Timestamp.now(),
    });

    nameController.clear();
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatsController.clear();
    selectedCategory = 'Other';

    await fetchLoggedFoods();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Food logged successfully!")),
    );
  }

  Future<void> deleteLoggedFood(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('logged_foods')
        .doc(docId)
        .delete();

    await fetchLoggedFoods();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Food deleted")),
    );
  }

  Widget nutrientSummary(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 4),
        Text("${value.toStringAsFixed(1)} g", style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalorieChart(
            totalCalories: allowedCalories,
            loggedFoods: loggedFoods,
          ),

          SizedBox(height: 24),
          Text("Today's Logged Foods", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),

          ...loggedFoods.asMap().entries.map((entry) {
            int index = entry.key;
            var food = entry.value;

            return FadeInUp(
              duration: Duration(milliseconds: 300 + index * 100),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                color: Colors.white,
                child: ListTile(
                  title: Text(food['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${food['calories']} kcal • Protein: ${food['protein']}g • Carbs: ${food['carbs']}g • Fats: ${food['fats']}g",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteLoggedFood(food['id']);
                    },
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 30),
          Text("Total Consumed", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              nutrientSummary("Calories", totalCalories, Colors.green),
              nutrientSummary("Protein", totalProtein, Colors.orange),
              nutrientSummary("Carbs", totalCarbs, Colors.blue),
              nutrientSummary("Fats", totalFats, Colors.purple),
            ],
          ),

          SizedBox(height: 40),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showManualLogger = !showManualLogger;
                });
              },
              icon: Icon(showManualLogger ? Icons.expand_less : Icons.expand_more),
              label: Text(showManualLogger ? "Hide Manual Logger" : "Manually Log Food"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          if (showManualLogger) ...[
            SizedBox(height: 20),
            _buildTextField(nameController, "Food Name"),
            _buildTextField(caloriesController, "Calories (kcal)", isNumber: true),
            _buildTextField(proteinController, "Protein (g)", isNumber: true),
            _buildTextField(carbsController, "Carbs (g)", isNumber: true),
            _buildTextField(fatsController, "Fats (g)", isNumber: true),

            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: ['Breakfast', 'Snack', 'Lunch', 'Dinner', 'Other']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: addManualFood,
                icon: Icon(Icons.add),
                label: Text("Log Food"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
