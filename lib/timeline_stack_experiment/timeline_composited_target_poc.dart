import 'package:flutter/material.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

main() {
  runApp(TimelineCompositedPoc());
}

///See (StackOverflow Question)[https://stackoverflow.com/questions/71933645]
///一个大神提出了CompositedTransformTarget和CompositedTransformFollower
class TimelineCompositedPoc extends StatefulWidget {
  @override
  State<TimelineCompositedPoc> createState() => _TimelineCompositedPocState();
}

class _TimelineCompositedPocState extends State<TimelineCompositedPoc> {
  int? selectedIndex;
  ScrollController _controller = ScrollController();
  final layerLinks = List.generate(20, (index) => LayerLink());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Listener(
            onPointerMove: (u) {
              setState(() {});
            },
            child: Overlay(initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (context) => ListView.builder(
                  controller: _controller,
                  physics: NoFlingScrollPhysics(),
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
                            child: SizedBox.square(
                              dimension: MediaQuery.of(context).size.width / 2,
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
            ])),
      ),
    );
  }

  Color get color => colorBlack ? Colors.black38 : Colors.blue.withOpacity(0.5);

  bool colorBlack = true;

  toggleColor() {
    setState(() {
      colorBlack = !colorBlack;
    });
  }

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
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () => toggleColor(),
                    onVerticalDragUpdate: (update) {
                      _controller.jumpTo(_controller.offset - update.delta.dy);
                    },
                    child: SizedBox.fromSize(
                        size: getDeflatedSize(layerLinks[index].leaderSize, 30),
                      child: Container(

                          color: color),
                    )),
              ),
            );
    });
  }

  test() {}

  Size? getDeflatedSize(Size? size, double delta){
    if(size == null) return null;
    return Size(size.width + 2 * delta, size.height + 2* delta);

  }
}
