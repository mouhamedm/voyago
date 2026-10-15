import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme_config.dart';

/// En-tête de la Home : avatar (pop) + salutation (slide depuis le haut).
class HomeHeader extends StatelessWidget {
  final ThemeConfig config;
  final double reveal; // 0..1

  const HomeHeader({super.key, required this.config, required this.reveal});

  @override
  Widget build(BuildContext context) {
    final t = reveal.clamp(0.0, 1.0);
    final avatarT = Curves.easeOutBack.transform(reveal.clamp(0.0, 1.0));
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, -30 * (1 - t)),
        child: Row(
          children: [
            Transform.scale(
              scale: 0.6 + 0.4 * avatarT,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: config.accent,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salut, Alex',
                  style: GoogleFonts.spaceGrotesk(
                    color: config.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Prêt pour la prochaine escale ?',
                  style: TextStyle(
                    color: config.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: config.isLight
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: config.isLight
                      ? const Color(0x1A0F4C81)
                      : Colors.white.withValues(alpha: 0.12),
                ),
                boxShadow: config.isLight
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F4C81).withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: config.textPrimary,
                    size: 22,
                  ),
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: config.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
