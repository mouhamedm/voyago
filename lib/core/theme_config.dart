import 'package:flutter/material.dart';

/// Les 3 univers de voyage disponibles pour le flow d'entrée.
enum TravelTheme { plane, boat, car }

/// ---------------------------------------------------------------------
/// POUR CHANGER DE THEME : modifie uniquement la ligne ci-dessous.
/// ---------------------------------------------------------------------
const TravelTheme kAppTheme = TravelTheme.plane;

/// Type de décor animé affiché derrière le véhicule (parallax 3 couches).
enum DecorStyle { clouds, waves, road }

/// Configuration complète d'un thème : palette, copy, décor, véhicule.
/// Rien n'est écrit en dur ailleurs dans le flow : tout part de cette classe.
class ThemeConfig {
  final TravelTheme theme;
  final String brandName;
  final String slogan;
  final String welcomeTitle; // 2 lignes séparées par \n
  final String welcomeSubtitle;
  final String ctaLabel;

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color accent;
  final Color secondary;

  final DecorStyle decor;

  final bool isLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color surfaceGlass;
  final Color surfaceBorder;
  final Color cardBackground;

  const ThemeConfig._({
    required this.theme,
    required this.brandName,
    required this.slogan,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.ctaLabel,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.accent,
    required this.secondary,
    required this.decor,
    this.isLight = false,
    this.textPrimary = Colors.white,
    this.textSecondary = const Color(0xB3FFFFFF),
    this.textMuted = const Color(0x66FFFFFF),
    this.surfaceGlass = const Color(0x14FFFFFF),
    this.surfaceBorder = const Color(0x1EFFFFFF),
    this.cardBackground = const Color(0x0FFFFFFF),
  });

  static const ThemeConfig _plane = ThemeConfig._(
    theme: TravelTheme.plane,
    brandName: 'VOYAGO',
    slogan: 'L\'excellence du voyage',
    welcomeTitle: 'Le ciel vous\nappartient enfin',
    welcomeSubtitle: 'Des voyages sur-mesure d\'une pureté absolue, partout dans le monde.',
    ctaLabel: 'Commencer',
    backgroundTop: Color(0xFFDCEBFA),
    backgroundBottom: Color(0xFFFFFFFF),
    accent: Color(0xFF0F4C81),
    secondary: Color(0xFF0284C7),
    decor: DecorStyle.clouds,
    isLight: true,
    textPrimary: Color(0xFF0B192C),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    surfaceGlass: Color(0xCCFFFFFF),
    surfaceBorder: Color(0x1A0F4C81),
    cardBackground: Color(0xFFFFFFFF),
  );

  static const ThemeConfig _boat = ThemeConfig._(
    theme: TravelTheme.boat,
    brandName: 'MARINA',
    slogan: 'Suivez le courant',
    welcomeTitle: 'L\'horizon commence\nau bord de l\'eau',
    welcomeSubtitle: 'Des croisières sur-mesure, loin du tumulte.',
    ctaLabel: 'Embarquer',
    backgroundTop: Color(0xFF04151F),
    backgroundBottom: Color(0xFF0A4D68),
    accent: Color(0xFF2EE6C5),
    secondary: Color(0xFF7FE3D8),
    decor: DecorStyle.waves,
  );

  static const ThemeConfig _car = ThemeConfig._(
    theme: TravelTheme.car,
    brandName: 'ROUTARD',
    slogan: 'La route est à vous',
    welcomeTitle: 'Chaque virage\nest une histoire',
    welcomeSubtitle: 'Louez, roulez, explorez sans limite de kilomètres.',
    ctaLabel: 'Démarrer',
    backgroundTop: Color(0xFF0D0A1F),
    backgroundBottom: Color(0xFF2B1055),
    accent: Color(0xFFFF3D81),
    secondary: Color(0xFFC79CFF),
    decor: DecorStyle.road,
  );

  static ThemeConfig of(TravelTheme theme) {
    switch (theme) {
      case TravelTheme.plane:
        return _plane;
      case TravelTheme.boat:
        return _boat;
      case TravelTheme.car:
        return _car;
    }
  }

  /// Instance active de l'application, dérivée de [kAppTheme].
  static final ThemeConfig current = ThemeConfig.of(kAppTheme);

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: isLight ? const [0.0, 0.45, 1.0] : null,
        colors: isLight
            ? [backgroundTop, const Color(0xFFF0F6FD), backgroundBottom]
            : [backgroundTop, backgroundBottom],
      );
}
