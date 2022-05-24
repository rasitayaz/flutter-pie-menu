import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        delayDuration: Duration.zero,
        buttonTheme: const PieButtonTheme(backgroundColor: Colors.black),
        buttonThemeHovered: PieButtonTheme.hovered(
          backgroundColor: Colors.lime[200],
        ),
        overlayColor: Colors.blue[200]!.withOpacity(0.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PieMenu(
              actions: [
                PieAction(
                  tooltip: 'GitHub',
                  child: const Icon(Icons.language),
                  onSelect: () {
                    openLink('https://github.com/rasitayaz');
                  },
                ),
                PieAction(
                  tooltip: 'LinkedIn',
                  child: const Text(
                    'in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  childHovered: const Text(
                    'in',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onSelect: () {
                    openLink('https://www.linkedin.com/in/rasitayaz/');
                  },
                ),
                PieAction(
                  tooltip: 'mrasitayaz@gmail.com',
                  child: const Icon(Icons.mail_rounded),
                  onSelect: () {
                    openLink('mailto:mrasitayaz@gmail.com');
                  },
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
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
            ),
            const SizedBox(height: 32),
            const FlutterLogo(size: 200),
          ],
        ),
      ),
    );
  }

  void openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
