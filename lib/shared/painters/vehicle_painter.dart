import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme_config.dart';

/// Dessine le véhicule du thème actif (avion / bateau / voiture) avec des
/// [Path] vectoriels. Le véhicule est toujours dessiné "face à droite" :
/// l'orientation réelle (tangente de trajectoire) est appliquée par le
/// widget appelant via un `Transform.rotate`.
///
/// Emplacement prévu pour remplacer plus tard ce rendu vectoriel par une
/// animation Lottie / Rive : il suffit de substituer le widget qui enrobe
/// ce CustomPaint par un `Lottie.asset(...)` tout en gardant la même API
/// (taille, rotation, couleurs) exposée par [ThemeConfig].
class VehiclePainter extends CustomPainter {
  final TravelTheme theme;
  final Color bodyColor;
  final Color accent;
  final Color windowColor;

  VehiclePainter({
    required this.theme,
    required this.bodyColor,
    required this.accent,
    this.windowColor = const Color(0xCCFFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case TravelTheme.plane:
        _paintPlane(canvas, size);
      case TravelTheme.boat:
        _paintBoat(canvas, size);
      case TravelTheme.car:
        _paintCar(canvas, size);
    }
  }

  void _paintPlane(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. OMBRE PORTÉE SOUS L'AVION (Effet de lévitation 3D au-dessus des nuages)
    final shadowPaint = Paint()
      ..color = const Color(0x280B192C)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final shadowFuselage = Path()
      ..moveTo(w * 0.96, h * 0.54)
      ..quadraticBezierTo(w * 0.76, h * 0.45, w * 0.20, h * 0.50)
      ..quadraticBezierTo(w * 0.06, h * 0.52, w * 0.04, h * 0.54)
      ..quadraticBezierTo(w * 0.06, h * 0.56, w * 0.20, h * 0.58)
      ..quadraticBezierTo(w * 0.76, h * 0.63, w * 0.96, h * 0.54)
      ..close();
    canvas.drawPath(shadowFuselage, shadowPaint);

    // 2. RÉACTEURS / RÉACTEURS TURBOFAN (Nacelles sous les ailes)
    void drawEngine(double dy) {
      final engineRect = Rect.fromCenter(
        center: Offset(w * 0.48, dy),
        width: w * 0.22,
        height: h * 0.11,
      );
      final engineShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      ).createShader(engineRect);

      final enginePaint = Paint()..shader = engineShader;
      canvas.drawRRect(
        RRect.fromRectAndRadius(engineRect, Radius.circular(h * 0.05)),
        enginePaint,
      );

      // Entrée d'air réacteur (intake cone sombre)
      final intakePaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.58, dy), width: w * 0.025, height: h * 0.09),
        intakePaint,
      );

      // Tuyère d'échappement arrière avec lueur cyan subtile
      final exhaustPaint = Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(w * 0.37, dy), h * 0.025, exhaustPaint);
    }

    drawEngine(h * 0.26); // Réacteur gauche
    drawEngine(h * 0.74); // Réacteur droit

    // 3. AILES PRINCIPALES AVEC DÉGRADÉ MÉTALLISÉ ET WINGLETS
    final wingRect = Rect.fromLTWH(w * 0.30, 0, w * 0.42, h);
    final wingShader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFE2E8F0), Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
    ).createShader(wingRect);

    final wingPaint = Paint()..shader = wingShader;

    // Aile gauche (haut)
    final leftWing = Path()
      ..moveTo(w * 0.68, h * 0.44)
      ..lineTo(w * 0.46, h * 0.02)
      ..quadraticBezierTo(w * 0.43, h * 0.005, w * 0.38, h * 0.03)
      ..lineTo(w * 0.43, h * 0.45)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    // Aile droite (bas)
    final rightWing = Path()
      ..moveTo(w * 0.68, h * 0.56)
      ..lineTo(w * 0.46, h * 0.98)
      ..quadraticBezierTo(w * 0.43, h * 0.995, w * 0.38, h * 0.97)
      ..lineTo(w * 0.43, h * 0.55)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // Winglets bleu cobalt aux extrémités des ailes
    final wingletPaint = Paint()..color = accent;
    final leftWinglet = Path()
      ..moveTo(w * 0.46, h * 0.02)
      ..lineTo(w * 0.42, h * 0.005)
      ..lineTo(w * 0.39, h * 0.035)
      ..close();
    canvas.drawPath(leftWinglet, wingletPaint);

    final rightWinglet = Path()
      ..moveTo(w * 0.46, h * 0.98)
      ..lineTo(w * 0.42, h * 0.995)
      ..lineTo(w * 0.39, h * 0.965)
      ..close();
    canvas.drawPath(rightWinglet, wingletPaint);

    // Feux de navigation réglementaires (Rouge à bâbord / Vert à tribord)
    final redBeacon = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.40, h * 0.03), 2.2, redBeacon);
    final greenBeacon = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(w * 0.40, h * 0.97), 2.2, greenBeacon);

    // 4. EMPENNAGE ARRIÈRE (Stabilisateurs horizontaux)
    final tailPaint = Paint()..color = const Color(0xFFE2E8F0);
    final tailplane = Path()
      ..moveTo(w * 0.25, h * 0.45)
      ..lineTo(w * 0.08, h * 0.24)
      ..quadraticBezierTo(w * 0.05, h * 0.23, w * 0.06, h * 0.31)
      ..lineTo(w * 0.15, h * 0.47)
      ..close()
      ..moveTo(w * 0.25, h * 0.55)
      ..lineTo(w * 0.08, h * 0.76)
      ..quadraticBezierTo(w * 0.05, h * 0.77, w * 0.06, h * 0.69)
      ..lineTo(w * 0.15, h * 0.53)
      ..close();
    canvas.drawPath(tailplane, tailPaint);

    // 5. FUSELAGE 3D ÉLÉGANT (Dégradé cylindrique blanc pur satiné)
    final fuselageRect = Rect.fromLTWH(w * 0.04, h * 0.38, w * 0.94, h * 0.24);
    final fuselageShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.35, 0.75, 1.0],
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFFAFAFC),
        Color(0xFFE2E8F0),
        Color(0xFFCBD5E1),
      ],
    ).createShader(fuselageRect);

    final fuselagePaint = Paint()..shader = fuselageShader;

    final fuselage = Path()
      ..moveTo(w * 0.98, h * 0.50)
      ..quadraticBezierTo(w * 0.78, h * 0.39, w * 0.18, h * 0.44)
      ..quadraticBezierTo(w * 0.05, h * 0.46, w * 0.04, h * 0.50)
      ..quadraticBezierTo(w * 0.05, h * 0.54, w * 0.18, h * 0.56)
      ..quadraticBezierTo(w * 0.78, h * 0.61, w * 0.98, h * 0.50)
      ..close();
    canvas.drawPath(fuselage, fuselagePaint);

    // Liseré de livrée luxe bleu cobalt sur le flanc
    final liveryPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final liveryLine = Path()
      ..moveTo(w * 0.15, h * 0.51)
      ..lineTo(w * 0.80, h * 0.51);
    canvas.drawPath(liveryLine, liveryPaint);

    // Dérive arrière verticale stylisée (Aileron arrière bleu cobalt)
    final finPaint = Paint()..color = accent;
    final finPath = Path()
      ..moveTo(w * 0.20, h * 0.49)
      ..lineTo(w * 0.07, h * 0.47)
      ..lineTo(w * 0.04, h * 0.50)
      ..lineTo(w * 0.07, h * 0.53)
      ..lineTo(w * 0.20, h * 0.51)
      ..close();
    canvas.drawPath(finPath, finPaint);

    // 6. COCKPIT HAUTE BRILLANCE (Verre teinté avec reflet blanc)
    final cockpitRect = Rect.fromCenter(
      center: Offset(w * 0.85, h * 0.50),
      width: w * 0.09,
      height: h * 0.14,
    );
    final cockpitShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F172A), Color(0xFF0284C7)],
    ).createShader(cockpitRect);

    final cockpitPaint = Paint()..shader = cockpitShader;
    canvas.drawOval(cockpitRect, cockpitPaint);

    // Reflet spéculaire blanc sur le pare-brise
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.86, h * 0.48), width: w * 0.06, height: h * 0.08),
      math.pi * 0.8,
      math.pi * 0.5,
      false,
      specularPaint,
    );

    // 7. HUBLOTS PASSAGERS AVEC ÉCLAIRAGE SUBTIL
    final windowPaint = Paint()..color = const Color(0xFF0B192C).withValues(alpha: 0.7);
    for (final dx in [0.32, 0.40, 0.48, 0.56, 0.64, 0.72]) {
      canvas.drawCircle(Offset(w * dx, h * 0.485), h * 0.016, windowPaint);
    }
  }

  void _paintBoat(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = bodyColor;
    final accentPaint = Paint()..color = accent;

    // Coque.
    final hull = Path()
      ..moveTo(w * 0.05, h * 0.62)
      ..quadraticBezierTo(w * 0.15, h * 0.85, w * 0.45, h * 0.88)
      ..lineTo(w * 0.85, h * 0.88)
      ..quadraticBezierTo(w * 1.0, h * 0.84, w * 0.95, h * 0.62)
      ..close();
    canvas.drawPath(hull, body);

    // Cabine.
    final cabin = Path()
      ..moveTo(w * 0.40, h * 0.62)
      ..lineTo(w * 0.46, h * 0.38)
      ..lineTo(w * 0.70, h * 0.38)
      ..lineTo(w * 0.74, h * 0.62)
      ..close();
    canvas.drawPath(cabin, Paint()..color = bodyColor.withValues(alpha: 0.9));

    // Mât + voile (accent).
    canvas.drawLine(
      Offset(w * 0.30, h * 0.62),
      Offset(w * 0.30, h * 0.05),
      Paint()
        ..color = accent
        ..strokeWidth = size.height * 0.03,
    );
    final sail = Path()
      ..moveTo(w * 0.30, h * 0.08)
      ..quadraticBezierTo(w * 0.62, h * 0.22, w * 0.30, h * 0.52)
      ..close();
    canvas.drawPath(sail, accentPaint..color = accent.withValues(alpha: 0.9));

    // Vaguelette sous la coque.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.9),
      h * 0.05,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _paintCar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = bodyColor;
    final accentPaint = Paint()..color = accent;

    // Carrosserie.
    final chassis = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.42, w * 0.92, h * 0.34),
      Radius.circular(h * 0.14),
    );
    canvas.drawRRect(chassis, body);

    // Habitacle.
    final cabin = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..quadraticBezierTo(w * 0.30, h * 0.14, w * 0.52, h * 0.14)
      ..lineTo(w * 0.74, h * 0.14)
      ..quadraticBezierTo(w * 0.82, h * 0.16, w * 0.80, h * 0.42)
      ..close();
    canvas.drawPath(cabin, Paint()..color = bodyColor.withValues(alpha: 0.95));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.34, h * 0.40)
        ..quadraticBezierTo(w * 0.38, h * 0.22, w * 0.52, h * 0.22)
        ..lineTo(w * 0.70, h * 0.22)
        ..quadraticBezierTo(w * 0.76, h * 0.24, w * 0.75, h * 0.40)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );

    // Roues.
    final wheelPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(w * 0.24, h * 0.80), h * 0.16, wheelPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.80), h * 0.16, wheelPaint);
    canvas.drawCircle(
      Offset(w * 0.24, h * 0.80),
      h * 0.07,
      Paint()..color = accent,
    );
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.80),
      h * 0.07,
      Paint()..color = accent,
    );

    // Phare.
    canvas.drawCircle(Offset(w * 0.95, h * 0.56), h * 0.045, accentPaint);
  }

  @override
  bool shouldRepaint(covariant VehiclePainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.accent != accent ||
        oldDelegate.windowColor != windowColor;
  }
}
