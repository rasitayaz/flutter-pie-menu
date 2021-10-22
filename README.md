<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter Pie Menu 🥧

A Flutter library that provides a circular context menu similar to Pinterest's.

|Screenshot|Easily Customizable|Works with Scrollables|
|:-:|:-:|:-:|
|<img src="showcase/screenshot.png" width=800 />|<img src="showcase/example-1.gif" width=800 />|<img src="showcase/example-2.gif" width=800 />|

## Usage

Wrap the widget that will react to gestures with `PieMenu` widget, and give the menu a list of `PieAction`s to display as menu buttons.

```dart
PieMenu(
  actions [
    PieAction(
      tooltip: 'Like',
      iconData: Icons.favorite,
      onSelect: () => print('Like action selected.'),
    ),
  ],
  child: YourWidget(),
),
```

Note that you can only use `PieMenu` in the sub-hierarchy of a `PieCanvas` widget. Wrap the parent widget of your page (or any other widget you want to draw the canvas on) with `PieCanvas` widget.

For example, if you want the menu to be displayed at the forefront, you can wrap your `Scaffold` with a `PieCanvas` like following:

```dart
PieCanvas(
  child: Scaffold(
    body: YourScaffoldBody(
      ...
        PieMenu(),
      ...
    ),
  ),
),
```

## Customization

You can customize the appearance and the behavior of menus using `PieTheme`.

Using the `theme` attribute of `PieCanvas` widget, you can specify a theme for all the `PieMenu`s that inherit it.

```dart
PieCanvas(
  theme: PieTheme(),
  ...
    PieMenu(), // Uses the canvas theme
  ...
    PieMenu(), // Uses the canvas theme
  ...
),
```

But if you want to specify menu specific themes, you can also use the `theme` attribute of `PieMenu` widget.

```dart
PieMenu(
  theme: PieTheme(), // Overrides the canvas theme
),
```

Buttons' background and icon colors are defined by theme's `buttonTheme` and `hoveredButtonTheme` properties. You can create a custom `PieButtonTheme` instances for your theme.

```dart
PieTheme(
  buttonTheme: PieButtonTheme(),

  // Using 'hovered' constructor is not necessary
  hoveredButtonTheme: PieButtonTheme.hovered(),
),
```

If you want to use a custom widget instead of an icon for the action button, you can use the `customWidget` and `customHoveredWidget` properties of the respective `PieAction`.
