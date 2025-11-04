import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthlink_app/screens/login.dart';
import 'package:healthlink_app/screens/signup.dart';
import 'package:healthlink_app/screens/home_screen.dart';
import 'package:healthlink_app/screens/clinics_screen.dart';
import 'package:healthlink_app/screens/tips_screen.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/alerts_screen.dart';

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
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator()
          )
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HealthLink App",
      initialRoute: "/login",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      // If user is logged in, go to HomeScreen, else, go to LoginScreen
      home: userId == null ? const Login() : HomeScreen(userId: userId!),

      routes: {
        "/login": (context) => const Login(),
        "/signup": (context) => const Signup(),
        "/home": (context) {
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            
              final prefs = snapshot.data as SharedPreferences;
              final savedUserId = prefs.getInt("userId") ?? 0;
              return HomeScreen(userId: savedUserId);
            },
          );
        },
         

        "/clinics": (context) => const ClinicsScreen(),
        "/tips": (context) => const TipsScreen(),
        "/symptomHistory": (context) {
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              
              final prefs = snapshot.data as SharedPreferences;
              return SymptomHistoryScreen(userId: prefs.getInt("userId") ?? 0);
            },
          );
        },
        
        "/addSymptom": (context) {
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              
              final prefs = snapshot.data as SharedPreferences;
              return AddSymptomScreen(userId: prefs.getInt("userId") ?? 0);
            },
          );
        },
        
        "/healthAlerts": (context) => const AlertsScreen(),
        "/addTip": (context) => const TipsScreen(),
      }

    );
  }
}
