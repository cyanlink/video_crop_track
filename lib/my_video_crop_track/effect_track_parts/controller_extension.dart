import 'package:flutter/cupertino.dart';

extension ScrollControllerExtension on ScrollController{
  double get timelineLength =>
      hasClients ? position.maxScrollExtent : -1;

  double get currentProgress => hasClients ? offset : 0;

  //因为在两边增加了padding，最大可滚动范围就是timeline widget全部的长度
  double get progressPercentage => currentProgress / timelineLength * 100;
}