import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'allergy_selection_page.dart';

class DietPreferencePage extends StatefulWidget {
  final String userId; // User ID for Firebase storage

  DietPreferencePage({required this.userId});

  @override
  _DietPreferencePageState createState() => _DietPreferencePageState();
}

class _DietPreferencePageState extends State<DietPreferencePage> {
  String? selectedDiet;

  // List of diet options
  final List<String> diets = [
    'Vegetarian',
    'Vegan',
    'Non-Vegetarian',
    'Keto',
    'Paleo',
    'Gluten-Free'
  ];

  // Save the selected diet in Firebase and navigate to the next page
  void saveAndContinue() async {
    if (selectedDiet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a diet preference!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'diet_preference': selectedDiet,
    });

    // Navigate to Allergy Selection Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllergySelectionPage(userId: widget.userId)),
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
              value: 0.85,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ),

            SizedBox(height: 30),

            Text(
              "Select Your Diet Preference",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Column(
              children: diets.map((diet) {
                return RadioListTile<String>(
                  title: Text(diet),
                  value: diet,
                  groupValue: selectedDiet,
                  onChanged: (value) {
                    setState(() {
                      selectedDiet = value;
                    });
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: saveAndContinue,
                child: Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
