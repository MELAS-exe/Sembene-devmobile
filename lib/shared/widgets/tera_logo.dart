import 'package:flutter/material.dart';
import 'package:tera/core/utils/app_colors.dart';

class TeraLogo extends StatelessWidget {
  const TeraLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TeraLogoPainter(),
    );
  }
}

class _TeraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 60;

    final centerRing = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * scale;
    canvas.drawCircle(Offset(cx, cy), 4 * scale, centerRing);

    // Top grain (green)
    final greenPaint = Paint()..color = AppColors.green;
    canvas.save();
    canvas.translate(cx, cy - 20 * scale);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: 16 * scale, height: 24 * scale),
      greenPaint,
    );
    canvas.restore();

    // Bottom-left grain (gold)
    final goldPaint = Paint()..color = AppColors.gold;
    canvas.save();
    canvas.translate(cx - 19 * scale, cy + 13 * scale);
    canvas.rotate(60 * 3.14159 / 180);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: 16 * scale, height: 24 * scale),
      goldPaint,
    );
    canvas.restore();

    // Bottom-right grain (terra)
    final terraPaint = Paint()..color = AppColors.terra;
    canvas.save();
    canvas.translate(cx + 19 * scale, cy + 13 * scale);
    canvas.rotate(-60 * 3.14159 / 180);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: 16 * scale, height: 24 * scale),
      terraPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
