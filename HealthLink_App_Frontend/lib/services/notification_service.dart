import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// CHANNELS
  // Appointment reminders
  static const String _appointmentChannelId = 'appointment_channel';
  static const String _appointmentChannelName = 'Appointment Reminders';

  // Medication reminders
  static const String _medChannelId = 'medication_channel';
  static const String _medChannelName = 'Medication Reminders';

  /// Initialize all notifications
  static Future<void> initialize({
    Function(String? payload)? onSelectNotification,
  }) async {
    try {
      tz.initializeTimeZones();
      final String deviceTimeZone =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone));
    } catch (error) {
      tz.initializeTimeZones();
      debugPrint('Warning: Unable to set timezone: $error');
    }

    // Android init
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS init
    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onSelectNotification != null) {
          onSelectNotification(response.payload);
        }
      },
    );

    // Create Android channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Appointment channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannelId,
          _appointmentChannelName,
          description: 'Reminds users 24 hours before appointments',
          importance: Importance.max,
        ),
      );

      // Medication channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _medChannelId,
          _medChannelName,
          description: 'Daily medication reminders',
          importance: Importance.max,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🟣 APPOINTMENT REMINDER — 24 HOURS BEFORE
  // ---------------------------------------------------------------------------
  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required DateTime appointmentDateTime,
    required String clinicName,
  }) async {
    try {
      final DateTime localTime = appointmentDateTime.toLocal();
      final tz.TZDateTime reminderTime = tz.TZDateTime.from(localTime, tz.local)
          .subtract(const Duration(hours: 24));

      if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) return;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentChannelId,
          _appointmentChannelName,
          channelDescription: 'Reminds users 24 hours before appointments',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        appointmentId,
        'Upcoming Appointment Reminder',
        'You have an appointment at $clinicName in 24 hours.',
        reminderTime,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("Scheduled appointment reminder at: $reminderTime");
    } catch (error) {
      debugPrint("Appointment schedule error: $error");
    }
  }

  // ---------------------------------------------------------------------------
  // 🔵 MEDICATION DAILY REMINDER — FIRES DAILY AT GIVEN TIME
  // ---------------------------------------------------------------------------
  static Future<void> scheduleMedicationReminder({
    required int medicationId,
    required String medicationName,
    required String dose,
    required String time,
  }) async {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);

      // Create today's reminder time
      tz.TZDateTime scheduleTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time already passed today → schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _medChannelId,
          _medChannelName,
          channelDescription: 'Daily medication reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        medicationId, // UNIQUE
        'Medication Reminder',
        'Time to take $medicationName ($dose)',
        scheduleTime,
        details,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time, // 🔥 DAILY REPEAT
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("Medication reminder scheduled: $scheduleTime");
    } catch (error) {
      debugPrint("Medication reminder error: $error");
    }
  }

  // ---------------------------------------------------------------------------
  // ❌ CANCEL REMINDERS
  // ---------------------------------------------------------------------------
  static Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint("Cancelled reminder ID=$id");
    } catch (error) {
      debugPrint("Error cancelling reminder: $error");
    }
  }
}
