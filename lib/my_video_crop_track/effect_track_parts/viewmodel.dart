import 'package:flutter/material.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/effect_track.dart';

class SomeEffect extends ChangeNotifier {
  SomeEffect(double startTime, double endTime, {minDuration = 3.0})
      : _startTime = startTime,
        _endTime = endTime,
        _minDuration = minDuration;

  double _startTime, _endTime;
  final double _minDuration;

  set startTime(double time) {
    _startTime = time;
    if (_startTime < 0) _startTime = 0;
    notifyListeners();
  }

  double get startTime => _startTime;

  set endTime(time) {
    _endTime = time;
    final minTime = _startTime + _minDuration;
    if (_endTime < minTime) _endTime = minTime;
    notifyListeners();
  }

  get endTime => _endTime;

  double get duration => _endTime - _startTime;
}

class EffectsViewModel extends ChangeNotifier {
  List<double> durationBetween;

  EffectsViewModel(this.effectList, timelineDuration)
      : _timelineDuration = timelineDuration,
        durationBetween = List.filled(effectList.length + 1, 0.0) {
    double lastTime = 0;
    var index = 0;
    for (final effect in effectList) {
      durationBetween[index++] = (effect.startTime - lastTime);
      lastTime = effect.endTime;
    }
    durationBetween[index] = _timelineDuration - lastTime;
  }

  double _timelineDuration;

  set timelineDuration(dur) {
    var oldTimelineDuration = _timelineDuration;
    _timelineDuration = dur;
    var diff = _timelineDuration - oldTimelineDuration;
    durationBetween.last += diff;
    if (durationBetween.last < 0) durationBetween.last = 0;
    notifyListeners();
  }

  get timelineDuration => _timelineDuration;
  final List<SomeEffect> effectList;

  addEffect(SomeEffect effect) {
    effectList.add(effect);
    notifyListeners();
  }

  getDurationBefore(int index) {
    return durationBetween[index];
  }

  //返回真实变化，不会越界的RealDelta，时间，不是Offset！
  double safeModifyStartTimeAndDurationBefore(int index, double delta) {
    final effect = effectList[index];
    final originalDurBefore = durationBetween[index];
    final pretestResult = originalDurBefore + delta;
    final realDelta = pretestResult <= 0 ? -originalDurBefore : delta;
    effect.startTime += realDelta;
    durationBetween[index] += realDelta;
    notifyListeners();
    return realDelta;
  }

  //这里逻辑需要改，不能往后
  ///返回真实变化的Realdelta，以时间形式
  double safeModifyEndTimeAndDurationAfter(int index, double delta) {
    final effect = effectList[index];
    final originalDurAfter = durationBetween[index + 1];
    final pretestResult = originalDurAfter - delta;
    final realDelta = pretestResult <= 0 ? originalDurAfter : delta;
    effect.endTime += realDelta;
    durationBetween[index + 1] -= realDelta;
    print(
        "sum:${durationBetween.reduce((value, element) => value + element) + effectList.map((e) => e.duration).reduce((value, element) => value + element)}, timeline duration: $_timelineDuration");
    notifyListeners();
    return realDelta;
  }
}

class TimelineDuration extends ChangeNotifier {
  TimelineDuration({required int clipCount})
      : clipDurations = List.filled(clipCount, 350 / widthUnitPerSecond);
  List<double> clipDurations;

  operator [](int index) => clipDurations[index];

  operator []=(int index, double val) {
    clipDurations[index] = val;
    notifyListeners();
  }

  double get timelineDuration =>
      clipDurations.reduce((value, element) => value + element);
}
