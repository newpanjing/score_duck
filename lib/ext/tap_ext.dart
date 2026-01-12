//给组件InkWell，和GestureDetector增加触控反馈
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

extension TapExt on Widget {
  Widget feel() {
    return Listener(
      onPointerDown: (_) => HapticFeedback.lightImpact(),
      child: this,
    );
  }
}
