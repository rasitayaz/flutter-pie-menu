import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_menu/pie_menu.dart';

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
      onMenuToggle: (displaying) {
        setState(() => _menuVisible = displaying);
      },
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + spacing,
          bottom: MediaQuery.of(context).padding.bottom + spacing,
          left: spacing,
          right: spacing,
        ),
        physics: _menuVisible
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: 16,
        separatorBuilder: (context, index) => const SizedBox(height: spacing),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 200,
            child: PieMenu(
              actions: [
                PieAction(
                  tooltip: 'Like',
                  child: const FaIcon(FontAwesomeIcons.solidHeart),
                  onSelect: () => showSnackBar('Like #$index', context),
                ),
                PieAction(
                  tooltip: 'Comment',
                  child: const FaIcon(FontAwesomeIcons.solidComment),
                  onSelect: () => showSnackBar('Comment #$index', context),
                ),
                PieAction(
                  tooltip: 'Save',
                  child: const FaIcon(FontAwesomeIcons.solidBookmark),
                  onSelect: () => showSnackBar('Save #$index', context),
                ),
                PieAction(
                  tooltip: 'Share',
                  child: const FaIcon(FontAwesomeIcons.share),
                  onSelect: () => showSnackBar('Share #$index', context),
                ),
              ],
              child: GestureDetector(
                onTap: _menuVisible
                    ? null
                    : () => showSnackBar(
                          'Tap #$index (Long press to display Pie Menu)',
                          context,
                        ),
                child: Container(
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
            ),
          );
        },
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
