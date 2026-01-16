import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:healthlink_app/screens/login.dart';
import 'package:healthlink_app/screens/signup.dart';
import 'package:healthlink_app/screens/home_screen.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_medication_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/my_appointments_screen.dart';
import 'package:healthlink_app/screens/tips_screen.dart';
import 'package:healthlink_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: false,
  );

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.initialize(
      onSelectNotification: (payload) {},
    );
  }

  runApp(const HealthLinkApp());
}

class HealthLinkApp extends StatelessWidget {
  const HealthLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthLink App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/login': (_) => const Login(),
        '/signup': (_) => const Signup(),
        '/home': (_) => const HomeScreen(),
        '/symptom-history': (_) => const SymptomHistoryScreen(),
        '/add-symptom': (_) => const AddSymptomScreen(),
        '/add-medication': (_) => const AddMedicationScreen(username: ''),
        '/tips': (_) => const TipsScreen(),
        '/alerts': (_) => const TipsScreen(),
        '/my-appointments': (_) => const MyAppointmentsScreen(userUuid: ''),
        
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          return const Login();
        }
        return const HomeScreen();
      },
    );
  }
}
