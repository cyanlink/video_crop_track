## flutter本身限制，不容易做出必剪时间线布局的骑缝转场按钮，用VEDemo那种平铺开的替代！
## 边缘滚动：递归实现，await animateTo来实现间隔时间，避免阻塞主线程

## 使用了一些很不好的硬编码，应该深入了解Flutter RenderObject，使用它来获得真实布局信息。

为了绕过Flutter绘制和HitTest的限制，可能还是得回到rect_getter配合Positioned.fromRect的思路上来实现骑缝按钮等功能。
用于特效、音频等的能自由拖拽的Track，先尝试使用Stack+Positioned看能不能较好实现。