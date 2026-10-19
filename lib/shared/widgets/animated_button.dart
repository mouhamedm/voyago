import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/motion.dart';

enum PillButtonPhase { idle, bouncing, collapsing, loading, success }

/// Bouton pilule "vivant" : halo pulsant, reflet qui balaie,
/// rebond élastique (haptic feedback visual), flèche >, et spinner vinyle/gyro
/// avec anneau de lumière 360° lors du chargement.
class PillActionButton extends StatefulWidget {
  final String label;
  final Color accent;
  final Color onAccent;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool showArrow;

  const PillActionButton({
    super.key,
    required this.label,
    required this.accent,
    this.onAccent = Colors.white,
    this.onPressed,
    this.width = 220,
    this.height = 56,
    this.showArrow = true,
  });

  @override
  State<PillActionButton> createState() => PillActionButtonState();
}

class PillActionButtonState extends State<PillActionButton> with TickerProviderStateMixin {
  late final AnimationController _loop;
  late final AnimationController _press;
  late final AnimationController _bounce;
  late final AnimationController _morph;
  late final AnimationController _checkmark;
  late final AnimationController _vinylSpin;

  PillButtonPhase phase = PillButtonPhase.idle;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: Motion.shimmerPeriod)..repeat();
    _press = AnimationController(vsync: this, duration: Motion.ctaPressDuration, value: 0);
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _morph = AnimationController(vsync: this, duration: Motion.welcomeToLoginTotal);
    _checkmark = AnimationController(vsync: this, duration: Motion.checkmarkDuration);
    _vinylSpin = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    _press.dispose();
    _bounce.dispose();
    _morph.dispose();
    _checkmark.dispose();
    _vinylSpin.dispose();
    super.dispose();
  }

  /// Rebond élastique visuel (Proposition 1 - The Vinyl & Sonic Pulse)
  Future<void> triggerElasticBounce() async {
    HapticFeedback.mediumImpact();
    await _bounce.forward(from: 0);
  }

  /// Contracte le bouton en cercle. Si [withLoader] est vrai, affiche le
  /// disque vinyle miniature avec anneau de lumière 360°.
  Future<void> collapse({bool withLoader = false}) async {
    setState(() => phase = PillButtonPhase.collapsing);
    await _morph.animateTo(1, duration: const Duration(milliseconds: 240), curve: Curves.easeInOutCubic);
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
    _bounce.value = 0;
    setState(() => phase = PillButtonPhase.idle);
  }

  void _onTapDown(TapDownDetails _) {
    if (phase != PillButtonPhase.idle) return;
    HapticFeedback.mediumImpact();
    _press.animateTo(1, duration: Motion.ctaPressDuration, curve: Curves.easeOut);
    _bounce.forward(from: 0);
  }

  void _onTapEnd() {
    if (phase != PillButtonPhase.idle) return;
    _press.animateWith(Motion.spring(_press.value, 0));
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = widget.height;
    return GestureDetector(
      onTap: () {
        if (phase == PillButtonPhase.idle) {
          widget.onPressed?.call();
        }
      },
      onTapDown: _onTapDown,
      onTapUp: (_) => _onTapEnd(),
      onTapCancel: _onTapEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _press, _bounce, _morph, _checkmark, _vinylSpin]),
        builder: (context, _) {
          // Rebond élastique naturel combiné avec le press
          final bounceCurve = math.sin(_bounce.value * math.pi * 1.5) * math.exp(-_bounce.value * 3.5);
          final elasticFactor = _bounce.isAnimating ? (1.0 - bounceCurve * 0.12) : 1.0;
          final pressScale = (1 - (_press.value * 0.04)) * elasticFactor;

          final morphT = Curves.easeInOutCubic.transform(_morph.value);
          final w = lerpDouble(widget.width, circleSize, morphT);
          final isRound = phase != PillButtonPhase.idle && phase != PillButtonPhase.collapsing;

          final halo = 0.18 + 0.3 * (0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi * (Motion.shimmerPeriod.inMilliseconds / Motion.haloPulsePeriod.inMilliseconds)));

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
                          color: widget.accent.withValues(alpha: phase == PillButtonPhase.idle ? halo : 0.35),
                          blurRadius: phase == PillButtonPhase.loading ? 30 : 24,
                          spreadRadius: phase == PillButtonPhase.loading ? 3 : 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: phase == PillButtonPhase.idle ? _buildShimmer() : null,
                  ),

                  // Label et flèche > (s'effacent au clic)
                  if (phase == PillButtonPhase.idle || phase == PillButtonPhase.collapsing)
                    Opacity(
                      opacity: (1 - morphT * 2.2).clamp(0.0, 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.onAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (widget.showArrow) ...[
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: Offset(math.sin(_loop.value * math.pi * 2) * 2.5, 0),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: widget.onAccent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Disque vinyle miniature avec anneau de lumière 360° (Proposition 1)
                  if (phase == PillButtonPhase.loading && isRound)
                    CustomPaint(
                      size: Size(circleSize * 0.65, circleSize * 0.65),
                      painter: _VinylSonicPulsePainter(
                        spin: _vinylSpin.value,
                        pulse: _loop.value,
                        accentColor: widget.accent,
                      ),
                    ),

                  // Checkmark de succès
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

/// Peintre du disque vinyle / gyroscope aéronautique avec anneau de lumière néon à 360°
class _VinylSonicPulsePainter extends CustomPainter {
  final double spin; // 0..1 rotation
  final double pulse; // 0..1 pulsation
  final Color accentColor;

  _VinylSonicPulsePainter({
    required this.spin,
    required this.pulse,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Fond sombre du disque vinyle / instrument de bord
    final discPaint = Paint()
      ..color = const Color(0xFF0A0F1D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, discPaint);

    // 2. Micro-sillons concentriques du disque vinyle
    final groovePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.75, groovePaint);
    canvas.drawCircle(center, radius * 0.55, groovePaint);
    canvas.drawCircle(center, radius * 0.38, groovePaint);

    // 3. Anneau de lumière néon rotatif à 360° (Sweep Gradient)
    final angle = spin * 2 * math.pi;
    final sweepShader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        const Color(0xFF00E5FF).withValues(alpha: 0.0),
        const Color(0xFF0284C7).withValues(alpha: 0.3),
        const Color(0xFFFF2A6D).withValues(alpha: 0.7), // Touche néon crimson
        const Color(0xFF00E5FF), // Brillance cyan éclatante
      ],
      stops: const [0.0, 0.45, 0.85, 1.0],
      transform: GradientRotation(angle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final ringPaint = Paint()
      ..shader = sweepShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 1.5, ringPaint);

    // 4. Point lumineux de tête (halo brillant qui tourne)
    final headOffset = Offset(
      center.dx + (radius - 1.5) * math.cos(angle),
      center.dy + (radius - 1.5) * math.sin(angle),
    );
    final headGlow = Paint()
      ..color = const Color(0xFF00E5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(headOffset, 3.5, headGlow);

    final headCore = Paint()..color = Colors.white;
    canvas.drawCircle(headOffset, 2.0, headCore);

    // 5. Noyau central (spindle) avec pulsation sonore
    final pulseScale = 1.0 + 0.25 * math.sin(pulse * 2 * math.pi);
    final centerGlowPaint = Paint()
      ..color = const Color(0xFFFF2A6D).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, 5.0 * pulseScale, centerGlowPaint);

    final centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _VinylSonicPulsePainter oldDelegate) =>
      oldDelegate.spin != spin || oldDelegate.pulse != pulse;
}

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
