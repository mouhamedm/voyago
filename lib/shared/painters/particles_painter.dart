import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Une particule (étoile/bulle) dérivant lentement dans l'une des 3 couches
/// de parallax du fond du preloader.
class _Particle {
  final double x; // position normalisée 0..1
  final double y;
  final double radius;
  final double baseOpacity;
  final int layer; // 0 = lointain (0.2x), 1 = moyen (0.5x), 2 = proche (1x)
  final double driftSeed;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.baseOpacity,
    required this.layer,
    required this.driftSeed,
  });
}

/// Fond de particules à 3 couches de parallax (vitesses 0.2x / 0.5x / 1x).
/// Génère 40 particules déterministes (seed fixe) pour un rendu stable.
class ParticlesPainter extends CustomPainter {
  static final List<_Particle> _particles = _generate(40);
  static const _speeds = [0.2, 0.5, 1.0];

  final double time;
  final Color color;

  ParticlesPainter({required this.time, required this.color});

  static List<_Particle> _generate(int count) {
    final rand = math.Random(42);
    return List.generate(count, (i) {
      return _Particle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        radius: 1.0 + rand.nextDouble() * 2.2,
        baseOpacity: 0.25 + rand.nextDouble() * 0.5,
        layer: i % 3,
        driftSeed: rand.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final speed = _speeds[p.layer];
      final dx = math.sin(time * 0.15 * speed + p.driftSeed) * 14 * speed;
      final dy = (time * 6 * speed + p.y * size.height) % (size.height + 20) - 10;
      final twinkle = 0.65 + 0.35 * math.sin(time * 1.4 + p.driftSeed * 3);
      final paint = Paint()..color = color.withValues(alpha: p.baseOpacity * twinkle);
      canvas.drawCircle(Offset(p.x * size.width + dx, dy), p.radius * (0.6 + p.layer * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.color != color;
}
