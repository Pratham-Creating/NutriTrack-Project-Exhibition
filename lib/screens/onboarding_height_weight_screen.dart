import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/screens/bmi_screen.dart';

class OnboardingHeightWeightScreen extends StatefulWidget {
  final String userId;
  final int age;

  const OnboardingHeightWeightScreen({super.key, required this.userId, required this.age});

  @override
  _OnboardingHeightWeightScreenState createState() =>
      _OnboardingHeightWeightScreenState();
}

class _OnboardingHeightWeightScreenState extends State<OnboardingHeightWeightScreen> {
  double _height = 160; // Default height in cm
  double _weight = 60;  // Default weight in kg

  Future<void> saveUserData() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'age': widget.age,
      'height': _height,
      'weight': _weight,
    }, SetOptions(merge: true)); // ✅ Merge data to avoid overwriting
  }

  void nextPage() async {
    await saveUserData(); // Save age, height, and weight before moving forward

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIScreen(userId: widget.userId, height: _height, weight: _weight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Height & Weight")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select your height", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("${_height.toInt()} cm", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Slider(
              value: _height,
              min: 100,
              max: 220,
              divisions: 120,
              label: _height.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _height = value;
                });
              },
            ),
            SizedBox(height: 30),
            Text("Select your weight", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("${_weight.toInt()} kg", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Slider(
              value: _weight,
              min: 30,
              max: 150,
              divisions: 120,
              label: _weight.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _weight = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextPage,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
