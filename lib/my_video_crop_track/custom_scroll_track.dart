import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/column_builder.dart';
import 'package:video_crop_track/my_video_crop_track/my_crop_clip.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

class CustomScrollTrack extends StatefulWidget {
  CustomScrollTrack({Key? key}) : super(key: key);

  @override
  State<CustomScrollTrack> createState() => _CustomScrollTrackState();
}

class _CustomScrollTrackState extends State<CustomScrollTrack>
    with WidgetsBindingObserver {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  static int childCount = 10;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupProgressListener();
    driveTimelineWithPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 200,
        child: ChangeNotifierProvider<ScrollController>.value(
          value: _controller,
          child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              physics: NoFlingScrollPhysics(parent: ClampingScrollPhysics()),
              controller: _controller,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: RowBuilder(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                itemBuilder: (c, index) =>
                                    MyCropClip(clipIndex: index),
                                itemCount: childCount,
                              ),
                            ),
                            Expanded(
                              //TODO 用真实的特效轨道替换
                              child:Row(
                                children: [
                                  Expanded(child: Container(height:100, color: Colors.orange,))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ]),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(20),
        child: Text("Progress: $progressPercentage%"),
      )
    ]);
  }

  double get timelineLength =>
      _controller.hasClients ? _controller.position.maxScrollExtent : -1;

  double get currentProgress => _controller.hasClients ? _controller.offset : 0;

  //因为在两边增加了padding，最大可滚动范围就是timeline widget全部的长度
  double get progressPercentage => currentProgress / timelineLength * 100;

  //是时间线控件驱动播放器，还是播放器的播放驱动时间线滚动
  bool timelineDrivingPlayer = false;

  Timer? player;

  setupProgressListener() {
    _controller.addListener(() {
      setState(() {});
    });

    _controller.addListener(scrollingStateListener);
  }

  void scrollingStateListener() {
    if (_controller.hasClients) {
      _controller.position.isScrollingNotifier.addListener(() {
        bool isScrolling = _controller.position.isScrollingNotifier.value;
        //当用户滚动时，是时间线去驱动播放器跳转
        timelineDrivingPlayer = isScrolling;
        timelineDrivingPlayer ? player?.cancel() : driveTimelineWithPlayer();
      });
      _controller.removeListener(scrollingStateListener);
    }
  }

  driveTimelineWithPlayer() {
    player = Timer.periodic(Duration(milliseconds: 50), (timer) {
      final currentPos = _controller.offset;
      _controller.animateTo(currentPos + 0.2,
          duration: Duration(milliseconds: 50), curve: Curves.linear);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }
}
