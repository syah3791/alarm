import 'package:flutter/material.dart';

class Alarm{
   int? id;
   var time;
   String? ringtone;
   bool? status;

   Alarm({this.id, this.time, this.ringtone, this.status});

   factory Alarm.fromJson(Map<String, dynamic> json) => new Alarm(
      id: json["id"],
      time: TimeOfDay(hour: int.parse(json["time"].split(":")[0]), minute: int.parse(json["time"].split(":")[1])),
      ringtone: json["ringtone"],
      status: json["status"] == 1,
   );
   Map<String, dynamic> toMap() => {
      "id": id,
      "time": time,
      "ringtone": ringtone,
      "status": status,
   };
}