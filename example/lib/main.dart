import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_menu/pie_menu.dart';
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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const SandboxApp());
}

class SandboxApp extends StatelessWidget {
  const SandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pie Menu Example',
      home: const HomePage(),
      theme: ThemeData(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Pie Menu 🥧',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: IndexedStack(
        index: _navigationIndex,
        children: const [
          StylingPage(),
          ListViewPage(),
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
            icon: FaIcon(FontAwesomeIcons.circleInfo),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

/// Different styles
class StylingPage extends StatelessWidget {
  const StylingPage({super.key});

  static const double spacing = 20;

  final _pageTheme = const PieTheme(
    delayDuration: Duration.zero,
  );

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: _pageTheme,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(spacing),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildBasicUsage(context),
                    const SizedBox(height: spacing),
                    _buildDarkMode(context),
                  ],
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: Column(
                  children: [
                    _buildLargeActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    Color? color,
    required IconData iconData,
  }) {
    return Container(
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

  Widget _buildBasicUsage(BuildContext context) {
    return Expanded(
      child: PieMenu(
        actions: [
          PieAction(
            tooltip: 'Play',
            onSelect: () => context.showSnackBar('Play'),
            child: const FaIcon(FontAwesomeIcons.play),

            /// Optical correction
            padding: const EdgeInsets.only(left: 4),
          ),
          PieAction(
            tooltip: 'Download',
            onSelect: () => context.showSnackBar('Download'),
            child: const FaIcon(FontAwesomeIcons.download),
          ),
          PieAction(
            tooltip: 'Share',
            onSelect: () => context.showSnackBar('Share'),
            child: const FaIcon(FontAwesomeIcons.share),
          ),
        ],
        child: _buildCard(
          color: Colors.deepOrangeAccent,
          iconData: FontAwesomeIcons.video,
        ),
      ),
    );
  }

  Widget _buildDarkMode(BuildContext context) {
    return Expanded(
      child: PieMenu(
        theme: _pageTheme.copyWith(
          buttonTheme: const PieButtonTheme(
            backgroundColor: Colors.deepOrange,
            iconColor: Colors.white,
          ),
          buttonThemeHovered: const PieButtonTheme(
            backgroundColor: Colors.orange,
            iconColor: Colors.black,
          ),
          brightness: Brightness.dark,
        ),
        actions: [
          PieAction(
            tooltip: 'how',
            onSelect: () => context.showSnackBar('1'),
            childHovered: _buildTextButton('1', true),
            child: _buildTextButton('1', false),
          ),
          PieAction(
            tooltip: 'cool',
            onSelect: () => context.showSnackBar('2'),
            childHovered: _buildTextButton('2', true),
            child: _buildTextButton('2', false),
          ),
          PieAction(
            tooltip: 'is',
            onSelect: () => context.showSnackBar('3'),
            child: _buildTextButton('3', false),
            childHovered: _buildTextButton('3', true),
          ),
          PieAction(
            tooltip: 'this?!',
            onSelect: () => context.showSnackBar('Pretty cool :)'),
            child: _buildTextButton('4', false),
            childHovered: _buildTextButton('4', true),
          ),
        ],
        child: _buildCard(
          color: Colors.deepPurple,
          iconData: FontAwesomeIcons.solidMoon,
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
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLargeActions(BuildContext context) {
    return Expanded(
      child: PieMenu(
        theme: _pageTheme.copyWith(
          tooltipStyle: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          pointerColor: Colors.red.withOpacity(0.5),
          overlayColor: Colors.lightGreen.withOpacity(0.7),
          buttonTheme: const PieButtonTheme(
            backgroundColor: Colors.red,
            iconColor: Colors.white,
          ),
          buttonThemeHovered: const PieButtonTheme(
            backgroundColor: Colors.white,
            iconColor: Colors.black,
          ),
          buttonSize: 84,
        ),
        actions: [
          PieAction(
            tooltip: 'Like the package',
            onSelect: () {
              launchUrlExternally('https://pub.dev/packages/pie_menu');
            },
            child: const FaIcon(FontAwesomeIcons.solidThumbsUp),
          ),
          PieAction(
            tooltip: 'Import to your app',

            /// Custom background color
            buttonTheme: const PieButtonTheme(
              backgroundColor: Colors.deepOrange,
              iconColor: Colors.white,
            ),
            onSelect: () {
              launchUrlExternally('https://pub.dev/packages/pie_menu');
            },
            child: const FaIcon(FontAwesomeIcons.download),
          ),
          PieAction(
            tooltip: 'Share with other developers',
            buttonTheme: const PieButtonTheme(
              backgroundColor: Colors.orange,
              iconColor: Colors.white,
            ),
            onSelect: () {
              launchUrlExternally('https://pub.dev/packages/pie_menu');
            },
            child: const FaIcon(FontAwesomeIcons.share),
          ),
        ],
        child: _buildCard(
          color: Colors.blue,
          iconData: FontAwesomeIcons.magnifyingGlassPlus,
        ),
      ),
    );
  }
}

/// List view example
class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  bool _menuVisible = false;

  static const double spacing = 20;

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      onMenuToggle: (visible) {
        setState(() => _menuVisible = visible);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(spacing),
        physics: _menuVisible
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: 16,
        separatorBuilder: (context, index) => const SizedBox(height: spacing),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 200,
            child: PieMenu(
              onTap: () {
                context.showSnackBar('Tap #$index (Long press for Pie Menu)');
              },
              actions: [
                PieAction(
                  tooltip: 'Like',
                  onSelect: () => context.showSnackBar('Like #$index'),
                  child: const FaIcon(FontAwesomeIcons.solidHeart),
                ),
                PieAction(
                  tooltip: 'Comment',
                  onSelect: () => context.showSnackBar('Comment #$index'),
                  child: const FaIcon(FontAwesomeIcons.solidComment),
                ),
                PieAction(
                  tooltip: 'Save',
                  onSelect: () => context.showSnackBar('Save #$index'),
                  child: const FaIcon(FontAwesomeIcons.solidBookmark),
                ),
                PieAction(
                  tooltip: 'Share',
                  onSelect: () => context.showSnackBar('Share #$index'),
                  child: const FaIcon(FontAwesomeIcons.share),
                ),
              ],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// About the developer
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        delayDuration: Duration.zero,
        tooltipStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
        buttonTheme: const PieButtonTheme(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
        buttonThemeHovered: PieButtonTheme(
          backgroundColor: Colors.lime[200],
          iconColor: Colors.black,
        ),
        overlayColor: Colors.blue[200]!.withOpacity(0.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FlutterLogo(size: 200),
            const SizedBox(height: 32),
            PieMenu(
              actions: [
                PieAction(
                  tooltip: 'github.com/rasitayaz',
                  onSelect: () {
                    launchUrlExternally('https://github.com/rasitayaz');
                  },
                  child: const FaIcon(FontAwesomeIcons.github),
                ),
                PieAction(
                  tooltip: 'in/rasitayaz',
                  onSelect: () {
                    launchUrlExternally(
                      'https://www.linkedin.com/in/rasitayaz/',
                    );
                  },
                  child: const FaIcon(FontAwesomeIcons.linkedinIn),
                ),
                PieAction(
                  tooltip: 'mrasitayaz@gmail.com',
                  onSelect: () {
                    launchUrlExternally('mailto:mrasitayaz@gmail.com');
                  },
                  child: const FaIcon(FontAwesomeIcons.solidEnvelope),
                ),
                PieAction(
                  tooltip: 'Buy me a coffee',
                  onSelect: () {
                    launchUrlExternally(
                      'https://www.buymeacoffee.com/rasitayaz',
                    );
                  },
                  child: const FaIcon(FontAwesomeIcons.mugSaucer, size: 20),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'created by',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      'Raşit Ayaz.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
