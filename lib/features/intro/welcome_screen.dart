import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion.dart';
import '../../core/theme_config.dart';
import '../../shared/painters/vehicle_painter.dart';
import '../../shared/widgets/animated_button.dart';
import '../../shared/widgets/circular_reveal_route.dart';
import '../../shared/widgets/scene_decor.dart';
import '../../shared/widgets/staggered_reveal.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/login_sheet.dart';
import '../home/home_screen.dart';

/// Séquences 2, 3 et 4 : écran d'accueil vivant, transition vers le login,
/// puis chorégraphie d'ouverture vers la Home. Les 3 séquences partagent le
/// même décor et le même véhicule pour une continuité visuelle totale.
class WelcomeScreen extends StatefulWidget {
  final ThemeConfig config;
  const WelcomeScreen({super.key, required this.config});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _clock; // horloge libre : décor + idle bob
  late final AnimationController _entrance; // séquence 2 : arrivée du véhicule + titre + CTA
  late final AnimationController _toLogin; // séquence 3 : welcome -> login (900 ms)
  late final AnimationController _opening; // séquence 4 : login -> home (2400 ms)
  late final AnimationController _pulseRipple; // Proposition 1 : onde lumineuse diffuse depuis le bouton

  final _ctaKey = GlobalKey<PillActionButtonState>();
  final _accederKey = GlobalKey<PillActionButtonState>();
  final _loginKey = GlobalKey<LoginSheetState>();
  final _auth = AuthController();

  bool _showLogin = false;
  bool _openingStarted = false;
  Offset _drag = Offset.zero;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 1000))..repeat();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _toLogin = AnimationController(vsync: this, duration: Motion.welcomeToLoginTotal);
    _opening = AnimationController(vsync: this, duration: Motion.openingTotal);
    _pulseRipple = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reduceMotion = Motion.reduceMotion;
      if (_reduceMotion) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    _entrance.dispose();
    _toLogin.dispose();
    _opening.dispose();
    _pulseRipple.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // Séquence 3 : tap sur "Commencer" (Proposition 1 : The Vinyl & Sonic Pulse)
  // -------------------------------------------------------------------
  Future<void> _handleStart() async {
    _ctaKey.currentState?.triggerElasticBounce();
    _pulseRipple.forward(from: 0);
    setState(() => _showLogin = true);
    _ctaKey.currentState?.collapse(withLoader: true);
    _toLogin.forward(from: 0);
  }

  // -------------------------------------------------------------------
  // Séquence 4 : tap sur "Accéder"
  // -------------------------------------------------------------------
  Future<void> _handleSubmit(String email, String password) async {
    final error = _auth.validate(email: email, password: password);
    if (error != null) {
      _loginKey.currentState?.showErrors(emailError: error.emailError, passwordError: error.passwordError);
      return;
    }

    setState(() => _openingStarted = true);
    _loginKey.currentState?.setSubmitting(true);
    _accederKey.currentState?.collapse(withLoader: true);
    _opening.forward(from: 0);

    final result = await _auth.login(email: email, password: password);
    if (!mounted) return;

    if (!result.ok) {
      _accederKey.currentState?.reset();
      _loginKey.currentState?.setSubmitting(false);
      _opening.reset();
      setState(() => _openingStarted = false);
      return;
    }

    await AuthService.instance.saveLogin(email: email);
    await _accederKey.currentState?.playSuccess();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _pushHome();
  }

  void _pushHome() {
    final box = _accederKey.currentContext?.findRenderObject() as RenderBox?;
    final center = box != null
        ? box.localToGlobal(box.size.center(Offset.zero))
        : Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    Navigator.of(context).push(
      CircularRevealRoute(page: HomeScreen(config: widget.config), center: center),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _drag = Offset(
            (_drag.dx + details.delta.dx * 0.3).clamp(-Motion.decorParallaxDrag, Motion.decorParallaxDrag),
            (_drag.dy + details.delta.dy * 0.3).clamp(-Motion.decorParallaxDrag, Motion.decorParallaxDrag),
          );
        });
      },
      onPanEnd: (_) => setState(() => _drag = Offset.zero),
      child: AnimatedBuilder(
        animation: Listenable.merge([_clock, _entrance, _toLogin, _opening, _pulseRipple]),
        builder: (context, _) {
          final time = _clock.value * 1000;
          // Proposition 1 : Zoom & Fade cinématographique en 3D lors du passage à la suite
          final zoomT = Curves.easeInOutCubic.transform(_toLogin.value);
          final sceneScale = 1.0 - 0.07 * zoomT;
          final sceneDy = -20.0 * zoomT;
          final sceneOpacity = (1.0 - 0.22 * zoomT).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Scène d'onboarding avec recul 3D et fade cinématographique
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective 3D
                  ..scaleByDouble(sceneScale, sceneScale, 1.0, 1.0)
                  ..setTranslationRaw(0.0, sceneDy, 0.0),
                child: Opacity(
                  opacity: sceneOpacity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: _drag,
                        child: RepaintBoundary(child: SceneDecor(config: config, time: time)),
                      ),
                      _buildVehicle(config, time),
                      _buildHeadline(config),
                    ],
                  ),
                ),
              ),

              // Onde lumineuse (pulse ripple) se diffusant depuis le bouton vers le fond
              if (_pulseRipple.value > 0 && _pulseRipple.value < 1)
                _buildPulseRipple(config),

              if (!_showLogin || _toLogin.value < 1) _buildCta(config),
              if (_showLogin) _buildLoginOverlay(config),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Véhicule : idle (séq.2) -> virage (séq.3) -> retour centre + décollage (séq.4)
  // -------------------------------------------------------------------
  Widget _buildVehicle(ThemeConfig config, double time) {
    final size = MediaQuery.of(context).size;
    final entranceT = Curves.easeOutCubic.transform(
      Interval(0, Motion.vehicleEntrance.inMilliseconds / 1400, curve: Curves.linear).transform(_entrance.value),
    );

    // Pose de repos (séquence 2) : légèrement à gauche, idle bob.
    final idlePhase = (time / Motion.vehicleIdlePeriod.inMilliseconds) * 2 * math.pi;
    final idleDy = _reduceMotion ? 0.0 : math.sin(idlePhase) * Motion.vehicleIdleAmplitude;
    final idleRot = _reduceMotion ? 0.0 : math.sin(idlePhase) * (Motion.vehicleIdleRotationDeg * math.pi / 180);
    final restCenter = Offset(size.width * 0.5, size.height * 0.34);
    final entranceOffsetX = (1 - entranceT) * -size.width * 0.6;

    var center = restCenter + Offset(entranceOffsetX, idleDy);
    var scale = 1.0;
    var rotation = idleRot;
    var opacity = entranceT;

    // Séquence 3 : virage vers le haut-gauche, rétrécit à 70%.
    final turnT = Interval(Motion.vehicleTurnStart, Motion.vehicleTurnEnd, curve: Motion.travel).transform(_toLogin.value);
    final turnedCenter = Offset(size.width * 0.22, size.height * 0.16);
    final afterTurnCenter = Offset.lerp(restCenter, turnedCenter, turnT)!;
    final afterTurnScale = lerpD(1.0, Motion.vehicleTurnScale, turnT);
    final afterTurnRot = lerpD(0, Motion.vehicleTurnAngleDeg * math.pi / 180, turnT);

    if (_toLogin.value > 0) {
      center = afterTurnCenter + Offset(0, idleDy * 0.3);
      scale = afterTurnScale;
      rotation = idleRot * 0.3 + afterTurnRot;
    }

    // Séquence 4 : retour au centre + grossissement, puis décollage.
    if (_openingStarted) {
      final returnT = Interval(Motion.loaderMorphEnd, Motion.successStart, curve: Motion.travel).transform(_opening.value);
      final homeCenter = Offset(size.width * 0.5, size.height * 0.4);
      final grownCenter = Offset.lerp(afterTurnCenter, homeCenter, returnT)!;
      final grownScale = lerpD(Motion.vehicleTurnScale, 1.25, returnT);
      final grownRot = lerpD(afterTurnRot, 0, returnT);

      final vibrateT = Interval(Motion.loaderMorphEnd, Motion.successEnd, curve: Curves.linear).transform(_opening.value);
      final vibrate = vibrateT > 0 && vibrateT < 1
          ? math.sin(time / Motion.engineVibratePeriod.inMilliseconds * 2 * math.pi) * Motion.engineVibrateAmplitude
          : 0.0;

      final takeoffT = Interval(Motion.takeoffStart, Motion.takeoffEnd, curve: Motion.exitFast).transform(_opening.value);
      final dir = const Offset(1, -1.2);
      final norm = dir / dir.distance;

      center = grownCenter + Offset(vibrate, vibrate) + norm * (takeoffT * size.longestSide * 1.2);
      scale = grownScale * (1 - takeoffT * 0.1);
      rotation = grownRot + takeoffT * 0.4;
      opacity = takeoffT > 0.7 ? (1 - (takeoffT - 0.7) / 0.3).clamp(0.0, 1.0) : 1.0;
    }

    const vehicleBaseSize = Size(96, 60);
    return Positioned(
      left: center.dx - (vehicleBaseSize.width * scale) / 2,
      top: center.dy - (vehicleBaseSize.height * scale) / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: RepaintBoundary(
              child: CustomPaint(
                size: vehicleBaseSize,
                painter: VehiclePainter(theme: config.theme, bodyColor: Colors.white, accent: config.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Titre + sous-titre (révélés en séquence 2, s'effacent en séquence 3)
  // -------------------------------------------------------------------
  Widget _buildHeadline(ThemeConfig config) {
    final exitT = Interval(Motion.headlineExitStart, Motion.headlineExitEnd, curve: Motion.travel).transform(_toLogin.value);
    return Positioned(
      left: 28,
      right: 28,
      top: MediaQuery.of(context).size.height * 0.52,
      child: Opacity(
        opacity: (1 - exitT).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -exitT * Motion.headlineExitSlide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaskedWordsReveal(
                parent: _entrance,
                text: config.welcomeTitle,
                style: GoogleFonts.spaceGrotesk(
                  color: config.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              _subtitle(config),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subtitle(ThemeConfig config) {
    final startFraction = Motion.subtitleDelay.inMilliseconds / 1400;
    final span = Motion.subtitleDuration.inMilliseconds / 1400;
    final anim = staggerSlice(_entrance, startFraction: startFraction, span: span, curve: Motion.entrance);
    final t = anim.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, Motion.subtitleSlide * (1 - t)),
        child: Text(
          config.welcomeSubtitle,
          style: TextStyle(
            color: config.textSecondary,
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // CTA "Commencer"
  // -------------------------------------------------------------------
  Widget _buildCta(ThemeConfig config) {
    final startFraction = Motion.ctaDelay.inMilliseconds / 1400;
    final span = Motion.ctaPopDuration.inMilliseconds / 1400;
    final anim = staggerSlice(_entrance, startFraction: startFraction, span: span, curve: Motion.pop);
    final t = anim.value.clamp(0.0, 1.0);
    final exitT = Interval(Motion.ctaCollapseStart, Motion.ctaCollapseEnd, curve: Curves.easeIn).transform(_toLogin.value);
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).size.height * 0.08,
      child: Opacity(
        opacity: (t * (1 - exitT)).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.8 + 0.2 * t,
          child: Center(
            child: PillActionButton(
              key: _ctaKey,
              label: config.ctaLabel,
              accent: config.accent,
              onPressed: _handleStart,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Carte de login (séquence 3/4)
  // -------------------------------------------------------------------
  Widget _buildLoginOverlay(ThemeConfig config) {
    final takeoffT = _openingStarted
        ? Interval(Motion.takeoffStart, Motion.takeoffEnd, curve: Motion.travel).transform(_opening.value)
        : 0.0;
    return Positioned(
      left: 20,
      right: 20,
      bottom: 28,
      child: Opacity(
        opacity: (1 - takeoffT).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, takeoffT * Motion.cardSuckTranslateY),
          child: Transform.scale(
            scale: lerpD(1.0, Motion.cardSuckScale, takeoffT),
            child: LoginSheet(
              key: _loginKey,
              config: config,
              accederKey: _accederKey,
              onSubmit: _handleSubmit,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Onde lumineuse diffuse (Pulse Ripple - Proposition 1)
  // -------------------------------------------------------------------
  Widget _buildPulseRipple(ThemeConfig config) {
    final bottomPadding = MediaQuery.of(context).size.height * 0.08 + 28;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: Center(
        child: CustomPaint(
          size: const Size(1, 1),
          painter: _PulseRippleWavePainter(
            progress: _pulseRipple.value,
            accent: config.accent,
          ),
        ),
      ),
    );
  }
}

class _PulseRippleWavePainter extends CustomPainter {
  final double progress; // 0..1
  final Color accent;

  _PulseRippleWavePainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset.zero;
    final t1 = progress.clamp(0.0, 1.0);
    final curve1 = Curves.easeOutCubic.transform(t1);

    // Onde 1 principale cyan/néon
    final radius1 = curve1 * 340.0;
    final opacity1 = (1.0 - curve1).clamp(0.0, 1.0);

    final glowPaint1 = Paint()
      ..color = accent.withValues(alpha: opacity1 * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * (1.0 - curve1 * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius1, glowPaint1);

    final linePaint1 = Paint()
      ..color = Colors.white.withValues(alpha: opacity1 * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius1, linePaint1);

    // Onde 2 en crimson/rose néon (décalée de 0.15)
    final t2 = (progress - 0.15) / 0.85;
    if (t2 > 0) {
      final curve2 = Curves.easeOutCubic.transform(t2.clamp(0.0, 1.0));
      final radius2 = curve2 * 260.0;
      final opacity2 = (1.0 - curve2).clamp(0.0, 1.0);

      final glowPaint2 = Paint()
        ..color = const Color(0xFFFF2A6D).withValues(alpha: opacity2 * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - curve2 * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius2, glowPaint2);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRippleWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

double lerpD(double a, double b, double t) => a + (b - a) * t;

