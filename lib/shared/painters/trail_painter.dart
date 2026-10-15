import 'package:flutter/material.dart';
import '../../core/motion.dart';

/// Traînée lumineuse qui se dessine progressivement derrière le véhicule
/// pendant le preloader : ligne pointillée fine en accent + glow, qui ne
/// garde qu'une fenêtre récente du trajet (fondu sur la queue).
class TrailPainter extends CustomPainter {
  final Path fullPath;
  final double pathLength;
  final double progress; // 0..1, position actuelle du véhicule sur le chemin
  final Color color;
  final double trailFraction; // portion du chemin visible derrière le véhicule

  TrailPainter({
    required this.fullPath,
    required this.pathLength,
    required this.progress,
    required this.color,
    this.trailFraction = 0.22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || pathLength <= 0) return;
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final headDist = progress * pathLength;
    final tailDist = (headDist - trailFraction * pathLength).clamp(0.0, pathLength);
    if (headDist - tailDist <= 1) return;

    final visible = metric.extractPath(tailDist, headDist);

    // Glow doux derrière le trait net.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, Motion.trailGlowBlurSigma);
    canvas.drawPath(visible, glowPaint);

    // Trait pointillé net avec fondu le long de la queue.
    const dashLength = 6.0;
    const gapLength = 7.0;
    double distance = 0;
    final span = headDist - tailDist;
    while (distance < span) {
      final segmentStart = tailDist + distance;
      final segmentEnd = (segmentStart + dashLength).clamp(tailDist, headDist);
      final dash = metric.extractPath(segmentStart, segmentEnd);
      final localT = (segmentStart - tailDist) / span; // 0 à la queue, 1 à la tête
      final dashPaint = Paint()
        ..color = color.withValues(alpha: 0.15 + 0.75 * localT)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(dash, dashPaint);
      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
