import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/motion.dart';
import '../../../core/theme_config.dart';

/// Barre de navigation inférieure : monte du bas avec un ressort, indicateur
/// "bulle" qui glisse vers l'icône active, et flou glassmorphic.
class BottomNav extends StatelessWidget {
  final ThemeConfig config;
  final double reveal; // 0..1, entrée (spring)
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({
    super.key,
    required this.config,
    required this.reveal,
    this.currentIndex = 0,
    this.onTap,
  });

  static const _icons = [
    Icons.explore_rounded,
    Icons.favorite_border_rounded,
    Icons.map_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutBack.transform(reveal.clamp(0.0, 1.0));
    return Opacity(
      opacity: reveal.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 80 * (1 - t)),
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: config.isLight
                      ? Colors.white.withValues(alpha: 0.88)
                      : const Color(0xFF0F172A).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: config.isLight
                        ? const Color(0x220F4C81)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: config.isLight
                          ? const Color(0xFF0F4C81).withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _icons.length;
              return Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 320),
                    curve: Motion.pop,
                    alignment: Alignment(-1 + (2 * currentIndex / (_icons.length - 1)), 0),
                    child: Container(
                      width: itemWidth - 8,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [config.accent, config.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: config.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_icons.length, (i) {
                      final selected = i == currentIndex;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap?.call(i),
                          child: SizedBox(
                            height: 44,
                            child: Icon(
                              _icons[i],
                              color: selected
                                  ? Colors.white
                                  : (config.isLight
                                      ? const Color(0xFF64748B)
                                      : Colors.white54),
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  ),
),
);
}
}
