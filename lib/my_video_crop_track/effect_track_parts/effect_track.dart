import 'package:flutter/cupertino.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/effect_block.dart';

///实现思路：使用链表，一种透明的SizedBox提供Offset，一种是真正的能拖拽的控件，但是这个控件在改变自身大小时还会
class EffectTrack extends StatefulWidget {
  EffectTrack({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectTrackState();
  }
}

class EffectTrackState extends State<EffectTrack> {
  double _start = 100.0;
  double get start => _start;
  set start(newVal){
    setState(() {
      _start = newVal;
      if(_start < 0) _start = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _start,
        ),
        EffectBlock(clipIndex: 0, parent: this)
      ],
    );
  }



  modifyStart(double delta) {
    setState(() {
      _start += delta;
      if(_start < 0) _start = 0;
    });
  }
}
