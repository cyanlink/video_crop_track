import 'package:flutter/cupertino.dart';

enum _Slot {
  timeline,
  effect_track,
}
class FollowTimelineWidth extends MultiChildLayoutDelegate{
  @override
  void performLayout(Size size) {
    Size leaderSize = Size.zero;

    if (hasChild(_Slot.timeline)) {
      leaderSize = layoutChild(_Slot.timeline, BoxConstraints.loose(size));
      positionChild(_Slot.timeline, Offset.zero);
    }

    if (hasChild(_Slot.effect_track)) {
      layoutChild(_Slot.effect_track, BoxConstraints.tight(leaderSize));
      positionChild(_Slot.effect_track, Offset(0,
          size.height - leaderSize.height));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
