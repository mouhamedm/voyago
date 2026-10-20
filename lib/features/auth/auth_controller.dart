import '../../core/motion.dart';

/// Résultat d'une tentative d'authentification.
class AuthResult {
  final bool ok;
  final String? emailError;
  final String? passwordError;

  const AuthResult._(this.ok, {this.emailError, this.passwordError});

  const AuthResult.success() : this._(true);

  const AuthResult.failure({String? emailError, String? passwordError})
      : this._(false, emailError: emailError, passwordError: passwordError);

  bool get hasError => emailError != null || passwordError != null;
}

/// Contrôleur d'authentification. Pour l'instant entièrement mocké
/// (Future.delayed) afin de piloter la chorégraphie de la séquence 4.
///
/// Pour brancher Firebase Auth plus tard : remplacer le corps de [login]
/// par un appel à `FirebaseAuth.instance.signInWithEmailAndPassword(...)`
/// et convertir les `FirebaseAuthException` en [AuthResult.failure].
class AuthController {
  /// Validation synchrone, jouée avant de lancer la chorégraphie d'ouverture
  /// (évite de démarrer l'animation de 2.4 s si les champs sont invalides).
  AuthResult? validate({required String email, required String password}) {
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    if (emailError != null || passwordError != null) {
      return AuthResult.failure(emailError: emailError, passwordError: passwordError);
    }
    return null;
  }

  Future<AuthResult> login({required String email, required String password}) async {
    await Future.delayed(Motion.mockAuthDelay);
    return const AuthResult.success();
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return 'Entrez votre email';
    if (!value.contains('@') || !value.contains('.')) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Entrez votre mot de passe';
    if (value.length < 4) return 'Mot de passe trop court';
    return null;
  }
}
