import 'dart:math' as math;
import 'dart:ui' show Tangent;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion.dart';
import '../../core/theme_config.dart';
import '../../shared/painters/particles_painter.dart';
import '../../shared/painters/trail_painter.dart';
import '../../shared/painters/vehicle_painter.dart';

/// Séquence 1 : preloader (3.2 s). Un seul AnimationController maître pilote
/// toute la chorégraphie via des [Interval] : logo lettre par lettre,
/// trajectoire du véhicule en S (Bézier cubique) orientée par la tangente du
/// chemin, traînée lumineuse, pourcentage de chargement, puis sortie flash.
class PreloaderScreen extends StatefulWidget {
  final ThemeConfig config;
  final VoidCallback onComplete;

  const PreloaderScreen({super.key, required this.config, required this.onComplete});

  @override
  State<PreloaderScreen> createState() => PreloaderScreenState();
}

class PreloaderScreenState extends State<PreloaderScreen> with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _clock; // horloge libre pour particules/bobbing
  bool _done = false;

  Size? _cachedSize;
  late Path _flightPath;
  late double _pathLength;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 1000))..repeat();
    _master = AnimationController(vsync: this, duration: Motion.preloaderTotal);
    _master.addStatusListener(_handleStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reduce = Motion.reduceMotion;
      _master.duration = reduce ? const Duration(milliseconds: 500) : Motion.preloaderTotal;
      _master.forward();
    });
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_done) {
      _done = true;
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _master.removeStatusListener(_handleStatus);
    _master.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _ensurePath(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;
    final w = size.width, h = size.height;
    _flightPath = Path()
      ..moveTo(-w * 0.12, h * 0.56)
      ..cubicTo(w * 0.22, h * 0.14, w * 0.62, h * 0.86, w * 0.92, h * 0.42);
    _pathLength = _flightPath.computeMetrics().first.length;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _ensurePath(size);
        return AnimatedBuilder(
          animation: Listenable.merge([_master, _clock]),
          builder: (context, _) {
            final time = _clock.value * 1000;

            // --- Fenêtres temporelles de la chorégraphie -------------------
            final logoEnv = const Interval(Motion.preloaderLogoStart, Motion.preloaderLogoEnd, curve: Curves.linear)
                .transform(_master.value);
            final flightLinear = const Interval(
              Motion.preloaderFlightStart,
              Motion.preloaderFlightEnd,
              curve: Curves.linear,
            ).transform(_master.value);
            final flightEased = const Interval(
              Motion.preloaderFlightStart,
              Motion.preloaderFlightEnd,
              curve: Curves.easeInOutCubic,
            ).transform(_master.value);
            final exitT = const Interval(
              Motion.preloaderExitStart,
              Motion.preloaderExitEnd,
              curve: Curves.easeInExpo,
            ).transform(_master.value);
            final exitLinear = const Interval(
              Motion.preloaderExitStart,
              Motion.preloaderExitEnd,
              curve: Curves.linear,
            ).transform(_master.value);

            final isFlying = _master.value >= Motion.preloaderFlightStart && _master.value < Motion.preloaderExitStart;
            final hasExited = _master.value >= Motion.preloaderExitStart;

            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: ParticlesPainter(
                      time: time,
                      color: config.isLight ? config.secondary.withValues(alpha: 0.6) : Colors.white,
                    ),
                  ),
                ),
                if (flightEased > 0)
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: TrailPainter(
                        fullPath: _flightPath,
                        pathLength: _pathLength,
                        progress: hasExited ? 1 : flightEased,
                        color: config.secondary,
                      ),
                    ),
                  ),
                if (isFlying || hasExited)
                  _buildVehicle(config, size, flightEased, hasExited, exitT, time),
                _buildLogo(config, logoEnv, exitLinear),
                _buildPercent(config, flightLinear, exitLinear),
                _buildFlash(exitLinear),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVehicle(ThemeConfig config, Size size, double flightEased, bool hasExited, double exitT, double time) {
    final metric = _flightPath.computeMetrics().first;
    final clampedProgress = flightEased.clamp(0.0, 1.0);
    final tangent = metric.getTangentForOffset(clampedProgress * _pathLength) ??
        Tangent(Offset.zero, const Offset(1, 0));
    var position = tangent.position;
    var angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

    if (hasExited) {
      final dir = const Offset(1, -1.1);
      final norm = dir / dir.distance;
      final exitEase = Curves.easeInExpo.transform(exitT);
      position = position + norm * (exitEase * size.longestSide * 1.1);
      angle = _lerpAngle(angle, math.atan2(norm.dy, norm.dx), exitEase);
    } else {
      final elapsedMs = flightEased * (Motion.preloaderFlightEnd - Motion.preloaderFlightStart) * Motion.preloaderTotal.inMilliseconds;
      final bobPhase = (elapsedMs / Motion.vehicleBobPeriod.inMilliseconds) * 2 * math.pi;
      position = position + Offset(0, math.sin(bobPhase) * Motion.vehicleBobAmplitude);
      angle += math.sin(bobPhase) * (Motion.vehicleBobRotationDeg * math.pi / 180);
    }

    const vehicleSize = Size(64, 40);
    return Positioned(
      left: position.dx - vehicleSize.width / 2,
      top: position.dy - vehicleSize.height / 2,
      child: Opacity(
        opacity: hasExited ? (1 - exitT).clamp(0.0, 1.0) * 0.6 + 0.4 : 1,
        child: Transform.rotate(
          angle: angle,
          child: RepaintBoundary(
            child: CustomPaint(
              size: vehicleSize,
              painter: VehiclePainter(theme: config.theme, bodyColor: Colors.white, accent: config.accent),
            ),
          ),
        ),
      ),
    );
  }

  double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return a + diff * t;
  }

  Widget _buildLogo(ThemeConfig config, double logoEnv, double exitLinear) {
    final letters = config.brandName.split('');
    final exitFade = 1 - exitLinear;
    final exitRise = exitLinear * 40;
    return Align(
      alignment: const Alignment(0, -0.25),
      child: Opacity(
        opacity: exitFade.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -exitRise),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(letters.length, (i) {
              final start = (i * Motion.preloaderLetterStaggerMs) / Motion.preloaderTotal.inMilliseconds / Motion.preloaderLogoEnd;
              final letterAnim = Interval(start.clamp(0.0, 0.99), 1.0, curve: Motion.entrance).transform(logoEnv);
              return Opacity(
                opacity: letterAnim.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, Motion.preloaderLetterSlide * (1 - letterAnim)),
                  child: Text(
                    letters[i],
                    style: GoogleFonts.spaceGrotesk(
                      color: config.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPercent(ThemeConfig config, double flightLinear, double exitLinear) {
    final percent = (flightLinear.clamp(0.0, 1.0) * 100).round();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 56,
      child: Opacity(
        opacity: (1 - exitLinear).clamp(0.0, 1.0),
        child: Center(
          child: Text(
            '$percent%',
            style: GoogleFonts.robotoMono(
              color: config.textSecondary,
              fontSize: 42,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlash(double exitLinear) {
    // Flash blanc doux concentré sur les 250 premières ms de la sortie.
    final flashWindow = 250 / (Motion.preloaderTotal.inMilliseconds * (Motion.preloaderExitEnd - Motion.preloaderExitStart));
    final f = (exitLinear / flashWindow).clamp(0.0, 1.0);
    final opacity = f < 0.5 ? (f * 2) * Motion.flashPeakOpacity : (1 - (f - 0.5) * 2) * Motion.flashPeakOpacity;
    return IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(color: Colors.white),
      ),
    );
  }
}
