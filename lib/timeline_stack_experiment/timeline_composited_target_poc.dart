import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

main() {
  runApp(
      MaterialApp(
        // NOTE i need it on linux platform
        // since without it the mouse des not work
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        home: TimelineCompositedPoc(),
      )
  );
}

///See (StackOverflow Question)[https://stackoverflow.com/questions/71933645]
class TimelineCompositedPoc extends StatefulWidget {
  @override
  State<TimelineCompositedPoc> createState() => _TimelineCompositedPocState();
}

class _TimelineCompositedPocState extends State<TimelineCompositedPoc> {
  int? selectedIndex;
  final layerLinks = List.generate(20, (index) => LayerLink());
  late List<double> heightList;
  @override
  initState(){
    super.initState();
    heightList = List.filled(20, context.findAncestorWidgetOfExactType<MediaQuery>()!.data.size.width / 2);
  }

  @override
  Widget build(BuildContext context) {
    //print('build');
    return Scaffold(
      body: Overlay(initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (context) => ListView.builder(
            itemBuilder: (context, index) {
              return Center(
                child: CompositedTransformTarget(
                  link: layerLinks[index],
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: heightList[index],
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(color: Colors.black)),
                            child: Text(index.toString())),
                      )),
                ),
              );
            },
            itemCount: 20,
          ),
        ),
        getHoveringEntry()
      ]),
    );
  }

  Color get color => colorBlack ? Colors.black38 : Colors.blue.withOpacity(0.5);

  bool colorBlack = true;

  toggleColor() {
    setState(() {
      colorBlack = !colorBlack;
    });
  }

  ///Don't forget we are in a OverlayEntry, its size is only constrained by the Overlay, aligning the Target by anchor params
  OverlayEntry getHoveringEntry() {
    return OverlayEntry(builder: (context) {
      final index = selectedIndex;
      return index == null
          ? SizedBox.shrink()
          : CompositedTransformFollower(
        followerAnchor: Alignment.center,
        targetAnchor: Alignment.center,
        showWhenUnlinked: false,
        link: layerLinks[index],
        child: Center(
          child: GestureDetector(
            onTap: () {
              toggleColor();
              setState(() {
                heightList[index] += 10;
              });
            },
            // NOTE that i removed _controller & _controller.jumpTo,
            // and now it works even better as in previous version it was
            // not possible to "fling" from selected, hovering area
            child: AbsorbPointer(
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //If we forget to use min, it will expand to screen height, not intrinsic height.
                  children: [
                    Container(height: 20,color: Colors.orange,),
                    SizedBox.fromSize(
                      size: layerLinks[index].leaderSize,
                      child: Container(color: color),
                    ),
                    Container(height: 20,color: Colors.orange,)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}