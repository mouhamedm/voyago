import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme_config.dart';

/// En-tête de la Home ultra-pro : Marque de luxe VOYAGO + statut VIP + avatar et notifications interactifs.
class HomeHeader extends StatelessWidget {
  final ThemeConfig config;
  final double reveal; // 0..1
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.config,
    required this.reveal,
    this.onProfileTap,
    this.onNotificationTap,
  });

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
            // Logo de marque & Statut VIP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.brandName,
                      style: GoogleFonts.spaceGrotesk(
                        color: config.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: config.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: config.accent.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'VIP',
                        style: TextStyle(
                          color: config.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'FIRST CLASS PASSENGER',
                  style: TextStyle(
                    color: config.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Bouton Notifications interactif
            GestureDetector(
              onTap: onNotificationTap ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Aucune nouvelle alerte pour votre vol.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
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
                      size: 20,
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: config.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Profil Avatar interactif
            GestureDetector(
              onTap: onProfileTap,
              child: Transform.scale(
                scale: 0.6 + 0.4 * avatarT,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: config.accent, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: config.accent.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: config.accent,
                    child: const Text(
                      'A',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
