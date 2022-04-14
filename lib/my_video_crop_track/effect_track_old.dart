import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class EffectTrack extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EffectTrackState();
}

//比如说，我们通过上层获取到了时间线的全长度
int thumbs = 10;
double timelineTotalLength = (80 * thumbs).toDouble();
double get timelineTotalTimeDuration => timelineTotalLength / 80 * 5000;


class EffectTrackState extends State<EffectTrack> {
  List<Widget> get widgetList {
    var lastItemEndTime = 0;
    final list = <Widget>[];
    for (var effect in effectList) {
      final double leng =
          timelineTotalLength * effect.startTime / timelineTotalTimeDuration;
      list.add(Container(
        width: leng,
      ));
      final double effectLeng = timelineTotalLength *
          (effect.endTime - effect.startTime) /
          timelineTotalTimeDuration;
      list.add(Container(
        width: effectLeng,
        child: Text(effect.description),
      ));
    }
    return list;
  }

  List<TimedEffect> effectList = [
    TimedEffect(1000, 5000, "Sticker"),
    TimedEffect(6000, 10000, "AudioStuff"),
  ];

  @override
  Widget build(BuildContext context) {
    final _controller = context.watch<ScrollController>();
    timelineTotalLength =
    _controller.hasClients ? _controller.position.maxScrollExtent : -1;
    return Row(children: widgetList);
  }
}

class TimedEffect {
  TimedEffect(this.startTime, this.endTime, this.description);

  int startTime, endTime;
  String description;
}
