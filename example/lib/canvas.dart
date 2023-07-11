import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_menu/pie_menu.dart';

class Node {
  final Offset offset;
  final int index;

  const Node(this.index, this.offset);

  String get name => 'Node $index';
}

const nodes = [
  Node(0, Offset(0.5, 0.5)),
  Node(1, Offset(0.2, 0.8)),
  Node(2, Offset(0.6, 0.3)),
  Node(3, Offset(0.9, 0.7)),
];

class NodePage extends StatefulWidget {
  const NodePage({super.key});

  @override
  State<NodePage> createState() => _NodePageState();
}

class _NodePageState extends State<NodePage> {
  final GlobalKey<PieMenuState> _pieMenuKey = GlobalKey<PieMenuState>();
  final GlobalKey _canvasKey = GlobalKey();
  final ValueNotifier<Node?> _pressedNode = ValueNotifier<Node?>(null);

  @override
  void dispose() {
    _pressedNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PieCanvas(
        theme: PieTheme(
          overlayColor: Colors.black38,
          buttonTheme: PieButtonTheme(
            backgroundColor: Colors.blueGrey.withOpacity(0.6),
            iconColor: Colors.white,
          ),
          buttonThemeHovered: PieButtonTheme(
            backgroundColor: Colors.blueGrey.withOpacity(0.9),
            iconColor: Colors.white,
          ),
          pointerColor: Colors.blueGrey.withOpacity(0.5),
          tooltipPadding: const EdgeInsets.all(20),
        ),
        child: GestureDetector(
          onLongPressDown: (details) {
            final RenderBox? box =
                _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final Node? node =
                NodePainter.doesTouch(box.size, nodes, details.localPosition);
            if (node == null) return;

            _pressedNode.value = node;
            // call on tap once the overlay is enabled
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                _pieMenuKey.currentState?.onTapLocal(details.localPosition));
          },
          child: CustomPaint(
            key: _canvasKey,
            painter: NodePainter(nodes),
            child: ValueListenableBuilder<Node?>(
              valueListenable: _pressedNode,
              builder: (context, node, child) => PieMenu(
                key: _pieMenuKey,
                disabled: node == null,
                onToggle: (bool isToggled) {
                  if (!isToggled) {
                    _pressedNode.value = null;
                  }
                },
                actions: [
                  PieAction(
                    tooltip: node?.name ?? '',
                    onSelect: () {},
                    child: const FaIcon(FontAwesomeIcons.question, size: 20),
                  ),
                ],
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const nodeGridSize = 50.0;
const nodeRadius = 30.0;

/// Node painter
class NodePainter extends CustomPainter {
  final List<Node> nodes;

  NodePainter(this.nodes);

  static Node? doesTouch(Size size, List<Node> nodes, Offset offset) {
    for (final Node n in nodes) {
      final rect = Rect.fromCenter(
        center: Offset(size.width * n.offset.dx, size.height * n.offset.dy),
        width: nodeRadius,
        height: nodeRadius,
      );
      if (rect.contains(offset)) return n;
    }
    return null;
  }

  void _drawBackground(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white70
      ..isAntiAlias = true;

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey
      ..isAntiAlias = true;

    final rows = size.height / nodeGridSize;
    final cols = size.width / nodeGridSize;

    for (int r = 0; r < rows; r++) {
      final y = r * nodeGridSize;
      final p1 = Offset(0, y);
      final p2 = Offset(size.width, y);

      canvas.drawLine(p1, p2, paint);
    }

    for (int c = 0; c < cols; c++) {
      final x = c * nodeGridSize;
      final p1 = Offset(x, 0);
      final p2 = Offset(x, size.height);

      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueAccent
      ..isAntiAlias = true;

    for (int i = 0; i < nodes.length; i++) {
      final c = Offset(
          size.width * nodes[i].offset.dx, size.height * nodes[i].offset.dy);
      canvas.drawCircle(c, nodeRadius, paint);
      _drawText(canvas, c, nodes[i].name);
    }
  }

  void _drawText(Canvas canvas, Offset offset, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    );

    final textPainter = TextPainter()
      ..text = textSpan
      ..textScaleFactor = 0.8
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..layout();

    final xCenter = (offset.dx - textPainter.width / 2);
    final yCenter = (offset.dy - textPainter.height / 2);

    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
    _drawNodes(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
