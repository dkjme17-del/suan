import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suan/shared/services/firebase_service.dart';

/// ViewModel pour les quiz en temps réel
class QuizRealtimeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  String _userId = '';
  int _currentLevel = 1;

  void initialize(String userId, {int level = 1}) {
    _userId = userId;
    _currentLevel = level;
    notifyListeners();
  }

  /// Stream de tous les quiz
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllQuizzes() {
    return _firebaseService.streamQuizzes();
  }

  /// Stream des quiz par niveau (String: 'beginner', 'intermediate', 'advanced' ou int: 1, 2, 3)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamQuizzesByLevel(dynamic level) {
    // Convertir le String en int si nécessaire
    int levelInt = 1; // Par défaut
    
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
    } else if (level is int) {
      levelInt = level;
    }
    
    return _firebaseService.streamQuizzesByLevel(levelInt);
  }

  /// Stream des quiz du niveau actuel
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCurrentLevelQuizzes() {
    return _firebaseService.streamQuizzesByLevel(_currentLevel);
  }

  /// Sauvegarder le résultat d'un quiz
  Future<void> saveQuizResult({
    required String quizId,
    required int score,
    required int totalPoints,
    required int timeSpent,
    List<int>? answers,
  }) async {
    try {
      await _firebaseService.saveQuizResult(
        userId: _userId,
        quizId: quizId,
        score: score,
        totalPoints: totalPoints,
        timeSpent: timeSpent,
        answers: answers,
      );
      print('✅ Résultat du quiz sauvegardé');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur sauvegarde résultat: $e');
    }
  }

  /// Stream des résultats de l'utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserQuizResults() {
    if (_userId.isEmpty) {
      return const Stream.empty();
    }
    return _firebaseService.streamUserQuizResults(_userId);
  }

  /// Changer de niveau
  void setLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }
}
