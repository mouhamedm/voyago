/// Service en mémoire pour la session utilisateur active.
/// Gère le profil de l'utilisateur connecté ou le statut invité ("Passer").
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String _userEmail = '';
  String _userName = 'Mouhamed Dicko';
  bool _isLoggedIn = false;
  bool _isGuest = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get userEmail => _userEmail;
  String get userName => _userName;

  Future<void> saveLogin({required String email, String? name}) async {
    _isLoggedIn = true;
    _isGuest = false;
    _userEmail = email;
    if (name != null && name.isNotEmpty) {
      _userName = name;
    }
  }

  Future<void> saveGuestLogin() async {
    _isLoggedIn = true;
    _isGuest = true;
    _userEmail = '';
    _userName = 'Mouhamed Dicko';
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isGuest = false;
    _userEmail = '';
  }
}
