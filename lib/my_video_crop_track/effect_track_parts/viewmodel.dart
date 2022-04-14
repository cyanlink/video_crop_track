import 'package:flutter/material.dart';

class SomeEffect extends ChangeNotifier {
  int _startTime, _endTime;

  set startTime(time) {
    _startTime = time;
    notifyListeners();
  }

  get startTime => _startTime;

  set endTime(time) {
    _endTime = time;
    notifyListeners();
  }

  get endTime => _endTime;

  SomeEffect(startTime, endTime)
      : _startTime = startTime,
        _endTime = endTime;
}

class EffectsViewModel extends ChangeNotifier {
  EffectsViewModel(this.effectList);

  final List<SomeEffect> effectList;

  addEffect(SomeEffect effect) {
    effectList.add(effect);
    notifyListeners();
  }
}
