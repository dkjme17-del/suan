import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/utils/logger.dart';

class CulturalService {
  static final CulturalService _instance = CulturalService._internal();
  factory CulturalService() => _instance;
  CulturalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream toutes les histoires culturelles en temps réel
  Stream<List<Map<String, dynamic>>> streamCulturalStories() {
    return _firestore
        .collection('cultural_stories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
          }).toList();
    }).handleError((error) {
      Logger.error('Erreur cultural stories', error);
      return [];
    });
  }

  /// Stream tous les proverbes en temps réel
  Stream<List<Map<String, dynamic>>> streamProverbs() {
    return _firestore
        .collection('proverbs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
          }).toList();
    }).handleError((error) {
      Logger.error('Erreur proverbs', error);
      return [];
    });
  }

  /// Stream tous les anciens (Elders) en temps réel
  Stream<List<Map<String, dynamic>>> streamElders() {
    return _firestore
        .collection('elders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
          }).toList();
    }).handleError((error) {
      Logger.error('Erreur elders', error);
      return [];
    });
  }

  /// Obtient une histoire culturelle par ID
  Future<Map<String, dynamic>?> getStoryById(String storyId) async {
    try {
      final doc = await _firestore.collection('cultural_stories').doc(storyId).get();
      if (doc.exists) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      Logger.error('Erreur récupération story', e);
      return null;
    }
  }

  /// Marque une histoire comme complétée
  Future<void> completeStory(String userId, String storyId) async {
    try {
      await _firestore.collection('user_stories').add({
        'userId': userId,
        'storyId': storyId,
        'completedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Histoire complétée: $storyId');
    } catch (e) {
      Logger.error('Erreur complétion story', e);
      rethrow;
    }
  }

  /// Ajoute un commentaire sur un proverbe
  Future<void> addProverbComment({
    required String proverbId,
    required String userId,
    required String comment,
  }) async {
    try {
      await _firestore.collection('proverbs').doc(proverbId).update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'comment': comment,
            'createdAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      Logger.error('Erreur ajout commentaire proverbe', e);
    }
  }

  /// Aime un proverbe
  Future<void> likeProverb(String proverbId, String userId) async {
    try {
      await _firestore.collection('proverbs').doc(proverbId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      Logger.error('Erreur like proverbe', e);
    }
  }

  /// Ajoute un proverbe
  Future<String> addProverb({
    required String text,
    required String meaning,
    required String category,
  }) async {
    try {
      final docRef = await _firestore.collection('proverbs').add({
        'text': text,
        'meaning': meaning,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
      });

      Logger.info('Proverbe ajouté: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      Logger.error('Erreur ajout proverbe', e);
      rethrow;
    }
  }

  /// Ajoute une histoire culturelle
  Future<String> addCulturalStory({
    required String title,
    required String content,
    required String category,
    String? author,
    String? audioUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('cultural_stories').add({
        'title': title,
        'content': content,
        'category': category,
        'author': author,
        'audioUrl': audioUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Histoire culturelle ajoutée: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      Logger.error('Erreur ajout histoire culturelle', e);
      rethrow;
    }
  }
}
