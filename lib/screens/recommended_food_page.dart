import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';

class RecommendedFoodPage extends StatefulWidget {
  final String userId;

  const RecommendedFoodPage({required this.userId});

  @override
  _RecommendedFoodPageState createState() => _RecommendedFoodPageState();
}

class _RecommendedFoodPageState extends State<RecommendedFoodPage> {
  Map<String, List<Map<String, dynamic>>> categorizedFoods = {
    'Breakfast': [],
    'Snack': [],
    'Lunch': [],
    'Dinner': [],
  };

  @override
  void initState() {
    super.initState();
    fetchAndCategorizeFoods();
  }

  Future<void> fetchAndCategorizeFoods() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (!userDoc.exists) return;

    final userData = userDoc.data()!;
    final List allergies = userData['allergies'] ?? [];
    final List userDiseases = userData['diseases'] ?? [];
    final String userDiet = userData['diet_preference'] ?? 'Any';

    final snapshot = await FirebaseFirestore.instance
        .collection('food_recommendations')
        .where('diet_type', isEqualTo: userDiet)
        .get();

    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Breakfast': [],
      'Snack': [],
      'Lunch': [],
      'Dinner': [],
    };

    for (var doc in snapshot.docs) {
      final food = doc.data();

      final allergens = food['allergens'] ?? [];
      final friendlyDiseases = food['disease_friendly'] ?? [];
      final category = food['category'] ?? 'Snack';

      if (allergies.any((a) => allergens.contains(a))) continue;
      if (userDiseases.isNotEmpty && !friendlyDiseases.any((d) => userDiseases.contains(d))) continue;

      final foodMap = {
        'id': doc.id,
        'name': food['name'],
        'calories': food['calories'],
        'protein': food['protein'],
        'carbs': food['carbs'],
        'fats': food['fats'],
        'category': category,
      };

      if (grouped.containsKey(category)) {
        grouped[category]!.add(foodMap);
      } else {
        grouped['Snack']!.add(foodMap); // fallback
      }
    }

    setState(() {
      categorizedFoods = grouped;
    });
  }

  Future<void> logFood(Map<String, dynamic> food) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('logged_foods')
        .add({
      'name': food['name'],
      'calories': food['calories'],
      'protein': food['protein'],
      'carbs': food['carbs'],
      'fats': food['fats'],
      'category': food['category'] ?? 'Other',
      'timestamp': Timestamp.now(),
      
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food['name']} logged successfully!')),
    );
  }

  Widget buildMealSection(String title, List<Map<String, dynamic>> foods) {
    if (foods.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInDown(
          duration: Duration(milliseconds: 400),
          child: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
        SizedBox(height: 8),
        ...foods.map((food) => FadeInUp(
              duration: Duration(milliseconds: 400),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: Icon(Icons.fastfood, color: Colors.teal),
                  ),
                  title: Text(food['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    "${food['calories']} kcal | Protein: ${food['protein']}g | Carbs: ${food['carbs']}g | Fats: ${food['fats']}g",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => logFood(food),
                    child: Text("Log"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            )),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return categorizedFoods.values.every((list) => list.isEmpty)
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 64, color: Colors.grey[400]),
                SizedBox(height: 10),
                Text(
                  "No recommended foods available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categorizedFoods.entries
                  .map((entry) => buildMealSection(entry.key, entry.value))
                  .toList(),
            ),
          );
  }
}
