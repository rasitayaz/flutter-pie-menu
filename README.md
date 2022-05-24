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

[![Pub](https://img.shields.io/pub/v/pie_menu.svg?style=popout)](https://pub.dartlang.org/packages/pie_menu)
[![APK](https://img.shields.io/badge/APK-Demo-brightgreen.svg)](https://github.com/rasitayaz/flutter-pie-menu/raw/master/example/demo.apk)
[![](https://img.shields.io/badge/github-rasitayaz-red)](https://github.com/rasitayaz)
[![](https://img.shields.io/badge/buy&nbsp;me&nbsp;a&nbsp;coffee-donate-blue)](https://www.buymeacoffee.com/RasitAyaz)

A Flutter package that provides a customizable circular/radial context menu similar to Pinterest's

|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/screenshot-1.jpg)|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/example-1.gif)|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/example-2.gif)|
|:-:|:-:|:-:|

## Usage

Wrap the widget that will react to gestures with `PieMenu` widget, and give the menu a list of `PieAction`s to display as menu buttons.

```dart
PieMenu(
  actions: [
    PieAction(
      tooltip: 'Like',
      onSelect: () => print('Like action selected.'),
      child: const Icon(Icons.favorite), // Not necessarily an icon widget
    ),
  ],
  child: YourWidget(),
),
```

Note that you can only use `PieMenu` in the sub-hierarchy of a `PieCanvas` widget. Menu will not be functional if it does not have a canvas ancestor.

Wrap the parent widget of your page (or any other widget you want to draw the canvas on) with `PieCanvas` widget.

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

## Using with Scrollable and Interactive Widgets

> ⚠️ If you want to use `PieMenu` inside a scrollable view like a `ListView`, or your widget is already interactive (e.g. it is clickable), you may need to **pay attention to this section.**

`PieCanvas` and `PieMenu` widgets have a functional callback named `onMenuToggle` which is triggered when a `PieMenu` that inherits the respective canvas is opened and closed. Using this callback, you can prevent your scrollable or interactive widget's default behavior in order to give the control to the `PieMenu`.

If you can think of a better implementation to handle this automatically, feel free to create a new issue on this package's repository and express your opinion.

Using the `menuVisible` parameter of the `onMenuToggle` callback, store a `bool` variable in your `StatefulWidget` state.

```dart
bool _menuVisible = false;

@override
Widget build(BuildContext context) {
  return PieCanvas(
    onMenuToggle: (menuVisible) {
      setState(() => _menuVisible = menuVisible);
    },
    ...
  );
}
```

### Scrollable Widgets

Using the `_menuVisible` variable, you can decide whether scrolling should be enabled or not.


```dart
ListView(
  // Disable scrolling if a 'PieMenu' is visible
  physics: _menuVisible
      ? NeverScrollableScrollPhysics()
      : ScrollPhysics(), // Or your default scroll physics
  ...
);
```

### Interactive Widgets

Again using the `_menuVisible` variable, you can disable the default behavior of your interactive widget. For example, if your widget detects taps using a `GestureDetector`, you can nullify the `onTap` callback when a `PieMenu` is visible.

```dart
GestureDetector(
  onTap: _menuVisible
      ? null
      : () => print('Tap'),
),
```

## Customization

You can customize the appearance and behavior of menus using `PieTheme`.

Using the `theme` attribute of `PieCanvas` widget, you can specify a theme for all the `PieMenu`s that inherit the canvas.

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

Buttons' background and icon colors are defined by theme's `buttonTheme` and `buttonThemeHovered` properties. You can create a custom `PieButtonTheme` instances for your theme.

```dart
PieTheme(
  buttonTheme: PieButtonTheme(),

  // Using 'hovered' constructor is not necessary
  buttonThemeHovered: PieButtonTheme.hovered(),
),
```
