import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme_config.dart';
import '../../../shared/painters/vehicle_painter.dart';

/// Grande carte héro : dégradé du thème + véhicule qui la traverse en
/// boucle lente. Parallax interne simple basé sur [scrollDy].
class HeroCard extends StatelessWidget {
  final ThemeConfig config;
  final double reveal; // 0..1, entrée
  final double time; // horloge libre (secondes)
  final double scrollDy;

  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.config,
    required this.reveal,
    required this.time,
    this.scrollDy = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(reveal.clamp(0.0, 1.0));
    final loop = (time % 8) / 8; // boucle de 8 s pour un défilement majestueux
    final shimmerT = ((time % 3500) / 3500); // cycle de brillance shimmer (Proposition 1)

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, 36 * (1 - t)),
        child: Transform.scale(
          scale: 0.93 + 0.07 * t,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F4C81).withValues(alpha: config.isLight ? 0.22 : 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                height: 200,
                child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(0, scrollDy * 0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: config.isLight
                              ? [
                                  const Color(0xFF0F4C81),
                                  const Color(0xFF1E3A8A),
                                  const Color(0xFF0284C7),
                                ]
                              : [config.backgroundBottom, config.accent.withValues(alpha: 0.55)],
                        ),
                      ),
                    ),
                  ),
                  // Nuages d'arrière-plan stylisés dans la carte héro
                  Positioned(
                    right: -20,
                    top: -10,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    top: 40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Avion qui traverse majestueusement
                  Positioned(
                    left: -60 + loop * 480,
                    top: 60,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(84, 52),
                        painter: VehiclePainter(
                          theme: config.theme,
                          bodyColor: Colors.white,
                          accent: const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                  // Badge Exclusif
                  Positioned(
                    left: 22,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'PREMIUM FLIGHT',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    bottom: 22,
                    right: 22,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Offre du moment',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                config.slogan,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Voir',
                            style: TextStyle(
                              color: const Color(0xFF0F4C81),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Effet de brillance (shimmer) traversant la bannière (Proposition 1)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CustomPaint(
                          painter: _HeroCardShimmerPainter(progress: shimmerT),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}

class _HeroCardShimmerPainter extends CustomPainter {
  final double progress; // 0..1
  _HeroCardShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Faisceau lumineux oblique qui balaie la carte
    final dx = (progress * 2.5 - 0.75) * size.width;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -0.6),
        end: const Alignment(1.0, 0.6),
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
        transform: _GradientTranslateTransform(dx / size.width),
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroCardShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GradientTranslateTransform extends GradientTransform {
  final double offsetFraction;
  const _GradientTranslateTransform(this.offsetFraction);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offsetFraction, 0.0, 0.0);
  }
}
