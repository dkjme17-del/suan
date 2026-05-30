import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suan/shared/services/firebase_service.dart';

/// ViewModel pour les leçons en temps réel
class LessonRealtimeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  String _userId = '';
  int _currentLevel = 1;
  String? _selectedLessonId;

  void initialize(String userId, {int level = 1}) {
    _userId = userId;
    _currentLevel = level;
    notifyListeners();
  }

  /// Stream de toutes les leçons
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllLessons() {
    return _firebaseService.streamLessons();
  }

  /// Stream des leçons par niveau (String: 'beginner', 'intermediate', 'advanced')
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLessonsByLevel(dynamic level) {
    // Convertir le String en int si nécessaire
    int levelInt = level;
    if (level is String) {
      switch (level.toLowerCase()) {
        case 'beginner':
          levelInt = 1;
          break;
        case 'intermediate':
          levelInt = 2;
          break;
        case 'advanced':
          levelInt = 3;
          break;
        default:
          levelInt = 1;
      }
    }
    return _firebaseService.streamLessonsByLevel(levelInt);
  }

  /// Stream des leçons du niveau actuel
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCurrentLevelLessons() {
    return _firebaseService.streamLessonsByLevel(_currentLevel);
  }

  /// Stream des commentaires d'une leçon
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLessonComments(String lessonId) {
    return _firebaseService.streamLessonComments(lessonId);
  }

  /// Ajouter un commentaire
  Future<void> addComment({
    required String lessonId,
    required String username,
    required String content,
  }) async {
    try {
      await _firebaseService.addComment(
        userId: _userId,
        username: username,
        content: content,
        lessonId: lessonId,
      );
      print('✅ Commentaire ajouté');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur ajout commentaire: $e');
    }
  }

  /// Aimer un commentaire
  Future<void> likeComment(String commentId) async {
    try {
      await _firebaseService.likeComment(commentId);
      notifyListeners();
    } catch (e) {
      print('❌ Erreur like commentaire: $e');
    }
  }

  /// Sélectionner une leçon
  void selectLesson(String lessonId) {
    _selectedLessonId = lessonId;
    notifyListeners();
  }

  /// Obtenir la leçon sélectionnée
  String? get selectedLessonId => _selectedLessonId;

  /// Changer de niveau
  void setLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }

  /// Basculer le statut favori d'une leçon dans Firestore
  Future<void> toggleFavoriteLessonInFirestore(
    String lessonId,
    bool isFavorite,
  ) async {
    try {
      final lessonsRef = FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonId);
      
      await lessonsRef.update({'isFavorite': isFavorite});
      print('✅ Statut favori updated: $isFavorite');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur update favori: $e');
    }
  }
}
