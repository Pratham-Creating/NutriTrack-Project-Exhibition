import 'package:flutter/material.dart';
import 'recommended_food_page.dart';
import 'logged_food_page.dart';
import 'settings_page.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecommendedFoodPage(userId: widget.userId),
      LoggedFoodPage(userId: widget.userId),
      const SettingsPage(), // ✅ Added SettingsPage here
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          "NutriTrack",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 6,
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Recommended',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_rounded),
              label: 'Logged',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
