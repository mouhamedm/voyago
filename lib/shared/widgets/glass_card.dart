import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/motion.dart';

/// Carte "glassmorphism" : flou de fond, remplissage blanc translucide et
/// bordure fine, utilisée pour la feuille de login.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.blurSigma = Motion.glassBlurSigma,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(Motion.glassRadius);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final fill = backgroundColor ??
        (isLight
            ? Colors.white.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: Motion.glassFillOpacity));

    final border = borderColor ??
        (isLight
            ? const Color(0x1E0F4C81)
            : Colors.white.withValues(alpha: Motion.glassBorderOpacity));

    final boxShadows = shadows ??
        (isLight
            ? [
                BoxShadow(
                  color: const Color(0xFF0F4C81).withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(
                color: border,
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
