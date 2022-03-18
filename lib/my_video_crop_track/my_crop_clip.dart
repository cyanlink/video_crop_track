import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCropClip extends StatefulWidget {
  MyCropClip({required this.clipIndex, this.showTrailingIcon = true, Key? key})
      : super(key: key);
  final int clipIndex;
  final bool showTrailingIcon;

  @override
  State<MyCropClip> createState() => _MyCropClipState();
}

class _MyCropClipState extends State<MyCropClip> {
  Offset maxEndOffset = Offset(400, 0);
  final Offset minBetweenOffset = Offset(20.0, 0);

  Offset startOffset = Offset(0, 0);
  Offset endOffset = Offset(120, 0);

  Offset get paddedStartOffset => startOffset + Offset(handlerWidth, 0);

  Offset get paddedEndOffset => endOffset + Offset(handlerWidth, 0);

  final handlerWidth = 20.0; //ear width

  bool isLeftDragging = false, isRightDragging = false;
  bool _autoScrolling = false;

  mockHandler() => SizedBox(
        width: handlerWidth,
      );

  @override
  initState() {
    super.initState();
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
                        width: 50,
                        height: 50,
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
              //TODO 添加边缘扩展滚动
              //NOTE 其实并不困难，此处添加边缘滚动，等于持续在边缘长拖拽时，执行下面的正常拖动逻辑，同时修改startOffset和进行整体滚动，
              //和正常逻辑是一样的，可提取出来复用
              onHorizontalDragDown: (detail) async {
                isLeftDragging = true;
              },
              onHorizontalDragEnd: (detail) {
                isLeftDragging = false;
              },
              onHorizontalDragUpdate: (detail) {
                makeLeftHandlerMovement(detail.delta, controller);
                leftAutoScrollWhileOnMargin(controller, detail.globalPosition);
              },
              child: Container(
                width: handlerWidth,
                child: Icon(Icons.arrow_left),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border(left: BorderSide(color: Colors.black38))),
              ),
            ),
            //content
            Container(
              width: endOffset.dx - startOffset.dx,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.white, width: 2))),
            ),
            //rightEar
            GestureDetector(
              onHorizontalDragUpdate: (update) {
                //右侧耳朵的移动不会影响外侧ScrollView，所以不用手动滚动
                setState(() {
                  endOffset += update.delta;
                  if (endOffset >= maxEndOffset) {
                    endOffset = maxEndOffset;
                  } else if (endOffset <= startOffset + minBetweenOffset) {
                    endOffset = startOffset + minBetweenOffset;
                  }
                });
              },
              child: Container(
                width: handlerWidth,
                child: Icon(Icons.arrow_right),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border(right: BorderSide(color: Colors.black38))),
              ),
            ),
            //TODO 添加转场按钮
            if (widget.showTrailingIcon)
              IconButton(
                  iconSize: 18.0,
                  onPressed: () {},
                  icon: Icon(Icons.add_circle_outlined))
          ],
        )
        //ThumbnailRow
        //DragCropHandler
      ],
    );
  }

  makeLeftHandlerMovement(Offset delta, ScrollController controller) async {
    var originalOffset = startOffset;
    setState(() {
      startOffset += delta;
      if (startOffset <= Offset.zero) {
        startOffset = Offset.zero;
      } else if (startOffset >= endOffset - minBetweenOffset) {
        startOffset = endOffset - minBetweenOffset;
      }
    });
    var realDelta = startOffset - originalOffset;

    //左耳朵向前移动，dx为-，整个ScrollView应对应向后滚动，左耳朵向后移动，dx为+，ScrollView向前滚动
    await controller.animateTo(controller.offset - realDelta.dx, duration: Duration(milliseconds: 14), curve: Curves.linear);
  }

  leftAutoScrollWhileOnMargin(
      ScrollController controller, Offset globalPos) async {
    if (isLeftDragging&& ! _autoScrolling) {
      if (globalPos <= Offset(50, 0)) {
        _autoScrolling = true;
        await makeLeftHandlerMovement(Offset(20,0), controller);
        _autoScrolling = false;
        leftAutoScrollWhileOnMargin(controller, globalPos);
      }
    }
  }
}
