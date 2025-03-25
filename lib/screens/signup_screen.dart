import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'onboarding_age_screen.dart';  // Import onboarding

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    
    var user = await AuthService().signUpWithEmail(email, password);

    if (user != null) {
      String userId = user.uid;

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'userId': userId,
        'createdAt': DateTime.now(),
      });

      // Navigate to the first onboarding screen (Age selection)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingAgeScreen(userId: userId)),
      );
    } else {
      print("Signup Failed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
