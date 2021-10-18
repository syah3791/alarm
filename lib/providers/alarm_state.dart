import 'dart:isolate';

import 'package:alarm/models/alarm.dart';
import 'package:alarm/models/respon_history.dart';
import 'package:alarm/pages/alarm_page.dart';
import 'package:alarm/utils/v_database.dart';
import 'package:alarm/utils/v_notification.dart';
import 'package:flutter/material.dart';

class AlarmSate with ChangeNotifier{
  List<Alarm> _alarmList = [];
  List<String> _ringtonList = ['a_long_cold_sting','slow_spring_board'];
  bool _isOn = false;
  bool _isSaveRespon = true;

  List<ResponHistory> _responHistoryList = [];

  List<Alarm> get alarmList => _alarmList;
  List<String> get ringtonList => _ringtonList;
  get isOn => _isOn;
  get isSaveRespon => _isSaveRespon;

  List<ResponHistory> get responHistoryList => _responHistoryList;

  AlarmSate(){
    getListAlarm();
  }

  Future <List<Alarm>> getListAlarm() async {
    _alarmList = await DBProvider.db.getAllAlarms();
    _isOn = false;
    _alarmList.forEach((e) => e.status! ? _isOn = true : null);
    notifyListeners();
    return _alarmList;
  }

  addAlarm(context, Alarm alarm) async {
    Alarm temp = Alarm(id: alarm.id, time: alarm.time.format(context), ringtone: alarm.ringtone, status: alarm.status);
    int id = await DBProvider.db.newAlarm(temp);
    alarm.id = id;
    NotificationService.scheduleAlarm(alarm);
    getListAlarm();
    getListRespon();
  }

  updateAlarm(context, Alarm alarm) async {
    Alarm temp = Alarm(id: alarm.id, time: alarm.time.format(context), ringtone: alarm.ringtone, status: alarm.status);
    await DBProvider.db.updateAlarm(temp);
    getListAlarm();
    if(alarm.status!) NotificationService.scheduleAlarm(alarm);
    else NotificationService.cancel(alarm);
  }

  Future getListRespon() async {
    _responHistoryList = await DBProvider.db.getAllRespons();
    notifyListeners();
  }

  addRespon(DateTime start) async {
    ResponHistory respon = ResponHistory(dateStart: start, dateRespon: DateTime.now(), diff: DateTime.now().difference(start).inMinutes);
    await DBProvider.db.newRespon(respon);
    _isSaveRespon = false;
    getListRespon();
  }
  updateRespon(ResponHistory respon) async {
    await DBProvider.db.updateRespon(respon);
    getListRespon();
  }
}