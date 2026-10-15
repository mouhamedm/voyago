import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Nuages vectoriels défilant en parallax infini sur 3 couches
/// (vitesses 0.2x / 0.5x / 1x). Utilisé par le thème [TravelTheme.plane].
class CloudsPainter extends CustomPainter {
  final double time; // secondes écoulées, pilote le défilement
  final Color color;
  final bool isLight;

  CloudsPainter({
    required this.time,
    required this.color,
    this.isLight = true,
  });

  static const _speeds = [0.18, 0.42, 0.85];
  static const _opacities = [0.45, 0.65, 0.90];
  static const _scales = [0.75, 1.1, 1.45];

  @override
  void paint(Canvas canvas, Size size) {
    for (var layer = 0; layer < 3; layer++) {
      final speed = _speeds[layer];
      // Nuages concentrés avec élégance dans le tiers supérieur
      final laneHeight = size.height * (0.05 + layer * 0.065);
      final scale = _scales[layer] * (size.width / 390);
      final spacing = 280.0 * scale;
      final shift = (time * 20 * speed) % spacing;
      final count = (size.width / spacing).ceil() + 2;
      final seedOffset = layer * 97.0;

      for (var i = -1; i < count; i++) {
        final baseX = i * spacing - shift;
        final wobble = math.sin((time * 0.25) + i * 1.5 + seedOffset) * 5;
        _drawVolumetricCloud(
          canvas,
          Offset(baseX, laneHeight + wobble),
          scale,
          _opacities[layer],
        );
      }
    }
  }

  void _drawVolumetricCloud(Canvas canvas, Offset center, double scale, double layerAlpha) {
    final r = 24.0 * scale;

    // Ombre portée douce sous le nuage (teinte ciel subtile)
    final shadowPaint = Paint()
      ..color = isLight
          ? const Color(0x3093C5FD).withValues(alpha: 0.18 * layerAlpha)
          : Colors.black.withValues(alpha: 0.15 * layerAlpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * scale);

    final shadowBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + Offset(0, r * 0.5), width: r * 3.2, height: r * 1.0),
      Radius.circular(r * 0.6),
    );
    canvas.drawRRect(shadowBody, shadowPaint);

    // Corps de base avec dégradé vertical (lumière zénithale blanche -> base bleutée)
    final cloudRect = Rect.fromCenter(center: center + Offset(0, r * 0.2), width: r * 3.4, height: r * 1.6);
    final cloudGradient = isLight
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.95 * layerAlpha),
              const Color(0xFFE8F1FC).withValues(alpha: 0.85 * layerAlpha),
            ],
          ).createShader(cloudRect)
        : null;

    final bodyPaint = Paint();
    if (cloudGradient != null) {
      bodyPaint.shader = cloudGradient;
    } else {
      bodyPaint.color = color.withValues(alpha: layerAlpha);
    }

    // Puffs arrondis pour créer le volume du nuage
    canvas.drawCircle(center, r, bodyPaint);
    canvas.drawCircle(center + Offset(r * 1.05, r * 0.18), r * 0.76, bodyPaint);
    canvas.drawCircle(center + Offset(-r * 1.0, r * 0.22), r * 0.68, bodyPaint);
    canvas.drawCircle(center + Offset(r * 0.38, -r * 0.42), r * 0.64, bodyPaint);
    canvas.drawCircle(center + Offset(-r * 0.45, -r * 0.32), r * 0.58, bodyPaint);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + Offset(0, r * 0.4), width: r * 3.0, height: r * 0.95),
      Radius.circular(r * 0.5),
    );
    canvas.drawRRect(body, bodyPaint);

    // Highlight supérieur lumineux pur blanc (effet de réflexion du soleil)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * layerAlpha);
    canvas.drawCircle(center + Offset(0, -r * 0.2), r * 0.5, highlightPaint);
    canvas.drawCircle(center + Offset(r * 0.4, -r * 0.35), r * 0.35, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CloudsPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.color != color || oldDelegate.isLight != isLight;
}
