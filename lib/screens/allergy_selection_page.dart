import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/screens/dashboard_screen.dart'; // ✅ Import Dashboard Screen

class AllergySelectionPage extends StatefulWidget {
  final String userId;

  AllergySelectionPage({required this.userId});

  @override
  _AllergySelectionPageState createState() => _AllergySelectionPageState();
}

class _AllergySelectionPageState extends State<AllergySelectionPage> {
  bool hasAllergies = false;
  List<String> selectedAllergies = [];

  // List of common food allergies
  final List<String> allergies = [
    'Peanuts', 'Tree Nuts', 'Dairy', 'Eggs', 'Shellfish',
    'Fish', 'Soy', 'Wheat (Gluten)', 'Sesame'
  ];

  void toggleAllergySelection(String allergy) {
    setState(() {
      if (selectedAllergies.contains(allergy)) {
        selectedAllergies.remove(allergy);
      } else {
        selectedAllergies.add(allergy);
      }
    });
  }

  // Save allergies to Firebase and navigate to Dashboard
  void saveAndContinue() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'has_allergies': hasAllergies ? 'Yes' : 'No',
      'allergies': hasAllergies ? selectedAllergies : [],
    }, SetOptions(merge: true)); // ✅ Prevents overwriting existing data

    // ✅ Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen(userId: widget.userId)),
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
              value: 1.0, // Final step in onboarding
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ),

            SizedBox(height: 30),

            Text(
              "Do you have any food allergies?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Row(
              children: [
                _buildChoiceButton("Yes", true),
                SizedBox(width: 20),
                _buildChoiceButton("No", false),
              ],
            ),

            SizedBox(height: 20),

            if (hasAllergies)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select your food allergies:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    children: allergies.map((allergy) {
                      bool isSelected = selectedAllergies.contains(allergy);
                      return ChoiceChip(
                        label: Text(allergy),
                        selected: isSelected,
                        onSelected: (_) => toggleAllergySelection(allergy),
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20),
                ],
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

  Widget _buildChoiceButton(String text, bool isYes) {
    bool isSelected = (isYes && hasAllergies) || (!isYes && !hasAllergies);
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            hasAllergies = isYes;
            selectedAllergies.clear(); // Reset allergies if re-selected
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(text),
      ),
    );
  }
}
