import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RadarLogo extends StatelessWidget {
  const RadarLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RadarLogoPainter(),
    );
  }
}

class _RadarLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    
    // Draw three concentric circles
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.textPrimary.withOpacity(0.6);

    // Outer circle
    canvas.drawCircle(center, radius - 8, circlePaint);
    
    // Middle circle
    canvas.drawCircle(center, radius - 24, circlePaint);
    
    // Inner circle
    canvas.drawCircle(center, radius - 40, circlePaint);

    // Draw radar sweep line (diagonal from center to top right)
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.textPrimary.withOpacity(0.8);

    // -45 degrees in radians (pointing to top right)
    final sweepAngle = -45 * (math.pi / 180);
    final sweepLength = radius - 12;
    final sweepEndX = center.dx + sweepLength * math.cos(sweepAngle);
    final sweepEndY = center.dy + sweepLength * math.sin(sweepAngle);

    canvas.drawLine(
      center,
      Offset(sweepEndX, sweepEndY),
      sweepPaint,
    );

    // Draw center dot
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.textPrimary;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

