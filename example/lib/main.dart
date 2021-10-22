import 'package:example/pages/about_page.dart';
import 'package:example/pages/list_view_page.dart';
import 'package:example/pages/styling_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SandboxApp());
}

class SandboxApp extends StatelessWidget {
  const SandboxApp({Key? key}) : super(key: key);

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
  const HomePage({Key? key}) : super(key: key);

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
            icon: Icon(Icons.palette),
            label: 'Styling',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list_fill),
            label: 'ListView',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scatter_plot),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
