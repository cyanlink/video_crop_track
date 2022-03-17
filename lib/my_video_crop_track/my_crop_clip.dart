import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCropClip extends StatefulWidget {
  MyCropClip({required this.clipIndex, Key? key}) : super(key: key);
  final int clipIndex;

  @override
  State<MyCropClip> createState() => _MyCropClipState();
}

class _MyCropClipState extends State<MyCropClip> {
  Offset maxEndOffset = Offset(200, 0);

  Offset startOffset = Offset(0, 0);
  Offset endOffset = Offset(50, 0);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ScrollController>();
    return Stack(
      children: [
        Positioned(
            left: -startOffset.dx,
            top: 0,
            child: Row(
              children: List.generate(
                  4,
                  (index) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.green,
                        alignment: Alignment.center,
                        child: Text(index.toString(), style: TextStyle(color: Colors.white),),
                      )),
            )),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //leftEar
            GestureDetector(
              onHorizontalDragUpdate: (update){
                var originalOffset = startOffset;
                setState(() {
                  startOffset += update.delta;
                  if(startOffset <= Offset.zero){
                    startOffset = Offset.zero;
                  }else if(startOffset >= endOffset - Offset(20, 0)){
                    startOffset = endOffset - Offset(20, 0);
                  }
                });
                var realDelta = startOffset - originalOffset;

                //左耳朵向前移动，dx为-，整个ScrollView应对应向后滚动，左耳朵向后移动，dx为+，ScrollView向前滚动
                controller.jumpTo(controller.offset - realDelta.dx);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_left)),
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
              onHorizontalDragUpdate: (update){
                setState(() {
                  endOffset += update.delta;
                  if(endOffset >= maxEndOffset){
                    endOffset = maxEndOffset;
                  }
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_right)),
            ),
          ],
        )
        //ThumbnailRow
        //DragCropHandler
      ],
    );
  }
}
