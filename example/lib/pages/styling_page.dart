import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

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
        child: Icon(
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
            child: const Icon(CupertinoIcons.play_fill),
            onSelect: () => showSnackBar('Play', context),
            // Optical correction
            padding: const EdgeInsets.only(left: 4),
          ),
          PieAction(
            tooltip: 'Download',
            child: const Icon(CupertinoIcons.floppy_disk),
            onSelect: () => showSnackBar('Download', context),
          ),
          PieAction(
            tooltip: 'Share',
            child: const Icon(Icons.share),
            onSelect: () => showSnackBar('Share', context),
          ),
        ],
        child: _buildCard(
          color: Colors.deepOrangeAccent,
          iconData: CupertinoIcons.video_camera_solid,
        ),
      ),
    );
  }

  Widget _buildDarkMode(BuildContext context) {
    return Expanded(
      child: PieMenu(
        theme: _pageTheme.copyWith(
          buttonTheme: const PieButtonTheme(backgroundColor: Colors.deepOrange),
          buttonThemeHovered: const PieButtonTheme.hovered(
            backgroundColor: Colors.orange,
          ),
          brightness: Brightness.dark,
        ),
        actions: [
          PieAction(
            tooltip: 'how',
            onSelect: () => showSnackBar('1', context),
            child: _buildTextButton('1', false),
            childHovered: _buildTextButton('1', true),
          ),
          PieAction(
            tooltip: 'cool',
            onSelect: () => showSnackBar('2', context),
            child: _buildTextButton('2', false),
            childHovered: _buildTextButton('2', true),
          ),
          PieAction(
            tooltip: 'is',
            onSelect: () => showSnackBar('3', context),
            child: _buildTextButton('3', false),
            childHovered: _buildTextButton('3', true),
          ),
          PieAction(
            tooltip: 'this?!',
            onSelect: () => showSnackBar('Pretty cool :)', context),
            child: _buildTextButton('4', false),
            childHovered: _buildTextButton('4', true),
          ),
        ],
        child: _buildCard(
          color: Colors.deepPurple,
          iconData: CupertinoIcons.moon_fill,
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
          brightness: Brightness.dark,
          overlayColor: Colors.green.withOpacity(0.7),
          buttonTheme: const PieButtonTheme(backgroundColor: Colors.red),
          buttonThemeHovered: const PieButtonTheme.hovered(
            backgroundColor: Colors.white,
          ),
          buttonSize: 84,
        ),
        actions: [
          PieAction(
            tooltip: 'Like the package',
            onSelect: () {},
            child: const Icon(Icons.thumb_up),
          ),
          PieAction(
            tooltip: 'Import to your app',
            // Custom icon size
            child: const Icon(Icons.scatter_plot, size: 32),
            // Custom background color
            buttonTheme: PieButtonTheme(backgroundColor: Colors.red[700]),
            onSelect: () {},
          ),
          PieAction(
            tooltip: 'Leave a feedback',
            child: const Icon(CupertinoIcons.chat_bubble_text_fill),
            buttonTheme: PieButtonTheme(backgroundColor: Colors.red[900]),
            onSelect: () {},
          ),
        ],
        child: _buildCard(
          color: Colors.blue,
          iconData: CupertinoIcons.zoom_in,
        ),
      ),
    );
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
