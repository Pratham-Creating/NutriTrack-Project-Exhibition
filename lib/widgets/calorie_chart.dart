import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CalorieChart extends StatelessWidget {
  final double totalCalories;
  final List<Map<String, dynamic>> loggedFoods;

  const CalorieChart({
    required this.totalCalories,
    required this.loggedFoods,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      'Breakfast': Colors.blue,
      'Snack': Colors.orange,
      'Lunch': Colors.green,
      'Dinner': Colors.purple,
      'Other': Colors.teal,
    };

    // Group calories by category
    final Map<String, double> caloriesByCategory = {};
    double totalConsumed = 0;

    for (var food in loggedFoods) {
      final category = (food['category'] ?? 'Other') as String;
      final calories = (food['calories'] ?? 0).toDouble();

      caloriesByCategory[category] = (caloriesByCategory[category] ?? 0) + calories;
      totalConsumed += calories;
    }

    double remaining = (totalCalories - totalConsumed).clamp(0, totalCalories);

    // Build chart sections
    final sections = caloriesByCategory.entries.map((entry) {
      final value = entry.value;
      final color = categoryColors[entry.key] ?? Colors.teal;

      return PieChartSectionData(
        value: value,
        color: color,
        title: "${entry.key}\n${value.toStringAsFixed(0)} kcal",
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    // Add remaining calories
    if (remaining > 0) {
      sections.add(
        PieChartSectionData(
          value: remaining,
          color: Colors.grey[300],
          title: '',
          radius: 60,
        ),
      );
    }

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Calorie Intake by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Allowed: ${totalCalories.toStringAsFixed(0)} kcal"),
          ],
        ),
      ),
    );
  }
}
