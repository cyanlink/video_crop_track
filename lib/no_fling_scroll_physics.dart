import 'package:flutter/cupertino.dart';

class NoFlingScrollPhysics extends ScrollPhysics{
  const NoFlingScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  double get minFlingVelocity => double.infinity;

  @override
  double get maxFlingVelocity => double.infinity;

  @override
  double get minFlingDistance => double.infinity;

  @override
  NoFlingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoFlingScrollPhysics(parent: buildParent(ancestor));
  }
}