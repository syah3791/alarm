import 'dart:isolate';

import 'package:alarm/models/alarm.dart';
import 'package:alarm/providers/alarm_state.dart';
import 'package:alarm/utils/v_notification.dart';
import 'package:alarm/widgets/v_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AlarmSate? _state;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    _state = Provider.of<AlarmSate>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50,),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      children: [
                        Center(
                          child: _state!.isOn ? Text("On", style:
                          TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ) : Text("Off", style:
                          TextStyle(fontSize: 50, color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right:10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Alarm", style:
                                TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                Text(DateFormat('HH:mm:ss').format(DateTime.now()), style:
                                TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                Text(DateFormat('MM/dd/yyyy').format(DateTime.now()), style:
                                TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ]
                          ),
                        )
                      ]
                  )
                ],
              ),
              SizedBox(height: 25,),
              Container(
                height: height/1.4,
                width: width,
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation:15,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _state!.alarmList.length,
                      itemBuilder: (context, index) {
                        return _listAlarm(index);
                      },
                    )
                ),
              ),
              SizedBox(height: 20,),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => _popUp(),
        tooltip: 'Increment',
        child: const Icon(Icons.add, color: Colors.blue,),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
    // return Container();
  }

  _listAlarm(int index){
    Alarm alarm = _state!.alarmList[index];
    return InkWell(
        onTap: () =>_popUp(alarm: _state!.alarmList[index]),
      child: Table(
        children: [
          TableRow(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: alarm.status ?? false ?
                Icon(Icons.access_alarm, color: Colors.blue, size: 30,) :
                Icon(Icons.access_alarm, color: Colors.red, size: 30,),
              ),
              Text(TimeOfDay(hour: alarm.time!.hour, minute: alarm.time!.minute).format(context), style:
              TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              CupertinoSwitch(
                activeColor: Colors.blue,
                trackColor: Colors.red,
                value: _state!.alarmList[index].status!,
                onChanged: (value) async {
                  alarm.status = value;
                  await _state!.updateAlarm(context, alarm);},
              ),
            ],
          )
        ],
      )
    );
  }
  _popUp({Alarm? alarm}){
    alarm ??= Alarm(id: null, time: TimeOfDay.now(), ringtone: 'a_long_cold_sting', status: true);
    showModalBottomSheet<void>(
      backgroundColor: Colors.black.withOpacity(0),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding:EdgeInsets.only(left:15, right:15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),),
            color: Colors.white,
          ),
          height: 280,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                VTimePicker(
                  time: alarm!.time,
                  onChanged: (value) =>alarm!.time = value,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Ringtone',
                      hintText: "Select Ringtone",
                  ),
                  value: alarm.ringtone,
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  onChanged: (String? newValue) {
                    alarm!.ringtone = newValue;
                    },
                  items: _state!.ringtonList.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () async {
                    alarm!.id == null ? await _state!.addAlarm(context, alarm) :
                    await _state!.updateAlarm(context, alarm)
                    ;
                    Navigator.pop(context);
                    },
                  child: Text('Save', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}