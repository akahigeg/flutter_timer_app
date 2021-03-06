import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TimerViewModel extends ChangeNotifier {
  String timerId = "timer1";

  int _initialMin = 0; // SharedPreferencesから読む
  int _initialSec = 0; // SharedPreferencesから読む
  int _initialMsec = 1000; // 設定できない値なので固定

  String _min = '00';
  String _sec = '00';
  String _msec = '00';

  var _timer;
  var _startTime;
  var _lastStopTime;
  var _stoppedMilliseconds = 0; // 中断時間の合計
  bool _isStart = false;
  bool _inEdit = false;

  int get initialMin => _initialMin;
  int get initialSec => _initialSec;

  String get min => _min;
  String get sec => _sec;
  String get msec => _msec;

  bool get isStart => _isStart;
  bool get inEdit => _inEdit;

  void restore() async {
    var prefs = await SharedPreferences.getInstance();
    var timer = prefs.getString(timerId) ?? "03:00:00";
    var numbers = timer.toString().split(":");

    _initialMin = int.parse(numbers[0]);
    _initialSec = int.parse(numbers[1]);
    _min = numbers[0].toString().padLeft(2, '0');
    _sec = numbers[1].toString().padLeft(2, '0');
    _msec = numbers[2].toString().padLeft(2, '0');

    update();

    notifyListeners();
  }

  void changeMin(newMin) {
    _min = newMin;

    notifyListeners();
  }

  void changeSec(newSec) {
    _sec = newSec;

    notifyListeners();
  }

  void _countDown(Timer timer) {
    // 開始時間と現在時間の差分から表示内容を求める
    var currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    // 経過した時間
    var pastMsec = currentTimestamp - _startTime.millisecondsSinceEpoch - _stoppedMilliseconds;
    int minusSec = (pastMsec / 1000).ceil();
    // タイマーが1:03で3秒経過で1:00 4秒経過で0:59になってほしい
    // タイマーが1:13で13秒経過で1:00 14秒経過で0:59になってほしい
    int minusMin;
    if (minusSec % 60 > _initialSec) {
      minusMin = (minusSec / 60).ceil();
    } else {
      minusMin = (minusSec / 60).floor();
    }

    // 表示する時間
    int newMsec = ((_initialMsec - pastMsec % 1000) ~/ 10).floor();
    int newSec = ((_initialSec - minusSec) % 60).floor();
    int newMin = (_initialMin - minusMin);

    _msec = newMsec.toString().padLeft(2, '0');
    _sec = newSec.toString().padLeft(2, '0');
    _min = newMin.toString().padLeft(2, '0');

    if (_min == '00' && _sec == '00' && _msec == '00') {
      // すべての桁が0になったらタイマー終了
      finish();
    }

    notifyListeners();
  }

  void start() {
    if (_min == '00' && _sec == '00' && _msec == '00') {
      // すべての桁が0であったらタイマーをスタートしない
      return;
    }

    _isStart = true;

    if (_lastStopTime == null) {
      // 新しいタイマーの開始
      _startTime = DateTime.now();
    } else {
      // 中断したタイマーの再開
      _stoppedMilliseconds = (DateTime.now().millisecondsSinceEpoch - _lastStopTime.millisecondsSinceEpoch).toInt() + _stoppedMilliseconds;
      print(_lastStopTime.millisecondsSinceEpoch);
      print(DateTime.now().millisecondsSinceEpoch);
      print(_stoppedMilliseconds);
    }

    _timer = Timer.periodic(
      Duration(milliseconds: 1),
      _countDown,
    );

    notifyListeners();
  }

  void stop() {
    _isStart = false;

    // 中断したタイマーの再開ができるように停めた時間を記録
    _lastStopTime = DateTime.now();
    _timer.cancel(); // _switchTimer以外から_stopTimerを呼び出すとなぜかバグる

    notifyListeners();
  }

  void reset() {
    _isStart = false;
    _lastStopTime = null;
    _stoppedMilliseconds = 0;

    if (_timer != null) {
      _timer.cancel();
    }

    // _stopTimer();
    restore();
  }

  void finish() {
    reset();
    // _stopTimer();
    // _player.play('warn.mp3'); Androidでビルドできないのでk
    // TODO: 完了処理を入れる
  }

  void startEdit() {
    _inEdit = true;
    if (_timer != null) {
      reset();
    }

    notifyListeners();
  }

  void update() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(timerId, "$_min:$_sec:00");
  }

  void finishEdit() {
    update();
    _inEdit = false;
    reset();
  }

  void cancelEdit() {
    _inEdit = false;
    reset();
  }
}
