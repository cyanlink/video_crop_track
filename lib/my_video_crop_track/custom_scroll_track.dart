import 'package:flutter/cupertino.dart';
import 'package:video_crop_track/my_video_crop_track/my_track.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

class CustomScrollTrack extends StatefulWidget {
  CustomScrollTrack({Key? key}) : super(key: key);

  @override
  State<CustomScrollTrack> createState() => _CustomScrollTrackState();
}

class _CustomScrollTrackState extends State<CustomScrollTrack> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      physics: NoFlingScrollPhysics(parent: ClampingScrollPhysics()),
      //TODO: real thing
      slivers: [
        SliverList(delegate: SliverChildBuilderDelegate((context, index){return MyCropClip();}))
      ]
    );
  }
}
