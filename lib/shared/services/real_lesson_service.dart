import 'package:suan/features/learning/domain/entities/lesson.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';

/// Service de leçons utilisant Firebase - Données réelles
class RealLessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final RealLessonService _instance = RealLessonService._internal();
  factory RealLessonService() => _instance;
  RealLessonService._internal();

  /// Récupère les leçons par niveau depuis Firebase
  Future<List<Lesson>> getLessonsByLevel(String level) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('level', isEqualTo: level)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lesson(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          level: data['level'] ?? level,
          content: data['content'] ?? '',
          vocabulary: List<String>.from(data['vocabulary'] ?? []),
          durationMinutes: data['durationMinutes'] ?? 5,
          audioUrl: data['audioUrl'],
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      Logger.error('Erreur récupération leçons par niveau', e);
      return [];
    }
  }

  /// Récupère toutes les leçons depuis Firebase
  Future<List<Lesson>> getAllLessons() async {
    try {
      final snapshot = await _firestore.collection('lessons').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lesson(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          level: data['level'] ?? 'beginner',
          content: data['content'] ?? '',
          vocabulary: List<String>.from(data['vocabulary'] ?? []),
          durationMinutes: data['durationMinutes'] ?? 5,
          audioUrl: data['audioUrl'],
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      Logger.error('Erreur récupération toutes les leçons', e);
      return [];
    }
  }

  /// Récupère une leçon par ID depuis Firebase
  Future<Lesson?> getLessonById(String id) async {
    try {
      final snapshot = await _firestore.collection('lessons').doc(id).get();

      if (!snapshot.exists) return null;

      final data = snapshot.data()!;
      return Lesson(
        id: snapshot.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        level: data['level'] ?? 'beginner',
        content: data['content'] ?? '',
        vocabulary: List<String>.from(data['vocabulary'] ?? []),
        durationMinutes: data['durationMinutes'] ?? 5,
        audioUrl: data['audioUrl'],
        isCompleted: data['isCompleted'] ?? false,
      );
    } catch (e) {
      Logger.error('Erreur récupération leçon par ID', e);
      return null;
    }
  }

  /// Marque une leçon comme complétée dans Firebase
  Future<void> completeLesson(String lessonId, String userId) async {
    try {
      await _firestore.collection('user_lessons').doc('$userId-$lessonId').set({
        'lessonId': lessonId,
        'userId': userId,
        'completedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      // Mettre à jour les statistiques utilisateur
      await _firestore.collection('users').doc(userId).update({
        'stats.lessonsCompleted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Leçon complétée: $lessonId pour utilisateur: $userId');
    } catch (e) {
      Logger.error('Erreur complétion leçon', e);
      rethrow;
    }
  }

  /// Ajoute une nouvelle leçon dans Firebase
  Future<String> addLesson({
    required String title,
    required String description,
    required String level,
    required String content,
    required List<String> vocabulary,
    int durationMinutes = 5,
    String? audioUrl,
  }) async {
    try {
      final doc = await _firestore.collection('lessons').add({
        'title': title,
        'description': description,
        'level': level,
        'content': content,
        'vocabulary': vocabulary,
        'durationMinutes': durationMinutes,
        'audioUrl': audioUrl,
        'isCompleted': false,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Leçon ajoutée: ${doc.id}');
      return doc.id;
    } catch (e) {
      Logger.error('Erreur ajout leçon', e);
      rethrow;
    }
  }

  /// Stream des leçons par niveau en temps réel
  Stream<List<Lesson>> streamLessonsByLevel(String level) {
    return _firestore
        .collection('lessons')
        .where('level', isEqualTo: level)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Lesson(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              level: data['level'] ?? level,
              content: data['content'] ?? '',
              vocabulary: List<String>.from(data['vocabulary'] ?? []),
              durationMinutes: data['durationMinutes'] ?? 5,
              audioUrl: data['audioUrl'],
              isCompleted: data['isCompleted'] ?? false,
            );
          }).toList();
        });
  }

  /// Stream de toutes les leçons en temps réel
  Stream<List<Lesson>> streamAllLessons() {
    return _firestore.collection('lessons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lesson(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          level: data['level'] ?? 'beginner',
          content: data['content'] ?? '',
          vocabulary: List<String>.from(data['vocabulary'] ?? []),
          durationMinutes: data['durationMinutes'] ?? 5,
          audioUrl: data['audioUrl'],
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    });
  }

  /// Incrémente le nombre de vues d'une leçon
  Future<void> incrementViews(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'views': FieldValue.increment(1),
        'lastViewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error('Erreur incrémentation vues leçon', e);
    }
  }

  /// Met à jour une leçon existante
  Future<void> updateLesson({
    required String lessonId,
    String? title,
    String? description,
    String? content,
    List<String>? vocabulary,
    int? durationMinutes,
    String? audioUrl,
    bool? isCompleted,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (content != null) updateData['content'] = content;
      if (vocabulary != null) updateData['vocabulary'] = vocabulary;
      if (durationMinutes != null) {
        updateData['durationMinutes'] = durationMinutes;
      }
      if (audioUrl != null) updateData['audioUrl'] = audioUrl;
      if (isCompleted != null) updateData['isCompleted'] = isCompleted;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('lessons').doc(lessonId).update(updateData);
      Logger.info('Leçon mise à jour: $lessonId');
    } catch (e) {
      Logger.error('Erreur mise à jour leçon', e);
      rethrow;
    }
  }

  /// Supprime une leçon
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).delete();
      Logger.info('Leçon supprimée: $lessonId');
    } catch (e) {
      Logger.error('Erreur suppression leçon', e);
      rethrow;
    }
  }
}
