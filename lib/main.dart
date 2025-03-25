import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:nutritrack/scripts/upload_indian_food_data.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriTrack',
      home: AuthWrapper(), // Automatically decide which screen to show
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading
        }

        if (snapshot.hasData) {
          String userId = snapshot.data!.uid;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                return DashboardScreen(userId: userId); 
              } else {
                // 🚀 If user exists in Auth but NOT in Firestore → Sign out and show login screen
                FirebaseAuth.instance.signOut();
                return LoginScreen();
              }

            },
          );
        }

        return LoginScreen(); // No user logged in -> Show login page
      },
    );
  }
}
