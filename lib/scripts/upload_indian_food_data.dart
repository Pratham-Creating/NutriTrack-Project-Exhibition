import 'package:cloud_firestore/cloud_firestore.dart';

void uploadFoodData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> foodData = [
    // 🍳 Indian Breakfast Items
    {"name": "Poha", "calories": 250, "protein": 6, "carbs": 40, "fats": 4, "category": "Breakfast", "diet_type": "Vegetarian", "allergens": [], "disease_friendly": ["Diabetes"]},
    {"name": "Idli & Sambar", "calories": 300, "protein": 10, "carbs": 50, "fats": 2, "category": "Breakfast", "diet_type": "Vegetarian", "allergens": ["Gluten"], "disease_friendly": ["Diabetes", "Heart Disease"]},
    {"name": "Besan Chilla", "calories": 200, "protein": 12, "carbs": 30, "fats": 5, "category": "Breakfast", "diet_type": "Vegan", "allergens": [], "disease_friendly": ["Diabetes"]},
    {"name": "Masala Oats", "calories": 220, "protein": 8, "carbs": 35, "fats": 4, "category": "Breakfast", "diet_type": "Vegetarian", "allergens": ["Gluten"], "disease_friendly": ["Diabetes"]},
    {"name": "Sprouts Salad", "calories": 180, "protein": 15, "carbs": 25, "fats": 3, "category": "Breakfast", "diet_type": "Vegan", "allergens": [], "disease_friendly": ["Diabetes", "Heart Disease"]},

    // 🍪 Indian Snacks
    {"name": "Roasted Chana", "calories": 150, "protein": 10, "carbs": 20, "fats": 2, "category": "Snack", "diet_type": "Vegan", "allergens": [], "disease_friendly": ["Diabetes", "Heart Disease"]},
    {"name": "Peanut Chikki", "calories": 250, "protein": 8, "carbs": 35, "fats": 10, "category": "Snack", "diet_type": "Vegetarian", "allergens": ["Peanuts"], "disease_friendly": ["Diabetes"]},
    {"name": "Makhanas (Fox Nuts)", "calories": 100, "protein": 4, "carbs": 15, "fats": 2, "category": "Snack", "diet_type": "Vegan", "allergens": [], "disease_friendly": ["Diabetes"]},
    {"name": "Hummus with Vegetable Sticks", "calories": 180, "protein": 6, "carbs": 20, "fats": 8, "category": "Snack", "diet_type": "Vegan", "allergens": ["Sesame"], "disease_friendly": ["Diabetes", "Heart Disease"]},
    
    // 🍛 Indian Lunch Items
    {"name": "Dal Tadka & Brown Rice", "calories": 400, "protein": 20, "carbs": 60, "fats": 10, "category": "Lunch", "diet_type": "Vegetarian", "allergens": [], "disease_friendly": ["Diabetes"]},
    {"name": "Palak Paneer", "calories": 350, "protein": 22, "carbs": 25, "fats": 15, "category": "Lunch", "diet_type": "Vegetarian", "allergens": ["Dairy"], "disease_friendly": ["Diabetes"]},
    {"name": "Chicken Curry & Whole Wheat Roti", "calories": 500, "protein": 40, "carbs": 50, "fats": 15, "category": "Lunch", "diet_type": "Non-Vegetarian", "allergens": [], "disease_friendly": ["Diabetes", "Heart Disease"]},
    {"name": "Rajma & Brown Rice", "calories": 420, "protein": 18, "carbs": 60, "fats": 8, "category": "Lunch", "diet_type": "Vegan", "allergens": [], "disease_friendly": ["Diabetes"]},
    
    // 🍲 Indian Dinner Items
    {"name": "Grilled Paneer & Stir-Fried Vegetables", "calories": 350, "protein": 30, "carbs": 25, "fats": 12, "category": "Dinner", "diet_type": "Vegetarian", "allergens": ["Dairy"], "disease_friendly": ["Diabetes"]},
    {"name": "Dal Khichdi", "calories": 380, "protein": 20, "carbs": 55, "fats": 8, "category": "Dinner", "diet_type": "Vegetarian", "allergens": [], "disease_friendly": ["Diabetes", "Heart Disease"]},
    {"name": "Grilled Fish & Mixed Greens", "calories": 400, "protein": 45, "carbs": 20, "fats": 10, "category": "Dinner", "diet_type": "Non-Vegetarian", "allergens": ["Fish"], "disease_friendly": ["Heart Disease"]},
  ];

  try {
    for (var food in foodData) {
      await firestore.collection("food_recommendations").add(food);
    }
    print("✅ Food data uploaded successfully!");
  } catch (e) {
    print("❌ Error uploading food data: $e");
  }
}