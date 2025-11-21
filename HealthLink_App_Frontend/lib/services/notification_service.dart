import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // appointment reminders
  static const String _appointmentChannelId = 'appointment_channel';
  static const String _appointmentChannelName = 'Appointment Reminders';

  // medication reminders
  static const String _medChannelId = 'medication_channel';
  static const String _medChannelName = 'Medication Reminders';

  // initialize all notifications
  static Future<void> initialize({
    Function(String? payload)? onSelectNotification,
  }) async {
    try {
      tz.initializeTimeZones();
      final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      final timezoneName = deviceTimeZone.toString(); 
      tz.setLocalLocation(tz.getLocation(timezoneName));

    } catch (error) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('Warning: Unable to set timezone: $error');
    }

    // Android initialization
    const androidInit = AndroidInitializationSettings('@drawable/notification_icon');

    // iOS initialization
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
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

    // creating android channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // appointment channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannelId,
          _appointmentChannelName,
          description: 'Reminds users 24 hours before appointments',
          importance: Importance.max,
        ),
      );

      // medication channel
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

  // appointment reminder 24 hours before
  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required DateTime appointmentDateTime,
    required String clinicName,
  }) async {
    try {
      final DateTime localTime = appointmentDateTime.toLocal();
      final tz.TZDateTime reminderTime = tz.TZDateTime.from(
        localTime,
        tz.local,
      ).subtract(const Duration(hours: 24));

      if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) return;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentChannelId,
          _appointmentChannelName,
          icon: '@drawable/notification_icon',
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (error) {
      debugPrint('Appointment schedule error: $error');
    }
  }

  // cancel appointment reminder
  static Future<void> cancelAppointmentReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      debugPrint('Cancelled appointment reminder for ID: $appointmentId');
    } catch (error) {
      debugPrint('Error cancelling appointment reminder: $error');
    }
  }

  // medication reminder on scheduled time
  static Future<void> scheduleDailyMedicationReminder({
    required int medicationId,
    required int index,
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

      // If time has already passed today, schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final notificationId = medicationId * 100 + index;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _medChannelId,
          _medChannelName,
          icon: '@drawable/notification_icon',
          channelDescription: 'Daily medication reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Medication Reminder',
        'Time to take $medicationName ($dose)',
        scheduleTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Medication reminder scheduled at $scheduleTime');
    } catch (error) {
      debugPrint('Medication reminder error: $error');
    }
  }

  // cancel medication reminder
  static Future<void> cancelMedicationReminders(
    int medicationId, {
    int maxTimes = 10,
  }) async {
    try {
      for (int i = 0; i < maxTimes; i++) {
        final id = medicationId * 100 + i;
        await _notificationsPlugin.cancel(id);
      }
    } catch (error) {
      debugPrint('Error cancelling reminder: $error');
    }
  }
}
