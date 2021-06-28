import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Clock(title: 'Flutter Demo Home Page'),
    );
  }
}

class Clock extends StatefulWidget {
  Clock({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  State<StatefulWidget> createState() {
    return _ClockState();
  }
}

class _ClockState extends State<Clock> {
  String _min = '99';
  String _sec = '59';
  String _msec = '59';

  @override
  void initState() {
    super.initState();
  }

  void _onTimer(Timer timer) {
    int secDown = 0;
    int newMsec = int.parse(_msec) - 1;
    if (newMsec < 0) {
      newMsec = 59;
      secDown = 1;
    }
    setState(() => _msec = newMsec.toString().padLeft(2, '0'));

    int minDown = 0;
    int newSec = int.parse(_sec) - secDown;
    if (newSec < 0) {
      newSec = 59;
      minDown = 1;
    }
    setState(() => _sec = newSec.toString().padLeft(2, '0'));

    int newMin = int.parse(_min) - minDown;
    if (newMin < 0) {
      // TODO: minが-1になった時点でタイマー終了
    }
    setState(() => _min = newMin.toString().padLeft(2, '0'));
  }

  void _startTimer() {
    Timer.periodic(
      Duration(milliseconds: 1),
      _onTimer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Remain time:',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_min:',
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  '$_sec:',
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  '$_msec',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Container(
              width: 100,
              height: 50,
              margin: EdgeInsets.only(top: 50.0),
              color: Colors.greenAccent,
              child: TextButton(child: Text('START'), onPressed: _startTimer),
              // TODO: ボタンを押したらSTART/STOPをトグル
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
