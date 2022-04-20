import 'package:boxy/flex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/effect_block.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/viewmodel.dart';

///实现思路：使用链表?，一种透明的SizedBox提供Offset，一种是真正的能拖拽的控件，但是这个控件在改变自身大小时还会
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
    return ChangeNotifierProxyProvider<TimelineDuration, EffectsViewModel>(
      create: (context) => EffectsViewModel(
          [
            SomeEffect(0.0, 5.0),
            SomeEffect(10.0, 15.0),
            SomeEffect(20.0, 25.0)
          ],
          Provider.of<TimelineDuration>(context, listen: false)
              .timelineDuration),
      update: (c, dur, evm) {
        evm!.timelineDuration = dur.timelineDuration;
        return evm;
      },
      builder: (context, child) => Row(
        children: [...itemListInRow(context)],
      ),
    );
  }

  List<Widget> itemListInRow(BuildContext context) {
    var effectsvm = context.watch<EffectsViewModel>();
    final effects = effectsvm.effectList;
    List<Widget> widgets = [];
    double lastTime = 0;
    var index = 0;
    for (var e in effects) {
      //TODO fix the following monkey patch!
      //TODO 仍然存在一个问题：修改effect不能更新依赖于effect list的这些spacer
      if (e.startTime < lastTime) e.startTime = lastTime;
      widgets.add(customizedSpacerRow(e, effectsvm, index++));
      lastTime = e.endTime;
    }
    widgets.add(
      //最后一个补齐Widget，使用Expanded防止overflow问题，
      Expanded(
        child: SizedBox(
          width: (effectsvm.getDurationBefore(index)) * widthUnitPerSecond,

        ),
      ),
    );
    return widgets;
  }

  Widget customizedSpacerRow(
      SomeEffect effect, EffectsViewModel effectsvm, int index) {
    return ChangeNotifierProvider<SomeEffect>.value(
      value: effect,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: (effectsvm.getDurationBefore(index)) * widthUnitPerSecond,
          ),
          EffectBlock(clipIndex: index)
        ],
      ),
    );
  }
}

const double secondsPerThumbnail = 5.0;
const double thumbnailSize = 80.0;
const secondsPerWidthUnit = secondsPerThumbnail / thumbnailSize;
const widthUnitPerSecond = 1 / secondsPerWidthUnit;
