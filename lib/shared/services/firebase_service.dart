import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/utils/logger.dart';

/// Service Firebase Firestore pour la base de données temps réel
///
/// Gère:
/// - Profils utilisateur
/// - Statistiques et points
/// - Leçons et quiz
/// - Leaderboard en temps réel
/// - Commentaires et communauté

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== UTILISATEURS ====================

  /// Créer ou mettre à jour le profil utilisateur
  Future<void> createUserProfile({
    required String userId,
    required String username,
    required String email,
    required int level,
    required int totalPoints,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'username':
            username, // Le nom d'utilisateur est maintenant le nom fourni
        'email': email,
        'level': level,
        'totalPoints': totalPoints,
        'stats': {
          'lessonsCompleted': 0,
          'quizzesCompleted': 0,
          'averageScore': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Logger.info('✅ Profil créé avec nom d\'utilisateur: $username');
    } catch (e) {
      Logger.error('❌ Erreur création profil', e);
      rethrow;
    }
  }

  /// Récupérer le profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      Logger.error('❌ Erreur récupération profil', e);
      return null;
    }
  }

  /// Écouter les changements du profil utilisateur en temps réel
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // ==================== STATISTIQUES ====================

  /// Mettre à jour les statistiques utilisateur
  Future<void> updateUserStats({
    required String userId,
    required int totalPoints,
    required int lessonsCompleted,
    required int quizzesCompleted,
    required int streakDays,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': totalPoints,
        'streakDays': streakDays,
        'stats.lessonsCompleted': lessonsCompleted,
        'stats.quizzesCompleted': quizzesCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Stats mises à jour pour: $userId');
    } catch (e) {
      Logger.error('❌ Erreur mise à jour stats', e);
      rethrow;
    }
  }

  /// Récupérer les statistiques en temps réel
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserStats(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // ==================== LEÇONS ====================

  /// Ajouter une leçon
  Future<String> addLesson({
    required String title,
    required String content,
    required int level,
    required String language,
    String? audioUrl,
    String? imageUrl,
  }) async {
    try {
      final doc = await _firestore.collection('lessons').add({
        'title': title,
        'content': content,
        'level': level,
        'language': language,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Leçon ajoutée: ${doc.id}');
      return doc.id;
    } catch (e) {
      Logger.error('❌ Erreur ajout leçon', e);
      rethrow;
    }
  }

  /// Récupérer toutes les leçons
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLessons() {
    return _firestore.collection('lessons').snapshots();
  }

  /// Récupérer les leçons par niveau
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLessonsByLevel(int level) {
    return _firestore
        .collection('lessons')
        .where('level', isEqualTo: level)
        .snapshots();
  }

  // ==================== QUIZ ====================

  /// Ajouter un quiz
  Future<String> addQuiz({
    required String title,
    required int level,
    required List<Map<String, dynamic>> questions,
    required int totalPoints,
    int timeLimit = 300,
  }) async {
    try {
      final doc = await _firestore.collection('quizzes').add({
        'title': title,
        'level': level,
        'questions': questions,
        'totalPoints': totalPoints,
        'timeLimit': timeLimit,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Quiz ajouté: ${doc.id}');
      return doc.id;
    } catch (e) {
      Logger.error('❌ Erreur ajout quiz', e);
      rethrow;
    }
  }

  /// Récupérer tous les quiz
  Stream<QuerySnapshot<Map<String, dynamic>>> streamQuizzes() {
    // Utiliser directement la collection des questions de quiz
    return _firestore.collection('quiz_questions').snapshots();
  }

  /// Récupérer les quiz par niveau
  Stream<QuerySnapshot<Map<String, dynamic>>> streamQuizzesByLevel(int level) {
    // Pour l'instant, aucun champ de niveau n'est défini dans quiz_questions,
    // donc on retourne simplement toutes les questions.
    return _firestore.collection('quiz_questions').snapshots();
  }

  // ==================== RÉSULTATS DE QUIZ ====================

  /// Sauvegarder le résultat d'un quiz
  Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required int score,
    required int totalPoints,
    required int timeSpent,
    List<int>? answers,
  }) async {
    try {
      await _firestore.collection('quiz_results').add({
        'userId': userId,
        'quizId': quizId,
        'score': score,
        'totalPoints': totalPoints,
        'timeSpent': timeSpent,
        'answers': answers ?? [],
        'completedAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Résultat sauvegardé pour: $userId');
    } catch (e) {
      Logger.error('❌ Erreur sauvegarde résultat', e);
      rethrow;
    }
  }

  /// Récupérer les résultats d'un utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserQuizResults(
    String userId,
  ) {
    return _firestore
        .collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  // ==================== LEADERBOARD ====================

  /// Récupérer le leaderboard global
  Stream<QuerySnapshot<Map<String, dynamic>>> streamGlobalLeaderboard({
    int limit = 100,
  }) {
    return _firestore
        .collection('leaderboard')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Mettre à jour le leaderboard
  Future<void> updateLeaderboard({
    required String userId,
    required String username,
    required int totalPoints,
    required int level,
  }) async {
    try {
      await _firestore.collection('leaderboard').doc(userId).set({
        'username': username,
        'totalPoints': totalPoints,
        'level': level,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Logger.info('✅ Leaderboard mis à jour: $username');
    } catch (e) {
      Logger.error('❌ Erreur mise à jour leaderboard', e);
      rethrow;
    }
  }

  // ==================== COMMENTAIRES ====================

  /// Ajouter un commentaire
  Future<void> addComment({
    required String userId,
    required String username,
    required String content,
    required String lessonId,
  }) async {
    try {
      await _firestore.collection('comments').add({
        'userId': userId,
        'username': username,
        'content': content,
        'lessonId': lessonId,
        'likes': 0,
        'replies': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Commentaire ajouté');
    } catch (e) {
      Logger.error('❌ Erreur ajout commentaire', e);
      rethrow;
    }
  }

  /// Récupérer les commentaires d'une leçon
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLessonComments(
    String lessonId,
  ) {
    return _firestore
        .collection('comments')
        .where('lessonId', isEqualTo: lessonId)
        .orderBy('likes', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Aimer un commentaire
  Future<void> likeComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      Logger.error('❌ Erreur like commentaire', e);
      rethrow;
    }
  }

  // ==================== AMIS ====================

  /// Ajouter un ami
  Future<void> addFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });
      Logger.info('✅ Ami ajouté: $friendId');
    } catch (e) {
      Logger.error('❌ Erreur ajout ami', e);
      rethrow;
    }
  }

  /// Récupérer les amis d'un utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots();
  }

  // ==================== ACTUALITÉS ====================

  /// Ajouter une actualité
  Future<void> addNews({
    required String title,
    required String content,
    String? imageUrl,
    bool featured = false,
  }) async {
    try {
      await _firestore.collection('news').add({
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'featured': featured,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Logger.info('✅ Actualité ajoutée: $title');
    } catch (e) {
      Logger.error('❌ Erreur ajout actualité', e);
      rethrow;
    }
  }

  /// Récupérer les actualités
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNews({
    bool featuredOnly = false,
  }) {
    var query = _firestore.collection('news') as Query<Map<String, dynamic>>;

    if (featuredOnly) {
      query = query.where('featured', isEqualTo: true);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== ACHIEVEMENTS ====================

  /// Déverrouiller un achievement
  Future<void> unlockAchievement({
    required String userId,
    required String achievementId,
    required String title,
    String? description,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .set({
            'title': title,
            'description': description,
            'unlockedAt': FieldValue.serverTimestamp(),
          });
      Logger.info('✅ Achievement déverrouillé: $title');
    } catch (e) {
      Logger.error('❌ Erreur déverrouillage achievement', e);
      rethrow;
    }
  }

  /// Récupérer les achievements d'un utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserAchievements(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots();
  }

  /// Uploader une photo de profil
  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      Logger.info('📤 Upload photo profil pour userId: $userId');

      final fileName =
          '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref('profile_pics/$fileName');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Mettre à jour le document user avec l'URL
      await _firestore.collection('users').doc(userId).update({
        'avatar': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('✅ Photo profil uploadée: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      Logger.error('❌ Erreur upload photo profil', e);
      rethrow;
    }
  }

  // ==================== UTILITAIRES ====================

  /// Vérifier la connectivité
  Future<bool> checkConnectivity() async {
    try {
      await _firestore.collection('_metadata').doc('connectivity_check').get();
      return true;
    } catch (e) {
      Logger.error('❌ Erreur connectivité', e);
      return false;
    }
  }

  /// Activer la persistence hors-ligne
  Future<void> enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        sslEnabled: true,
      );
      Logger.info('✅ Persistance hors-ligne activée');
    } catch (e) {
      Logger.error('⚠ Erreur persistance', e);
    }
  }
}
