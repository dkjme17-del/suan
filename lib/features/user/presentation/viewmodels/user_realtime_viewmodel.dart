import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suan/shared/services/firebase_service.dart';
import 'package:suan/shared/services/firebase_auth_service.dart';
import 'package:suan/core/utils/logger.dart';

/// ViewModel pour les données en temps réel de l'utilisateur
class UserRealtimeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _userId = '';
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  String get userId => _userId;
  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Valeurs par défaut cohérentes
  int get totalPoints => _userData['stats']?['totalPoints'] ?? 0;
  int get level => _userData['level'] ?? 1;
  int get streakDays => _userData['stats']?['currentStreak'] ?? 0;
  String get username =>
      _userData['username'] ?? _userData['displayName'] ?? 'Apprenant';
  String get email => _userData['email'] ?? '';
  String get avatar =>
      _userData['avatar'] ?? _userData['profile']?['avatar'] ?? '👤';
  String get bio => _userData['bio'] ?? _userData['profile']?['bio'] ?? '';

  // Stats from nested structure
  int get lessonsCompleted => _userData['stats']?['lessonsCompleted'] ?? 0;
  int get quizzesCompleted => _userData['stats']?['quizzesCompleted'] ?? 0;
  double get averageScore =>
      (_userData['stats']?['averageLessonScore'] ?? 0.0).toDouble();

  /// Constructeur - pas d'auto-initialisation pour éviter setState during build
  UserRealtimeViewModel() {
    // L'initialisation sera faite de manière lazy quand nécessaire
  }

  /// Initialisation lazy - appelée seulement quand nécessaire
  Future<void> ensureInitialized() async {
    if (_userId.isEmpty && !_isLoading) {
      await _initialize();
    }
  }

  /// Auto-initialisation avec l'ID utilisateur Firebase actuel
  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUserId = _authService.getCurrentUserId();
      if (currentUserId != null && currentUserId.isNotEmpty) {
        _userId = currentUserId;
        Logger.info(
          '🔄 UserRealtimeViewModel initialisé avec userId: $_userId',
        );
      } else {
        Logger.warning('⚠️ Aucun utilisateur connecté');
        _errorMessage = 'Aucun utilisateur connecté';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      Logger.error('❌ Erreur initialisation UserRealtimeViewModel', e);
      _errorMessage = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialiser avec l'ID utilisateur (si fourni explicitement)
  void initialize(String userId) {
    if (userId.isNotEmpty) {
      _userId = userId;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Rafraîchir les données utilisateur
  Future<void> refresh() async {
    await _initialize();
  }

  /// Stream du profil utilisateur en temps réel
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile() {
    if (_userId.isEmpty) {
      // Retourner un stream d'erreur simulé
      return Stream.error('Aucun utilisateur connecté');
    }

    Logger.info('📡 Création du stream pour userId: $_userId');
    return _firebaseService.streamUserProfile(_userId);
  }

  /// Mettre à jour les données locales depuis un snapshot
  void updateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      _userData = snapshot.data()!;
      _errorMessage = null;
      Logger.info('✅ Données profil mises à jour: $username');
    } else {
      _errorMessage = 'Profil non trouvé';
      Logger.warning('⚠️ Profil non trouvé pour userId: $_userId');
    }
    notifyListeners();
  }

  /// Mettre à jour les statistiques
  Future<void> updateStats({
    required int totalPoints,
    required int lessonsCompleted,
    required int quizzesCompleted,
    required int streakDays,
  }) async {
    if (_userId.isEmpty) {
      Logger.error('❌ Impossible de mettre à jour: userId vide');
      return;
    }

    try {
      await _firebaseService.updateUserStats(
        userId: _userId,
        totalPoints: totalPoints,
        lessonsCompleted: lessonsCompleted,
        quizzesCompleted: quizzesCompleted,
        streakDays: streakDays,
      );

      // Mettre à jour le leaderboard
      await _firebaseService.updateLeaderboard(
        userId: _userId,
        username: username,
        totalPoints: totalPoints,
        level: level,
      );

      Logger.info('✅ Stats mises à jour avec succès');
      notifyListeners();
    } catch (e) {
      Logger.error('❌ Erreur mise à jour stats: $e');
      _errorMessage = 'Erreur de mise à jour: $e';
      notifyListeners();
    }
  }

  /// Débloquer un achievement
  Future<void> unlockAchievement({
    required String achievementId,
    required String title,
    String? description,
  }) async {
    if (_userId.isEmpty) {
      Logger.error('❌ Impossible de débloquer achievement: userId vide');
      return;
    }

    try {
      await _firebaseService.unlockAchievement(
        userId: _userId,
        achievementId: achievementId,
        title: title,
        description: description,
      );
      Logger.info('✅ Achievement débloqué: $title');
      notifyListeners();
    } catch (e) {
      Logger.error('❌ Erreur déblocage achievement: $e');
      _errorMessage = 'Erreur: $e';
      notifyListeners();
    }
  }

  /// Stream des achievements
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAchievements() {
    if (_userId.isEmpty) {
      return const Stream.empty();
    }
    return _firebaseService.streamUserAchievements(_userId);
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _userId.isNotEmpty;

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
