## 1.2.4

* Improved menu bounce animations.

## 1.2.3

* Fixed broken repository links in `README.md`.

## 1.2.2

* Fixed menu not displaying and child disappearing on iOS devices: [#23](https://github.com/rasitayaz/flutter-pie-menu/issues/23)
* Fixed menu being able to be activated from blank canvas areas.

## 1.2.1

* Fixed stateful menu children not being updated.

## 1.2.0

* Added `ScrollConfiguration` to disable scrolling automatically when a `PieMenu` is visible, but it is not working properly at the moment due to [an issue with Flutter framework](https://github.com/flutter/flutter/issues/111170).
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

Initial version
