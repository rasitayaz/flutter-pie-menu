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
    required this.size,
    required this.pressedOffset,
    required this.child,
    this.bounceFactor = 0.95,
    this.tiltEnabled = true,
    this.filterQuality,
  });

  final Animation<double> animation;
  final Size size;
  final Offset? pressedOffset;
  final Widget child;
  final double bounceFactor;
  final bool tiltEnabled;
  final FilterQuality? filterQuality;

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        if (widget.size == Size.zero) return child!;

        final v = 0.5 / max(widget.size.width, widget.size.height);
        final transform = Matrix4.identity()..setEntry(3, 2, v);

        transform.scale(
          lerpDouble(1, widget.bounceFactor, widget.animation.value),
        );

        final offset = widget.pressedOffset;

        if (widget.tiltEnabled && offset != null) {
          final x = offset.dx / widget.size.width;
          final y = offset.dy / widget.size.height;

          const tiltAngle = pi / 10;

          final xAngle = (y - 0.5) * tiltAngle;
          final yAngle = (x - 0.5) * (-tiltAngle);

          transform.rotateX(xAngle * widget.animation.value);
          transform.rotateY(yAngle * widget.animation.value);
        }

        return Transform(
          transform: transform,
          origin: Offset(widget.size.width / 2, widget.size.height / 2),
          filterQuality: widget.filterQuality,
          child: child,
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

class PieAnimatedChild extends StatefulWidget {
  const PieAnimatedChild._({
    super.key,
    required this.menuChild,
    required this.pressedOffset,
    required this.beforeOpenAnimation,
    required this.beforeOpenBuilder,
    required this.whileMenuOpenChildAnimation,
    required this.whileMenuOpenChildBuilder,
  });

  factory PieAnimatedChild({
    Key? key,
    Widget? menuChild,
    Offset? pressedOffset,
    Animation<double> animation = const AlwaysStoppedAnimation(0),
    Animation<double> whileMenuOpenChildAnimation = const AlwaysStoppedAnimation(0),
    Widget Function(
      Widget child,
      Size size,
      Offset? pressedOffset,
      Animation<double> animation,
    )? beforeOpenBuilder,
    Widget Function(
      Widget child,
      Size size,
      Offset? pressedOffset,
      Animation<double> animation,
    )? whileMenuOpenChildBuilder,
  }) {
    return PieAnimatedChild._(
      key: key,
      menuChild: menuChild,
      pressedOffset: pressedOffset,
      beforeOpenAnimation: animation,
      beforeOpenBuilder: beforeOpenBuilder ??
          (child, size, pressedOffset, animation) => BouncingWidget(
                animation: animation,
                size: size,
                pressedOffset: pressedOffset,
                bounceFactor: 0.95,
                filterQuality: null,
                tiltEnabled: true,
                child: child,
              ),
      whileMenuOpenChildAnimation: whileMenuOpenChildAnimation,
      whileMenuOpenChildBuilder: whileMenuOpenChildBuilder,
    );
  }

  final Widget Function(
    Widget child,
    Size size,
    Offset? pressedOffset,
    Animation<double> animation,
  ) beforeOpenBuilder;
  final Widget? menuChild;
  final Offset? pressedOffset;
  final Animation<double> beforeOpenAnimation;
  final Animation<double> whileMenuOpenChildAnimation;
  final Widget Function(
    Widget child,
    Size size,
    Offset? pressedOffset,
    Animation<double> animation,
  )? whileMenuOpenChildBuilder;

  @override
  State<PieAnimatedChild> createState() => _PieAnimatedChildState();
}

class _PieAnimatedChildState extends State<PieAnimatedChild> {
  var lastSize = Size.zero;

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final sizeWrapper = _WidgetSizeWrapper(
          onSizeChange: (newSize) {
            if (lastSize == newSize) return;
            setState(() => lastSize = newSize);
          },
          child: widget.menuChild ?? const SizedBox.shrink(),
        );
        if (lastSize == Size.zero) return sizeWrapper;

        if (widget.whileMenuOpenChildBuilder != null) {
          return widget.whileMenuOpenChildBuilder!(
            widget.beforeOpenBuilder(
              sizeWrapper,
              lastSize,
              widget.pressedOffset,
              widget.beforeOpenAnimation,
            ),
            lastSize,
            widget.pressedOffset,
            widget.whileMenuOpenChildAnimation,
          );
        }
        return widget.beforeOpenBuilder(sizeWrapper, lastSize, widget.pressedOffset, widget.beforeOpenAnimation);
      },
    );
  }
}
