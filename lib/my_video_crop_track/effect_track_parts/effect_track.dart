import 'package:flutter/cupertino.dart';


///实现思路：使用链表，一种透明的SizedBox提供Offset，一种是真正的能拖拽的控件，但是这个控件在改变自身大小时还会
class EffectTrack extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EffectTrackState();
  }
}

class EffectTrackState extends State<EffectTrack>{
  @override
  Widget build(BuildContext context) {
    return Center();
  }
}