import 'storage_service.dart';
import 'package:suan/features/learning/domain/entities/user.dart';

class AuthService {
  final StorageService storageService;

  AuthService({required this.storageService});

  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // Inscription
  Future<bool> register(String name, String email, String password) async {
    try {
      // Dans une vraie app, faire un appel API
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        learningMode: 'classic',
        currentLevel: 'beginner',
        createdAt: DateTime.now(),
      );

      await storageService.saveJson(_userKey, user.toJson());
      await storageService.saveString(_tokenKey, 'token_${user.id}');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      // Dans une vraie app, faire un appel API
      if (email.isEmpty || password.isEmpty) return false;

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@')[0],
        email: email,
        learningMode: 'classic',
        currentLevel: 'beginner',
        createdAt: DateTime.now(),
      );

      await storageService.saveJson(_userKey, user.toJson());
      await storageService.saveString(_tokenKey, 'token_${user.id}');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Récupère l'utilisateur connecté
  User? getCurrentUser() {
    final data = storageService.getJson(_userKey);
    if (data == null) return null;
    return User.fromJson(data);
  }

// Vérifie si l'utilisateur est connecté
  bool isLoggedIn() {
    return storageService.containsKey(_tokenKey);
  }

// Déconnexion
  Future<void> logout() async {
    await storageService.remove(_userKey);
    await storageService.remove(_tokenKey);
  }

// Récupère le token
  String? getToken() {
    return storageService.getString(_tokenKey);
  }

// Met à jour le profil
  Future<bool> updateProfile(User user) async {
    try {
      await storageService.saveJson(_userKey, user.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}


