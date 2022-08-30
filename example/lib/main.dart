import 'package:example/pages/about_page.dart';
import 'package:example/pages/list_view_page.dart';
import 'package:example/pages/styling_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
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
          'Flutter Pie Menu',
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
