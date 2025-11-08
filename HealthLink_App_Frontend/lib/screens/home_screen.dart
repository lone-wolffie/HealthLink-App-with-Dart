import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/alerts_screen.dart';
import 'package:healthlink_app/screens/clinics_screen.dart';
import 'package:healthlink_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({
    super.key, 
    required this.userId
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Bottom navigation screens
    final List<Widget> screens = [
      _HomeDashboard(userId: widget.userId),
      AddSymptomScreen(userId: widget.userId),
      ClinicsScreen(),
      AlertsScreen(),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),

      body: SafeArea(child: screens[_selectedIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: const Color.fromARGB(255, 33, 33, 33),

        onTap: (index) => setState(() => _selectedIndex = index),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), 
            label: 'Add Symptom'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital), 
            label: 'Clinics'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.warning), 
            label: 'Alerts'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final int userId;
  const _HomeDashboard({required this.userId});

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  String username = "";

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? ""; // fallback if empty
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            // ✅ Centered Welcome Text with Username
            Center(
              child: Column(
                children: [
                  Text(
                    username.isNotEmpty ? "Welcome $username 👋" : "Welcome 👋",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your health and wellness with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ Top Feature Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, size: 55, color: Colors.green.shade700),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Track symptoms early to stay healthier and informed 💚',
                      style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Quick Actions
            GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _ActionTile(
                  icon: Icons.history,
                  label: 'Symptom History',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SymptomHistoryScreen(userId: widget.userId)),
                  ),
                ),
                _ActionTile(
                  icon: Icons.add_circle_outline,
                  label: 'Add Symptom',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSymptomScreen(userId: widget.userId)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// Reusable Tile Widget
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon, 
    required this.label, 
    required this.color, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                size: 42, 
                color: color
              ),
              const SizedBox(height: 8),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w600, 
                  color: color
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
