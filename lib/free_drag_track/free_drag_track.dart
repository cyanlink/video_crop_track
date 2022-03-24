import 'package:flutter/material.dart';

class FreeDragTrack extends StatefulWidget{
  FreeDragTrack({Key? key}):super(key: key);

  @override
  State<FreeDragTrack> createState() => _FreeDragTrackState();
}

class _FreeDragTrackState extends State<FreeDragTrack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

    ],);
  }
}

class DragBlock extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => DragBlockState();
}

class DragBlockState extends State<DragBlock>{
  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: GestureDetector(
        child: Container(color: Colors.blue, width: 50, height: 50,),
      ),
    );
  }
}