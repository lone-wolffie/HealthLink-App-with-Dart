// lib/services/notification_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android channel id / name
  static const String _channelId = 'appointment_channel';
  static const String _channelName = 'Appointment Reminders';
  static const String _channelDescription =
      'Reminds users 24 hours before appointments';

  /// Initialize notifications — call once at app startup (before runApp).
  static Future<void> initialize({
    Function(String? payload)? onSelectNotification,
  }) async {
    // Initialize Timezone database and set local timezone
    try {
      tz.initializeTimeZones();
      final String deviceTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone));
    } catch (e) {
      // Fallback: still initialize tz DB (it uses UTC fallback)
      tz.initializeTimeZones();
      debugPrint('Warning: failed to set local timezone: $e');
    }

    // Android init settings
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS init settings
    final DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {
        // iOS older callback if needed (optional)
      },
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

    // Create Android notification channel (Android 8+)
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
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

  /// Schedule reminder 24 hours before appointment.
  /// appointmentDateTime can be in UTC or local DateTime — we convert to tz.local before scheduling.
  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required DateTime appointmentDateTime,
    required String clinicName,
  }) async {
    try {
      // Convert to local timezone tz.TZDateTime
      final DateTime dtLocal = appointmentDateTime.toLocal();
      final tz.TZDateTime scheduled = tz.TZDateTime.from(dtLocal, tz.local)
          .subtract(const Duration(hours: 24));

      // Skip if in the past
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Reminder time has already passed — not scheduling. scheduled=$scheduled');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // color and icon are optional
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        appointmentId, // id
        'Upcoming Appointment Reminder',
        'You have an appointment at $clinicName in 24 hours.',
        scheduled,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled reminder (id=$appointmentId) at $scheduled');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  /// Cancel scheduled reminder
  static Future<void> cancelReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      debugPrint('Cancelled reminder id=$appointmentId');
    } catch (e) {
      debugPrint('Error cancelling reminder $appointmentId: $e');
    }
  }
}
