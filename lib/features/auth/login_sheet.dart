import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/motion.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/animated_button.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/staggered_reveal.dart';

/// Séquence 3/4 (partie formulaire) : carte glassmorphism contenant le
/// formulaire de connexion. Monte du bas avec un ressort (géré ici par un
/// seul AnimationController maître [_rise]), puis révèle son contenu en
/// cascade (stagger 90 ms). Le bouton "Accéder" est contrôlé depuis
/// l'extérieur (WelcomeScreen) via [accederKey] pour orchestrer la
/// séquence 4 (loader -> succès -> décollage) sur l'ensemble de l'écran.
class LoginSheet extends StatefulWidget {
  final ThemeConfig config;
  final GlobalKey<PillActionButtonState> accederKey;
  final void Function(String email, String password) onSubmit;

  const LoginSheet({
    super.key,
    required this.config,
    required this.accederKey,
    required this.onSubmit,
  });

  @override
  State<LoginSheet> createState() => LoginSheetState();
}

class LoginSheetState extends State<LoginSheet> with TickerProviderStateMixin {
  late final AnimationController _rise;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFieldKey = GlobalKey<_AnimatedFieldState>();
  final _passwordFieldKey = GlobalKey<_AnimatedFieldState>();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rise = AnimationController(vsync: this, upperBound: 1.4);
    if (Motion.reduceMotion) {
      _rise.value = 1;
    } else {
      _rise.animateWith(Motion.spring(0, 1));
    }
  }

  @override
  void dispose() {
    _rise.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void setSubmitting(bool value) => setState(() => _submitting = value);

  void showErrors({String? emailError, String? passwordError}) {
    _emailFieldKey.currentState?.setError(emailError);
    _passwordFieldKey.currentState?.setError(passwordError);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return AnimatedBuilder(
      animation: _rise,
      builder: (context, _) {
        final envelope = _rise.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: envelope,
          child: Transform.translate(
            offset: Offset(0, (1 - _rise.value) * 120),
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _staggered(
                      envelope,
                      0,
                      'Bon retour',
                      child: Text(
                        'Bon retour',
                        style: TextStyle(
                          color: config.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _staggered(
                      envelope,
                      1,
                      'subtitle',
                      child: Text(
                        'Connectez-vous pour continuer l\'aventure ${config.brandName}.',
                        style: TextStyle(color: config.textSecondary, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _staggered(
                      envelope,
                      2,
                      'email',
                      child: _AnimatedField(
                        key: _emailFieldKey,
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        accent: config.accent,
                        enabled: !_submitting,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _staggered(
                      envelope,
                      3,
                      'password',
                      child: _AnimatedField(
                        key: _passwordFieldKey,
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock_outline_rounded,
                        accent: config.accent,
                        obscurable: true,
                        enabled: !_submitting,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _staggered(
                      envelope,
                      4,
                      'cta',
                      child: Center(
                        child: PillActionButton(
                          key: widget.accederKey,
                          label: 'Accéder',
                          accent: config.accent,
                          width: 200,
                          onPressed: _submitting
                              ? null
                              : () => widget.onSubmit(_emailController.text, _passwordController.text),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _staggered(
                      envelope,
                      5,
                      'forgot',
                      child: Center(
                        child: TextButton(
                          onPressed: _submitting ? null : () {},
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(color: config.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _staggered(double envelope, int index, String debugLabel, {required Widget child}) {
    final anim = staggerSlice(
      AlwaysStoppedAnimation(envelope),
      startFraction: index * 0.09,
      span: 0.5,
      curve: Motion.travel,
    );
    final t = anim.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, Motion.fieldSlide * (1 - t)), child: child),
    );
  }
}

/// Champ de formulaire avec label flottant (natif Material), glow au focus,
/// pulse d'icône, et shake + message d'erreur en cas d'échec de validation.
class _AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accent;
  final bool obscurable;
  final bool enabled;

  const _AnimatedField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accent,
    this.obscurable = false,
    this.enabled = true,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> with TickerProviderStateMixin {
  late final AnimationController _focusGlow;
  late final AnimationController _iconPulse;
  late final AnimationController _shake;
  final _focusNode = FocusNode();
  String? _error;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusGlow = AnimationController(vsync: this, duration: Motion.fieldFocusGlow);
    _iconPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _shake = AnimationController(vsync: this, duration: Motion.fieldShake);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _focusGlow.forward();
      _iconPulse.forward(from: 0).then((_) => _iconPulse.reverse());
    } else {
      _focusGlow.reverse();
    }
  }

  void setError(String? error) {
    setState(() => _error = error);
    if (error != null) {
      HapticFeedback.selectionClick();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _focusGlow.dispose();
    _iconPulse.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AnimatedBuilder(
      animation: Listenable.merge([_focusGlow, _iconPulse, _shake]),
      builder: (context, _) {
        final shakeT = _shake.value;
        final dx = math.sin(shakeT * 3 * 2 * math.pi) * Motion.fieldShakeOffset * (1 - shakeT);
        final defaultBorder = isLight
            ? const Color(0xFFCBD5E1)
            : Colors.white.withValues(alpha: 0.18);
        final borderColor = hasError
            ? Colors.redAccent
            : Color.lerp(defaultBorder, widget.accent, _focusGlow.value)!;

        return Transform.translate(
          offset: Offset(dx, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (_focusGlow.value > 0 && !hasError)
                      BoxShadow(
                        color: widget.accent.withValues(alpha: (isLight ? 0.2 : 0.35) * _focusGlow.value),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscurable && _obscured,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF0F172A) : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    labelStyle: TextStyle(
                      color: isLight ? const Color(0xFF64748B) : Colors.white.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: isLight
                        ? const Color(0xFFF8FAFC)
                        : Colors.white.withValues(alpha: 0.06),
                    prefixIcon: Transform.scale(
                      scale: 1 + _iconPulse.value * 0.25,
                      child: Icon(
                        widget.icon,
                        color: hasError
                            ? Colors.redAccent
                            : (isLight ? const Color(0xFF475569) : Colors.white70),
                      ),
                    ),
                    suffixIcon: widget.obscurable
                        ? IconButton(
                            onPressed: () => setState(() => _obscured = !_obscured),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, anim) => RotationTransition(
                                turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: Icon(
                                _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                key: ValueKey(_obscured),
                                color: isLight ? const Color(0xFF475569) : Colors.white70,
                              ),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor, width: hasError ? 1.4 : 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor, width: 1.4),
                    ),
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: hasError
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
