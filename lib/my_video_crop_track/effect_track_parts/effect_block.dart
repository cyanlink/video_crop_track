import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/viewmodel.dart';
import 'effect_track.dart';

class EffectBlock extends StatefulWidget {
  EffectBlock({required this.clipIndex, this.showTrailingIcon = false, Key? key})
      : super(key: key);
  final int clipIndex;
  final bool showTrailingIcon;

  @override
  State<EffectBlock> createState() => _EffectBlockState();
}

class _EffectBlockState extends State<EffectBlock> {
  Offset maxEndOffset = Offset(800, 0);
  final Offset minBetweenOffset = Offset(20.0, 0);

  bool get canExtendLeft => startOffset.dx > 0;

  bool get canExtendRight => endOffset.dx < maxEndOffset.dx;

  Offset startOffset = Offset(0, 0);
  Offset endOffset = Offset(350, 0);

  Offset get paddedStartOffset => startOffset + Offset(handlerWidth, 0);

  Offset get paddedEndOffset => endOffset + Offset(handlerWidth, 0);

  final handlerWidth = 40.0; //ear width

  bool isLeftExtending = false, isRightExtending = false;
  bool _autoScrolling = false;

  static const autoScrollAreaWidth = 50.0;

  late ScrollableState _scrollable;

  mockHandler() => SizedBox(
        width: handlerWidth,
      );

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scrollable = Scrollable.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ScrollController>();
    return Stack(
      children: [
        //底部的缩略图条
        Positioned(
            left: -startOffset.dx,
            top: 0,
            child: Row(
              children: List.generate(
                  8,
                  (index) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(color: Colors.black26)),
                        alignment: Alignment.center,
                        child: Text(
                          index.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                //前后添加占位符
                ..insert(0, mockHandler())
                ..add(mockHandler()),
            )),
        //上层拖拽框选条
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //leftEar
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              //NOTE 其实并不困难，此处添加边缘滚动，等于持续在边缘长拖拽时，执行下面的正常拖动逻辑，同时修改startOffset和进行整体滚动，
              //和正常逻辑是一样的，可提取出来复用
              onHorizontalDragEnd: (detail) {
                isLeftExtending = false;
              },
              onHorizontalDragUpdate: (detail) {
                makeLeftHandlerMovement(detail.delta, controller);
                if (detail.delta <= Offset.zero) {
                  isLeftExtending = true;
                  leftAutoScrollWhileOnMargin(
                      controller, detail.globalPosition);
                } else {
                  isLeftExtending = false;
                }
              },
              child: Container(
                width: handlerWidth,
                child: Icon(Icons.arrow_left),
                decoration: BoxDecoration(
                    color: canExtendLeft ? Colors.blue : Colors.grey,
                    border: Border(left: BorderSide(color: Colors.black38))),
              ),
            ),
            //content
            longPressMover(
              child: Container(
                width: endOffset.dx - startOffset.dx,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.white, width: 2))),
              ),
            ),

            //rightEar
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (detail) {
                isRightExtending = false;
              },
              onHorizontalDragUpdate: (detail) {
                makeRightHandlerMovement(detail.delta, controller);
                if (detail.delta >= Offset.zero) {
                  isRightExtending = true;
                  rightAutoScrollWhileOnMargin(
                      controller, detail.globalPosition);
                } else {
                  isRightExtending = false;
                }
              },
              child: Container(
                width: handlerWidth,
                child: Icon(Icons.arrow_right),
                decoration: BoxDecoration(
                    color: canExtendRight ? Colors.blue : Colors.grey,
                    border: Border(right: BorderSide(color: Colors.black38))),
              ),
            ),
            if (widget.showTrailingIcon)
              Container(
                color: Colors.lightBlue,
                child: IconButton(
                    iconSize: 18.0,
                    onPressed: () {},
                    icon: Icon(Icons.add_circle_outlined)),
              )
          ],
        )
        //ThumbnailRow
        //DragCropHandler
      ],
    );
  }

  makeLeftHandlerMovement(Offset delta, ScrollController controller) async {
    var originalOffset = startOffset;
    if (mounted)
      setState(() {
        startOffset += delta;
        if (startOffset <= Offset.zero) {
          startOffset = Offset.zero;
        } else if (startOffset >= endOffset - minBetweenOffset) {
          startOffset = endOffset - minBetweenOffset;
        }
      });
    var realDelta = startOffset - originalOffset;
    final effect = context.read<SomeEffect>();
    effect.startTime += delta.dx * secondsPerWidthUnit;

    final vm = context.read<EffectsViewModel>();
    final index = vm.effectList.indexOf(effect);
    vm.modifyDurationBefore(index, delta.dx * secondsPerWidthUnit);
    //左耳朵向前移动，dx为-，整个ScrollView应对应向后滚动，左耳朵向后移动，dx为+，ScrollView向前滚动
    //controller.jumpTo(controller.offset - realDelta.dx);
  }

  leftAutoScrollWhileOnMargin(
      ScrollController controller, Offset globalPos) async {
    RenderBox renderBox = _scrollable.context.findRenderObject()! as RenderBox;
    final globalRenderBox = renderBox.localToGlobal(Offset.zero);
    final scrollableLeftEdge = globalRenderBox.dx;
    //如果正在向左扩展（用户向左划动/最终按住停下），且没有在进行自动滚动
    if (isLeftExtending && !_autoScrolling && canExtendLeft) {
      if (globalPos.dx <= scrollableLeftEdge + autoScrollAreaWidth) {
        _autoScrolling = true;
        await makeLeftHandlerAutoScroll(Offset(-4, 0), controller);
        _autoScrolling = false;
        leftAutoScrollWhileOnMargin(controller, globalPos);
      }
    }
  }

  makeLeftHandlerAutoScroll(Offset delta, ScrollController controller) async {
    if (mounted)
      setState(() {
        startOffset += delta;
        if (startOffset <= Offset.zero) {
          startOffset = Offset.zero;
        } else if (startOffset >= endOffset - minBetweenOffset) {
          startOffset = endOffset - minBetweenOffset;
        }
      });

    final effect = context.read<SomeEffect>();
    effect.endTime += delta.dx * secondsPerWidthUnit;

    final vm = context.read<EffectsViewModel>();
    final index = vm.effectList.indexOf(effect);
    vm.modifyDurationAfter(index, delta.dx * secondsPerWidthUnit);
    //左侧扩展滚动不会导致前面全部Item长度变化，因此ScrollView的offset不用变
    await Future.delayed(Duration(milliseconds: 14));
  }

  makeRightHandlerMovement(Offset delta, ScrollController controller) {
    if (mounted)
      setState(() {
        endOffset += delta;
        if (endOffset >= maxEndOffset) {
          endOffset = maxEndOffset;
        } else if (endOffset <= startOffset + minBetweenOffset) {
          endOffset = startOffset + minBetweenOffset;
        }
      });
    //右侧耳朵的移动不会影响外侧ScrollView，所以不用手动滚动
  }

  rightAutoScrollWhileOnMargin(
      ScrollController controller, Offset globalPos) async {
    RenderBox renderBox = _scrollable.context.findRenderObject()! as RenderBox;
    final globalRenderBox = renderBox.localToGlobal(Offset.zero);
    final scrollableLeftEdge = globalRenderBox.dx;
    final scrollableRightEdge = scrollableLeftEdge + renderBox.size.width;
    if (isRightExtending && !_autoScrolling && canExtendRight) {
      if (globalPos.dx >= scrollableRightEdge - autoScrollAreaWidth) {
        _autoScrolling = true;
        await makeRightHandlerAutoScroll(Offset(4, 0), controller);
        _autoScrolling = false;
        rightAutoScrollWhileOnMargin(controller, globalPos);
      }
    }
  }

  makeRightHandlerAutoScroll(Offset delta, ScrollController controller) async {
    if (mounted)
      setState(() {
        endOffset += delta;
        if (endOffset >= maxEndOffset) {
          endOffset = maxEndOffset;
        } else if (endOffset <= startOffset + minBetweenOffset) {
          endOffset = startOffset + minBetweenOffset;
        }
      });
    //右侧扩展滚动会带动整个ScrollView滚动
    //await controller.animateTo(controller.offset + delta.dx, duration: const Duration(milliseconds: 14), curve: Curves.linear);
  }

  longPressMover({required Widget child}){
    return Consumer<SomeEffect>(

      builder:(context, effect, _)=> GestureDetector(
        onHorizontalDragUpdate: (update){
          effect.endTime+=update.delta.dx * secondsPerWidthUnit;
          effect.startTime+=update.delta.dx * secondsPerWidthUnit;
        },
        child: child,
      ),
    );
  }
}


