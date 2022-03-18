import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_crop_track/my_video_crop_track/my_crop_clip.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

class CustomScrollTrack extends StatefulWidget {
  CustomScrollTrack({Key? key}) : super(key: key);

  @override
  State<CustomScrollTrack> createState() => _CustomScrollTrackState();
}

class _CustomScrollTrackState extends State<CustomScrollTrack> {
  final _controller = ScrollController();

  double progressPercentage = 0;

  @override
  void initState() {
    super.initState();
  }


  static int childCount = 10;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupProgressListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          child: ChangeNotifierProvider<ScrollController>.value(
            value: _controller,
            child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                physics: NoFlingScrollPhysics(parent: ClampingScrollPhysics()),
                controller: _controller,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return MyCropClip(
                          clipIndex: index,
                          showTrailingIcon: index != childCount - 1,
                        );
                      },
                      childCount: childCount,
                    )),
                  )
                ]),
          ),
        ),
        Padding(padding: EdgeInsets.all(20),child: Text("Progress: $progressPercentage%"),)
      ]
    );
  }

  setupProgressListener() {
    _controller.addListener(() {
      final wholeLength = _controller.position.maxScrollExtent;

      //因为在两边增加了padding，最大可滚动范围就是timeline widget全部的长度
      final timelineLength = wholeLength;
      final currentProgress = _controller.offset;

      setState(() {
        progressPercentage = currentProgress / timelineLength * 100;
      });
    });
  }
}
