import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/motion.dart';

enum PillButtonPhase { idle, collapsing, loading, success }

/// Bouton pilule "vivant" : halo pulsant, reflet qui balaie toutes les 3 s,
/// press-scale avec haptique, et capacité de se transformer en cercle avec
/// loader puis coche (utilisé pour "Commencer" et "Accéder").
class PillActionButton extends StatefulWidget {
  final String label;
  final Color accent;
  final Color onAccent;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const PillActionButton({
    super.key,
    required this.label,
    required this.accent,
    this.onAccent = Colors.white,
    this.onPressed,
    this.width = 220,
    this.height = 56,
  });

  @override
  State<PillActionButton> createState() => PillActionButtonState();
}

class PillActionButtonState extends State<PillActionButton> with TickerProviderStateMixin {
  late final AnimationController _loop;
  late final AnimationController _press;
  late final AnimationController _morph;
  late final AnimationController _checkmark;

  PillButtonPhase phase = PillButtonPhase.idle;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: Motion.shimmerPeriod)..repeat();
    _press = AnimationController(vsync: this, duration: Motion.ctaPressDuration, value: 0);
    _morph = AnimationController(vsync: this, duration: Motion.welcomeToLoginTotal);
    _checkmark = AnimationController(vsync: this, duration: Motion.checkmarkDuration);
  }

  @override
  void dispose() {
    _loop.dispose();
    _press.dispose();
    _morph.dispose();
    _checkmark.dispose();
    super.dispose();
  }

  /// Contracte le bouton en cercle. Si [withLoader] est vrai, affiche un
  /// loader circulaire fin une fois la forme contractée (flow "Accéder").
  Future<void> collapse({bool withLoader = false}) async {
    setState(() => phase = PillButtonPhase.collapsing);
    await _morph.animateTo(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOutCubic);
    if (!mounted) return;
    if (withLoader) {
      setState(() => phase = PillButtonPhase.loading);
    }
  }

  /// Joue la coche de succès (dessin progressif + burst de particules).
  Future<void> playSuccess() async {
    setState(() => phase = PillButtonPhase.success);
    HapticFeedback.heavyImpact();
    await _checkmark.forward(from: 0);
  }

  void reset() {
    _morph.value = 0;
    _checkmark.value = 0;
    setState(() => phase = PillButtonPhase.idle);
  }

  void _onTapDown(TapDownDetails _) {
    if (phase != PillButtonPhase.idle) return;
    HapticFeedback.mediumImpact();
    _press.animateTo(1, duration: Motion.ctaPressDuration, curve: Curves.easeOut);
  }

  void _onTapEnd() {
    if (phase != PillButtonPhase.idle) return;
    _press.animateWith(Motion.spring(_press.value, 0));
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = widget.height;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) {
        _onTapEnd();
        widget.onPressed?.call();
      },
      onTapCancel: _onTapEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _press, _morph, _checkmark]),
        builder: (context, _) {
          final pressScale = 1 - (_press.value * 0.05);
          final morphT = Curves.easeInOutCubic.transform(_morph.value);
          final w = lerpDouble(widget.width, circleSize, morphT);
          final isRound = phase != PillButtonPhase.idle && phase != PillButtonPhase.collapsing;

          final halo = 0.15 + 0.3 * (0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi * (Motion.shimmerPeriod.inMilliseconds / Motion.haloPulsePeriod.inMilliseconds)));

          return Transform.scale(
            scale: pressScale,
            child: SizedBox(
              width: w,
              height: widget.height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.accent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: phase == PillButtonPhase.idle ? halo : 0.25),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: phase == PillButtonPhase.idle ? _buildShimmer() : null,
                  ),
                  if (phase == PillButtonPhase.idle || phase == PillButtonPhase.collapsing)
                    Opacity(
                      opacity: (1 - morphT * 2).clamp(0.0, 1.0),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.onAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  if (phase == PillButtonPhase.loading && isRound)
                    SizedBox(
                      width: circleSize * 0.45,
                      height: circleSize * 0.45,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: widget.onAccent,
                      ),
                    ),
                  if (phase == PillButtonPhase.success && isRound)
                    SizedBox(
                      width: circleSize * 0.5,
                      height: circleSize * 0.5,
                      child: CustomPaint(
                        painter: _CheckmarkPainter(progress: _checkmark.value, color: widget.onAccent),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    final sweepT = (_loop.value).clamp(0.0, 1.0);
    final fast = Curves.easeInOutCubic.transform(math.min(sweepT * 2.4, 1));
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionalTranslation(
          translation: Offset(lerpDouble(-1.4, 2.2, fast), 0),
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: widget.width * 0.4,
              height: widget.height * 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.76)
      ..lineTo(size.width * 0.84, size.height * 0.26);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));
    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => oldDelegate.progress != progress;
}
