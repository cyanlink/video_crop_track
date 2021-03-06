import 'dart:async';

import 'package:boxy/flex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/effect_track_parts/viewmodel.dart';
import 'package:video_crop_track/my_video_crop_track/flex_builder.dart';
import 'package:video_crop_track/my_video_crop_track/my_crop_clip.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

import 'effect_track_parts/effect_track.dart';

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

  static int childCount = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setupProgressListener();
    driveTimelineWithPlayer();
  }

  final timelineKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ChangeNotifierProvider<ScrollController>.value(
              value: _controller,
              child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  physics:
                      NoFlingScrollPhysics(parent: ClampingScrollPhysics()),
                  controller: _controller,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 2),
                      sliver: SliverToBoxAdapter(
                        child: MultiProvider(
                          providers: [
                            ChangeNotifierProvider<TimelineDuration>(
                                create: (c) =>
                                    TimelineDuration(clipCount: childCount))
                          ],
                          child: Center(
                            child: BoxyColumn(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Dominant(
                                child: SizedBox(
                                  height: 100,
                                  child: RowBuilder(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    itemBuilder: (c, index) =>
                                        MyCropClip(clipIndex: index, showTrailingIcon: false,),
                                    itemCount: childCount,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  //width: tw.timelineWidth,
                                  height: 50,
                                  child: EffectTrack()),
                            ]),
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

  //????????????????????????padding??????????????????????????????timeline widget???????????????
  double get progressPercentage => currentProgress / timelineLength * 100;

  //?????????????????????????????????????????????????????????????????????????????????
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
        //?????????????????????????????????????????????????????????
        timelineDrivingPlayer = isScrolling;
        timelineDrivingPlayer ? player?.cancel() : driveTimelineWithPlayer();
      });
      _controller.removeListener(scrollingStateListener);
    }
  }

  driveTimelineWithPlayer() {
    //TODO change back???
    /*player = Timer.periodic(Duration(milliseconds: 50), (timer) {
      final currentPos = _controller.offset;
      _controller.animateTo(currentPos + 0.2,
          duration: Duration(milliseconds: 50), curve: Curves.linear);
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }
}
