import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home_screen.dart';
import 'screens/clinics_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/symptom_history_screen.dart';
import 'screens/add_symptom_screen.dart';
import 'screens/alerts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt("userId");

  runApp(HealthLinkApp(savedUserId: savedUserId));
}

class HealthLinkApp extends StatelessWidget {
  final int? savedUserId;
  const HealthLinkApp({super.key, this.savedUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HealthLink App",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // Decide starting screen
      home: savedUserId == null ? const Login() : HomeScreen(userId: savedUserId!),

      routes: {
        "/login": (context) => const Login(),
        "/signup": (context) => const Signup(),

        "/home": (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return HomeScreen(userId: userId);
        },

        "/clinics": (context) => const ClinicsScreen(),
        "/tips": (context) => const TipsScreen(),
        "/symptomHistory": (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return SymptomHistoryScreen(userId: userId);
        },
        "/addSymptom": (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return AddSymptomScreen(userId: userId);
        },
        "/healthAlerts": (context) => const AlertsScreen(),
      },
    );
  }
}
