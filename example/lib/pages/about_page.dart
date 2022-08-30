import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_menu/pie_menu.dart';

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
                  child: const FaIcon(FontAwesomeIcons.github),
                  onSelect: () {
                    launchUrlExternally('https://github.com/rasitayaz');
                  },
                ),
                PieAction(
                  tooltip: 'in/rasitayaz',
                  child: const FaIcon(FontAwesomeIcons.linkedinIn),
                  onSelect: () {
                    launchUrlExternally(
                      'https://www.linkedin.com/in/rasitayaz/',
                    );
                  },
                ),
                PieAction(
                  tooltip: 'mrasitayaz@gmail.com',
                  child: const FaIcon(FontAwesomeIcons.solidEnvelope),
                  onSelect: () {
                    launchUrlExternally('mailto:mrasitayaz@gmail.com');
                  },
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
