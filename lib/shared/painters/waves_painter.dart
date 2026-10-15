import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Vagues animées en 3 couches de parallax (0.2x / 0.5x / 1x), utilisées
/// par le thème [TravelTheme.boat]. Chaque couche est une sinusoïde pleine
/// dont la phase défile avec le temps.
class WavesPainter extends CustomPainter {
  final double time;
  final Color color;

  WavesPainter({required this.time, required this.color});

  static const _speeds = [0.2, 0.5, 1.0];
  static const _opacities = [0.22, 0.32, 0.5];
  static const _amplitudes = [10.0, 16.0, 22.0];

  @override
  void paint(Canvas canvas, Size size) {
    for (var layer = 0; layer < 3; layer++) {
      final speed = _speeds[layer];
      final amplitude = _amplitudes[layer];
      final baseY = size.height * (0.55 + layer * 0.14);
      final phase = time * speed * 2.2;
      final paint = Paint()..color = color.withValues(alpha: _opacities[layer]);

      final path = Path()..moveTo(0, size.height);
      const step = 12.0;
      for (double x = 0; x <= size.width; x += step) {
        final y = baseY +
            math.sin((x / 70) + phase) * amplitude +
            math.sin((x / 31) - phase * 1.4) * (amplitude * 0.35);
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WavesPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.color != color;
}
