import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                  tooltip: 'github.com/rasitayaz',
                  child: const FaIcon(FontAwesomeIcons.github),
                  onSelect: () {
                    launchUrl(Uri.parse('https://github.com/rasitayaz'));
                  },
                ),
                PieAction(
                  tooltip: 'in/rasitayaz',
                  child: const FaIcon(FontAwesomeIcons.linkedinIn),
                  onSelect: () {
                    launchUrl(
                      Uri.parse('https://www.linkedin.com/in/rasitayaz/'),
                    );
                  },
                ),
                PieAction(
                  tooltip: 'mrasitayaz@gmail.com',
                  child: const FaIcon(FontAwesomeIcons.solidEnvelope),
                  onSelect: () {
                    launchUrl(Uri.parse('mailto:mrasitayaz@gmail.com'));
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
}
