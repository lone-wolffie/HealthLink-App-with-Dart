// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   final int userId;

//   const HomeScreen({
//     super.key, 
//     required this.userId
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('HealthLink App Home'),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Welcome Back!',
//               style: Theme.of(context).textTheme.headlineMedium,
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/symptomHistory',
//                   arguments: userId,
//                 );
//               },
//               child: const Text('My Symptom History'),
//             ),

//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/addSymptom',
//                   arguments: userId,
//                 );
//               },
//               child: const Text('Add New Symptom'),
//             ),

//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/clinics');
//               },
//               child: const Text('Nearby Clinics'),
//             ),

//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/healthAlerts');
//               },
//               child: const Text('Health Alerts'),
//             ),

//             const SizedBox(height: 30),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//               child: const Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/alerts_screen.dart';
import 'package:healthlink_app/screens/clinics_screen.dart';
import 'package:healthlink_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Screens for each bottom nav item (PASS userId where needed)
    final List<Widget> screens = [
      SymptomHistoryScreen(userId: widget.userId),
      AddSymptomScreen(userId: widget.userId),
      ClinicsScreen(),
      AlertsScreen(),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("HealthLink App")),

      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: "Clinics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
