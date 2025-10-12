import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This widget is highly inspired by [Bounce](https://pub.dev/packages/bounce)
/// package created by [Guillaume Cendre](https://github.com/mrcendre)
class BouncingWidget extends StatefulWidget {
  const BouncingWidget({
    super.key,
    required this.animation,
    required this.pressedOffset,
    required this.child,
    this.bounceFactor = 0.95,
    this.tiltEnabled = true,
    this.filterQuality,
  });

  final Animation<double> animation;
  final Offset? pressedOffset;
  final Widget child;
  final double bounceFactor;
  final bool tiltEnabled;
  final FilterQuality? filterQuality;

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget> {
  var lastSize = Size.zero;

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final sizeWrapper = _WidgetSizeWrapper(
          onSizeChange: (newSize) {
            if (lastSize == newSize) return;
            setState(() => lastSize = newSize);
          },
          child: widget.child,
        );

        if (lastSize == Size.zero) return sizeWrapper;

        final v = 0.5 / max(lastSize.width, lastSize.height);
        final transform = Matrix4.identity()..setEntry(3, 2, v);

        transform.scale(
          lerpDouble(1, widget.bounceFactor, widget.animation.value),
        );

        final offset = widget.pressedOffset;

        if (widget.tiltEnabled && offset != null) {
          final x = offset.dx / lastSize.width;
          final y = offset.dy / lastSize.height;

          const tiltAngle = pi / 10;

          final xAngle = (y - 0.5) * tiltAngle;
          final yAngle = (x - 0.5) * (-tiltAngle);

          transform.rotateX(xAngle * widget.animation.value);
          transform.rotateY(yAngle * widget.animation.value);
        }

        return Transform(
          transform: transform,
          origin: Offset(lastSize.width / 2, lastSize.height / 2),
          filterQuality: widget.filterQuality,
          child: sizeWrapper,
        );
      },
      child: widget.child,
    );
  }
}

typedef _OnWidgetSizeChange = Function(Size newSize);

class _WidgetSizeRenderObject extends RenderProxyBox {
  _WidgetSizeRenderObject(this.onSizeChange);

  final _OnWidgetSizeChange onSizeChange;
  Size? currentSize;

  @override
  void performLayout() {
    super.performLayout();

    try {
      Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChange(newSize);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class _WidgetSizeWrapper extends SingleChildRenderObjectWidget {
  const _WidgetSizeWrapper({
    required this.onSizeChange,
    required Widget super.child,
  });

  final _OnWidgetSizeChange onSizeChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _WidgetSizeRenderObject(onSizeChange);
  }
}

class AnimatedChild extends StatelessWidget {
  const AnimatedChild._({
    super.key,
    required this.menuChild,
    required this.pressedOffset,
    required this.animation,
    required this.beforeOpenBuilder,
  });

  factory AnimatedChild({
    Key? key,
    Widget? menuChild,
    Offset? pressedOffset,
    Animation<double> animation = const AlwaysStoppedAnimation(0),
    Widget Function(
      Widget child,
      Offset? pressedOffset,
      Animation<double> animation,
    )? beforeOpenBuilder,
  }) {
    return AnimatedChild._(
      key: key,
      menuChild: menuChild,
      pressedOffset: pressedOffset,
      animation: animation,
      beforeOpenBuilder: beforeOpenBuilder ??
          (child, pressedOffset, animation) => BouncingWidget(
                animation: animation,
                pressedOffset: pressedOffset,
                bounceFactor: 0.95,
                filterQuality: null,
                tiltEnabled: true,
                child: child,
              ),
    );
  }

  final Widget Function(
    Widget child,
    Offset? pressedOffset,
    Animation<double> animation,
  ) beforeOpenBuilder;
  final Widget? menuChild;
  final Offset? pressedOffset;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return beforeOpenBuilder(menuChild ?? const SizedBox.shrink(), pressedOffset, animation);
  }
}
