import 'package:flutter/material.dart';

/// Route en perspective avec lampadaires, utilisée par le thème
/// [TravelTheme.car]. 3 couches de parallax : silhouette urbaine lointaine
/// (0.2x), lampadaires (0.5x), marquage au sol (1x).
class RoadPainter extends CustomPainter {
  final double time;
  final Color color;
  final Color accent;

  RoadPainter({required this.time, required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.62;

    // Route (trapèze en perspective vers un point de fuite central).
    final vanishing = Offset(size.width * 0.5, horizonY);
    final roadPaint = Paint()..color = color.withValues(alpha: 0.5);
    final road = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(vanishing.dx - 6, vanishing.dy)
      ..lineTo(vanishing.dx + 6, vanishing.dy)
      ..lineTo(size.width * 0.82, size.height)
      ..close();
    canvas.drawPath(road, roadPaint);

    // Silhouette urbaine lointaine (couche 0.2x).
    final farShift = (time * 24 * 0.2) % 160;
    final farPaint = Paint()..color = color.withValues(alpha: 0.25);
    for (var i = -1; i < (size.width / 160).ceil() + 2; i++) {
      final x = i * 160.0 - farShift;
      final h = 40.0 + (i % 3) * 18;
      canvas.drawRect(Rect.fromLTWH(x, horizonY - h, 54, h), farPaint);
    }

    // Marquage central défilant (couche 1x) = tirets qui filent vers le bas.
    final dashShift = (time * 220) % 70;
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    for (double t = dashShift - 70; t < size.height - horizonY; t += 70) {
      final f = (t / (size.height - horizonY)).clamp(0.0, 1.0);
      final y = horizonY + t;
      final halfW = 2.0 + f * 7;
      canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, y), width: halfW, height: 18), dashPaint);
    }

    // Lampadaires (couche 0.5x) avec halo accent.
    final lampShift = (time * 60) % 220;
    for (final side in [-1, 1]) {
      for (var i = -1; i < (size.height / 220).ceil() + 2; i++) {
        final depth = (i * 220.0 - lampShift) / (size.height - horizonY);
        if (depth < 0 || depth > 1.2) continue;
        final y = horizonY + depth * (size.height - horizonY);
        final spread = 0.08 + depth * 0.42;
        final x = size.width / 2 + side * spread * size.width;
        final r = 2.0 + depth * 5;
        canvas.drawCircle(Offset(x, y), r * 2.2, Paint()
          ..color = accent.withValues(alpha: 0.25 * (1 - depth * 0.5))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        canvas.drawCircle(Offset(x, y), r, Paint()..color = accent.withValues(alpha: 0.9));
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.color != color || oldDelegate.accent != accent;
}
