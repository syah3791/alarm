import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VTimePicker extends StatelessWidget {
  List<int> _hour = List<int>.generate(24, (index) => index);
  List<int> _minute = List<int>.generate(60, (index) => index);
  TimeOfDay? time;
  Function(TimeOfDay)? onChanged;
  VTimePicker({this.time, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
              height: 100.0,
              alignment: Alignment.center,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                itemExtent: 24,
                scrollController: FixedExtentScrollController(initialItem: time!.hour),
                childCount: _hour.length,
                onSelectedItemChanged: (value) {
                  time = time!.replacing(hour: value);
                  onChanged!(time!);
                  },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '$index',// ?? DATETIME_PICKER_ITEM_TEXT_STYLE,
                    ),
                  );
                },
              ),
            )
        ),
        Text(':', style: TextStyle(fontWeight: FontWeight.bold),),
        Expanded(
            flex: 1,
          child: Container(
            height: 100.0,
            alignment: Alignment.center,
            child: CupertinoPicker.builder(
              backgroundColor: Colors.white,
              itemExtent: 24,
              scrollController: FixedExtentScrollController(initialItem: time!.minute),
              childCount: _minute.length,
              onSelectedItemChanged: (value) {
                time = time!.replacing(minute: value);
                onChanged!(time!);
              },
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '$index',// ?? DATETIME_PICKER_ITEM_TEXT_STYLE,
                  ),
                );
              },
            ),
          )
        )
      ],
    );
  }
}