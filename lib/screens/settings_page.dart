import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); // 👈 update this if your login route is different
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Settings",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text("Logout", style: TextStyle(fontSize: 18)),
            onTap: () => _logout(context),
          ),
          Divider(),
          // You can add more settings here later
        ],
      ),
    );
  }
}
