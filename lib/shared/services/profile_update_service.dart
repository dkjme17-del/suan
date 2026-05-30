import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_auth_service.dart';
import '../../core/utils/logger.dart';

/// Service spécialisé pour la mise à jour automatique du profil utilisateur
class ProfileUpdateService {
  static final ProfileUpdateService _instance =
      ProfileUpdateService._internal();
  factory ProfileUpdateService() => _instance;
  ProfileUpdateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Met à jour automatiquement le profil utilisateur après l'inscription
  /// en utilisant le nom comme nom d'utilisateur par défaut
  Future<void> updateProfileAfterRegistration({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      Logger.info('🔄 Mise à jour automatique du profil pour: $name');

      // 1. Mettre à jour Firebase Auth avec le nom comme displayName
      final firebaseAuthService = FirebaseAuthService();
      await firebaseAuthService.updateUserProfile(
        userId: userId,
        displayName: name,
      );
      Logger.info('✅ DisplayName mis à jour dans Firebase Auth: $name');

      // 2. Mettre à jour Firestore avec le profil complet
      await _firestore.collection('users').doc(userId).set({
        'username': name, // Le nom devient le nom d'utilisateur
        'displayName': name, // Aussi utilisé comme displayName
        'email': email,
        'level': 1,
        'totalPoints': 0,
        'stats': {
          'lessonsCompleted': 0,
          'quizzesCompleted': 0,
          'averageScore': 0.0,
          'dailyChallengesCompleted': 0,
        },
        'preferences': {
          'notificationsEnabled': true,
          'soundsEnabled': true,
          'language': 'Français',
          'theme': 'light',
          'learningMode': 'progressif',
        },
        'profile': {
          'bio':
              'Nouvel utilisateur passionné par l\'apprentissage du baoulé! 🎯',
          'avatar': null,
          'joinedAt': FieldValue.serverTimestamp(),
        },
        'gamification': {
          'streakDays': 0,
          'longestStreak': 0,
          'lastActiveDate': FieldValue.serverTimestamp(),
          'achievements': [],
          'badges': [],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Logger.info('✅ Profil Firestore créé avec succès pour: $name');

      // 3. Créer les collections de suivi pour le nouvel utilisateur
      await _createUserTrackingCollections(userId, name);

      Logger.info('🎉 Mise à jour automatique du profil terminée pour: $name');
    } catch (e) {
      Logger.error('❌ Erreur mise à jour automatique du profil', e);
      rethrow;
    }
  }

  /// Crée les collections de suivi pour le nouvel utilisateur
  Future<void> _createUserTrackingCollections(
    String userId,
    String username,
  ) async {
    try {
      // Collection pour suivre la progression des leçons
      await _firestore.collection('user_lessons').doc(userId).set({
        'userId': userId,
        'username': username,
        'completedLessons': [],
        'currentLesson': null,
        'progress': 0.0,
        'lastAccessDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Collection pour suivre les quiz complétés
      await _firestore.collection('user_quiz_progress').doc(userId).set({
        'userId': userId,
        'username': username,
        'completedQuizzes': [],
        'quizScores': [],
        'averageScore': 0.0,
        'totalQuizPoints': 0,
        'lastQuizDate': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Collection pour les défis quotidiens
      await _firestore.collection('user_daily_challenges').doc(userId).set({
        'userId': userId,
        'username': username,
        'completedChallenges': [],
        'currentStreak': 0,
        'longestStreak': 0,
        'totalChallengePoints': 0,
        'lastChallengeDate': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Logger.info('✅ Collections de suivi créées pour: $username');
    } catch (e) {
      Logger.error('❌ Erreur création collections suivi', e);
      // Ne pas faire échouer l'inscription si les collections de suivi échouent
    }
  }

  /// Vérifie si le nom d'utilisateur est disponible
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      Logger.error('❌ Erreur vérification disponibilité nom d\'utilisateur', e);
      return false;
    }
  }

  /// Génère un nom d'utilisateur unique si celui fourni est déjà pris
  Future<String> generateUniqueUsername(String baseUsername) async {
    if (await isUsernameAvailable(baseUsername)) {
      return baseUsername;
    }

    int counter = 1;
    String newUsername = '$baseUsername$counter';

    while (!await isUsernameAvailable(newUsername)) {
      counter++;
      newUsername = '$baseUsername$counter';

      // Limiter le nombre de tentatives pour éviter une boucle infinie
      if (counter > 999) {
        // Ajouter un timestamp si tous les numéros sont pris
        newUsername =
            '${baseUsername}_${DateTime.now().millisecondsSinceEpoch}';
        break;
      }
    }

    Logger.info('🔄 Nom d\'utilisateur généré: $newUsername');
    return newUsername;
  }

  /// Met à jour le profil avec un nouveau nom d'utilisateur
  Future<bool> updateUsername({
    required String userId,
    required String newUsername,
  }) async {
    try {
      // Vérifier la disponibilité du nouveau nom d'utilisateur
      if (!await isUsernameAvailable(newUsername)) {
        Logger.warning('⚠️ Nom d\'utilisateur déjà pris: $newUsername');
        return false;
      }

      // Mettre à jour Firestore
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
        'displayName': newUsername,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour Firebase Auth
      final firebaseAuthService = FirebaseAuthService();
      await firebaseAuthService.updateUserProfile(
        userId: userId,
        displayName: newUsername,
      );

      Logger.info('✅ Nom d\'utilisateur mis à jour: $newUsername');
      return true;
    } catch (e) {
      Logger.error('❌ Erreur mise à jour nom d\'utilisateur', e);
      return false;
    }
  }
}
