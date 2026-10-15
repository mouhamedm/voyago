import 'package:flutter/material.dart';
import '../../../core/theme_config.dart';

/// Barre de recherche qui se déploie en largeur depuis le centre.
class AnimatedSearchBar extends StatelessWidget {
  final ThemeConfig config;
  final double reveal; // 0..1

  const AnimatedSearchBar({super.key, required this.config, required this.reveal});

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutExpo.transform(reveal.clamp(0.0, 1.0));
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: t.clamp(0.0, 1.0),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: config.isLight
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: config.isLight
                    ? const Color(0x1E0F4C81)
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: config.isLight
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F4C81).withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: config.isLight ? config.secondary : Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Où partons-nous ?',
                    style: TextStyle(
                      color: config.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: config.accent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: config.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
