import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/screens/onboarding_height_weight_screen.dart';
// import 'package:uuid/uuid.dart'; // For generating unique user IDs

class OnboardingAgeScreen extends StatefulWidget {
  final String userId; // ✅ Use the user ID from sign-up

  const OnboardingAgeScreen({super.key, required this.userId}); // ✅ Pass userId

  @override
  _OnboardingAgeScreenState createState() => _OnboardingAgeScreenState();
}

class _OnboardingAgeScreenState extends State<OnboardingAgeScreen> {
  double _age = 18; // Default age

  Future<void> saveUserAge() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'age': _age.toInt(),
    }, SetOptions(merge: true)); // ✅ Merge to avoid overwriting existing data
  }

  void nextPage() async {
    await saveUserAge(); // Save age before moving forward

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingHeightWeightScreen(userId: widget.userId, age: _age.toInt()), // ✅ Pass correct userId
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Age")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("How old are you?", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("${_age.toInt()} years", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Slider(
              value: _age,
              min: 1,
              max: 100,
              divisions: 99, // 1 to 100
              label: _age.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _age = value;
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
