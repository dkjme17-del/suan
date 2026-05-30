import 'package:flutter/foundation.dart';
import '../../../../shared/services/user_statistics_service.dart';
import '../../../../core/utils/logger.dart';

/// ViewModel pour gérer les statistiques utilisateur
class UserStatisticsViewModel extends ChangeNotifier {
  final UserStatisticsService _statisticsService = UserStatisticsService();
  
  // État
  Map<String, dynamic> _userStats = {};
  bool _isLoading = false;
  String? _error;
  
  // Classement
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoadingLeaderboard = false;
  
  // Getters
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  
  // Getters calculés
  int get level => _userStats['level'] ?? 1;
  int get totalPoints => _userStats['totalPoints'] ?? 0;
  int get lessonsCompleted => _userStats['lessonsCompleted'] ?? 0;
  int get quizzesCompleted => _userStats['quizzesCompleted'] ?? 0;
  int get dailyChallengesCompleted => _userStats['dailyChallengesCompleted'] ?? 0;
  double get averageLessonScore => (_userStats['averageLessonScore'] as num?)?.toDouble() ?? 0.0;
  double get averageQuizScore => (_userStats['averageQuizScore'] as num?)?.toDouble() ?? 0.0;
  double get quizAccuracy => ((_userStats['quizAccuracy'] as num?)?.toDouble() ?? 0.0) * 100;
  int get currentStreak => _userStats['currentStreak'] ?? 0;
  int get longestStreak => _userStats['longestStreak'] ?? 0;
  int get totalTimeSpent => _userStats['totalTimeSpent'] ?? 0;
  
  /// Charge les statistiques de l'utilisateur
  Future<void> loadUserStatistics(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final stats = await _statisticsService.getUserStatistics(userId);
      _userStats = stats;
      
      Logger.info('✅ Statistiques utilisateur chargées');
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques';
      Logger.error('❌ Erreur chargement stats utilisateur', e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Charge le classement
  Future<void> loadLeaderboard({int limit = 10}) async {
    try {
      _isLoadingLeaderboard = true;
      notifyListeners();
      
      final leaderboard = await _statisticsService.getLeaderboard(limit: limit);
      _leaderboard = leaderboard;
      
      Logger.info('✅ Classement chargé');
    } catch (e) {
      Logger.error('❌ Erreur chargement classement', e);
    } finally {
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }
  
  /// Met à jour les statistiques après une leçon
  Future<void> updateLessonStats({
    required String userId,
    required String lessonId,
    required bool completed,
    required int score,
    required Duration timeSpent,
  }) async {
    try {
      await _statisticsService.updateLessonStats(
        userId: userId,
        lessonId: lessonId,
        completed: completed,
        score: score,
        timeSpent: timeSpent,
      );
      
      // Mettre à jour le niveau
      await _statisticsService.updateUserLevel(userId);
      
      // Recharger les statistiques
      await loadUserStatistics(userId);
      
      Logger.info('✅ Stats leçon mises à jour avec succès');
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des statistiques';
      Logger.error('❌ Erreur mise à jour stats leçon', e);
      notifyListeners();
    }
  }
  
  /// Met à jour les statistiques après un quiz
  Future<void> updateQuizStats({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required Duration timeSpent,
  }) async {
    try {
      await _statisticsService.updateQuizStats(
        userId: userId,
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        timeSpent: timeSpent,
      );
      
      // Mettre à jour le niveau
      await _statisticsService.updateUserLevel(userId);
      
      // Recharger les statistiques
      await loadUserStatistics(userId);
      
      Logger.info('✅ Stats quiz mises à jour avec succès');
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des statistiques';
      Logger.error('❌ Erreur mise à jour stats quiz', e);
      notifyListeners();
    }
  }
  
  /// Met à jour les statistiques après un défi quotidien
  Future<void> updateDailyChallengeStats({
    required String userId,
    required String challengeId,
    required bool completed,
    required int pointsEarned,
  }) async {
    try {
      await _statisticsService.updateDailyChallengeStats(
        userId: userId,
        challengeId: challengeId,
        completed: completed,
        pointsEarned: pointsEarned,
      );
      
      // Mettre à jour le niveau
      await _statisticsService.updateUserLevel(userId);
      
      // Recharger les statistiques
      await loadUserStatistics(userId);
      
      Logger.info('✅ Stats défi quotidien mises à jour avec succès');
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des statistiques';
      Logger.error('❌ Erreur mise à jour stats défi quotidien', e);
      notifyListeners();
    }
  }
  
  /// Met à jour la dernière activité de l'utilisateur
  Future<void> updateLastActivity(String userId) async {
    try {
      await _statisticsService.updateLastActivity(userId);
    } catch (e) {
      Logger.error('❌ Erreur mise à jour dernière activité', e);
    }
  }
  
  /// Calcule la progression vers le prochain niveau
  Map<String, dynamic> getLevelProgress() {
    final currentLevelPoints = (level - 1) * 100;
    final nextLevelPoints = level * 100;
    final currentPoints = totalPoints;
    
    final pointsInCurrentLevel = currentPoints - currentLevelPoints;
    final pointsNeededForNextLevel = nextLevelPoints - currentLevelPoints;
    final progress = pointsNeededForNextLevel > 0 
        ? pointsInCurrentLevel / pointsNeededForNextLevel 
        : 1.0;
    
    return {
      'currentLevel': level,
      'nextLevel': level + 1,
      'currentPoints': currentPoints,
      'pointsNeededForNextLevel': pointsNeededForNextLevel,
      'pointsInCurrentLevel': pointsInCurrentLevel,
      'progress': progress.clamp(0.0, 1.0),
    };
  }
  
  /// Calcule les badges débloqués
  List<String> getUnlockedBadges() {
    final badges = <String>[];
    
    // Badge débutant
    if (lessonsCompleted >= 1) badges.add('Première Leçon');
    
    // Badge quiz master
    if (quizzesCompleted >= 5) badges.add('Quiz Master');
    
    // Badge streak
    if (currentStreak >= 7) badges.add('Semaine Parfaite');
    
    // Badge points
    if (totalPoints >= 500) badges.add('Collectionneur de Points');
    
    // Badge précision
    if (quizAccuracy >= 80) badges.add('Précision Exceptionnelle');
    
    // Badge temps
    if (totalTimeSpent >= 120) badges.add('Apprenti Dévoué');
    
    return badges;
  }
  
  /// Calcule le rang dans le classement
  int getLeaderboardRank() {
    if (_leaderboard.isEmpty) return -1;
    
    for (int i = 0; i < _leaderboard.length; i++) {
      if (_leaderboard[i]['userId'] == _userStats['userId']) {
        return i + 1;
      }
    }
    return -1;
  }
  
  /// Réinitialise l'état
  void reset() {
    _userStats = {};
    _leaderboard = [];
    _error = null;
    _isLoading = false;
    _isLoadingLeaderboard = false;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Correction : notifier après le build pour éviter l'exception Flutter
    Future.microtask(() => notifyListeners());
  }
}
