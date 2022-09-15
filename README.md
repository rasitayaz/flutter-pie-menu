# Flutter Pie Menu 🥧

[![pub](https://img.shields.io/pub/v/pie_menu.svg?style=popout)](https://pub.dartlang.org/packages/pie_menu)
[![apk](https://img.shields.io/badge/APK-Demo-brightgreen.svg)](https://github.com/rasitayaz/flutter-pie-menu/raw/master/example/demo.apk)
[![exe](https://img.shields.io/badge/EXE-Windows&nbsp;Demo-blueviolet)](https://github.com/rasitayaz/flutter-pie-menu/raw/master/example/demo-windows.zip)
[![github](https://img.shields.io/badge/github-rasitayaz-red)](https://github.com/rasitayaz)
[![buy me a coffee](https://img.shields.io/badge/buy&nbsp;me&nbsp;a&nbsp;coffee-donate-blue)](https://www.buymeacoffee.com/RasitAyaz)

A Flutter package that provides a customizable circular/radial context menu similar to Pinterest's

|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/screenshot-1.jpg)|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/example-1.gif)|![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/master/showcase/example-2.gif)|
|:-:|:-:|:-:|

## Usage

Wrap the widget that will react to gestures with `PieMenu` widget, and give the menu a list of `PieAction`s to display as menu buttons.

```dart
PieMenu(
  onTap: () => print('tap'),
  actions: [
    PieAction(
      tooltip: 'like',
      onSelect: () => print('liked'),
      child: const Icon(Icons.favorite), // Not necessarily an icon widget
    ),
  ],
  child: YourWidget(),
),
```

> 💡 Note that you can only use `PieMenu` in the sub-hierarchy of a `PieCanvas` widget.

Wrap your page (or any other widget you want to draw pie buttons and background overlay on) with `PieCanvas` widget.

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

## Using with scrollable and interactive widgets

> ⚠️ If you want to use `PieMenu` inside a scrollable view like a `ListView`, or your widget is already interactive (e.g. it is clickable), you may need to **pay attention to this section.**

`PieCanvas` and `PieMenu` widgets have functional callbacks named `onMenuToggle` and `onToggle` respectively, which are triggered when `PieMenu` visibility changed. Using these callbacks, you can prevent your scrollable or interactive widget's default behavior in order to give the control to `PieMenu`.

> 💡 You can use `onTap` callback defined in `PieMenu` to handle tap events without using an additional widget like `GestureDetector`.

> 💡 As for the scrollables, there is an issue with Flutter framework related to `ScrollConfiguration`, so automatically disabling scroll may not be an option until [this issue](https://github.com/flutter/flutter/issues/111170) is resolved.

Using the `visible` parameter of the callbacks, store a `bool` variable in your state.

```dart
bool _menuVisible = false;

@override
Widget build(BuildContext context) {
  return PieCanvas(
    onMenuToggle: (visible) {
      setState(() => _menuVisible = visible);
    },
    ...
  );
}
```

For example, you can decide whether scrolling should be enabled or not using this variable.


```dart
ListView(
  // Disable scrolling if a PieMenu is visible
  physics: _menuVisible
      ? NeverScrollableScrollPhysics()
      : null, // Uses the default physics
  ...
);
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

It is also possible to copy the canvas theme with custom parameters, but make sure you are accessing it with the right `context`.

```dart
PieMenu(
  theme: PieTheme.of(context).copyWith(
    ...
  ),
),
```

### Button themes

Buttons' background and icon colors are defined by theme's `buttonTheme` and `buttonThemeHovered`. You can create a custom `PieButtonTheme` instances for your canvas and menu themes.

```dart
PieTheme(
  buttonTheme: PieButtonTheme(),
  buttonThemeHovered: PieButtonTheme(),
),
```

### Custom button widgets

If you wish to use custom widgets inside buttons instead of just icons, it is recommended to use `PieAction.builder()` with a `builder` which provides whether the action is hovered or not.

```dart
PieAction.builder(
  tooltip: 'like',
  onSelect: () => print('liked'),
  builder: (hovered) {
    return Text(
      '<3',
      style: TextStyle(
        color: hovered ? Colors.green : Colors.red,
      ),
    );
  },
),
```

### Display the menu on tap instead of long press

If you wish to show the menu as soon as the child is pressed, you may set `delayDuration` of your theme to `Duration.zero`.

```dart
PieTheme(
  delayDuration: Duration.zero,
),
```