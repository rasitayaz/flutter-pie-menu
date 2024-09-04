# Flutter Pie Menu 🥧

[![pub](https://badges.genua.fr/pub/v/pie_menu)](https://pub.dev/packages/pie_menu)
[![pub likes](https://badges.genua.fr/pub/likes/pie_menu)](https://pub.dev/packages/pie_menu)
[![web](https://img.shields.io/badge/live-web&nbsp;demo-white.svg)](https://rasitayaz.github.io/flutter-pie-menu)
[![apk](https://img.shields.io/badge/apk-android&nbsp;demo-teal.svg)](https://github.com/rasitayaz/flutter-pie-menu/raw/showcase/demo/android.zip)
[![app](https://img.shields.io/badge/app-macos&nbsp;demo-blueviolet)](https://github.com/rasitayaz/flutter-pie-menu/raw/showcase/demo/macos.zip)
[![github](https://img.shields.io/badge/github-rasitayaz-red)](https://github.com/rasitayaz)
[![buy me a coffee](https://img.shields.io/badge/buy&nbsp;me&nbsp;a&nbsp;coffee-donate-gold)](https://buymeacoffee.com/rasitayaz)

A Flutter package providing a highly customizable circular/radial context menu, similar to Pinterest's.

[Click here to try Flutter Pie Menu online!](https://rasitayaz.github.io/flutter-pie-menu)

| ![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/showcase/preview/screenshot-1.jpg) | ![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/showcase/preview/example-1.gif) | ![](https://raw.githubusercontent.com/rasitayaz/flutter-pie-menu/showcase/preview/example-2.gif) |
| :-------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------: |

## Table of Contents

- [Flutter Pie Menu 🥧](#flutter-pie-menu-)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Customization](#customization)
    - [Button themes](#button-themes)
    - [Custom button widgets](#custom-button-widgets)
    - [Display angle of menu buttons](#display-angle-of-menu-buttons)
    - [Specific menu position](#specific-menu-position)
    - [Tap, long press or right click to open the menu](#tap-long-press-or-right-click-to-open-the-menu)
  - [Controllers and callbacks](#controllers-and-callbacks)
  - [Contributing](#contributing)
  - [Donation](#donation)

## Usage

Wrap the widget that should respond to gestures with the `PieMenu` widget, and provide the menu with an array of `PieAction`s to display as circular buttons.

```dart
PieMenu(
  onPressed: () => print('pressed'),
  actions: [
    PieAction(
      tooltip: const Text('like'),
      onSelect: () => print('liked'),
      child: const Icon(Icons.favorite), // Can be any widget
    ),
  ],
  child: ChildWidget(),
),
```

> 💡 Don't forget that you can only use `PieMenu` as a descendant of a `PieCanvas` widget.

Wrap your page, or any other desired widget for drawing the menu and the background overlay, with `PieCanvas` widget.

For instance, if you want the menu to be displayed at the forefront, wrap your `Scaffold` with a `PieCanvas` like following:

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

> 💡 You can utilize the `onPressed` callback defined in `PieMenu` to manage tap events without the need for an extra widget such as `GestureDetector`.

## Customization

You can customize the appearance and behavior of menus using `PieTheme`.

Using the `theme` attribute of `PieCanvas` widget, you can specify a theme for all the descendant `PieMenu` widgets.

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

It is also possible to copy the canvas theme with additional parameters, but make sure you are accessing it with the right `context`.

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

You can even give the buttons custom styles using `decoration` property of `PieButtonTheme`.

```dart
PieButtonTheme(
  decoration: BoxDecoration(),
),
```

### Custom button widgets

If you wish to use custom widgets inside buttons instead of just icons, it is recommended to use `PieAction.builder()` with a `builder` which provides whether the action is hovered or not as a parameter.

```dart
PieAction.builder(
  tooltip: const Text('like'),
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

### Display angle of menu buttons

If you don't want the dynamic angle calculation and have the menu appear at a fixed angle, set `customAngle` and `customAngleAnchor` attributes of `PieTheme`.

```dart
PieTheme(
  customAngle: 90, // In degrees
  customAngleAnchor: PieAnchor.center, // start, center, end
),
```

You can also use `customAngleDiff` or `spacing` to adjust the angle between buttons, and `angleOffset` to rotate the menu.

### Specific menu position

Use `menuAlignment` attribute of `PieTheme` to make the menu appear at a specific position regardless of the pressed point. Combine it with `menuDisplacement` to fine-tune the position.

```dart
PieTheme(
  menuAlignment: Alignment.center,
  menuDisplacement: Offset(0, 0),
),
```

### Tap, long press or right click to open the menu

Set `delayDuration` of your theme to `Duration.zero` to open the menu instantly on tap.

```dart
PieTheme(
  delayDuration: Duration.zero,
),
```

Using `rightClickShowsMenu` and `leftClickShowsMenu` attributes of `PieTheme`, you can customize the mouse button behavior.

```dart
PieTheme(
  rightClickShowsMenu: true,
  leftClickShowsMenu: false,
),
```

## Controllers and callbacks

To open, close or toggle a menu programmatically, assign a `PieMenuController` to it.

```dart
// Create a controller inside a stateful widget.
final _pieMenuController = PieMenuController();

// Assign the controller to a PieMenu.
PieMenu(
  controller: _pieMenuController,
  ...
),

// Control the menu using the controller.
_pieMenuController.open(
  menuAlignment: Alignment.center,
);
```

If you need to do something when the menu is toggled, use `onToggle` callback of `PieMenu`, or `onMenuToggle` callback of `PieCanvas`.

```dart
PieMenu(
  onToggle: (menuOpen) => print('Menu ${menuOpen ? 'opened' : 'closed'}'),
  ...
),

PieCanvas(
  onMenuToggle: (menuOpen) => print('A menu ${menuOpen ? 'opened' : 'closed'}'),
  ...
),
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

[![github](https://img.shields.io/badge/github-flutter%20pie%20menu-white)](https://github.com/rasitayaz/flutter-pie-menu)

## Donation

If you find this package useful, please consider donating to support the project.

[![buy me a coffee](https://img.shields.io/badge/buy&nbsp;me&nbsp;a&nbsp;coffee-donate-gold)](https://buymeacoffee.com/rasitayaz)