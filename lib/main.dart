import 'dart:io';

import 'package:alarm/pages/alarm_page.dart';
import 'package:alarm/pages/home_page.dart';
import 'package:alarm/providers/alarm_state.dart';
import 'package:alarm/utils/v_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

String initialRoute = HomePage.routeName;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.init();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
      Platform.isLinux
      ? null
      : await NotificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    initialRoute = AlarmPage.routeName;
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }
  void _configureSelectNotificationSubject() {
    NotificationService.selectNotificationSubject.stream.listen((String? payload) async {
      navigatorKey.currentState!.push( MaterialPageRoute (
        builder: (BuildContext context) => const AlarmPage(),
      ),);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => AlarmSate(),),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Alarm',
        initialRoute: initialRoute,
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
        ),
        routes: <String, WidgetBuilder>{
          HomePage.routeName: (_) => HomePage(),
          AlarmPage.routeName: (_) => AlarmPage()
        },
        // home: HomePage(),
      ),
    );
  }
}
