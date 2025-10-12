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
    this.whileMenuOpenChildBuilder,
    this.whileMenuOpenChildDuration = const Duration(milliseconds: 150),
    this.whileMenuOpenChildCurve = Curves.easeOutCubic,
    this.whileMenuOpenChildReverseCurve = Curves.easeInCubic,
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
  ///   beforeOpenBuilder: (child, size, pressedOffset, animation) => BouncingWidget(
  ///     animation: animation,
  ///     size: size,
  ///     pressedOffset: pressedOffset,
  ///     bounceFactor: 0.5,
  ///     tiltEnabled: false,
  ///     child: child,
  ///   ),
  /// );
  /// ```
  final Widget Function(
    Widget child,
    Size size,
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

  /// Use this builder to provide any animation for the child
  /// widget while the menu is open.
  ///
  /// You can choose to not pass this prop if no animation is required.
  ///
  /// ```dart
  /// PieAnimationTheme(
  ///   whileMenuOpenChildBuilder: (child, size, pressedOffset, animation) {
  ///     return AnimatedBuilder(
  ///       animation: animation,
  ///         child: child,
  ///         builder: (context, child) {
  ///           final transform = Matrix4.identity();
  ///           final centerX = size.width / 2;
  ///           final centerY = size.height / 2;
  ///           transform
  ///             ..setEntry(3, 2, 0.001)
  ///             ..translate(centerX, centerY)
  ///             ..rotateZ(-0.15 * animation.value)
  ///             ..translate(-centerX, -centerY);
  ///           return Transform(
  ///             transform: transform,
  ///             child: child,
  ///           );
  ///         },
  ///       );
  ///     },
  /// );
  /// ```
  final Widget Function(
    Widget child,
    Size size,
    Offset? pressedOffset,
    Animation<double> animation,
  )? whileMenuOpenChildBuilder;

  /// The duration of the animation of the child while the menu is open.
  final Duration whileMenuOpenChildDuration;

  /// The curve of the animation of the child that runs while the menu is open.
  final Curve whileMenuOpenChildCurve;

  /// The reverse curve of the animation of the child that runs while the menu is open.
  final Curve whileMenuOpenChildReverseCurve;
}
