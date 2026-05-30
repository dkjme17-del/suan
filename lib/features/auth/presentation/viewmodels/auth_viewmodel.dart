import 'package:flutter/material.dart';
import 'package:suan/shared/services/firebase_auth_service.dart';
import 'package:suan/shared/services/auth_service.dart';
import 'package:suan/shared/services/firebase_initialization_service.dart';

import 'package:suan/features/learning/domain/entities/user.dart';

/// ViewModel pour l'authentification (Firebase + Local)
class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService? firebaseAuthService;
  final AuthService? localAuthService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _useFirebase = true; // Utiliser Firebase par défaut
  
  // Subscription au stream de l'utilisateur pour les mises à jour en temps réel
  dynamic _userStreamSubscription;

  AuthViewModel({
    this.firebaseAuthService,
    this.localAuthService,
  });

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isLoggedIn {
    if (_useFirebase && firebaseAuthService != null) {
      return firebaseAuthService!.isLoggedIn();
    }
    return localAuthService?.isLoggedIn() ?? false;
  }

  // Effacer le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // S'abonner au stream du profil utilisateur (mises à jour en temps réel)
  void _subscribeToUserStream() {
    if (_useFirebase && firebaseAuthService != null) {
      // Canceller l'ancienne subscription s'il en existe une
      _userStreamSubscription?.cancel();
      
      // S'abonner au stream de l'utilisateur
      _userStreamSubscription = 
        firebaseAuthService!.streamCurrentUser().listen(
          (user) {
            if (user != null) {
              _currentUser = user;
              print('📊 Profil mis à jour: ${user.name} - Points: ${user.totalPoints} - Niveau: ${user.currentLevel}');
              notifyListeners();
            }
          },
          onError: (error) {
            print('❌ Erreur stream profil: $error');
          },
        );
    }
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    if (_useFirebase && firebaseAuthService != null) {
      _currentUser = firebaseAuthService!.getCurrentUser();
    } else if (localAuthService != null) {
      _currentUser = localAuthService!.getCurrentUser();
    }
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = false;
      
      if (_useFirebase && firebaseAuthService != null) {
        success = await firebaseAuthService!.registerWithEmail(
          name: name,
          email: email,
          password: password,
        );
      } else if (localAuthService != null) {
        success = await localAuthService!.register(name, email, password);
      }

      if (success) {
        if (_useFirebase && firebaseAuthService != null) {
          _currentUser = firebaseAuthService!.getCurrentUser();
          // S'abonner au stream pour les mises à jour en temps réel du profil
          _subscribeToUserStream();
          // Initialiser les données Firestore après inscription
          await FirebaseInitializationService().initializeFirebaseData();
        } else if (localAuthService != null) {
          _currentUser = localAuthService!.getCurrentUser();
        }
      }
      return success;
    } catch (e) {
      // Extraire le message d'erreur sans "Exception: "
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      _error = errorMessage;
      print('❌ Erreur inscription: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = false;
      
      if (_useFirebase && firebaseAuthService != null) {
        success = await firebaseAuthService!.loginWithEmail(
          email: email,
          password: password,
        );
      } else if (localAuthService != null) {
        success = await localAuthService!.login(email, password);
      }

      if (success) {
        if (_useFirebase && firebaseAuthService != null) {
          _currentUser = firebaseAuthService!.getCurrentUser();
          // Initialiser les données Firestore après connexion
          await FirebaseInitializationService().initializeFirebaseData();
          // S'abonner au stream pour les mises à jour en temps réel du profil
          _subscribeToUserStream();
        } else if (localAuthService != null) {
          _currentUser = localAuthService!.getCurrentUser();
        }
      }
      return success;
    } catch (e) {
      // Extraire le message d'erreur sans "Exception: "
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      _error = errorMessage;
      print('❌ Erreur connexion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_useFirebase && firebaseAuthService != null) {
      await firebaseAuthService!.logout();
    } else {
      await localAuthService?.logout();
    }
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateUserLearningMode(String mode) async {
    if (_currentUser == null) return false;
    
    _currentUser = _currentUser!.copyWith(learningMode: mode);
    
    if (_useFirebase && firebaseAuthService != null) {
      return await firebaseAuthService!.updateUserProfile(
        userId: _currentUser!.id,
        learningMode: mode,
      );
    } else {
      final success = await localAuthService?.updateProfile(_currentUser!) ?? false;
      notifyListeners();
      return success;
    }
  }

  Future<bool> updateUserLevel(String level) async {
    if (_currentUser == null) return false;
    
    _currentUser = _currentUser!.copyWith(currentLevel: level);
    
    if (_useFirebase && firebaseAuthService != null) {
      return await firebaseAuthService!.updateUserProfile(
        userId: _currentUser!.id,
        currentLevel: level,
      );
    } else {
      final success = await localAuthService?.updateProfile(_currentUser!) ?? false;
      notifyListeners();
      return success;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (_useFirebase && firebaseAuthService != null) {
      return await firebaseAuthService!.resetPassword(email);
    }
    return false;
  }

  /// Mettre à jour les statistiques de l'utilisateur
  Future<void> updateUserStats({
    int? totalPoints,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
  }) async {
    if (_currentUser == null) return;
    
    if (_useFirebase && firebaseAuthService != null) {
      await firebaseAuthService!.updateUserStats(
        userId: _currentUser!.id,
        totalPoints: totalPoints,
        currentLevel: currentLevel,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
      // Le stream va automatiquement notifier les changements
    }
  }

  /// Ajouter des points à l'utilisateur
  Future<void> addPoints(int points) async {
    if (_currentUser == null) return;
    
    final newTotal = (_currentUser?.totalPoints ?? 0) + points;
    await updateUserStats(totalPoints: newTotal);
  }

  /// Augmenter la série actuelle
  Future<void> increaseStreak() async {
    if (_currentUser == null) return;
    
    final newStreak = (_currentUser?.currentStreak ?? 0) + 1;
    await updateUserStats(currentStreak: newStreak);
  }

  /// Réinitialiser la série (ex: après une pause)
  Future<void> resetStreak() async {
    if (_currentUser == null) return;
    
    await updateUserStats(currentStreak: 0);
  }
}
