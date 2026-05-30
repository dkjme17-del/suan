import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/utils/logger.dart';

/// Service pour la gamification avancée avec Firestore
///
/// Gère en temps réel:
/// - Achievements visuels enrichis
/// - Badges et trophées
/// - Défis quotidiens avancés
/// - Systèmes de récompenses

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de tous les achievements en temps réel
  Stream<List<Map<String, dynamic>>> streamAchievements() {
    return _firestore
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        })
        .handleError((error) {
          Logger.error('Erreur achievements', error);
          return [];
        });
  }

  /// Stream les achievements d'un utilisateur
  Stream<List<Map<String, dynamic>>> streamUserAchievements(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        })
        .handleError((error) {
          Logger.error('Erreur user achievements', error);
          return [];
        });
  }

  /// Stream les badges d'un utilisateur
  Stream<List<Map<String, dynamic>>> streamUserBadges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        })
        .handleError((error) {
          Logger.error('Erreur user badges', error);
          return [];
        });
  }

  /// Vérifier et déverrouiller achievements basés sur les statistiques
  Future<void> checkAndUnlockAchievements({
    required String userId,
    required int totalPoints,
    required int lessonsCompleted,
    required int quizzesCompleted,
    required int currentStreak,
    required int longestStreak,
  }) async {
    try {
      final Map<String, bool> achievementsToUnlock = {};

      // Achievements basés sur les points
      if (totalPoints >= 1000) achievementsToUnlock['points_1000'] = true;
      if (totalPoints >= 5000) achievementsToUnlock['points_5000'] = true;
      if (totalPoints >= 10000) achievementsToUnlock['points_10000'] = true;

      // Achievements basés sur les leçons
      if (lessonsCompleted >= 10) achievementsToUnlock['lessons_10'] = true;
      if (lessonsCompleted >= 50) achievementsToUnlock['lessons_50'] = true;
      if (lessonsCompleted >= 100) achievementsToUnlock['lessons_100'] = true;

      // Achievements basés sur les quiz
      if (quizzesCompleted >= 25) achievementsToUnlock['quiz_25'] = true;
      if (quizzesCompleted >= 50) achievementsToUnlock['quiz_50'] = true;

      // Achievements basés sur les streaks
      if (currentStreak >= 3) achievementsToUnlock['streak_3'] = true;
      if (currentStreak >= 7) achievementsToUnlock['streak_7'] = true;
      if (longestStreak >= 30) achievementsToUnlock['streak_30'] = true;

      // Sauvegarder les achievements déverrouillés
      for (var entry in achievementsToUnlock.entries) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc(entry.key)
            .set({
              'unlockedAt': FieldValue.serverTimestamp(),
              'isUnlocked': true,
            }, SetOptions(merge: true));
      }

      Logger.info('Achievements vérifiés pour user: $userId');
    } catch (e) {
      Logger.error('Erreur vérification achievements', e);
    }
  }

  /// Complète un défi quotidien
  Future<void> completeDailyChallenge({
    required String userId,
    required String challengeId,
    required int pointsEarned,
  }) async {
    try {
      await _firestore.collection('user_daily_challenges').add({
        'userId': userId,
        'challengeId': challengeId,
        'pointsEarned': pointsEarned,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour les statistiques utilisateur
      await _firestore.collection('users').doc(userId).update({
        'stats.dailyChallengesCompleted': FieldValue.increment(1),
        'stats.totalPoints': FieldValue.increment(pointsEarned),
      });

      Logger.info('Défi quotidien complété');
    } catch (e) {
      Logger.error('Erreur complétion défi quotidien', e);
      rethrow;
    }
  }

  /// Gagne un badge
  Future<void> earnBadge({
    required String userId,
    required String badgeId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badgeId)
          .set({
            'earnedAt': FieldValue.serverTimestamp(),
            'isUnlocked': true,
          }, SetOptions(merge: true));

      Logger.info('Badge gagné: $badgeId');
    } catch (e) {
      Logger.error('Erreur gain badge', e);
      rethrow;
    }
  }

  /// Initialiser le service
  Future<void> initialize() async {
    try {
      Logger.info('GamificationService initialisé');
    } catch (e) {
      Logger.error('Erreur initialisation GamificationService', e);
    }
  }

  /// Récupère tous les badges
  Future<List<Map<String, dynamic>>> getAllBadges() async {
    try {
      final snapshot = await _firestore.collection('badges').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Logger.error('Erreur récupération badges', e);
      return [];
    }
  }

  /// Récupère les défis quotidiens
  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('daily_challenges')
          .where('active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Logger.error('Erreur récupération défis quotidiens', e);
      return [];
    }
  }

  /// Récupère la progression quotidienne
  Future<DailyProgress> getDailyProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_progress')
          .doc(DateTime.now().toIso8601String().split('T')[0])
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        return DailyProgress(
          completed: data['completed'] ?? 0,
          total: data['total'] ?? 10,
          totalReward: data['totalReward'] ?? 100,
          earnedReward: data['earnedReward'] ?? 0,
          progressPercent: data['progressPercent'] ?? 0,
        );
      }

      return DailyProgress(
        completed: 0,
        total: 10,
        totalReward: 100,
        earnedReward: 0,
        progressPercent: 0,
      );
    } catch (e) {
      Logger.error('Erreur récupération progression quotidienne', e);
      return DailyProgress(
        completed: 0,
        total: 10,
        totalReward: 100,
        earnedReward: 0,
        progressPercent: 0,
      );
    }
  }

  /// Dispose du service
  void dispose() {
    Logger.info('GamificationService disposé');
  }
}

/// Modèle Achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int reward;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.reward,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'reward': reward,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
  };
}

/// Modèle Badge
class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String rarity; // common, rare, epic, legendary
  bool isUnlocked;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'rarity': rarity,
    'isUnlocked': isUnlocked,
  };
}

/// Modèle Daily Challenge amélioré
class DailyChallengePlus {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int reward;
  final String difficulty; // easy, medium, hard
  final String category; // learning, quiz, audio, community
  bool isCompleted;
  DateTime? completedAt;

  DailyChallengePlus({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.reward,
    required this.difficulty,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'reward': reward,
    'difficulty': difficulty,
    'category': category,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };
}

/// Event: Achievement déverrouillé
class AchievementUnlocked {
  final Achievement achievement;
  final int triggerValue;

  AchievementUnlocked({required this.achievement, required this.triggerValue});
}

/// Event: Badge gagné
class BadgeEarned {
  final Badge badge;
  final String reason;

  BadgeEarned({required this.badge, required this.reason});
}

/// Modèle Progression quotidienne
class DailyProgress {
  final int completed;
  final int total;
  final int totalReward;
  final int earnedReward;
  final int progressPercent;

  DailyProgress({
    required this.completed,
    required this.total,
    required this.totalReward,
    required this.earnedReward,
    required this.progressPercent,
  });
}
