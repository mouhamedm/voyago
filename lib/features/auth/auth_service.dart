/// Service en mémoire pour la session utilisateur active.
/// Ne persiste PAS la connexion après rechargement ou redémarrage de l'application.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String _userEmail = 'alexandre.vance@voyago.com';
  String _userName = 'Alexandre Vance';
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get userName => _userName;

  Future<void> saveLogin({required String email, String? name}) async {
    _isLoggedIn = true;
    _userEmail = email;
    if (name != null) {
      _userName = name;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
  }
}
