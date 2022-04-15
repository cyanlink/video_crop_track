import 'package:flutter/material.dart';

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

  EffectsViewModel(this.effectList)
      : durationBetween = List.filled(effectList.length + 1, 0.0) {
    double lastTime = 0;
    for (final effect in effectList) {
      int index = effectList.indexOf(effect);
      durationBetween[index] = (effect.startTime - lastTime);
    }
  }

  final List<SomeEffect> effectList;

  addEffect(SomeEffect effect) {
    effectList.add(effect);
    notifyListeners();
  }

  getDurationBefore(int index) {
    return durationBetween[index];
  }

  setDurationBefore(int index, double duration) {
    durationBetween[index] = duration;
    notifyListeners();
  }

  modifyDurationBefore(int index, double delta) {
    durationBetween[index] += delta;
    notifyListeners();
  }

  setDurationAfter(int index, double duration) {
    durationBetween[index + 1] = duration;
    notifyListeners();
  }

  modifyDurationAfter(int index, double delta) {
    durationBetween[index + 1] += delta;
    notifyListeners();
  }

  safeModifyStartTimeAndDurationBefore(int index, double delta) {
    final effect = effectList[index];
    final originalDurBefore = durationBetween[index];
    final val = originalDurBefore + delta;
    final realDelta = val < 0 ? 0 : delta;
    effect.startTime += realDelta;
    durationBetween[index] += realDelta;
    notifyListeners();
  }


  //这里逻辑需要改，不能往后
  safeModifyEndTimeAndDurationAfter(int index, double delta) {
    final effect = effectList[index];
    final originalDurAfter = durationBetween[index + 1];
    final pretestResult = originalDurAfter - delta;
    final realDelta = pretestResult < 0 ? 0 : delta;
    effect.endTime += realDelta;
    durationBetween[index + 1] -= realDelta;
    notifyListeners();
  }
}
