import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // android reminder
  static const String _channelId = 'appointment_channel';
  static const String _channelName = 'Appointment Reminders';
  static const String _channelDescription = 'Reminds users 24 hours before appointments';

  static Future<void> initialize({
    Function(String? payload)? onSelectNotification,
  }) async {
    try {
      tz.initializeTimeZones();
      final String deviceTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone));
    } catch (error) {
      tz.initializeTimeZones();
      debugPrint('Warning: failed to set local timezone: $error');
    }

    // Android settings
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS settings
    final DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
      macOS: null,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (onSelectNotification != null) onSelectNotification(payload);
      },
    );

    // android notification 
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
        ),
      );
    }
  }

  // reminder 24 hours before appointment.
  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required DateTime appointmentDateTime,
    required String clinicName,
  }) async {
    try {
      final DateTime dtLocal = appointmentDateTime.toLocal();
      final tz.TZDateTime scheduled = tz.TZDateTime.from(dtLocal, tz.local).subtract(
        const Duration(hours: 24)
      );

      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Reminder time has already passed');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        appointmentId, 
        'Upcoming Appointment Reminder',
        'You have an appointment at $clinicName in 24 hours.',
        scheduled,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(r'Scrheduled reminder (id=$appointmentId) at $scheduled');
    } catch (error) {
      debugPrint('Error scheduling reminder: $error');
    }
  }

  /// cancel scheduled reminder
  static Future<void> cancelReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      debugPrint('Cancelled reminder id=$appointmentId');
    } catch (error) {
      debugPrint('Error cancelling reminder $appointmentId: $error');
    }
  }
}
