import 'package:flutter/material.dart';

class SomeEffect extends ChangeNotifier {
  SomeEffect(double startTime, double endTime, {minDuration = 3.0})
      : _startTime = startTime,
        _endTime = endTime,
        _minDuration = minDuration;

  double _startTime, _endTime, _minDuration;

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
  EffectsViewModel(this.effectList);

  final List<SomeEffect> effectList;

  addEffect(SomeEffect effect) {
    effectList.add(effect);
    notifyListeners();
  }
}
