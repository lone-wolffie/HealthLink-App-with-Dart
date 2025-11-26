// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // appointment reminders
//   static const String _appointmentChannelId = 'appointment_channel';
//   static const String _appointmentChannelName = 'Appointment Reminders';

//   // medication reminders
//   static const String _medChannelId = 'medication_channel';
//   static const String _medChannelName = 'Medication Reminders';

//   // initialize all notifications
//   static Future<void> initialize({
//     Function(String? payload)? onSelectNotification,
//   }) async {
//     try {
//       tz.initializeTimeZones();
//       final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
//       final String timezoneName = deviceTimeZone.identifier;
//       tz.setLocalLocation(tz.getLocation(timezoneName));
//       debugPrint('Timezone set to: $timezoneName');
//     } catch (error) {
//       tz.initializeTimeZones();
//       tz.setLocalLocation(tz.getLocation('UTC'));
//       debugPrint('Warning: Unable to set timezone: $error');
//     }

//     // Android initialization
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization
//     final iosInit = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     final initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iosInit,
//     );

//     await _notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         debugPrint('Notification tapped: ${response.payload}');
//         if (onSelectNotification != null) {
//           onSelectNotification(response.payload);
//         }
//       },
//     );

//     if (Platform.isAndroid) {
//       final androidImpl = _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >();

//       final bool? granted = await androidImpl?.requestNotificationsPermission();
//       debugPrint('Notification permission granted: $granted');

//       // Request exact alarm permission
//       final bool? exactAlarmGranted = await androidImpl
//           ?.requestExactAlarmsPermission();
//       debugPrint('Exact alarm permission granted: $exactAlarmGranted');
//     }

//     // creating android channels
//     if (!kIsWeb && Platform.isAndroid) {
//       final androidPlugin = _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >();

//       // appointment channel
//       await androidPlugin?.createNotificationChannel(
//         const AndroidNotificationChannel(
//           _appointmentChannelId,
//           _appointmentChannelName,
//           description: 'Reminds users 24 hours before appointments',
//           importance: Importance.max,
//           playSound: true,
//           enableVibration: true,
//         ),
//       );

//       // medication channel
//       await androidPlugin?.createNotificationChannel(
//         const AndroidNotificationChannel(
//           _medChannelId,
//           _medChannelName,
//           description: 'Daily medication reminders',
//           importance: Importance.max,
//           playSound: true,
//           enableVibration: true,
//         ),
//       );

//       debugPrint('Notification channels created');
//     }
//   }

//   // appointment reminder 24 hours before
//   static Future<void> scheduleAppointmentReminder({
//     required int appointmentId,
//     required DateTime appointmentDateTime,
//     required String clinicName,
//   }) async {
//     try {
//       final DateTime localTime = appointmentDateTime.toLocal();
//       final tz.TZDateTime reminderTime = tz.TZDateTime.from(
//         localTime,
//         tz.local,
//       ).subtract(const Duration(hours: 24));

//       final now = tz.TZDateTime.now(tz.local);

//       debugPrint('Scheduling appointment reminder:');
//       debugPrint('Appointment: $localTime');
//       debugPrint('Reminder: $reminderTime');
//       debugPrint('Current: $now');
//       debugPrint('ID: $appointmentId');

//       if (reminderTime.isBefore(now)) {
//         debugPrint('Reminder time is in the past, skipping');
//         return;
//       }

//       const details = NotificationDetails(
//         android: AndroidNotificationDetails(
//           _appointmentChannelId,
//           _appointmentChannelName,
//           icon: '@mipmap/ic_launcher',
//           channelDescription: 'Reminds users 24 hours before appointments',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//           enableVibration: true,
//         ),
//         iOS: DarwinNotificationDetails(),
//       );

//       await _notificationsPlugin.zonedSchedule(
//         appointmentId,
//         'Upcoming Appointment Reminder',
//         'You have an appointment at $clinicName in 24 hours.',
//         reminderTime,
//         details,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );

//       debugPrint('Appointment reminder scheduled');
//     } catch (error) {
//       debugPrint('Appointment schedule error: $error');
//     }
//   }

//   // cancel appointment reminder
//   static Future<void> cancelAppointmentReminder(int appointmentId) async {
//     try {
//       await _notificationsPlugin.cancel(appointmentId);
//       debugPrint('Cancelled appointment reminder (ID: $appointmentId)');
//     } catch (error) {
//       debugPrint('Error cancelling appointment: $error');
//     }
//   }

//   // medication reminder on scheduled time
//   static Future<void> scheduleDailyMedicationReminder({
//     required int medicationId,
//     required int index,
//     required String medicationName,
//     required String dose,
//     required String time,
//   }) async {
//     try {
//       final parts = time.split(':');
//       final hour = int.parse(parts[0]);
//       final minute = int.parse(parts[1]);

//       final now = tz.TZDateTime.now(tz.local);

//       // Create today's reminder time
//       tz.TZDateTime scheduleTime = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute,
//       );

//       // If time has already passed today, schedule for tomorrow
//       if (scheduleTime.isBefore(now)) {
//         scheduleTime = scheduleTime.add(const Duration(days: 1));
//       }

//       final notificationId = medicationId * 100 + index;

//       debugPrint('Scheduling medication:');
//       debugPrint('Name: $medicationName ($dose)');
//       debugPrint('Time: $time');
//       debugPrint('Schedule: $scheduleTime');
//       debugPrint('Current: $now');
//       debugPrint('ID: $notificationId');

//       const details = NotificationDetails(
//         android: AndroidNotificationDetails(
//           _medChannelId,
//           _medChannelName,
//           icon: '@mipmap/ic_launcher',
//           channelDescription: 'Daily medication reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//           enableVibration: true,
//         ),
//         iOS: DarwinNotificationDetails(),
//       );

//       await _notificationsPlugin.zonedSchedule(
//         notificationId,
//         'Medication Reminder',
//         'Time to take $medicationName ($dose)',
//         scheduleTime,
//         details,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.time,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );

//       debugPrint('Medication reminder scheduled');
//     } catch (error) {
//       debugPrint('Medication reminder error: $error');
//     }
//   }

//   // cancel medication reminder
//   static Future<void> cancelMedicationReminders(
//     int medicationId, {
//     int maxTimes = 10,
//   }) async {
//     try {
//       for (int i = 0; i < maxTimes; i++) {
//         final id = medicationId * 100 + i;
//         await _notificationsPlugin.cancel(id);
//       }
//       debugPrint('Cancelled medication reminders (ID: $medicationId)');
//     } catch (error) {
//       debugPrint('Error cancelling medication: $error');
//     }
//   }

//   // List all pending notifications (for debugging)
//   static Future<void> listPendingNotifications() async {
//     final pending = await _notificationsPlugin.pendingNotificationRequests();
//     debugPrint('Pending notifications: ${pending.length}');
//     for (var notification in pending) {
//       debugPrint(
//         'ID: ${notification.id} | ${notification.title} | ${notification.body}',
//       );
//     }
//   }
// }

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _appointmentChannelId = 'appointment_channel';
  static const String _appointmentChannelName = 'Appointment Reminders';
  static const String _medChannelId = 'medication_channel';
  static const String _medChannelName = 'Medication Reminders';

  // Port for isolate communication
  static const String _isolateName = 'notification_isolate';
  static ReceivePort? _receivePort;

  // Initialize both notification systems
  static Future<void> initialize({
    Function(String? payload)? onSelectNotification,
  }) async {
    // Initialize timezone
    try {
      tz.initializeTimeZones();
      final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      final String timezoneName = deviceTimeZone.identifier;
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('✅ Timezone set to: $timezoneName');
    } catch (error) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('⚠️ Warning: Unable to set timezone: $error');
    }

    // Initialize AlarmManager
    await AndroidAlarmManager.initialize();
    debugPrint('✅ AlarmManager initialized');

    // Setup isolate communication
    _removeIsolateCallback();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      _isolateName,
    );

    // Android notification initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
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
        debugPrint('📲 Notification tapped: ${response.payload}');
        if (onSelectNotification != null) {
          onSelectNotification(response.payload);
        }
      },
    );

    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImpl?.requestNotificationsPermission();
      debugPrint('📱 Notification permission granted: $granted');

      final bool? exactAlarmGranted =
          await androidImpl?.requestExactAlarmsPermission();
      debugPrint('⏰ Exact alarm permission granted: $exactAlarmGranted');
    }

    // Create notification channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannelId,
          _appointmentChannelName,
          description: 'Reminds users 24 hours before appointments',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _medChannelId,
          _medChannelName,
          description: 'Daily medication reminders',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      debugPrint('✅ Notification channels created');
    }
  }

  static void _removeIsolateCallback() {
    IsolateNameServer.removePortNameMapping(_isolateName);
  }

  // Callback for AlarmManager (must be static and top-level or static method)
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    debugPrint('🔔 Alarm triggered!');
    await _showNotificationFromAlarm();
  }

  static Future<void> _showNotificationFromAlarm() async {
    final plugin = FlutterLocalNotificationsPlugin();
    
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Notifications triggered by alarms',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⏰ HealthLink Reminder',
      'This is your scheduled reminder',
      details,
    );
  }

  // Test immediate notification
  static Future<void> showTestNotification() async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentChannelId,
          _appointmentChannelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        999,
        '🧪 Test Notification',
        'Immediate notification working!',
        details,
      );

      debugPrint('✅ Test notification sent (ID: 999)');
    } catch (e) {
      debugPrint('❌ Test notification error: $e');
    }
  }

  // Schedule test using AlarmManager (more reliable on TECNO)
  static Future<void> scheduleTestWithAlarm() async {
    try {
      final now = DateTime.now();
      final scheduleTime = now.add(const Duration(seconds: 30));
      
      debugPrint('⏰ Scheduling alarm for: $scheduleTime');

      final success = await AndroidAlarmManager.oneShotAt(
        scheduleTime,
        998, // Unique ID
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: false,
      );

      if (success) {
        debugPrint('✅ Alarm scheduled successfully for 30 seconds from now');
      } else {
        debugPrint('❌ Failed to schedule alarm');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling alarm: $e');
    }
  }

  // Schedule test notification (original method)
  static Future<void> scheduleTestNotification() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduleTime = now.add(const Duration(seconds: 30));

      debugPrint('⏰ Current time: $now');
      debugPrint('⏰ Will schedule for: $scheduleTime');

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _medChannelId,
          _medChannelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        998,
        '⏰ Scheduled Test',
        'This notification was scheduled for 30 seconds',
        scheduleTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Test notification scheduled');
      await listPendingNotifications();
    } catch (error) {
      debugPrint('❌ Error scheduling test: $error');
    }
  }

  // Check if exact alarms are allowed
  static Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      try {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final canSchedule = await androidImpl?.canScheduleExactNotifications();
        debugPrint('📱 Can schedule exact alarms: $canSchedule');
        return canSchedule ?? false;
      } catch (e) {
        debugPrint('⚠️ Error checking alarm permission: $e');
        return false;
      }
    }
    return true;
  }

  // Schedule appointment reminder using AlarmManager
  static Future<void> scheduleAppointmentReminderWithAlarm({
    required int appointmentId,
    required DateTime appointmentDateTime,
    required String clinicName,
  }) async {
    try {
      final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
      
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('⚠️ Reminder time is in the past, skipping');
        return;
      }

      debugPrint('📅 Scheduling appointment alarm:');
      debugPrint('   Appointment: $appointmentDateTime');
      debugPrint('   Reminder: $reminderTime');
      debugPrint('   ID: $appointmentId');

      // Store appointment details for the callback
      // You'll need to implement a way to pass data to the callback
      // For now, we'll use a generic callback

      final success = await AndroidAlarmManager.oneShotAt(
        reminderTime,
        appointmentId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      if (success) {
        debugPrint('✅ Appointment alarm scheduled');
      } else {
        debugPrint('❌ Failed to schedule appointment alarm');
      }
    } catch (error) {
      debugPrint('❌ Appointment alarm error: $error');
    }
  }

  // Original appointment reminder (keep as fallback)
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

      final now = tz.TZDateTime.now(tz.local);

      if (reminderTime.isBefore(now)) {
        debugPrint('⚠️ Reminder time is in the past, skipping');
        return;
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentChannelId,
          _appointmentChannelName,
          icon: '@mipmap/ic_launcher',
          channelDescription: 'Reminds users 24 hours before appointments',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          category: AndroidNotificationCategory.reminder,
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

      debugPrint('✅ Appointment reminder scheduled');
    } catch (error) {
      debugPrint('❌ Appointment schedule error: $error');
    }
  }

  // Cancel appointment reminder
  static Future<void> cancelAppointmentReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      await AndroidAlarmManager.cancel(appointmentId);
      debugPrint('✅ Cancelled appointment reminder (ID: $appointmentId)');
    } catch (error) {
      debugPrint('❌ Error cancelling appointment: $error');
    }
  }

  // Schedule medication reminder
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
      tz.TZDateTime scheduleTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final notificationId = medicationId * 100 + index;

      debugPrint('💊 Scheduling medication:');
      debugPrint('   Name: $medicationName ($dose)');
      debugPrint('   Time: $time');
      debugPrint('   Schedule: $scheduleTime');
      debugPrint('   ID: $notificationId');

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _medChannelId,
          _medChannelName,
          icon: '@mipmap/ic_launcher',
          channelDescription: 'Daily medication reminders',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          category: AndroidNotificationCategory.reminder,
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

      debugPrint('✅ Medication reminder scheduled');
    } catch (error) {
      debugPrint('❌ Medication reminder error: $error');
    }
  }

  // Cancel medication reminders
  static Future<void> cancelMedicationReminders(
    int medicationId, {
    int maxTimes = 10,
  }) async {
    try {
      for (int i = 0; i < maxTimes; i++) {
        final id = medicationId * 100 + i;
        await _notificationsPlugin.cancel(id);
        await AndroidAlarmManager.cancel(id);
      }
      debugPrint('✅ Cancelled medication reminders (ID: $medicationId)');
    } catch (error) {
      debugPrint('❌ Error cancelling medication: $error');
    }
  }

  // List pending notifications
  static Future<void> listPendingNotifications() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Pending notifications: ${pending.length}');
    for (var notification in pending) {
      debugPrint(
          '   ID: ${notification.id} | ${notification.title} | ${notification.body}');
    }
  }
}