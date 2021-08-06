/*
 * 项目名:    XyAppDelegate
 * 包名       
 * 文件名:    video_track_widget
 * 创建时间:  2021/8/5 on 10:46
 * 描述:     TODO
 *
 * @author   阿钟
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_crop_track/track_custom_paint.dart';
import 'package:video_crop_track/video_track_painter.dart';

typedef OnSelectDuration<T> = void Function(Duration start, Duration end);
typedef TrackWidgetBuilder = Widget Function(
    BuildContext context, String data, Size size);

class VideoTrackWidget extends StatefulWidget {
  final OnSelectDuration? onSelectDuration;
  final TrackWidgetBuilder trackWidgetBuilder;

  ///视频时长s
  final Duration totalDuration;

  ///图片数量
  final List<String> imgList;

  VideoTrackWidget(
      {Key? key,
      this.onSelectDuration,
      required this.totalDuration,
      required this.imgList,
      required this.trackWidgetBuilder});

  @override
  State<StatefulWidget> createState() {
    return VideoTrackWidgetState();
  }
}

class VideoTrackWidgetState extends State<VideoTrackWidget>
    with TickerProviderStateMixin {
  late Size viewSize;
  late Size trackSize;

  ///左右两边拖拽元素的大小
  Size earSize = Size(20, 48);

  ///左右两边拖拽元素的位置偏移量
  Offset leftEarOffset = Offset.zero;
  Offset timelineOffset = Offset.zero;
  Offset? rightEarOffset;

  bool touchLeft = false;
  bool touchRight = false;

  ///两个滑块将的最小距离
  late double minInsets;

  ///轨道最大显示180秒
  int maxSecond = 180;

  ///最小选择的时间 秒
  int minSelectedSecond = 3;
  late Duration duration;

  ///选中的时间
  late Duration selectStartDur = Duration.zero;

  late Duration selectEndDur;

  ///时间线动画
  AnimationController? _timelineController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    ///最大只能选择180秒，初始默认选择的时间
    duration = selectEndDur = widget.totalDuration.inSeconds > maxSecond
        ? Duration(seconds: maxSecond)
        : widget.totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _initView(constraints);
              return GestureDetector(
                onHorizontalDragDown: (down) {
                  _hideTimeline();
                  _stopAnimation();
                  _onDown(down.localPosition);
                },
                onHorizontalDragUpdate: (move) {
                  _onMove(move.delta);
                },
                onHorizontalDragEnd: (up) {
                  touchLeft = false;
                  touchRight = false;
                  _startTimelineAnimation();
                  _notificationResult();
                },
                child: Stack(
                  children: [
                    Positioned(
                      left: earSize.width,
                      right: earSize.width,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) =>
                            notificationListener(notification),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: _getImageChild(),
                        ),
                      ),
                    ),
                    TrackCustomPaint(
                      size: viewSize,
                      painter: VideoTrackPainter(
                        leftEarOffset: leftEarOffset,
                        rightEarOffset: rightEarOffset!,
                        timelineOffset: timelineOffset,
                        earSize: earSize,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$selectStartDur ～ $selectEndDur',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 14),
        )
      ],
    );
  }

  ///回调
  void _notificationResult() {
    widget.onSelectDuration?.call(selectStartDur, selectEndDur);
  }

  ///只会走一次
  void _initView(BoxConstraints constraints) {
    if (rightEarOffset == null) {
      viewSize = Size(constraints.maxWidth, constraints.maxHeight);
      trackSize = Size(viewSize.width - earSize.width * 2, viewSize.height);
      rightEarOffset = Offset(viewSize.width - earSize.width, 0);
      minInsets = _calcMinInsets();
      _startTimelineAnimation();
    }
  }

  ///计算最小3秒的间隔 宽度是多少
  double _calcMinInsets() {
    return trackSize.width / duration.inSeconds * minSelectedSecond;
  }

  ///滚动监听
  bool notificationListener(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _startTimelineAnimation();
      _notificationResult();
    } else if (notification is ScrollUpdateNotification) {
      _calcSelectDuration();
      setState(() {});
    }
    return false;
  }

  ///时间线动画
  _startTimelineAnimation() {
    if (_timelineController != null) return;
    int selectDuration = selectEndDur.inSeconds - selectStartDur.inSeconds;
    _timelineController = new AnimationController(
        duration: Duration(seconds: selectDuration), vsync: this);
    CurvedAnimation curve =
        CurvedAnimation(parent: _timelineController!, curve: Curves.linear);
    Animation animation =
        Tween(begin: leftEarOffset.dx + earSize.width, end: rightEarOffset!.dx)
            .animate(curve);
    animation.addListener(() {
      setState(() {
        timelineOffset = Offset(animation.value, 0);
      });
    });
    _timelineController?.repeat();
  }

  ///隐藏时间线
  _hideTimeline() {
    setState(() {
      timelineOffset = Offset(-1, 0);
    });
  }

  _onDown(Offset offset) {
    double dx = offset.dx;
    if (dx <= 0) dx = 0;

    ///判断选中的是哪一个
    Rect leftRect = leftEarOffset & earSize;
    if (leftRect.contains(offset)) {
      touchLeft = true;
      return;
    }
    Rect rightRect = rightEarOffset! & earSize;
    if (rightRect.contains(offset)) {
      touchRight = true;
      return;
    }
  }

  _onMove(Offset offset) {
    double dx = offset.dx;
    if (touchLeft) {
      double end = (leftEarOffset.dx + dx) <= 0 ? 0 : leftEarOffset.dx + dx;

      ///距离右边
      double max = rightEarOffset!.dx - minInsets;
      if (end + earSize.width >= max) end = max - earSize.width;
      leftEarOffset = Offset(end, 0);
    }
    if (touchRight) {
      ///偏移量要减去宽度
      double end = (rightEarOffset!.dx + dx) >= viewSize.width - earSize.width
          ? viewSize.width - earSize.width
          : rightEarOffset!.dx + dx;

      ///距离左边
      double min = leftEarOffset.dx + earSize.width + minInsets;
      if (end <= min) end = min;
      rightEarOffset = Offset(end, 0);
    }
    _calcSelectDuration();
    setState(() {});
  }

  ///计算选中时长
  void _calcSelectDuration() {
    ///计算滚动的时间
    double scrollerSecond = 0;
    double perScrollerSecond = _calcScrollerSecond();
    if (perScrollerSecond != 0) {
      scrollerSecond = _scrollController.offset / perScrollerSecond;
    }

    ///开始的偏移量
    double perSeconds = trackSize.width / duration.inSeconds;
    double startSecond = leftEarOffset.dx / perSeconds + scrollerSecond;

    ///首尾相差的偏移量
    double diffSecond =
        (rightEarOffset!.dx - leftEarOffset.dx - earSize.width) / perSeconds;
    double endSecond = startSecond + diffSecond;
    selectStartDur = Duration(seconds: startSecond.toInt());
    selectEndDur = Duration(seconds: endSecond.toInt());
  }

  ///计算每秒的偏移量
  double _calcScrollerSecond() {
    int diffDuration = widget.totalDuration.inSeconds - duration.inSeconds;
    if (diffDuration == 0) return 0;
    return _scrollController.position.maxScrollExtent / diffDuration;
  }

  ///视频帧
  ///轨道最长显示180s，多余的超出显示
  ///动态计算每张图片的宽度
  Widget _getImageChild() {
    double width;
    if (widget.totalDuration.inSeconds > maxSecond) {
      width = 48;
    } else {
      width = trackSize.width / widget.imgList.length;
    }
    List<Widget> widgets = [];
    for (int i = 0; i < widget.imgList.length; i++) {
      widgets.add(
        widget.trackWidgetBuilder
            .call(context, widget.imgList[i], Size(width, viewSize.height)),
      );
    }
    return Row(children: widgets);
  }

  ///停止时间线动画
  _stopAnimation() {
    if (_timelineController == null) return;
    _timelineController?.dispose();
    _timelineController = null;
  }

  @override
  void dispose() {
    _stopAnimation();
    _scrollController.dispose();
    super.dispose();
  }
}