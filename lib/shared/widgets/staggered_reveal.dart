import 'package:flutter/material.dart';

/// Construit une sous-animation [0,1] à partir d'un [parent] (lui-même 0..1)
/// pour un élément démarrant à [startFraction] de la durée totale du groupe
/// et occupant [span] de cette durée. Permet de faire du stagger sans créer
/// un AnimationController par élément : tout dérive du controller maître.
Animation<double> staggerSlice(
  Animation<double> parent, {
  required double startFraction,
  required double span,
  Curve curve = Curves.easeOutCubic,
}) {
  final end = (startFraction + span).clamp(0.0, 1.0);
  return CurvedAnimation(
    parent: parent,
    curve: Interval(startFraction.clamp(0.0, 1.0), end, curve: curve),
  );
}

/// Révèle une liste d'enfants en cascade (slide-up + fade) à partir d'une
/// seule [Animation] parente, sans AnimationController dédié.
class StaggeredReveal extends StatelessWidget {
  final Animation<double> parent;
  final List<Widget> children;
  final double staggerFraction; // décalage relatif entre 2 éléments
  final double itemSpan; // durée relative de l'animation de chaque élément
  final double slideOffset;
  final Curve curve;
  final Axis direction;

  const StaggeredReveal({
    super.key,
    required this.parent,
    required this.children,
    this.staggerFraction = 0.08,
    this.itemSpan = 0.5,
    this.slideOffset = 20,
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (i) {
        final start = (i * staggerFraction).clamp(0.0, 1.0 - 0.001);
        final anim = staggerSlice(parent, startFraction: start, span: itemSpan, curve: curve);
        return AnimatedBuilder(
          animation: anim,
          builder: (context, _) {
            final t = anim.value;
            final offset = direction == Axis.vertical
                ? Offset(0, slideOffset * (1 - t))
                : Offset(slideOffset * (1 - t), 0);
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(offset: offset, child: children[i]),
            );
          },
        );
      }),
    );
  }
}

/// Révèle un texte mot par mot avec un masque (ClipRect) qui glisse vers le
/// haut, comme un rideau qui se lève sur chaque mot.
class MaskedWordsReveal extends StatelessWidget {
  final Animation<double> parent;
  final String text;
  final TextStyle style;
  final double staggerFraction;
  final double itemSpan;
  final TextAlign textAlign;

  const MaskedWordsReveal({
    super.key,
    required this.parent,
    required this.text,
    required this.style,
    this.staggerFraction = 0.12,
    this.itemSpan = 0.6,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment:
          textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines.length, (lineIndex) {
        final words = lines[lineIndex].split(' ');
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Wrap(
            alignment: textAlign == TextAlign.center ? WrapAlignment.center : WrapAlignment.start,
            children: List.generate(words.length, (wordIndex) {
              final globalIndex = lineIndex * 10 + wordIndex;
              final start = (globalIndex * staggerFraction).clamp(0.0, 1.0 - 0.001);
              final anim = staggerSlice(
                parent,
                startFraction: start,
                span: itemSpan,
                curve: Curves.easeOutExpo,
              );
              return AnimatedBuilder(
                animation: anim,
                builder: (context, _) {
                  final t = anim.value;
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      heightFactor: t.clamp(0.0, 1.0),
                      child: Opacity(
                        opacity: t.clamp(0.0, 1.0),
                        child: Text('${words[wordIndex]} ', style: style),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      }),
    );
  }
}
