import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthlink_app/screens/login.dart';
import 'package:healthlink_app/screens/signup.dart';
import 'package:healthlink_app/screens/home_screen.dart';
import 'package:healthlink_app/screens/clinics_screen.dart';
import 'package:healthlink_app/services/notification_service.dart';
import 'package:healthlink_app/screens/book_appointment_screen.dart';
import 'package:healthlink_app/screens/tips_screen.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/alerts_screen.dart';
import 'package:healthlink_app/screens/my_appointments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(
    onSelectNotification: (payload) {
      debugPrint('Notification tapped with payload: $payload');
    },
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt('userId');

  runApp(HealthLinkApp(savedUserId: savedUserId));
}

class HealthLinkApp extends StatelessWidget {
  final int? savedUserId;

  const HealthLinkApp({
    super.key, 
    this.savedUserId
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthLink App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      // starting screen
      initialRoute: savedUserId == null ? '/signup' : '/home',

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const Login());
          
          case '/signup':
            return MaterialPageRoute(builder: (_) => const Signup());
          
          case '/home':
            int? userId;
            
            if (settings.arguments != null && settings.arguments is int) {
              userId = settings.arguments as int;
            } else {
              userId = savedUserId;
            }

            if (userId != null) {
              return MaterialPageRoute(
                builder: (_) => HomeScreen(userId: userId!),
              );
            } else {
              // If no userId, redirect to login
              return MaterialPageRoute(builder: (_) => const Login());
            }
          
          case '/clinics':
            return MaterialPageRoute(builder: (_) => const ClinicsScreen());
          
          case '/tips':
            return MaterialPageRoute(builder: (_) => const TipsScreen());
          
          case '/symptomHistory':
            final userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => SymptomHistoryScreen(userId: userId),
            );
          
          case '/addSymptom':
            final userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => AddSymptomScreen(userId: userId),
            );
          
          case '/healthAlerts':
            return MaterialPageRoute(builder: (_) => const AlertsScreen());

          case '/bookAppointment':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => BookAppointmentScreen(
                userId: args['userId'],
                clinicId: args['clinicId'],
                clinicName: args['clinicName'],
              ),
            );

          case '/myAppointments':
            final userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => MyAppointmentsScreen(userId: userId),
            );
          
          default:
            return MaterialPageRoute(builder: (_) => const Login());
        }
      },
    );
  }
}
