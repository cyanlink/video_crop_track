import 'package:flutter/material.dart';
import 'package:video_crop_track/my_video_crop_track/custom_scroll_track.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: CustomScrollTrack(),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      //Stack的布局逻辑是，将自身大小定为容纳所有非Positioned子组件的大小。
      Positioned(
        //可以通过此处的负的Offset表达startTime，同时在UI上剪裁掉被剪掉的部分
          left: -10,
          top: 0,
          //SingleChildScrollView，缩略图整个一长条
          child: Container(width: 100, height: 50, color: Colors.orange)),
      //剪辑框
      Container(
        //width表示剪辑duration，加上上面offset，以此能算出endTime
          width: 50,
          height: 50,
          color: Colors.transparent,
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          )
      )
    ]);
  }
}