import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Centralise toutes les durées et courbes du flow d'entrée.
/// Aucune durée/courbe magique ne doit être écrite ailleurs dans le code.
class Motion {
  Motion._();

  // ---------------------------------------------------------------------
  // Courbes communes
  // ---------------------------------------------------------------------
  static const Curve entrance = Curves.easeOutExpo;
  static const Curve travel = Curves.easeInOutCubic;
  static const Curve pop = Curves.easeOutBack;
  static const Curve exitFast = Curves.easeInExpo;
  static const Curve linear = Curves.linear;

  /// Simulation ressort partagée par toutes les cartes/feuilles qui "poppent".
  static SpringSimulation spring(double start, double end, {double velocity = 0}) {
    const spring = SpringDescription(mass: 1, stiffness: 180, damping: 18);
    return SpringSimulation(spring, start, end, velocity);
  }

  // ---------------------------------------------------------------------
  // SEQUENCE 1 — Preloader (durée totale 3.2 s)
  // ---------------------------------------------------------------------
  static const Duration preloaderTotal = Duration(milliseconds: 3200);
  // Intervalles exprimés en fraction de [preloaderTotal] pour le controller maître.
  static const double preloaderLogoStart = 0.0;
  static const double preloaderLogoEnd = 0.4 / 3.2;
  static const double preloaderFlightStart = 0.4 / 3.2;
  static const double preloaderFlightEnd = 2.6 / 3.2;
  static const double preloaderExitStart = 2.6 / 3.2;
  static const double preloaderExitEnd = 1.0;

  static const int preloaderLetterStaggerMs = 40;
  static const double preloaderLetterSlide = 24;

  static const Duration vehicleBobPeriod = Duration(milliseconds: 900);
  static const double vehicleBobAmplitude = 3;
  static const double vehicleBobRotationDeg = 2;

  static const Duration flashDuration = Duration(milliseconds: 250);
  static const double flashPeakOpacity = 0.35;

  static const double trailGlowBlurSigma = 6;

  // ---------------------------------------------------------------------
  // SEQUENCE 2 — Welcome
  // ---------------------------------------------------------------------
  static const Duration vehicleEntrance = Duration(milliseconds: 800);
  static const Duration vehicleIdlePeriod = Duration(milliseconds: 2400);
  static const double vehicleIdleAmplitude = 6;
  static const double vehicleIdleRotationDeg = 1.5;

  static const Duration titleWordDuration = Duration(milliseconds: 700);
  static const int titleWordStaggerMs = 90;
  static const Duration subtitleDelay = Duration(milliseconds: 500);
  static const Duration subtitleDuration = Duration(milliseconds: 500);
  static const double subtitleSlide = 16;

  static const Duration ctaDelay = Duration(milliseconds: 900);
  static const Duration ctaPopDuration = Duration(milliseconds: 420);
  static const Duration haloPulsePeriod = Duration(milliseconds: 1600);
  static const Duration shimmerPeriod = Duration(seconds: 3);
  static const Duration ctaPressDuration = Duration(milliseconds: 80);

  static const double decorParallaxDrag = 10;

  // ---------------------------------------------------------------------
  // SEQUENCE 3 — Welcome -> Login (900 ms chorégraphiés)
  // ---------------------------------------------------------------------
  static const Duration welcomeToLoginTotal = Duration(milliseconds: 900);
  static const double ctaCollapseStart = 0 / 900;
  static const double ctaCollapseEnd = 200 / 900;
  static const double headlineExitStart = 100 / 900;
  static const double headlineExitEnd = 600 / 900;
  static const double vehicleTurnStart = 150 / 900;
  static const double vehicleTurnEnd = 700 / 900;
  static const double cardRiseStart = 300 / 900;
  static const double cardRiseEnd = 900 / 900;
  static const int loginFieldStaggerMs = 90;
  static const double headlineExitSlide = 40;
  static const double vehicleTurnAngleDeg = 15;
  static const double vehicleTurnScale = 0.7;

  static const double glassBlurSigma = 18;
  static const double glassFillOpacity = 0.08;
  static const double glassBorderOpacity = 0.15;
  static const double glassRadius = 28;

  static const Duration fieldFocusGlow = Duration(milliseconds: 220);
  static const Duration fieldShake = Duration(milliseconds: 350);
  static const double fieldShakeOffset = 8;
  static const double fieldSlide = 20;

  // ---------------------------------------------------------------------
  // SEQUENCE 4 — Login -> Home (ouverture, 2.4 s)
  // ---------------------------------------------------------------------
  static const Duration openingTotal = Duration(milliseconds: 2400);
  static const double loaderMorphStart = 0 / 2400;
  static const double loaderMorphEnd = 300 / 2400;
  static const Duration mockAuthDelay = Duration(milliseconds: 1500);
  static const double successStart = 1500 / 2400;
  static const double successEnd = 1900 / 2400;
  static const double takeoffStart = 1700 / 2400;
  static const double takeoffEnd = 2400 / 2400;
  static const double revealStart = 1500 / 2400;
  static const double revealEnd = 2400 / 2400;

  static const Duration checkmarkDuration = Duration(milliseconds: 400);
  static const int successParticleCount = 12;
  static const Duration takeoffDuration = Duration(milliseconds: 700);
  static const Duration circularRevealDuration = Duration(milliseconds: 900);
  static const double cardSuckScale = 0.9;
  static const double cardSuckTranslateY = -60;

  static const double engineVibrateAmplitude = 1;
  static const Duration engineVibratePeriod = Duration(milliseconds: 60);

  // ---------------------------------------------------------------------
  // SEQUENCE 5 — Home opening
  // ---------------------------------------------------------------------
  static const Duration homeRevealDelay = Duration(milliseconds: 300);
  static const Duration headerEntrance = Duration(milliseconds: 600);
  static const double headerSlide = 30;
  static const Duration avatarPopDuration = Duration(milliseconds: 420);
  static const Duration searchBarExpand = Duration(milliseconds: 700);
  static const Duration cardStagger = Duration(milliseconds: 100);
  static const double cardSlide = 40;
  static const double cardScaleFrom = 0.96;
  static const Duration counterDuration = Duration(milliseconds: 900);
  static const Duration bottomNavEntrance = Duration(milliseconds: 500);

  // ---------------------------------------------------------------------
  // Divers
  // ---------------------------------------------------------------------
  static const Duration hapticDebounce = Duration(milliseconds: 40);

  /// Durée totale indicative du flow complet filmé (preloader -> home animée).
  static const Duration totalFlowTarget = Duration(seconds: 10, milliseconds: 500);

  /// Accessibilité : préférence système "réduire les animations".
  /// Lu directement depuis la plate-forme pour rester utilisable dans les
  /// `initState()` (où `MediaQuery.of(context)` n'est pas encore valide).
  static bool get reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
}
