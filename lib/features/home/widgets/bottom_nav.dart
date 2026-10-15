import 'package:flutter/material.dart';
import '../../../core/motion.dart';
import '../../../core/theme_config.dart';

/// Barre de navigation inférieure : monte du bas avec un ressort, indicateur
/// "bulle" qui glisse vers l'icône active.
class BottomNav extends StatefulWidget {
  final ThemeConfig config;
  final double reveal; // 0..1, entrée (spring)

  const BottomNav({super.key, required this.config, required this.reveal});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _active = 0;
  static const _icons = [
    Icons.explore_rounded,
    Icons.favorite_border_rounded,
    Icons.map_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutBack.transform(widget.reveal.clamp(0.0, 1.0));
    return Opacity(
      opacity: widget.reveal.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 80 * (1 - t)),
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: widget.config.isLight
                ? Colors.white.withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.config.isLight
                  ? const Color(0x180F4C81)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.config.isLight
                    ? const Color(0xFF0F4C81).withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.3),
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
                    alignment: Alignment(-1 + (2 * _active / (_icons.length - 1)), 0),
                    child: Container(
                      width: itemWidth - 8,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.config.accent, widget.config.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.config.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_icons.length, (i) {
                      final selected = i == _active;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _active = i),
                          child: SizedBox(
                            height: 44,
                            child: Icon(
                              _icons[i],
                              color: selected
                                  ? Colors.white
                                  : (widget.config.isLight
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
    );
  }
}
