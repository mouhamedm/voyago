import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/animated_button.dart';
import '../home/home_screen.dart';
import 'auth_controller.dart';
import 'auth_service.dart';

/// Page de connexion avec structure inspirée du mock-up :
/// - Fond (aile d'avion) visible en arrière-plan en haut (~30% de l'écran)
/// - Bouton retour '<' à gauche et bouton "Passer" à droite en haut
/// - Feuille / carte de connexion en bas avec poignée (grab handle)
/// - Sélecteur Connexion / Inscription
/// - Champ "Nom et prénom" visible en mode Inscription
/// - Animation de secousse (shake) et bordures rouges si champs non remplis
/// - Déclenchement instantané en temps réel du spinner blanc sans lag
/// - Boutons sociaux (Google, Apple) et "Continuer en tant qu'invité"
class LoginScreen extends StatefulWidget {
  final ThemeConfig config;
  const LoginScreen({super.key, required this.config});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _continuerKey = GlobalKey<PillActionButtonState>();
  final _auth = AuthController();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _showErrors = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final isNameEmpty = _isSignUp && name.isEmpty;
    final isEmailEmpty = email.isEmpty;
    final isPasswordEmpty = password.isEmpty;

    // 1. Validation de présence des champs : si vide, bordures rouges + secousse (shake)
    if (isNameEmpty || isEmailEmpty || isPasswordEmpty) {
      HapticFeedback.heavyImpact();
      setState(() {
        _showErrors = true;
        _errorMessage = 'Veuillez remplir tous les champs obligatoires';
      });
      _shakeController.forward(from: 0);
      _continuerKey.currentState?.reset();
      return;
    }

    // 2. Validation de format
    final validation = _auth.validate(email: email, password: password);
    if (validation != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _showErrors = true;
        _errorMessage = validation.emailError ?? validation.passwordError;
      });
      _shakeController.forward(from: 0);
      _continuerKey.currentState?.reset();
      return;
    }

    setState(() {
      _showErrors = false;
      _errorMessage = null;
    });

    // 3. Déclenchement instantané en temps réel du spinner blanc sans aucune seconde d'attente
    await _continuerKey.currentState?.collapse(withLoader: true);

    final result = await _auth.login(email: email, password: password);
    if (!mounted) return;

    if (!result.ok) {
      HapticFeedback.heavyImpact();
      setState(() {
        _showErrors = true;
        _errorMessage = 'Identifiants invalides';
      });
      _shakeController.forward(from: 0);
      _continuerKey.currentState?.reset();
      return;
    }

    await AuthService.instance.saveLogin(
      email: email,
      name: name.isNotEmpty ? name : 'Mouhamed Dicko',
    );
    await _continuerKey.currentState?.playSuccess();
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
    AuthService.instance.saveGuestLogin();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(config: widget.config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF070C1E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fond aile d'avion visible en arrière-plan
          Image.asset(
            'assets/aile-avion.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // 2. Dégradé sombre pour faire ressortir les boutons supérieurs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),


          // 4. Feuille de connexion en bas (occupant la partie inférieure)
          Column(
            children: [
              // Espace supérieur laissant voir le fond (~28% de la hauteur)
              SizedBox(height: (screenHeight * 0.28).clamp(100.0, 230.0)),

              // Carte / Sheet de connexion
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B132B).withValues(alpha: 0.94),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 36,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poignée supérieure (Grab handle)
                          Center(
                            child: Container(
                              width: 44,
                              height: 4.5,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),

                          // Sélecteur Sign In / Sign Up (Connexion / Inscription)
                          Container(
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = false;
                                        _showErrors = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: !_isSignUp ? const Color(0xFF2563EB) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: !_isSignUp
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                                                  blurRadius: 12,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Connexion',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = true;
                                        _showErrors = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _isSignUp ? const Color(0xFF2563EB) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: _isSignUp
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                                                  blurRadius: 12,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Inscription',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _isSignUp ? Colors.white : const Color(0xFF94A3B8),
                                          fontSize: 14,
                                          fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Titre & Sous-titre
                          Text(
                            _isSignUp ? 'Créez votre compte Voyago' : 'Bienvenue sur Voyago',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isSignUp
                                ? 'Renseignez vos informations pour embarquer'
                                : 'Entrez vos identifiants pour continuer votre voyage',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Bloc des champs avec animation de secousse (shake)
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value, 0),
                                child: child,
                              );
                            },
                            child: Column(
                              children: [
                                // Champ "Nom et prénom" (affiché uniquement en mode Inscription)
                                if (_isSignUp) ...[
                                  TextField(
                                    controller: _nameController,
                                    textCapitalization: TextCapitalization.words,
                                    onChanged: (_) {
                                      if (_showErrors) setState(() => _showErrors = false);
                                    },
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: (_showErrors && _nameController.text.trim().isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                      hintText: 'Nom et prénom',
                                      hintStyle: TextStyle(
                                        color: (_showErrors && _nameController.text.trim().isEmpty)
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: (_showErrors && _nameController.text.trim().isEmpty)
                                          ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                          : const Color(0xFF1E293B).withValues(alpha: 0.6),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: (_showErrors && _nameController.text.trim().isEmpty)
                                              ? const Color(0xFFEF4444)
                                              : Colors.white.withValues(alpha: 0.08),
                                          width: (_showErrors && _nameController.text.trim().isEmpty) ? 1.8 : 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: (_showErrors && _nameController.text.trim().isEmpty)
                                              ? const Color(0xFFEF4444)
                                              : Colors.white.withValues(alpha: 0.08),
                                          width: (_showErrors && _nameController.text.trim().isEmpty) ? 1.8 : 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: (_showErrors && _nameController.text.trim().isEmpty)
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF2563EB),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                // Champ "Adresse email"
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_showErrors) setState(() => _showErrors = false);
                                  },
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.alternate_email_rounded,
                                      color: (_showErrors && _emailController.text.trim().isEmpty)
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    hintText: 'Adresse email',
                                    hintStyle: TextStyle(
                                      color: (_showErrors && _emailController.text.trim().isEmpty)
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: (_showErrors && _emailController.text.trim().isEmpty)
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                        : const Color(0xFF1E293B).withValues(alpha: 0.6),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _emailController.text.trim().isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: (_showErrors && _emailController.text.trim().isEmpty) ? 1.8 : 1.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _emailController.text.trim().isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: (_showErrors && _emailController.text.trim().isEmpty) ? 1.8 : 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _emailController.text.trim().isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF2563EB),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Champ "Mot de passe"
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onChanged: (_) {
                                    if (_showErrors) setState(() => _showErrors = false);
                                  },
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: (_showErrors && _passwordController.text.isEmpty)
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    hintText: 'Mot de passe',
                                    hintStyle: TextStyle(
                                      color: (_showErrors && _passwordController.text.isEmpty)
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: (_showErrors && _passwordController.text.isEmpty)
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                        : const Color(0xFF1E293B).withValues(alpha: 0.6),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _passwordController.text.isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: (_showErrors && _passwordController.text.isEmpty) ? 1.8 : 1.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _passwordController.text.isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: (_showErrors && _passwordController.text.isEmpty) ? 1.8 : 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (_showErrors && _passwordController.text.isEmpty)
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF2563EB),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFFCA5A5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Ligne "Se souvenir de moi" et "Mot de passe oublié ?"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    Icon(
                                      _rememberMe ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: _rememberMe ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Se souvenir de moi',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Un lien de réinitialisation a été envoyé.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Mot de passe oublié ?',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bouton principal d'action avec le spinner blanc instantané
                          Center(
                            child: PillActionButton(
                              key: _continuerKey,
                              label: 'Continuer',
                              accent: const Color(0xFF2563EB),
                              width: MediaQuery.of(context).size.width - 48,
                              height: 52,
                              showArrow: true,
                              onPressed: _handleLogin,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Ligne de séparation "Ou continuer avec"
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Ou continuer avec',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Boutons de connexion sociale : Google & Apple
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'G',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.apple, color: Colors.white, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Apple',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Option "Continuer en tant qu'invité"
                          Center(
                            child: TextButton(
                              onPressed: _continueAsGuest,
                              child: Text(
                                'Continuer en tant qu\'invité',
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
                ),
              ),
            ],
          ),

          // 3. Barre supérieure : Bouton retour '<' à gauche et 'Passer' à droite
          Positioned(
            top: topPadding + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton retour rond
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),

                // Bouton "Passer" (Skip)
                GestureDetector(
                  onTap: _continueAsGuest,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'Passer',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
