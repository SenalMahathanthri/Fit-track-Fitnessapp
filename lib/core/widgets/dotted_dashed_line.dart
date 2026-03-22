// lib/common_widget/dotted_dashed_line.dart
import 'package:flutter/material.dart';

class DottedDashedLine extends StatelessWidget {
  final double height;
  final double width;
  final Color dashColor;
  final double dashGap;
  final double dashWidth;
  final double strokeWidth;
  final Axis axis;

  const DottedDashedLine({
    super.key,
    required this.height,
    required this.width,
    required this.dashColor,
    this.dashGap = 5,
    this.dashWidth = 5,
    this.strokeWidth = 1,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _DottedDashedLinePainter(
          dashColor: dashColor,
          dashGap: dashGap,
          dashWidth: dashWidth,
          strokeWidth: strokeWidth,
          axis: axis,
        ),
      ),
    );
  }
}

class _DottedDashedLinePainter extends CustomPainter {
  final Color dashColor;
  final double dashGap;
  final double dashWidth;
  final double strokeWidth;
  final Axis axis;

  _DottedDashedLinePainter({
    required this.dashColor,
    required this.dashGap,
    required this.dashWidth,
    required this.strokeWidth,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = dashColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    if (axis == Axis.vertical) {
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashGap;
      }
    } else {
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2),
          paint,
        );
        startX += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DottedDashedLinePainter oldDelegate) {
    return oldDelegate.dashColor != dashColor ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.axis != axis;
  }
}
