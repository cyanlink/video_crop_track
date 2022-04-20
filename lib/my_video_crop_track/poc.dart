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
        body: SizedBox.expand(
          child: Center(
            child: CustomScrollTrack(),
          ),
        ),
      ),
    );
  }
}