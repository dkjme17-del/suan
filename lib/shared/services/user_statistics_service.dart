import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';

/// Service pour gérer les statistiques et la progression des utilisateurs
class UserStatisticsService {
  static final UserStatisticsService _instance =
      UserStatisticsService._internal();
  factory UserStatisticsService() => _instance;
  UserStatisticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Met à jour les statistiques de l'utilisateur après une leçon
  Future<void> updateLessonStats({
    required String userId,
    required String lessonId,
    required bool completed,
    required int score,
    required Duration timeSpent,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Récupérer les stats actuelles
      final userDoc = await userRef.get();
      final currentStats =
          userDoc.data()?['stats'] as Map<String, dynamic>? ?? {};

      // Mettre à jour les stats
      final newStats = Map<String, dynamic>.from(currentStats);

      if (completed) {
        newStats['lessonsCompleted'] = (newStats['lessonsCompleted'] ?? 0) + 1;
        newStats['totalLessonScore'] =
            (newStats['totalLessonScore'] ?? 0) + score;
        newStats['averageLessonScore'] =
            newStats['totalLessonScore'] / newStats['lessonsCompleted'];
        newStats['totalTimeSpent'] =
            (newStats['totalTimeSpent'] ?? 0) + timeSpent.inMinutes;
      }

      // Mettre à jour la progression de la leçon spécifique
      await userRef.collection('lesson_progress').doc(lessonId).set({
        'completed': completed,
        'score': score,
        'timeSpent': timeSpent.inMinutes,
        'completedAt': completed ? FieldValue.serverTimestamp() : null,
        'lastAccessedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mettre à jour les stats globales
      await userRef.update({
        'stats': newStats,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      Logger.info('✅ Stats leçon mises à jour pour utilisateur: $userId');
    } catch (e) {
      Logger.error('❌ Erreur mise à jour stats leçon', e);
      rethrow;
    }
  }

  /// Met à jour les statistiques de l'utilisateur après un quiz
  Future<void> updateQuizStats({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required Duration timeSpent,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Récupérer les stats actuelles
      final userDoc = await userRef.get();
      final currentStats =
          userDoc.data()?['stats'] as Map<String, dynamic>? ?? {};

      // Mettre à jour les stats
      final newStats = Map<String, dynamic>.from(currentStats);
      newStats['quizzesCompleted'] = (newStats['quizzesCompleted'] ?? 0) + 1;
      newStats['totalQuizScore'] = (newStats['totalQuizScore'] ?? 0) + score;
      newStats['totalQuizQuestions'] =
          (newStats['totalQuizQuestions'] ?? 0) + totalQuestions;
      newStats['totalCorrectAnswers'] =
          (newStats['totalCorrectAnswers'] ?? 0) + correctAnswers;

      // Calculer les moyennes
      newStats['averageQuizScore'] =
          newStats['totalQuizScore'] / newStats['quizzesCompleted'];
      newStats['quizAccuracy'] =
          newStats['totalCorrectAnswers'] / newStats['totalQuizQuestions'];

      // Mettre à jour les points totaux
      newStats['totalPoints'] = (newStats['totalPoints'] ?? 0) + score;

      // Enregistrer la progression du quiz spécifique
      await userRef.collection('quiz_progress').doc(quizId).set({
        'score': score,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'accuracy': correctAnswers / totalQuestions,
        'timeSpent': timeSpent.inMinutes,
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mettre à jour les stats globales
      await userRef.update({
        'stats': newStats,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      Logger.info('✅ Stats quiz mises à jour pour utilisateur: $userId');
    } catch (e) {
      Logger.error('❌ Erreur mise à jour stats quiz', e);
      rethrow;
    }
  }

  /// Met à jour les statistiques de l'utilisateur après un défi quotidien
  Future<void> updateDailyChallengeStats({
    required String userId,
    required String challengeId,
    required bool completed,
    required int pointsEarned,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Récupérer les stats actuelles
      final userDoc = await userRef.get();
      final currentStats =
          userDoc.data()?['stats'] as Map<String, dynamic>? ?? {};

      // Mettre à jour les stats
      final newStats = Map<String, dynamic>.from(currentStats);

      if (completed) {
        newStats['dailyChallengesCompleted'] =
            (newStats['dailyChallengesCompleted'] ?? 0) + 1;
        newStats['totalChallengePoints'] =
            (newStats['totalChallengePoints'] ?? 0) + pointsEarned;
        newStats['totalPoints'] = (newStats['totalPoints'] ?? 0) + pointsEarned;

        // Mettre à jour le streak
        final today = DateTime.now();
        final lastChallengeDate =
            (userDoc.data()?['lastChallengeDate'] as Timestamp?)?.toDate();

        if (lastChallengeDate != null) {
          final daysDiff = today.difference(lastChallengeDate).inDays;
          if (daysDiff == 1) {
            // Streak continu
            newStats['currentStreak'] = (newStats['currentStreak'] ?? 0) + 1;
            newStats['longestStreak'] =
                newStats['currentStreak'] > (newStats['longestStreak'] ?? 0)
                ? newStats['currentStreak']
                : newStats['longestStreak'];
          } else if (daysDiff > 1) {
            // Streak rompu
            newStats['currentStreak'] = 1;
          }
        } else {
          // Premier défi
          newStats['currentStreak'] = 1;
          newStats['longestStreak'] = 1;
        }
      }

      // Enregistrer la progression du défi
      await userRef.collection('daily_challenges').doc(challengeId).set({
        'completed': completed,
        'pointsEarned': pointsEarned,
        'completedAt': completed ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));

      // Mettre à jour les stats globales
      await userRef.update({
        'stats': newStats,
        'lastChallengeDate': completed
            ? FieldValue.serverTimestamp()
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      Logger.info(
        '✅ Stats défi quotidien mises à jour pour utilisateur: $userId',
      );
    } catch (e) {
      Logger.error('❌ Erreur mise à jour stats défi quotidien', e);
      rethrow;
    }
  }

  /// Met à jour le niveau de l'utilisateur en fonction des points
  Future<void> updateUserLevel(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      final totalPoints = userDoc.data()?['stats']?['totalPoints'] ?? 0;

      // Calcul du niveau (100 points par niveau)
      final newLevel = (totalPoints / 100).floor() + 1;
      final currentLevel = userDoc.data()?['level'] ?? 1;

      if (newLevel > currentLevel) {
        await userRef.update({
          'level': newLevel,
          'levelUpAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        Logger.info(
          '🎉 Niveau mis à jour pour utilisateur $userId: $currentLevel -> $newLevel',
        );
      }
    } catch (e) {
      Logger.error('❌ Erreur mise à jour niveau utilisateur', e);
      rethrow;
    }
  }

  /// Récupère les statistiques complètes d'un utilisateur
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {};
      }

      final data = userDoc.data()!;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};

      return {
        'userId': userId,
        'username': data['username'] ?? '',
        'level': data['level'] ?? 1,
        'totalPoints': stats['totalPoints'] ?? 0,
        'lessonsCompleted': stats['lessonsCompleted'] ?? 0,
        'quizzesCompleted': stats['quizzesCompleted'] ?? 0,
        'dailyChallengesCompleted': stats['dailyChallengesCompleted'] ?? 0,
        'averageLessonScore': stats['averageLessonScore'] ?? 0.0,
        'averageQuizScore': stats['averageQuizScore'] ?? 0.0,
        'quizAccuracy': stats['quizAccuracy'] ?? 0.0,
        'currentStreak': stats['currentStreak'] ?? 0,
        'longestStreak': stats['longestStreak'] ?? 0,
        'totalTimeSpent': stats['totalTimeSpent'] ?? 0,
        'joinedAt': data['createdAt'],
        'lastActivityAt': data['lastActivityAt'],
        'updatedAt': data['updatedAt'],
      };
    } catch (e) {
      Logger.error('❌ Erreur récupération stats utilisateur', e);
      return {};
    }
  }

  /// Récupère le classement des utilisateurs
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('stats.totalPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final stats = data['stats'] as Map<String, dynamic>? ?? {};

        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'level': data['level'] ?? 1,
          'totalPoints': stats['totalPoints'] ?? 0,
          'lessonsCompleted': stats['lessonsCompleted'] ?? 0,
          'quizzesCompleted': stats['quizzesCompleted'] ?? 0,
          'currentStreak': stats['currentStreak'] ?? 0,
        };
      }).toList();
    } catch (e) {
      Logger.error('❌ Erreur récupération classement', e);
      return [];
    }
  }

  /// Met à jour l'activité de l'utilisateur
  Future<void> updateLastActivity(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error('❌ Erreur mise à jour dernière activité', e);
    }
  }

  /// Réinitialise les statistiques d'un utilisateur (admin seulement)
  Future<void> resetUserStatistics(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats': {
          'lessonsCompleted': 0,
          'quizzesCompleted': 0,
          'dailyChallengesCompleted': 0,
          'totalPoints': 0,
          'totalLessonScore': 0,
          'totalQuizScore': 0,
          'totalQuizQuestions': 0,
          'totalCorrectAnswers': 0,
          'totalChallengePoints': 0,
          'averageLessonScore': 0.0,
          'averageQuizScore': 0.0,
          'quizAccuracy': 0.0,
          'currentStreak': 0,
          'longestStreak': 0,
          'totalTimeSpent': 0,
        },
        'level': 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Supprimer les collections de progression
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('lesson_progress')
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_progress')
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

      Logger.info('🔄 Statistiques réinitialisées pour utilisateur: $userId');
    } catch (e) {
      Logger.error('❌ Erreur réinitialisation stats utilisateur', e);
      rethrow;
    }
  }
}
