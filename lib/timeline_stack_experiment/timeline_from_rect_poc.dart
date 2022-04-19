import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:video_crop_track/no_fling_scroll_physics.dart';

main() {
  runApp(TimelinePoc());
}

class TimelinePoc extends StatefulWidget {
  @override
  State<TimelinePoc> createState() => _TimelinePocState();
}

final keys = List.generate(20, (index) => RectGetter.createGlobalKey());

class _TimelinePocState extends State<TimelinePoc>
    with TickerProviderStateMixin {
  int? selectedIndex;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(
        Duration.zero,
        () => _controller.position.isScrollingNotifier.addListener(() async {
              while (_controller.position.isScrollingNotifier.value) {
                setState(() {});
                await Future.delayed(Duration(milliseconds: 10));
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Listener(
          child: Stack(
            children: [
              ListView.builder(
                controller: _controller,
                physics: NoFlingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: RectGetter(
                            key: keys[index],
                            child: SizedBox.square(
                              dimension: MediaQuery.of(context).size.width / 2,
                              child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.green,
                                  child: Text(index.toString())),
                            ))),
                  );
                },
                itemCount: 20,
              ),
              Positioned.fromRect(
                  rect: getRect(selectedIndex),
                  child: GestureDetector(
                      onTap: () => toggleColor(),
                      child: Container(color: color)))
            ],
          ),
        ),
      ),
    );
  }

  getRect(int? index) {
    if (index == null) return Rect.zero;
    var rect = RectGetter.getRectFromKey(keys[index]);
    rect = rect?.inflate(10);
    return rect ?? Rect.zero;
  }

  Color get color => colorBlack ? Colors.black38 : Colors.blue.withOpacity(0.5);

  bool colorBlack = true;

  toggleColor() {
    setState(() {
      colorBlack = !colorBlack;
    });
  }
}
