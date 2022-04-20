import 'package:flutter/cupertino.dart';

enum _Slot {
  timeline,
  effect_track,
}

///这一套行不通，为什么呢？因为我想要让它实现MainAxisSize.min或者说shrinkWrap功能，要去自己手写RenderObject！！
class FollowTimelineWidth extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    Size leaderSize = Size.zero;
    Size trackSize = Size.zero;

    if (hasChild(_Slot.timeline)) {
      leaderSize = layoutChild(_Slot.timeline, BoxConstraints.loose(size));
      positionChild(_Slot.timeline, Offset.zero);
    }

    if (hasChild(_Slot.effect_track)) {
      trackSize = layoutChild(_Slot.effect_track, BoxConstraints.tight(leaderSize));
      positionChild(_Slot.effect_track, Offset(0,
          leaderSize.height));
    }

  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;

  @override
  Size getSize(BoxConstraints constraints) {
    Size leaderSize = Size.zero;
    Size trackSize = Size.zero;
    if (hasChild(_Slot.timeline)) {
      leaderSize = layoutChild(_Slot.timeline, BoxConstraints.loose(constraints.biggest));
    }

    if (hasChild(_Slot.effect_track)) {
      trackSize = layoutChild(_Slot.effect_track, BoxConstraints.tight(leaderSize));
    }
    return constraints.constrain(leaderSize+Offset(0, trackSize.height));
  }
}

class NewCompositeTimelineTrack extends StatelessWidget {
  NewCompositeTimelineTrack(
      {required this.timeline, required this.effectTrack});

  final Widget timeline;
  final Widget effectTrack;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(delegate: FollowTimelineWidth(),
      children: [
        LayoutId(id: _Slot.timeline, child: timeline),
        LayoutId(id: _Slot.effect_track, child: effectTrack)
      ],);
  }
}

class Playground extends MultiChildLayoutDelegate{
  @override
  void performLayout(Size size) {
    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}