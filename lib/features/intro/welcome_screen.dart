import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/animated_button.dart';
import '../auth/login_screen.dart';

/// Écran 1 (Onboarding / Welcome) :
/// Fidèle à la première capture d'écran :
/// - Fond : assets/aile-avion.png
/// - Logo : assets/logo-avion-en-papier.png + VOYAGO + "Explorez le monde, plus facilement."
/// - Titre : "Le ciel vous attend" (avec "attend" en bleu éclatant #2563EB)
/// - Sous-titre : "Trouvez et réservez vos vols en quelques secondes, vers plus de  destinations."
/// - Indicateurs 4 points
/// - Bouton "Commencer →" animé avec rebond élastique et spinner rotatif vinyle/gyro 360°
class WelcomeScreen extends StatefulWidget {
  final ThemeConfig config;
  const WelcomeScreen({super.key, required this.config});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final _commencerKey = GlobalKey<PillActionButtonState>();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onCommencer() async {
    if (_isNavigating) return;
    _isNavigating = true;

    // Déclenchement instantané en temps réel du spinner blanc dès le clic
    await _commencerKey.currentState?.collapse(withLoader: true);

    // Bref délai pour apprécier la rotation fluide du spinner blanc
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // 4. Glissement latéral fluide et soyeux (Droite ➔ Gauche) sans coupure
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(config: widget.config),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );

    // Réinitialise le bouton au retour de la page de connexion
    if (mounted) {
      _isNavigating = false;
      _commencerKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image de fond : aile-avion.png
          Image.asset(
            'assets/aile-avion.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // 2. Dégradés atmosphériques pour lisibilité optimale
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25, 0.45, 0.75, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  const Color(0xFF0B132B).withValues(alpha: 0.75),
                  const Color(0xFF070C1E).withValues(alpha: 0.98),
                ],
              ),
            ),
          ),

          // 3. Contenu au premier plan
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SUPÉRIEUR ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo-avion-en-papier.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VOYAGO',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                            ),
                          ),
                          Text(
                            'Explorez le monde, plus facilement.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // --- SECTION INFÉRIEURE ANIMÉE ---
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre : "Le ciel\nvous attend"
                          Text(
                            'Le ciel',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'vous ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'attend',
                                  style: TextStyle(color: Color(0xFF3B82F6)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Sous-titre
                          Text(
                            'Trouvez et réservez vos vols en quelques secondes, vers plus de  destinations.',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Indicateur 4 points
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Bouton "Commencer →" animé avec rebond élastique et spinner rotatif 360°
                          Center(
                            child: PillActionButton(
                              key: _commencerKey,
                              label: 'Commencer',
                              accent: const Color(0xFF2563EB),
                              onAccent: Colors.white,
                              width: MediaQuery.of(context).size.width - 48,
                              height: 56,
                              showArrow: true,
                              onPressed: _onCommencer,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
