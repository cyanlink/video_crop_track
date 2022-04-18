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
}

class EffectsViewModel extends ChangeNotifier {
  List<double> durationBetween;

  EffectsViewModel(this.effectList,timelineDuration): _timelineDuration = timelineDuration,
      durationBetween = List.filled(effectList.length + 1, 0.0) {
    double lastTime = 0;
    var index = 0;
    for (final effect in effectList) {
      durationBetween[index++] = (effect.startTime - lastTime);
    }
  }
  double _timelineDuration;
  set timelineDuration(dur){
    _timelineDuration = dur;
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

  setDurationAt(int index, double dur) {
    durationBetween[index] = dur;
    notifyListeners();
  }

  modifyDurationBefore(int index, double delta) {
    durationBetween[index] += delta;
    notifyListeners();
  }

  modifyDurationAfter(int index, double delta) {
    durationBetween[index + 1] += delta;
    notifyListeners();
  }

  bool safeModifyStartTimeAndDurationBefore(int index, double delta) {
    final effect = effectList[index];
    final originalDurBefore = durationBetween[index];
    final pretestResult = originalDurBefore + delta;
    final realDelta = pretestResult < 0 ? 0 : delta;
    effect.startTime += realDelta;
    durationBetween[index] += realDelta;
    notifyListeners();
    return pretestResult < 0;
  }

  //这里逻辑需要改，不能往后
  ///返回是否发生了"截断"，即后侧到头了
  bool safeModifyEndTimeAndDurationAfter(int index, double delta) {
    final effect = effectList[index];
    final originalDurAfter = durationBetween[index + 1];
    final pretestResult = originalDurAfter - delta;
    final realDelta = pretestResult < 0 ? 0 : delta;
    effect.endTime += realDelta;
    durationBetween[index + 1] -= realDelta;
    notifyListeners();
    return pretestResult < 0;
  }
}

class TimelineWidth extends ChangeNotifier {
  double? _timelineWidth;

  get timelineWidth => _timelineWidth;

  set timelineWidth(w) {
    _timelineWidth = w;
    notifyListeners();
  }
}

class TimelineDuration extends ChangeNotifier {
  TimelineDuration({required int clipCount}): clipDurations = List.filled(clipCount, 350 / widthUnitPerSecond);
  List<double> clipDurations;

  operator [](int index) => clipDurations[index];

  operator []=(int index, double val) {
    clipDurations[index] = val;
    notifyListeners();
  }

  double get timelineDuration => clipDurations.reduce((value, element) => value + element);
}
