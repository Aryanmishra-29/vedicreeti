import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    try {
      developer.log('Initializing ReminderService...', name: 'ReminderService');
      tz.initializeTimeZones();
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        final String currentTimeZone = tzInfo.identifier;
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
      } catch (e) {
        debugPrint('Could not get local timezone: $e');
      }
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      developer.log('ReminderService initialized successfully.', name: 'ReminderService');
    } catch (e, stackTrace) {
      developer.log('Failed to initialize ReminderService', name: 'ReminderService', error: e, stackTrace: stackTrace);
    }
  }
  Future<void> scheduleDailyMantraReminder(TimeOfDay time, String title, String body, {int id = 0}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_mantra_channel',
      'Daily Mantras & Fasts',
      channelDescription: 'Exact background alarms for daily mantras and fasts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ensures it repeats daily at this exact time
    );
  }
  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  Future<bool> hasNotificationPermission() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return result ?? true; // Default to true if unable to verify
  }
  Future<void> scheduleExactReminder(int id, String title, String body, DateTime scheduledTime, {String? customAudioPath}) async {
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // Cannot schedule in the past
    }
    final diff = scheduledTime.difference(DateTime.now());
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'exact_reminders',
      'Exact Reminders',
      channelDescription: 'Used for scheduled user reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    if (diff.inMinutes > 15) {
      final preTime = scheduledDate.subtract(const Duration(minutes: 15));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id * 10 + 1, // distinct ID for pre-notification
        'Upcoming: $title',
        'Starting in 15 minutes. $body',
        preTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? globalCustomPath = prefs.getString('custom_alarm_path');
      final String? explicitPath = (customAudioPath != null && customAudioPath.isNotEmpty) ? customAudioPath : globalCustomPath;
      final String audioPath = (explicitPath != null && explicitPath.isNotEmpty) ? explicitPath : 'assets/audio/flute.mp3';
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: scheduledTime,
        assetAudioPath: audioPath,
        loopAudio: true,
        vibrate: true,
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          stopButton: 'Stop',
        ),
        volumeSettings: VolumeSettings.fade(
          fadeDuration: const Duration(seconds: 3),
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint('Error setting alarm: $e');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
  Box get _box => Hive.box('remindersBox');
  Future<String> saveLocalReminder(String title, DateTime time, {String? customAudioPath, String? existingId}) async {
    final id = existingId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final reminderData = {
      'id': id,
      'title': title,
      'time': time.toUtc().toIso8601String(),
      'isActive': true,
    };
    if (customAudioPath != null && customAudioPath.isNotEmpty) {
      reminderData['customAudioPath'] = customAudioPath;
    }
    await _box.put(id, reminderData);
    return id;
  }
  List<Map<String, dynamic>> getLocalReminders() {
    return _box.values.map((e) {
      if (e is Map) {
        return Map<String, dynamic>.from(e);
      }
      return <String, dynamic>{};
    }).toList();
  }
  Future<void> deleteLocalReminder(String id) async {
    await _box.delete(id);
  }
  Future<void> toggleReminderActive(String id, bool isActive) async {
    final reminderData = _box.get(id);
    if (reminderData != null && reminderData is Map) {
      final updatedData = Map<String, dynamic>.from(reminderData);
      updatedData['isActive'] = isActive;
      await _box.put(id, updatedData);
    }
  }
}
