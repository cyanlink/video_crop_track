import 'package:flutter/cupertino.dart';
import 'package:video_crop_track/track_custom_paint.dart';
import 'package:video_crop_track/track_style.dart';

import '../video_track_painter.dart';

class MyCropClip extends StatefulWidget {
  MyCropClip({Key? key}) : super(key: key);

  @override
  State<MyCropClip> createState() => _MyCropClipState();
}

class _MyCropClipState extends State<MyCropClip> {
  Offset startOffset = Offset(0, 0);
  Offset endOffset = Offset(0, 0);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: - startOffset.dx,
            top: 0,
            child: Row()
        ),
        TrackCustomPaint(
          size: Size(100, 0),
          painter: VideoTrackPainter(
            leftEarOffset: Offset.zero,
            rightEarOffset: endOffset - startOffset,
            timelineOffset: Offset.zero,
            style: const TrackStyle(),
          ),
        ),
        //ThumbnailRow
        //DragCropHandler
      ],
    );
  }
}
