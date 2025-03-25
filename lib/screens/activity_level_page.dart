import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diet_preference_page.dart'; // Navigate to Diet Preference Page

class ActivityLevelPage extends StatefulWidget {
  final String userId;

  ActivityLevelPage({required this.userId});

  @override
  _ActivityLevelPageState createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<ActivityLevelPage> {
  String? selectedActivity;

  // List of activity levels
  final List<Map<String, dynamic>> activityLevels = [
    {'name': 'Sedentary (Little or No Exercise)', 'icon': Icons.chair, 'value': 'Sedentary'},
    {'name': 'Lightly Active (Light Exercise 1-3 Days)', 'icon': Icons.directions_walk, 'value': 'Lightly Active'},
    {'name': 'Moderately Active (Moderate Exercise 3-5 Days)', 'icon': Icons.directions_run, 'value': 'Moderately Active'},
    {'name': 'Very Active (Intense Exercise 6-7 Days)', 'icon': Icons.fitness_center, 'value': 'Very Active'},
    {'name': 'Super Active (Hard Physical Work/Training)', 'icon': Icons.sports, 'value': 'Super Active'},
  ];

  // Save activity level and navigate to Diet Preference Page
  void saveAndContinue() async {
    if (selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an activity level!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'activity_level': selectedActivity,
    });

    // Navigate to Diet Preference Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DietPreferencePage(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: 0.8, // Adjust progress accordingly
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ).animate().fadeIn(duration: 500.ms),

            SizedBox(height: 30),

            Text(
              "Select Your Activity Level",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 600.ms),

            SizedBox(height: 20),

            Wrap(
              spacing: 10,
              children: activityLevels.map((activity) {
                bool isSelected = selectedActivity == activity['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(activity['icon'], size: 20, color: isSelected ? Colors.white : Colors.grey[700]),
                      SizedBox(width: 5),
                      Text(activity['name']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedActivity = activity['value'];
                    });
                  },
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  elevation: 2,
                ).animate().fadeIn(duration: 700.ms);
              }).toList(),
            ),

            SizedBox(height: 20),

            if (selectedActivity != null)
              Center(
                child: ElevatedButton(
                  onPressed: saveAndContinue,
                  child: Text("Continue"),
                ).animate().scale(delay: 400.ms),
              ),
          ],
        ),
      ),
    );
  }
}
