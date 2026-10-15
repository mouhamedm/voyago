import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/motion.dart';

/// Route de transition "reveal circulaire" : un cercle grandit depuis
/// [center] jusqu'à couvrir tout l'écran, révélant la page suivante.
/// Utilisée pour le moment viral login -> home (séquence 4).
class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({required Widget page, required Offset center})
      : super(
          transitionDuration: Motion.circularRevealDuration,
          reverseTransitionDuration: Motion.circularRevealDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Motion.travel);
            return AnimatedBuilder(
              animation: curved,
              builder: (context, _) => ClipPath(
                clipper: _CircleRevealClipper(center: center, fraction: curved.value),
                child: child,
              ),
            );
          },
        );
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double fraction;

  _CircleRevealClipper({required this.center, required this.fraction});

  @override
  Path getClip(Size size) {
    final radius = _maxRadius(size) * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  double _maxRadius(Size size) {
    final dx = math.max(center.dx, size.width - center.dx);
    final dy = math.max(center.dy, size.height - center.dy);
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) => oldClipper.fraction != fraction;
}
