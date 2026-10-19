import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/animated_button.dart';
import '../home/home_screen.dart';
import 'auth_controller.dart';
import 'auth_service.dart';

/// Page de connexion dédiée :
/// Redirection après avoir cliqué sur "Commencer" avec le spinner rotatif.
/// Propose :
/// - Formulaire Email / Mot de passe élégant
/// - Validation instantanée via AuthController
/// - Bouton "Accéder" avec le même spinner vinyle/gyro 360° et coche de succès
/// - Lien vers la page Accueil une fois connecté
class LoginScreen extends StatefulWidget {
  final ThemeConfig config;
  const LoginScreen({super.key, required this.config});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'mouhamed@voyago.app');
  final _passwordController = TextEditingController(text: 'password123');
  final _accederKey = GlobalKey<PillActionButtonState>();
  final _auth = AuthController();

  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final validation = _auth.validate(email: email, password: password);
    if (validation != null) {
      setState(() {
        _errorMessage = validation.emailError ?? validation.passwordError;
      });
      _accederKey.currentState?.reset();
      return;
    }

    setState(() => _errorMessage = null);
    await _accederKey.currentState?.triggerElasticBounce();
    await _accederKey.currentState?.collapse(withLoader: true);

    final result = await _auth.login(email: email, password: password);
    if (!mounted) return;

    if (!result.ok) {
      setState(() => _errorMessage = 'Identifiants invalides');
      _accederKey.currentState?.reset();
      return;
    }

    await AuthService.instance.saveLogin(email: email, name: 'Mouhamed Dicko');
    await _accederKey.currentState?.playSuccess();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(config: widget.config),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  void _continueAsGuest() {
    AuthService.instance.saveLogin(email: 'invite@voyago.app', name: 'Mouhamed Dicko');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(config: widget.config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070C1E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fond aile d'avion avec filtre sombre
          Image.asset(
            'assets/aile-avion.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF070C1E).withValues(alpha: 0.85),
                  const Color(0xFF0B132B).withValues(alpha: 0.94),
                  const Color(0xFF070C1E).withValues(alpha: 0.98),
                ],
              ),
            ),
          ),

          // 2. Contenu formulaire
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre supérieure : Retour < et Logo
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/logo-avion-en-papier.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VOYAGO',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Titres
                  Text(
                    'Bon retour,',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connectez-vous pour retrouver vos réservations, vos miles et vos escales favorites.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Carte formulaire
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Champ Email
                        Text(
                          'Adresse email',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                            hintText: 'ex. mouhamed@voyago.app',
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF1E293B).withValues(alpha: 0.7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Champ Mot de passe
                        Text(
                          'Mot de passe',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            hintText: 'Votre mot de passe',
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF1E293B).withValues(alpha: 0.7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),

                        // Message d'erreur éventuel
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Un lien de réinitialisation a été envoyé.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Bouton d'action "Accéder" avec le spinner rotatif
                        Center(
                          child: PillActionButton(
                            key: _accederKey,
                            label: 'Accéder',
                            accent: const Color(0xFF2563EB),
                            width: MediaQuery.of(context).size.width - 48 - 44,
                            height: 52,
                            showArrow: true,
                            onPressed: _handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Option "Continuer en tant qu'invité"
                  Center(
                    child: TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        'Explorer l\'application en tant qu\'invité →',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
