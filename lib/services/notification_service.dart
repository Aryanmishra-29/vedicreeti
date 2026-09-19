import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        developer.log('Notification clicked: ${response.payload}', name: 'NotificationService');
      },
    );
  }
  Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (alarmStatus.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }
  Future<void> scheduleFestivalReminder(String festivalName, DateTime festivalDate) async {
    final DateTime eventAt9AM = DateTime(festivalDate.year, festivalDate.month, festivalDate.day, 9, 0);
    final DateTime sevenDaysBefore = eventAt9AM.subtract(const Duration(days: 7));
    final DateTime oneDayBefore = eventAt9AM.subtract(const Duration(days: 1));
    final now = DateTime.now();
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'festival_reminders',
      'Festival Reminders',
      channelDescription: 'Notifications for upcoming festivals',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    if (sevenDaysBefore.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        festivalName.hashCode,
        'Upcoming Festival: $festivalName',
        '$festivalName is in 1 week! Tap to view Puja Vidhi.',
        tz.TZDateTime.from(sevenDaysBefore, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      developer.log('Scheduled 7-day reminder for $festivalName at $sevenDaysBefore', name: 'NotificationService');
    }
    if (oneDayBefore.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        festivalName.hashCode + 1, // ensure unique ID for the 1-day reminder
        'Tomorrow: $festivalName',
        '$festivalName is in 1 day! Tap to view Puja Vidhi.',
        tz.TZDateTime.from(oneDayBefore, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      developer.log('Scheduled 1-day reminder for $festivalName at $oneDayBefore', name: 'NotificationService');
    }
  }
  Future<void> autoScheduleFestivalReminders(List<dynamic>? upcomingFestivals) async {
    if (upcomingFestivals == null || upcomingFestivals.isEmpty) return;
    for (var festival in upcomingFestivals) {
      if (festival is Map<String, dynamic>) {
        final String festivalName = festival['name'] ?? 'Unknown Festival';
        final String dateString = festival['date'] ?? '';
        if (dateString.isEmpty) continue;
        try {
          final DateTime festivalDate = DateTime.parse(dateString);
          await scheduleFestivalReminder(festivalName, festivalDate);
        } catch (e) {
          developer.log('Failed to parse festival date: $e', name: 'NotificationService');
        }
      }
    }
  }
  Future<void> scheduleAdvancedReminder(int id, String title, String body, DateTime scheduledTime) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;
    final DateTime fifteenMinsPrior = scheduledTime.subtract(const Duration(minutes: 15));
    if (fifteenMinsPrior.isAfter(now)) {
      const AndroidNotificationDetails preAlarmChannel = AndroidNotificationDetails(
        'pre_alarm_channel',
        'Pre-Alarm Reminders',
        channelDescription: 'Silent notifications 15 minutes before your alarm',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id * 10, // Unique ID for pre-alarm
        'Upcoming Reminder: $title',
        'Your reminder "$title" is in 15 minutes.',
        tz.TZDateTime.from(fifteenMinsPrior, tz.local),
        const NotificationDetails(android: preAlarmChannel, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    const AndroidNotificationDetails exactAlarmChannel = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Reminders',
      channelDescription: 'Full-screen alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // For full-screen intent
      sound: RawResourceAndroidNotificationSound('om_namah_shivaya'), // Default ringtone prep
      playSound: true,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(android: exactAlarmChannel, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    developer.log('Scheduled advanced reminder for $title at $scheduledTime', name: 'NotificationService');
  }
  Future<String?> pickAndSaveCustomRingtone() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        File sourceFile = File(result.files.single.path!);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String fileName = result.files.single.name;
        String newFilePath = '${appDocDir.path}/$fileName';
        await sourceFile.copy(newFilePath);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_ringtone_path', newFilePath);
        developer.log('Custom ringtone saved locally at $newFilePath', name: 'NotificationService');
        return newFilePath;
      }
    } catch (e) {
      developer.log('Error picking custom ringtone: $e', name: 'NotificationService');
    }
    return null;
  }
  Future<void> scheduleReminderNotification(int id, String title, String body, {Duration delay = const Duration(minutes: 10)}) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'engagement_reminders',
      'Engagement Reminders',
      channelDescription: 'Reminders for cart abandonment and engagement',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    developer.log('Scheduled engagement reminder "$title" for $scheduledDate', name: 'NotificationService');
  }
  Future<void> showSavedItemsSuggestion() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'product_suggestions',
      'Product Suggestions',
      channelDescription: 'Notifications for saved items and recommendations',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
      0, // ID 0 for generic suggestions
      'Still thinking about it?',
      'Take another look at your saved Rudraksha before it goes out of stock!',
      platformChannelSpecifics,
      payload: '/wishlist',
    );
    developer.log('Showed saved items suggestion notification', name: 'NotificationService');
  }
}
