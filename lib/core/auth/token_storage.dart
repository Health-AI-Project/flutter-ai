import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  static String? _tokenCache;
  static String? _userIdCache;

  static String? get cachedToken => _tokenCache;

  /// À appeler une fois au démarrage pour pré-charger le token depuis le disque.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = prefs.getString(_tokenKey);
    _userIdCache = prefs.getString(_userIdKey);
  }

  static Future<void> save(String token, {String? userId}) async {
    _tokenCache = token;
    _userIdCache = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (userId != null) await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> get() async {
    if (_tokenCache != null) return _tokenCache;
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = prefs.getString(_tokenKey);
    return _tokenCache;
  }

  static Future<String?> getUserId() async {
    if (_userIdCache != null) return _userIdCache;
    final prefs = await SharedPreferences.getInstance();
    _userIdCache = prefs.getString(_userIdKey);
    return _userIdCache;
  }

  static Future<void> clear() async {
    _tokenCache = null;
    _userIdCache = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }
}
