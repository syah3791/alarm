import 'package:alarm/models/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final BehaviorSubject<String?> selectNotificationSubject =
  BehaviorSubject<String?>();

  factory NotificationService() {
    return _notificationService;
  }

  static const MethodChannel platform =
  MethodChannel('syah.dev/alarm');

  NotificationService._internal();

  static Future<void> init() async {

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('alarm_icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid, iOS: null, macOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            debugPrint('notification payload: $payload');
          }
          selectNotificationSubject.add(payload);
        });
    tz.initializeTimeZones();
  }

  static void showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      'alarm_notif',
      // 'Channel for Alarm notification',
      icon: 'alarm_icon',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      largeIcon: DrawableResourceAndroidBitmap('alarm_icon'),
        fullScreenIntent: true
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'slow_spring_board.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(0, 'title', 'body coba', platformChannelSpecifics, payload: "payload");
  }

  static void scheduleAlarm(Alarm alarm) async {
    tz.initializeTimeZones();
    var jakarta = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(jakarta);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleAlarmDateTime  = tz.TZDateTime(tz.local, now.year, now.month, now.day, alarm.time.hour, alarm.time.minute, 0, 0, 0);
    if (scheduleAlarmDateTime.isBefore(now))
      scheduleAlarmDateTime = scheduleAlarmDateTime.add(Duration(days: 1));
    final String? alarmUri = await platform.invokeMethod<String>('getAlarmUri');
    var tempRing =
    alarm.ringtone == 'uri_sound' ? UriAndroidNotificationSound(alarmUri!) :
    RawResourceAndroidNotificationSound(alarm.ringtone);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      alarm.id.toString(),
      'alarm_notif',
      icon: 'alarm_icon',
      sound: tempRing,
      largeIcon: DrawableResourceAndroidBitmap('alarm_icon'),
      fullScreenIntent: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: alarm.ringtone,
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    print(DateTime.now().timeZoneOffset);
    await flutterLocalNotificationsPlugin.zonedSchedule(alarm.id!, 'Alarm', "Wake Up",
        scheduleAlarmDateTime, platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.time,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,);
  }
  static void cancel(Alarm alarm) async {
    await flutterLocalNotificationsPlugin.cancel(alarm.id!);
  }
}