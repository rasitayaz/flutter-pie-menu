import 'package:flutter/material.dart';

/// Defines the animations of the pie menu and its children.
class PieAnimationTheme {
  const PieAnimationTheme({
    this.beforeOpenBuilder,
    this.beforeOpenDuration = const Duration(milliseconds: 150),
    this.beforeOpenCurve = Curves.easeOutCubic,
    this.beforeOpenReverseCurve = Curves.easeInCubic,
    this.pieMenuOpenDuration = const Duration(seconds: 1),
    this.pieMenuOpenCurve = Curves.elasticOut,
    this.pieMenuOpenReverseCurve = Curves.elasticOut,
  });

  /// Use this builder to provide any animation for the child
  /// widget that starts and ends BEFORE the pie menu opens.
  ///
  /// You can choose to not pass this prop if no animation is required.
  ///
  /// If you would like to use the default bouncing animation but
  /// change its behavior, use this prop like so:
  ///
  /// ```dart
  /// PieAnimationTheme(
  ///   beforeOpenBuilder: (child, pressedOffset, animation) => BouncingWidget(
  ///     animation: animation,
  ///     pressedOffset: pressedOffset,
  ///     bounceFactor: 0.5,
  ///     tiltEnabled: false,
  ///     child: child,
  ///   ),
  /// );
  /// ```
  final Widget Function(
    Widget child,
    Offset? pressedOffset,
    Animation<double> animation,
  )? beforeOpenBuilder;

  /// The duration of the animation that starts and ends BEFORE the pie menu opens.
  final Duration beforeOpenDuration;

  /// The curve of the animation that starts and ends BEFORE the pie menu opens.
  final Curve beforeOpenCurve;

  /// The reverse curve of the animation that starts and ends AFTER the pie menu opens.
  final Curve beforeOpenReverseCurve;

  /// Duration of [PieButton] opening animation.
  final Duration pieMenuOpenDuration;

  /// The curve of the animation that starts and ends BEFORE the pie menu opens.
  final Curve pieMenuOpenCurve;

  /// The reverse curve of the animation that starts and ends AFTER the pie menu opens.
  final Curve pieMenuOpenReverseCurve;
}
