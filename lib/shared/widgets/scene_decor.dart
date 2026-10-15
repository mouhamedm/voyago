import 'package:flutter/material.dart';
import '../../core/theme_config.dart';
import '../painters/clouds_painter.dart';
import '../painters/road_painter.dart';
import '../painters/waves_painter.dart';

/// Sélectionne et peint le décor animé correspondant au [DecorStyle] du
/// thème actif (nuages / vagues / route+lampadaires), à partir d'un simple
/// temps écoulé en secondes pour piloter le parallax infini.
class SceneDecor extends StatelessWidget {
  final ThemeConfig config;
  final double time;

  const SceneDecor({super.key, required this.config, required this.time});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: switch (config.decor) {
          DecorStyle.clouds => CloudsPainter(time: time, color: Colors.white, isLight: config.isLight),
          DecorStyle.waves => WavesPainter(time: time, color: config.secondary),
          DecorStyle.road => RoadPainter(time: time, color: config.secondary, accent: config.accent),
        },
        size: Size.infinite,
      ),
    );
  }
}
