import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/effect_block.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/viewmodel.dart';

///实现思路：使用链表，一种透明的SizedBox提供Offset，一种是真正的能拖拽的控件，但是这个控件在改变自身大小时还会
class EffectTrack extends StatefulWidget {
  EffectTrack({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectTrackState();
  }
}

class EffectTrackState extends State<EffectTrack> {

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ScrollController>();
    return ChangeNotifierProvider<EffectsViewModel>(
      create: (context) => EffectsViewModel(
          [SomeEffect(5.0, 10.0), SomeEffect(15.0, 20.0), SomeEffect(25.0, 30.0)]),
      builder: (context, child) => Row(
        children: [
          ...itemListInRow(context)
        ],
      ),
    );
  }


  List<Widget> itemListInRow(BuildContext context) {
    var effectsvm = context.watch<EffectsViewModel>();

    final effects = effectsvm.effectList;
    List<Widget> widgets = [];
    double lastTime = 0;
    for (var e in effects) {
      //TODO fix the following monkey patch!
      //TODO 仍然存在一个问题：修改effect不能更新依赖于effect list的这些spacer
      if(e.startTime < lastTime)
        e.startTime = lastTime;
      widgets.add(SizedBox(
        width: (effectsvm.getDurationBefore(effects.indexOf(e))) * widthUnitPerSecond,
      ));
      widgets.add(ChangeNotifierProvider<SomeEffect>.value(
          value: e,
          child: EffectBlock(clipIndex: effects.indexOf(e))));
      lastTime = e.endTime;
    }
    return widgets;
  }
}

const double secondsPerThumbnail = 5.0;
const double thumbnailSize = 80.0;
const secondsPerWidthUnit = secondsPerThumbnail / thumbnailSize;
const widthUnitPerSecond = 1 / secondsPerWidthUnit;
