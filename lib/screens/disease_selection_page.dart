import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_level_page.dart'; // Next onboarding step

class DiseaseSelectionPage extends StatefulWidget {
  final String userId; // User ID for Firebase storage

  DiseaseSelectionPage({required this.userId});

  @override
  _DiseaseSelectionPageState createState() => _DiseaseSelectionPageState();
}

class _DiseaseSelectionPageState extends State<DiseaseSelectionPage> {
  bool hasMedicalCondition = false;
  bool isYesSelected = false;
  List<String> selectedDiseases = [];

  // Updated List of diseases with icons
  final List<Map<String, dynamic>> diseases = [
    {'name': 'Diabetes', 'icon': Icons.bloodtype},
    {'name': 'Hypertension (High BP)', 'icon': Icons.favorite},
    {'name': 'PCOS/PCOD', 'icon': Icons.female},
    {'name': 'Obesity', 'icon': Icons.scale},
    {'name': 'Thyroid Disorders', 'icon': Icons.science},
    {'name': 'High Cholesterol', 'icon': Icons.health_and_safety},
    {'name': 'Heart Disease', 'icon': Icons.favorite_border},
    {'name': 'Kidney Disease', 'icon': Icons.water_drop},
    {'name': 'Liver Disease (Hepatitis, Cirrhosis)', 'icon': Icons.local_hospital},
    {'name': 'Gastric Issues (GERD, Ulcer)', 'icon': Icons.medical_services},
    {'name': 'Anemia', 'icon': Icons.healing},
    {'name': 'Celiac Disease', 'icon': Icons.fastfood},
    {'name': 'Osteoporosis', 'icon': Icons.emoji_people},
    {'name': 'Cancer (Chemo Diet)', 'icon': Icons.spa},
  ];

  void toggleDiseaseSelection(String disease) {
    setState(() {
      if (selectedDiseases.contains(disease)) {
        selectedDiseases.remove(disease);
      } else {
        selectedDiseases.add(disease);
      }
    });
  }

  // Save data to Firestore and navigate to Activity Level Page
  void saveAndContinue() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'medical_condition': hasMedicalCondition ? 'Yes' : 'No',
      'diseases': selectedDiseases,
    });

    // Navigate to Activity Level Page
    Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityLevelPage(userId: widget.userId)));
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
              value: 0.7,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ).animate().fadeIn(duration: 500.ms),

            SizedBox(height: 30),

            // Show question only if user has NOT selected 'Yes'
            if (!isYesSelected) ...[
              Text(
                "Do you have any medical condition that requires calorie management?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 600.ms),

              SizedBox(height: 20),

              Row(
                children: [
                  _buildChoiceButton("Yes", true),
                  SizedBox(width: 20),
                  _buildChoiceButton("No", false),
                ],
              ).animate().fadeIn(duration: 700.ms),
            ],

            SizedBox(height: 20),

            // Show disease options if 'Yes' is selected
            if (hasMedicalCondition)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select your medical conditions:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: 800.ms),

                  SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    children: diseases.map((disease) {
                      bool isSelected = selectedDiseases.contains(disease['name']);
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(disease['icon'], size: 20, color: isSelected ? Colors.white : Colors.grey[700]),
                            SizedBox(width: 5),
                            Text(disease['name']),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => toggleDiseaseSelection(disease['name']),
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        elevation: 2,
                      ).animate().fadeIn(duration: 900.ms);
                    }).toList(),
                  ),

                  SizedBox(height: 20),

                  if (selectedDiseases.isNotEmpty)
                    ElevatedButton(
                      onPressed: saveAndContinue,
                      child: Text("Continue"),
                    ).animate().scale(delay: 400.ms),
                ],
              ),

            // If user selects 'No', show continue button
            if (!hasMedicalCondition && isYesSelected)
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
    bool isSelected = (isYes && hasMedicalCondition) || (!isYes && !hasMedicalCondition);
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isYesSelected = true;
            hasMedicalCondition = isYes;
            selectedDiseases.clear(); // Reset diseases if re-selected
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
