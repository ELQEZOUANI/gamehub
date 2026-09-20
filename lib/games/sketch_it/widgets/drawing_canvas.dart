import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class DrawingCanvas extends StatelessWidget {
  final List<DrawingPoint?> points;

  const DrawingCanvas({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: _DrawingPainter(points: points),
        size: Size.infinite,
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  _DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => oldDelegate.points != points;
}
