import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/logger.dart';

/// Entités pour la communauté
class UserProfile {
  final String id;
  final String username;
  final int level;
  final int totalPoints;
  final int streakDays;
  final String? avatarUrl;
  final List<String> friends;
  final DateTime createdAt;
  final String? bio;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final double averageScore;

  UserProfile({
    required this.id,
    required this.username,
    required this.level,
    required this.totalPoints,
    required this.streakDays,
    this.avatarUrl,
    this.friends = const [],
    required this.createdAt,
    this.bio,
    this.lessonsCompleted = 0,
    this.quizzesCompleted = 0,
    this.averageScore = 0.0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final gamification = data['gamification'] as Map<String, dynamic>? ?? {};
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final profile = data['profile'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      id: doc.id,
      username: data['username'] ?? data['displayName'] ?? '',
      level: data['level'] ?? data['currentLevel'] ?? 1,
      totalPoints: data['totalPoints'] ?? 0,
      // Support both flat and nested formats
      streakDays:
          data['streakDays'] ??
          gamification['streakDays'] ??
          data['currentStreak'] ??
          0,
      avatarUrl:
          (data['avatarUrl'] ??
                  profile['avatarUrl'] ??
                  profile['avatar'] ??
                  data['avatar'])
              as String?,
      friends: List<String>.from(data['friends'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: data['bio'] ?? data['profile']?['bio'],
      lessonsCompleted: stats['lessonsCompleted'] ?? 0,
      quizzesCompleted: stats['quizzesCompleted'] ?? 0,
      averageScore: (stats['averageScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'level': level,
      'totalPoints': totalPoints,
      'streakDays': streakDays,
      'avatarUrl': avatarUrl,
      'friends': friends,
      'createdAt': FieldValue.serverTimestamp(),
      'bio': bio,
      'stats': {
        'lessonsCompleted': lessonsCompleted,
        'quizzesCompleted': quizzesCompleted,
        'averageScore': averageScore,
      },
    };
  }
}

class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String? imageUrl;
  final int likes;
  final List<String> comments;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = const [],
    required this.createdAt,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Service de communauté utilisant Firebase - Données réelles
class RealCommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final RealCommunityService _instance =
      RealCommunityService._internal();
  factory RealCommunityService() => _instance;
  RealCommunityService._internal();

  UserProfile? _currentUser;

  /// Définir l'utilisateur courant
  void setCurrentUser(UserProfile user) {
    _currentUser = user;
  }

  /// Obtenir le classement communautaire depuis Firebase
  Future<List<UserProfile>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.error('Erreur récupération leaderboard', e);
      return [];
    }
  }

  /// Stream du classement en temps réel
  Stream<List<UserProfile>> streamLeaderboard({int limit = 10}) {
    return _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProfile.fromFirestore(doc))
              .toList(),
        );
  }

  /// Ajouter un ami
  Future<bool> addFriend(String userId) async {
    try {
      if (_currentUser == null) return false;

      // Ajouter l'ami dans les deux sens
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'friends': FieldValue.arrayUnion([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([_currentUser!.id]),
      });

      Logger.info('Ami ajouté: $userId pour utilisateur: ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('Erreur ajout ami', e);
      return false;
    }
  }

  /// Retirer un ami
  Future<bool> removeFriend(String userId) async {
    try {
      if (_currentUser == null) return false;

      // Retirer l'ami dans les deux sens
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'friends': FieldValue.arrayRemove([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayRemove([_currentUser!.id]),
      });

      Logger.info('Ami retiré: $userId pour utilisateur: ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('Erreur retrait ami', e);
      return false;
    }
  }

  /// Obtenir les posts de la communauté
  Future<List<CommunityPost>> getCommunityPosts({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CommunityPost.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.error('Erreur récupération posts communauté', e);
      return [];
    }
  }

  /// Stream des posts de la communauté en temps réel
  Stream<List<CommunityPost>> streamCommunityPosts({int limit = 20}) {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromFirestore(doc))
              .toList(),
        );
  }

  /// Créer un nouveau post
  Future<String> createPost({required String content, String? imageUrl}) async {
    try {
      if (_currentUser == null) throw Exception('Utilisateur non connecté');

      final doc = await _firestore.collection('community_posts').add({
        'userId': _currentUser!.id,
        'username': _currentUser!.username,
        'content': content,
        'imageUrl': imageUrl,
        'likes': 0,
        'comments': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Post créé: ${doc.id} par ${_currentUser!.username}');
      return doc.id;
    } catch (e) {
      Logger.error('Erreur création post', e);
      rethrow;
    }
  }

  /// Aimer un post
  Future<bool> likePost(String postId) async {
    try {
      if (_currentUser == null) return false;

      await _firestore.collection('community_posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });

      Logger.info('Post aimé: $postId par ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('Erreur like post', e);
      return false;
    }
  }

  /// Commenter un post
  Future<bool> commentPost({
    required String postId,
    required String comment,
  }) async {
    try {
      if (_currentUser == null) return false;

      await _firestore.collection('community_posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([
          '${_currentUser!.username}: $comment',
        ]),
      });

      Logger.info('Commentaire ajouté: $postId par ${_currentUser!.username}');
      return true;
    } catch (e) {
      Logger.error('Erreur commentaire post', e);
      return false;
    }
  }

  /// Récupère les commentaires d'un post
  Future<List<String>> getPostComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .doc(postId)
          .get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      return List<String>.from(data?['comments'] ?? []);
    } catch (e) {
      Logger.error('Erreur récupération commentaires', e);
      return [];
    }
  }

  /// Obtenir le profil d'un utilisateur
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();

      if (!snapshot.exists) return null;

      return UserProfile.fromFirestore(snapshot);
    } catch (e) {
      Logger.error('Erreur récupération profil utilisateur', e);
      return null;
    }
  }

  /// Stream le profil d'un utilisateur (pour afficher ses amis, etc.)
  Stream<DocumentSnapshot> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  /// Mettre à jour le profil utilisateur
  Future<bool> updateUserProfile({String? username, String? avatarUrl}) async {
    try {
      if (_currentUser == null) return false;

      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updateData);

      Logger.info('Profil mis à jour: ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('Erreur mise à jour profil', e);
      return false;
    }
  }

  /// Stream des amis de l'utilisateur (liste d'IDs)
  Stream<List<String>> streamFriends(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      return List<String>.from(data?['friends'] ?? []);
    });
  }

  /// Stream des posts d'un utilisateur spécifique
  Stream<List<CommunityPost>> streamUserPosts(String userId) {
    return _firestore
        .collection('community_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromFirestore(doc))
              .toList(),
        );
  }

  /// Supprimer un post
  Future<bool> deletePost(String postId) async {
    try {
      if (_currentUser == null) return false;

      // Vérifier que le post appartient à l'utilisateur
      final postSnapshot = await _firestore
          .collection('community_posts')
          .doc(postId)
          .get();

      if (!postSnapshot.exists) return false;

      final postData = postSnapshot.data() as Map<String, dynamic>;
      if (postData['userId'] != _currentUser!.id) return false;

      await _firestore.collection('community_posts').doc(postId).delete();

      Logger.info('Post supprimé: $postId par ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('Erreur suppression post', e);
      return false;
    }
  }
}
