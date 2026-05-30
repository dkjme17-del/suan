import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/utils/logger.dart';
import '../../features/community/domain/services/community_service.dart';

class RealCommunityService {
  static final RealCommunityService _instance =
      RealCommunityService._internal();
  factory RealCommunityService() => _instance;
  RealCommunityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _currentUser;

  /// Stream le profil utilisateur en temps réel
  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data())
        .handleError((error) {
          Logger.error('Erreur user profile', error);
          return null;
        });
  }

  Stream<List<Map<String, dynamic>>> streamLeaderboard({int limit = 10}) {
    return _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        })
        .handleError((error) {
          Logger.error('Erreur leaderboard', error);
          return <Map<String, dynamic>>[];
        });
  }

  /// Stream les amis d'un utilisateur
  Stream<List<String>> streamFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            Logger.info('Aucun document trouvé pour l\'utilisateur: $userId');
            return <String>[];
          }

          final data = snapshot.data();
          if (data == null) {
            Logger.info('Aucune donnée trouvée pour l\'utilisateur: $userId');
            return <String>[];
          }

          if (!data.containsKey('friends')) {
            Logger.info(
              'Le champ "friends" est manquant pour l\'utilisateur: $userId',
            );
            return <String>[];
          }

          final friendsList = data['friends'];
          if (friendsList is List) {
            Logger.info(
              'Liste des amis récupérée pour l\'utilisateur $userId: $friendsList',
            );
            return friendsList
                .map<String>((friend) => friend.toString())
                .toList();
          }

          Logger.info(
            'Le champ "friends" n\'est pas une liste pour l\'utilisateur: $userId',
          );
          return <String>[];
        })
        .handleError((error) {
          Logger.error(
            'Erreur lors de la récupération des amis pour l\'utilisateur: $userId',
            error,
          );
          return <String>[];
        });
  }

  /// Stream tous les posts de la communauté
  Stream<List<Map<String, dynamic>>> streamCommunityPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        })
        .handleError((error) {
          Logger.error('Erreur community posts', error);
          return <Map<String, dynamic>>[];
        });
  }

  /// Stream les posts d'un utilisateur
  Stream<List<Map<String, dynamic>>> streamUserPosts(String userId) {
    return _firestore
        .collection('community_posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        })
        .handleError((error) {
          Logger.error('Erreur user posts', error);
          return <Map<String, dynamic>>[];
        });
  }

  /// Ajoute un ami
  Future<void> addFriend(String currentUserId, String friendId) async {
    try {
      // Récupérer le document utilisateur actuel
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentFriends = List<String>.from(
        userDoc.data()?['friends'] ?? [],
      );

      // Ajouter l'ami s'il n'est pas déjà dans la liste
      if (!currentFriends.contains(friendId)) {
        currentFriends.add(friendId);

        // Mettre à jour la liste d'amis dans le document utilisateur
        await _firestore.collection('users').doc(currentUserId).update({
          'friends': currentFriends,
          'stats.friendsCount': currentFriends
              .length, // Optionnel: compter les amis dans les stats
        });

        Logger.info('Ami ajouté: $friendId');

        // Mettre à jour aussi le compteur dans l'autre sens (bidirectionnel)
        await _firestore.collection('users').doc(friendId).update({
          'stats.friendsCount': FieldValue.increment(1),
        });
      } else {
        Logger.info('Ami déjà présent: $friendId');
      }
    } catch (e) {
      Logger.error('Erreur ajout ami', e);
      rethrow;
    }
  }

  /// Retire un ami
  Future<void> removeFriend(String currentUserId, String friendId) async {
    try {
      // Récupérer le document utilisateur actuel
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentFriends = List<String>.from(
        userDoc.data()?['friends'] ?? [],
      );

      // Retirer l'ami s'il est dans la liste
      if (currentFriends.contains(friendId)) {
        currentFriends.remove(friendId);

        // Mettre à jour la liste d'amis dans le document utilisateur
        await _firestore.collection('users').doc(currentUserId).update({
          'friends': currentFriends,
          'stats.friendsCount': currentFriends
              .length, // Optionnel: compter les amis dans les stats
        });

        Logger.info('Ami retiré: $friendId');

        // Mettre à jour aussi le compteur dans l'autre sens (bidirectionnel)
        await _firestore.collection('users').doc(friendId).update({
          'stats.friendsCount': FieldValue.increment(-1),
        });
      } else {
        Logger.info('Ami non trouvé: $friendId');
      }
    } catch (e) {
      Logger.error('Erreur retrait ami', e);
      rethrow;
    }
  }

  /// Crée un post dans la communauté
  Future<String> createPost({
    required String userId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('community_posts').add({
        'authorId': userId,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
      });

      Logger.info('Post créé: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      Logger.error('Erreur création post', e);
      rethrow;
    }
  }

  /// Aime un post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      Logger.error('Erreur like post', e);
    }
  }

  /// Ajoute un commentaire à un post
  Future<void> commentPost({
    required String postId,
    required String comment,
    required String userId,
  }) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'content': comment,
            'createdAt': FieldValue.serverTimestamp(),
          },
        ]),
      });
      Logger.info('Commentaire ajouté au post: $postId');
    } catch (e) {
      Logger.error('Erreur ajout commentaire', e);
      rethrow;
    }
  }

  /// Récupère les commentaires d'un post
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      final doc = await _firestore
          .collection('community_posts')
          .doc(postId)
          .get();
      final data = doc.data();
      if (data != null && data.containsKey('comments')) {
        return List<Map<String, dynamic>>.from(data['comments'] ?? []);
      }
      return [];
    } catch (e) {
      Logger.error('Erreur récupération commentaires', e);
      return [];
    }
  }

  /// Supprime un post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).delete();
      Logger.info('Post supprimé: $postId');
    } catch (e) {
      Logger.error('Erreur suppression post', e);
      rethrow;
    }
  }

  /// Définit l'utilisateur courant
  void setCurrentUser(UserProfile user) {
    _currentUser = user;
  }

  UserProfile? get currentUser => _currentUser;
}
