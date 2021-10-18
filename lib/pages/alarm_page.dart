import 'package:alarm/models/respon_history.dart';
import 'package:alarm/providers/alarm_state.dart';
import 'package:alarm/widgets/v_clock.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  static const String routeName = '/alarmPage';

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  AlarmSate? _state;
  DateTime _start = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _state = Provider.of<AlarmSate>(context);
    List<charts.Series<ResponHistory, num>> series = [
      charts.Series(
          id: "History",
          data: _state!.responHistoryList,
          domainFn: (ResponHistory series, _) => series.id!,
          measureFn: (ResponHistory series, _) => series.diff!,
          colorFn: (ResponHistory series, _) => charts.ColorUtil.fromDartColor(Colors.blue),
      )
    ];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if(_state!.isSaveRespon) _state!.addRespon(_start);
      },
      child: Column(
        children: <Widget>[
          SizedBox(height:200),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Align(
              alignment: Alignment.center,
              child: VClock(
                size: MediaQuery.of(context).size.height / 4,
              ),
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(25),
            child: Card(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Tap To View",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Your respon since alarm start in minutes",
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: charts.LineChart(series,
                          domainAxis: const charts.NumericAxisSpec(
                            tickProviderSpec:
                            charts.BasicNumericTickProviderSpec(zeroBound: true),
                            viewport: charts.NumericExtents(1.0, 10.0),
                          ),
                          animate: true),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}