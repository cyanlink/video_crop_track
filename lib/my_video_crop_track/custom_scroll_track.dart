import 'package:flutter/cupertino.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        child: ChangeNotifierProvider<ScrollController>.value(
          value: _controller,
          child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              physics: NoFlingScrollPhysics(parent: ClampingScrollPhysics()),
              controller: _controller,

              slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MyCropClip(
                      clipIndex: index,
                    );
                  },
                  childCount: 10,
                ))
              ]),
        ),
      ),
    );
  }
}
