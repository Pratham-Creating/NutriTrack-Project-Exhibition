import 'package:flutter/material.dart';
import 'package:nutritrack/screens/signup_screen.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';  // Import Dashboard Screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    
    var user = await AuthService().signInWithEmail(email, password);

    if (user != null) {
      print("Login Successful!");
      
      // Navigate to the user's dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(userId: user.uid)),
      );
    } else {
      print("Login Failed!");
    }
  }

  void loginWithGoogle() async {
    var user = await AuthService().signInWithGoogle();
    
    if (user != null) {
      print("Google Login Successful!");

      // Navigate to the user's dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(userId: user.uid)),
      );
    } else {
      print("Google Login Failed!");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: loginWithGoogle, child: Text("Login with Google")),
            ElevatedButton(onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => SignupScreen()),);},
            child: Text("Don't have an account? Sign Up")),
          ],
        ),
      ),
    );
  }
}
