## 3.2.6

* Added `childBounceFilterQuality` option to `PieTheme` to adjust the quality of the child bounce transformation.

## 3.2.5

* Fixed child widget initializing twice when bouncing is enabled.

## 3.2.4

* Hotfix for scrollable performance issue.

## 3.2.3

* Another hotfix for exceptions thrown from bouncing widget.

## 3.2.2

* Fixed exceptions thrown from bouncing widget. [#57](https://github.com/rasitayaz/flutter-pie-menu/issues/57)
* Fixed inconsistency in menu child positioning when the scroll position changes while the menu is open.

## 3.2.1

* Fixed some stateful widgets are trying to set their state after being disposed.

## 3.2.0

* Added `menuAlignment` and `menuDisplacement` to `PieTheme` to allow custom positioning of the menu. [#50](https://github.com/rasitayaz/flutter-pie-menu/issues/50)
* Added `PieMenuController` to programmatically control the menus. [#48](https://github.com/rasitayaz/flutter-pie-menu/issues/48)
* Fixed `PieCanvas` theme is not updating after widget initialization.

## 3.1.3

* Fixed changelog typos.

## 3.1.2

* Small bug fixes.

## 3.1.1

* Fixed timers not being disposed properly, causing errors during navigation.
* Fixed some child bounce animation issues.

## 3.1.0

* Improved the child bounce animation by adding a 3D tilt effect to it inspired by [Bounce](https://pub.dev/packages/bounce) package. Can be disabled by setting `childTiltEnabled` to `false` in `PieTheme`.
* Added `overlayStyle` to `PieTheme` to switch between the old and new overlay styles. `PieOverlayStyle.behind` (the old style) is used by default because the new one causes render issues in some cases.
* Other minor improvements and bug fixes.

## 3.0.0

* When a `PieMenu` activates, other gestures are now automatically cancelled. You no longer need to use `NeverScrollableScrollPhysics` to disable scrolling or to deactivate the functionality of your interactive menu child.
* Overlay is now drawn around the menu child using `CustomPaint`. This addresses the issue of the menu child losing its state when the menu is activated.
* Fixed some animation issues and slightly improved performance by implementing a better state management solution.
* Replaced `childBounceDistance` with `childBounceFactor` in `PieTheme`.
* Other minor improvements and bug fixes.

## 2.0.2

* Fixed changelog typos.

## 2.0.1

* Wrapped canvas with a transparent `Material` to be able to use it outside `Scaffold`.

## 2.0.0

* Desktop and web experience is significantly improved with this update. Check [new features](#new-features-and-enhancements) and [updated readme](https://pub.dev/packages/pie_menu) for details.
* Added live Flutter web demo, [give it a try!](https://rasitayaz.github.io/flutter-pie-menu)

### Breaking changes

**Inside `PieTheme`;**

* Changed `tooltip` type from `String` to `Widget`, you can now use custom widgets as tooltips.
* Renamed `tooltipStyle` to `tooltipTextStyle`.
* Renamed `distance` to `radius`.
* `bouncingMenu` is renamed to `childBounceEnabled`, and all the related attributes that starts with `menuBounce...` are renamed to `childBounce...` to avoid confusion.

**Other;**

* `onTap` callback inside `PieMenu` is renamed to `onPressed`. Also added a new `onPressedWithDevice` callback that provides `PointerDeviceKind`, allowing you to distinguish between mouse and touch events.
* Removed `padding` from `PieAction` since it already has a `child` that can be wrapped with a `Padding` widget.

### New features and enhancements

**Inside `PieTheme`;**

* Added `rightClickShowsMenu` and `leftClickShowsMenu` attributes to customize the mouse behavior. [#13](https://github.com/rasitayaz/flutter-pie-menu/issues/13)
* Added `customAngle` and `customAngleAnchor` attributes to set a fixed positioning for the buttons. [#34](https://github.com/rasitayaz/flutter-pie-menu/issues/34)
* Added `tooltipCanvasAlignment` to specify a custom alignment for the tooltip in the canvas. [#35](https://github.com/rasitayaz/flutter-pie-menu/pull/35)
* Added `tooltipUseFittedBox` to allow the tooltip to be resized to fit the text into a single line.
* Added `pointerDecoration`, allowing you to style the widget at the center of the menu.

**Other;**

* Hovering over the buttons with mouse highlights them now. Also, cursor changes when the menu or buttons are hovered. [#16](https://github.com/rasitayaz/flutter-pie-menu/issues/16)
* Improved dynamic menu angle calculation (again).
* Improved dynamic tooltip positioning.
* Fixed text style related issues. Menu, canvas and default text styles are now being merged properly.
* Other performance improvements and bug fixes.

## 1.3.0

* Improved menu angle calculation, the menu is now displayed at a better angle when opened from the corners of the screen.
* Added `angleOffset` parameter to `PieTheme` to adjust the menu angle.

## 1.2.6

* Fixed some critical gesture issues.

## 1.2.5

* Replaced `menuBounceDepth` with `menuBounceDistance` in `PieTheme` and improved default bounce animation.
* Fixed [#28](https://github.com/rasitayaz/flutter-pie-menu/issues/28).

## 1.2.4

* Improved menu bounce animations.
* Added [macOS demo](https://github.com/rasitayaz/flutter-pie-menu/raw/main/example/demo-macos.zip).

## 1.2.3

* Fixed broken repository links in `README.md`.

## 1.2.2

* Fixed menu not displaying and child disappearing on iOS devices. [#23](https://github.com/rasitayaz/flutter-pie-menu/issues/23)
* Fixed menu being able to be activated from blank canvas areas.

## 1.2.1

* Fixed stateful menu children not being updated.

## 1.2.0

* Added `ScrollConfiguration` to disable scrolling automatically when a `PieMenu` is visible, but it is not working properly at the moment because of [this issue with Flutter framework](https://github.com/flutter/flutter/issues/111170).
* Added missing `copyWith()` parameters in `PieTheme`.
* Added `PieTheme.of(context)` function to access `PieCanvas` theme from `PieMenu` and customize it easily.
* Removed `childHovered` parameter from `PieAction`, you can use `PieAction.builder()` and its `builder` parameter for custom hovered buttons.
* Fixed menu child staying visible after dismiss.
* Fixed issues related to animations after dispose.
* Improved fade animations.
* Stability and performance improvements.

## 1.1.0

* Added bouncing menu child animation. (Can be customized or disabled with `PieTheme`)
* Added `onTap` callback to `PieMenu`.
* Clicking the center of the menu now dismisses it.
* Bug fixes and stabilization improvements.

## 1.0.0

* Migrated to Flutter 3
* Updated `PieAction` properties, now `child` and `childHovered` should be used instead of the old `iconData`, `customWidget`, `customHoveredWidget` properties.
* No longer depends on the `font_awesome_flutter` package, because icons should be specified as widgets.
* Some property names are updated. Check the documentation for more info.

## 0.2.0

* Menu now stays open when the pointer is released over the pressed area.
* Fixed listener above the menu not responding to some pointer events outside of menus.
* Added custom menu child to display when the menu is visible.

## 0.1.1

* Fixed last selected action label becoming visible for a short time after reopening the menu.
* Using `PieMenu` without `PieCanvas` now deactivates the menu and just displays the child.

## 0.1.0

* Font Awesome Icons can now be used with `font_awesome_flutter` package.

## 0.0.7

* Custom container decoration can now be specified using `decoration` property of `PieButtonTheme`.

## 0.0.6

* Added `iconSize` property for `PieTheme`.
* Fixed selected action is becoming non-hovered before the menu fades out.

## 0.0.5

* Fixed `onMenuToggle` callback of `PieMenu` is not being called when the canvas callback is null.

## 0.0.4

* `onMenuToggle` callback at `PieCanvas` also added for `PieMenu`.

## 0.0.3

* Updated README.md showcase images.

## 0.0.2

* Fixed README.md images.
* Updated package description.

## 0.0.1

* Initial release.
