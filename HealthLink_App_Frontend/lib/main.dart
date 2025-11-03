import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login.dart';
// import 'screens/signup.dart';
// import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/clinics_screen.dart';
import 'screens/tips_screen.dart';
// import 'screens/add_tip_screen.dart';
import 'screens/symptom_history_screen.dart';
// import 'screens/symptoms_screen.dart';
import 'screens/add_symptom_screen.dart';
import 'screens/alerts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthLinkApp());
}

class HealthLinkApp extends StatefulWidget {
  const HealthLinkApp({
    super.key
  });

  @override
  State<HealthLinkApp> createState() => _HealthLinkAppState();
}

class _HealthLinkAppState extends State<HealthLinkApp> {
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HealthLink App",
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),

      // If user is logged in, go to HomeScreen, else, go to LoginScreen
      home: userId == null ? const Login() : HomeScreen(userId: userId!),

      routes: {
        "/login": (context) => const Login(),
        "/home": (context) => HomeScreen(userId: userId ?? 0),
        "/clinics": (context) => const ClinicsScreen(),
        "/tips": (context) => const TipsScreen(),
        "/symptoms-history": (context) => SymptomHistoryScreen(userId: userId ?? 0),
        "/add-symptom": (context) => AddSymptomScreen(userId: userId ?? 0),
        "/alerts": (context) => const AlertsScreen(),
      },
    );
  }
}
