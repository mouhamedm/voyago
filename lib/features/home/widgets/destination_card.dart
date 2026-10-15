import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/motion.dart';
import '../../../core/theme_config.dart';

class DestinationData {
  final String title;
  final String location;
  final int price;
  final int durationDays;
  const DestinationData({required this.title, required this.location, required this.price, required this.durationDays});
}

/// Carte destination avec entrée en cascade (slide-up + fade + scale) et
/// chiffres clés en count-up. Un léger effet de profondeur est appliqué
/// par le parent via [depthScale] lorsque la carte quitte le viewport.
class DestinationCard extends StatelessWidget {
  final ThemeConfig config;
  final DestinationData data;
  final double reveal; // 0..1, entrée en cascade
  final double depthScale; // 0.95..1, profondeur au scroll
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.config,
    required this.data,
    required this.reveal,
    this.depthScale = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(reveal.clamp(0.0, 1.0));
    final isLight = config.isLight;

    final IconData icon = switch (data.location) {
      'Portugal' => Icons.wb_sunny_rounded,
      'Norvège' => Icons.waves_rounded,
      'Maroc' => Icons.nightlight_round,
      'Japon' => Icons.park_rounded,
      _ => Icons.flight_takeoff_rounded,
    };

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, Motion.cardSlide * (1 - t)),
        child: Transform.scale(
          scale: (Motion.cardScaleFrom + (1 - Motion.cardScaleFrom) * t) * depthScale,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isLight ? const Color(0x180F4C81) : Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [config.accent, config.secondary],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: config.accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.spaceGrotesk(
                          color: config.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 13, color: config.secondary),
                          const SizedBox(width: 3),
                          Text(
                            data.location,
                            style: TextStyle(
                              color: config.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _CountUpText(
                      target: data.price,
                      reveal: reveal,
                      prefix: '',
                      suffix: ' €',
                      color: config.accent,
                      fontSize: 18,
                    ),
                    const SizedBox(height: 2),
                    _CountUpText(
                      target: data.durationDays,
                      reveal: reveal,
                      suffix: ' jours',
                      color: config.textMuted,
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _CountUpText extends StatelessWidget {
  final int target;
  final double reveal;
  final String prefix;
  final String suffix;
  final Color color;
  final double fontSize;

  const _CountUpText({
    required this.target,
    required this.reveal,
    this.prefix = '',
    this.suffix = '',
    required this.color,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(reveal.clamp(0.0, 1.0));
    final value = (target * t).round();
    return Text(
      '$prefix$value$suffix',
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: fontSize),
    );
  }
}
