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
          [SomeEffect(5, 10), SomeEffect(15, 20), SomeEffect(25, 30)]),
      builder: (context, child) => Row(
        children: [
          ...itemListInRow(context)
        ],
      ),
    );
  }


  List<Widget> itemListInRow(BuildContext context) {
    var effectsvm = context.watch<EffectsViewModel>();
    var controller = context.watch<ScrollController>();

    final effects = effectsvm.effectList;
    List<Widget> widgets = [];
    var lastTime = 0;
    for (var e in effects) {
      widgets.add(SizedBox(
        width: (e.startTime - lastTime) * widthUnitPerSecond,
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
