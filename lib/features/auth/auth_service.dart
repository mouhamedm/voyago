import 'package:shared_preferences/shared_preferences.dart';

/// Service persistant pour l'état d'authentification de l'utilisateur.
/// Conserve la session même après actualisation ou redémarrage de l'application.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _kLoggedInKey = 'voyago_is_logged_in';
  static const String _kUserEmailKey = 'voyago_user_email';
  static const String _kUserNameKey = 'voyago_user_name';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLoggedIn {
    return _prefs?.getBool(_kLoggedInKey) ?? false;
  }

  String get userEmail {
    return _prefs?.getString(_kUserEmailKey) ?? 'alexandre.vance@voyago.com';
  }

  String get userName {
    return _prefs?.getString(_kUserNameKey) ?? 'Alexandre Vance';
  }

  Future<void> saveLogin({required String email, String? name}) async {
    await init();
    await _prefs?.setBool(_kLoggedInKey, true);
    await _prefs?.setString(_kUserEmailKey, email);
    if (name != null) {
      await _prefs?.setString(_kUserNameKey, name);
    }
  }

  Future<void> logout() async {
    await init();
    await _prefs?.setBool(_kLoggedInKey, false);
  }
}
