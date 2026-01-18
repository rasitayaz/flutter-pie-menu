import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

void launchUrlExternally(String url) {
  launchUrlString(url, mode: LaunchMode.externalApplication);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Pie Menu',
          home: const HomePage(),
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            fontFamily: 'Poppins',
            textTheme: const TextTheme().apply(fontFamily: 'Poppins'),
            snackBarTheme: const SnackBarThemeData(
              contentTextStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _navigationIndex = 1;

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        brightness: Brightness.dark,
        buttonTheme: const PieButtonTheme(backgroundColor: Colors.transparent, iconColor: Colors.transparent),
        buttonThemeHovered: const PieButtonTheme(backgroundColor: Colors.transparent, iconColor: Colors.transparent),
        radius: 64,
        buttonSize: 56,
        pointerColor: Colors.transparent,
        regularPressShowsMenu: true,
        longPressShowsMenu: false,
        leftClickShowsMenu: false,
        rightClickShowsMenu: false,
        animationTheme: PieAnimationTheme(
          beforeOpenCurve: Easing.linear,
          beforeOpenDuration: Durations.extralong4,
          beforeOpenReverseCurve: Curves.bounceOut,
          beforeOpenBuilder: (child, size, pressedOffset, animation) => child,
          pieMenuOpenCurve: Curves.linear,
          pieMenuOpenDuration: Durations.short1,
          pieMenuOpenReverseCurve: Curves.linear,
          whileMenuOpenChildBuilder: (child, size, pressedOffset, animation) {
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final transform = Matrix4.identity();
                final centerX = size.width / 2;
                final centerY = size.height / 2;
                transform
                  ..setEntry(3, 2, 0.001)
                  ..translate(centerX, centerY)
                  ..rotateZ(-0.15 * animation.value)
                  ..translate(-centerX, -centerY);
                return Transform(
                  transform: transform,
                  child: child,
                );
              },
            );
          },
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Flutter Pie Menu 🥧',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: IndexedStack(
          index: _navigationIndex,
          children: const [
            StylingPage(),
            ListViewPage(),
            PinterestPage(),
            AboutPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _navigationIndex,
          onTap: (index) => setState(() => _navigationIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.palette),
              label: 'Styling',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.list),
              label: 'ListView',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.pinterest),
              label: 'Pinterest',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.circleInfo),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

//* different styles *//
class StylingPage extends StatelessWidget {
  const StylingPage({super.key});

  static const double spacing = 20;

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: const PieTheme(
        regularPressShowsMenu: true,
        tooltipTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Builder(
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(spacing),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PieMenu(
                            actions: [
                              PieAction(
                                tooltip: const Text('Play'),
                                onSelect: () => context.showSnackBar('Play'),

                                /// Optical correction
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: FaIcon(FontAwesomeIcons.play),
                                ),
                              ),
                              PieAction(
                                tooltip: const Text('Like'),
                                onSelect: () => context.showSnackBar('Like'),
                                child: const FaIcon(
                                  FontAwesomeIcons.solidThumbsUp,
                                ),
                              ),
                              PieAction(
                                tooltip: const Text('Share'),
                                onSelect: () => context.showSnackBar('Share'),
                                child: const FaIcon(FontAwesomeIcons.share),
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.orangeAccent,
                              iconData: FontAwesomeIcons.solidSun,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing),
                        Expanded(
                          child: PieMenu(
                            theme: PieTheme.of(context).copyWith(
                              buttonTheme: const PieButtonTheme(
                                backgroundColor: Colors.deepOrange,
                                iconColor: Colors.white,
                              ),
                              buttonThemeHovered: const PieButtonTheme(
                                backgroundColor: Colors.orangeAccent,
                                iconColor: Colors.black,
                              ),
                              brightness: Brightness.dark,
                            ),
                            actions: [
                              PieAction.builder(
                                tooltip: const Text('how'),
                                onSelect: () => context.showSnackBar('1'),
                                builder: (hovered) {
                                  return _buildTextButton('1', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('cool'),
                                onSelect: () => context.showSnackBar('2'),
                                builder: (hovered) {
                                  return _buildTextButton('2', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('is'),
                                onSelect: () => context.showSnackBar('3'),
                                builder: (hovered) {
                                  return _buildTextButton('3', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('this?!'),
                                onSelect: () => context.showSnackBar('Pretty cool :)'),
                                builder: (hovered) {
                                  return _buildTextButton('4', hovered);
                                },
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.deepPurple,
                              iconData: FontAwesomeIcons.solidMoon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PieMenu(
                            theme: PieTheme.of(context).copyWith(
                              tooltipTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              overlayColor: Colors.teal.withValues(alpha: 0.7),
                              pointerSize: 40,
                              pointerDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withValues(alpha: 0.5),
                              ),
                              buttonTheme: const PieButtonTheme(
                                backgroundColor: Colors.black,
                                iconColor: Colors.white,
                              ),
                              buttonThemeHovered: const PieButtonTheme(
                                backgroundColor: Colors.white,
                                iconColor: Colors.black,
                              ),
                              buttonSize: 84,
                              leftClickShowsMenu: false,
                              rightClickShowsMenu: true,
                            ),
                            onPressedWithDevice: (kind) {
                              if (kind == PointerDeviceKind.mouse) {
                                context.showSnackBar(
                                  'Right click to show the menu',
                                );
                              }
                            },
                            actions: [
                              PieAction(
                                tooltip: const Text('Available on pub.dev'),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },
                                child: const FaIcon(FontAwesomeIcons.boxOpen),
                              ),
                              PieAction(
                                tooltip: const Text('Highly customizable'),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },

                                /// Custom background color
                                buttonTheme: PieButtonTheme(
                                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                                  iconColor: Colors.white,
                                ),
                                child: const FaIcon(FontAwesomeIcons.palette),
                              ),
                              PieAction(
                                tooltip: const Text('Now with right click support!'),
                                buttonTheme: PieButtonTheme(
                                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                                  iconColor: Colors.white,
                                ),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },
                                child: const FaIcon(
                                  FontAwesomeIcons.computerMouse,
                                ),
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.teal,
                              iconData: FontAwesomeIcons.solidHeart,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    Color? color,
    required IconData iconData,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: FaIcon(
          iconData,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, bool hovered) {
    return Text(
      text,
      style: TextStyle(
        color: hovered ? Colors.black : Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

//* list view example *//
class ListViewPage extends StatelessWidget {
  const ListViewPage({super.key});

  static const spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: spacing,
        bottom: spacing,
        left: MediaQuery.of(context).padding.left + spacing,
        right: MediaQuery.of(context).padding.right + spacing,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: 16,
      separatorBuilder: (context, index) => const SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 200,
          child: PieMenu(
            onPressed: () {
              context.showSnackBar(
                '#$index — Long press or right click to show the menu',
              );
            },
            actions: [
              PieAction(
                tooltip: const Text('Like'),
                onSelect: () => context.showSnackBar('Like #$index'),
                child: const FaIcon(FontAwesomeIcons.solidHeart),
              ),
              PieAction(
                tooltip: const Text('Comment'),
                onSelect: () => context.showSnackBar('Comment #$index'),
                child: const FaIcon(FontAwesomeIcons.solidComment),
              ),
              PieAction(
                tooltip: const Text('Save'),
                onSelect: () => context.showSnackBar('Save #$index'),
                child: const FaIcon(FontAwesomeIcons.solidBookmark),
              ),
              PieAction(
                tooltip: const Text('Share'),
                onSelect: () => context.showSnackBar('Share #$index'),
                child: const FaIcon(FontAwesomeIcons.share),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 64,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//* pinterest example *//
class PinterestPage extends StatelessWidget {
  const PinterestPage({super.key});
  String imageUrl(int index) => 'https://picsum.photos/seed/$index/400/600';

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        brightness: Brightness.dark,
        buttonTheme: const PieButtonTheme(backgroundColor: Colors.transparent, iconColor: Colors.transparent),
        buttonThemeHovered: const PieButtonTheme(backgroundColor: Colors.transparent, iconColor: Colors.transparent),
        radius: 64,
        buttonSize: 56,
        pointerColor: Colors.transparent,
        regularPressShowsMenu: true,
        longPressShowsMenu: true,
        leftClickShowsMenu: false,
        rightClickShowsMenu: false,
        closeOnTapUp: true,
        animationTheme: PieAnimationTheme(
          beforeOpenCurve: Easing.linear,
          beforeOpenDuration: Durations.extralong4,
          beforeOpenReverseCurve: Curves.bounceOut,
          beforeOpenBuilder: (child, size, pressedOffset, animation) => child,
          pieMenuOpenCurve: Curves.linear,
          pieMenuOpenDuration: Durations.short1,
          pieMenuOpenReverseCurve: Curves.linear,
          whileMenuOpenChildBuilder: (child, size, pressedOffset, animation) {
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final transform = Matrix4.identity();
                final centerX = size.width / 2;
                final centerY = size.height / 2;
                transform
                  ..setEntry(3, 2, 0.001)
                  ..translate(centerX, centerY)
                  ..rotateZ(-0.15 * animation.value)
                  ..translate(-centerX, -centerY);
                return Transform(
                  transform: transform,
                  child: child,
                );
              },
            );
          },
        ),
      ),
      child: MasonryGridView.count(
        itemCount: 50,
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        itemBuilder: (context, index) {
          return PieMenu(
            actions: [
              PieActionIcon(icon: 'assets/icons/eyes.png', onSelect: () {}),
              PieActionIcon(icon: 'assets/icons/heart-fiery.png', onSelect: () {}),
            ],
            child: Hero(
              tag: 'focused-$index',
              child: Image.network(imageUrl(index), height: (index % 5 + 1) * 100, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}

class PieActionIcon extends PieAction {
  PieActionIcon({required String icon, required VoidCallback super.onSelect})
      : super.builder(
          tooltip: const SizedBox.shrink(),
          builder: (hovered) => LiquidGlass(
            settings:
                const LiquidGlassSettings(ambientStrength: 0.5, lightAngle: 0.2 * math.pi, glassColor: Colors.white12),
            shape: const LiquidRoundedSuperellipse(borderRadius: Radius.circular(40)),
            glassContainsChild: false,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox.square(dimension: 36, child: Image.asset(icon)),
            ),
          ),
        );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        regularPressShowsMenu: true,
        tooltipTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        tooltipUseFittedBox: true,
        buttonTheme: const PieButtonTheme(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
        buttonThemeHovered: PieButtonTheme(
          backgroundColor: Colors.lime[200],
          iconColor: Colors.black,
        ),
        overlayColor: Colors.blue[200]?.withValues(alpha: 0.7),
        rightClickShowsMenu: true,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(size: 100),
                  SizedBox(width: 16),
                  Text(
                    '🥧',
                    style: TextStyle(
                      fontSize: 100,
                      height: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('github/rasitayaz'),
                      onSelect: () {
                        launchUrlExternally('https://github.com/rasitayaz');
                      },
                      child: const FaIcon(FontAwesomeIcons.github),
                    ),
                    PieAction(
                      tooltip: const Text('linkedin/rasitayaz'),
                      onSelect: () {
                        launchUrlExternally(
                          'https://linkedin.com/in/rasitayaz/',
                        );
                      },
                      child: const FaIcon(FontAwesomeIcons.linkedinIn),
                    ),
                    PieAction(
                      tooltip: const Text('mrasitayaz@gmail.com'),
                      onSelect: () {
                        launchUrlExternally('mailto:mrasitayaz@gmail.com');
                      },
                      child: const FaIcon(FontAwesomeIcons.solidEnvelope),
                    ),
                    PieAction(
                      tooltip: const Text('buy me a coffee'),
                      onSelect: () {
                        launchUrlExternally(
                          'https://buymeacoffee.com/rasitayaz',
                        );
                      },
                      child: const FaIcon(FontAwesomeIcons.mugSaucer, size: 20),
                    ),
                  ],
                  child: FittedBox(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'created by',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                          Text(
                            'Raşit Ayaz',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
