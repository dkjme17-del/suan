import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/utils/logger.dart';

/// Entité Quiz
class Quiz {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final List<Question> questions;
  final int difficulty;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.questions,
    required this.difficulty,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      questions:
          (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      difficulty: json['difficulty'] ?? 1,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Entité Question
class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream toutes les catégories de quiz en temps réel
  Stream<List<Map<String, dynamic>>> streamQuizCategories() {
    return _firestore
        .collection('quiz_categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              // Assure un id stable même si le champ "id" n'existe pas
              'id': (data['id'] as String?)?.trim().isNotEmpty == true
                  ? data['id']
                  : doc.id,
            };
          }).toList();
        })
        .handleError((error) {
          Logger.error('Erreur quiz categories', error);
          return [];
        });
  }

  /// Stream les défis quotidiens en temps réel
  Stream<List<Map<String, dynamic>>> streamDailyChallenges() {
    return _firestore
        .collection('daily_challenges')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        })
        .handleError((error) {
          Logger.error('Erreur daily challenges', error);
          return [];
        });
  }

  /// Stream les quiz d'une catégorie
  Stream<List<Map<String, dynamic>>> streamQuizByCategory(String categoryId) {
    return _firestore
        .collection('quizzes')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        })
        .handleError((error) {
          Logger.error('Erreur quiz by category', error);
          return [];
        });
  }

  /// Sauvegarde la réponse d'un utilisateur à un quiz
  Future<void> saveQuizAnswer({
    required String userId,
    required String quizId,
    required String answer,
    required bool isCorrect,
    required int pointsEarned,
  }) async {
    try {
      await _firestore.collection('user_quiz_answers').add({
        'userId': userId,
        'quizId': quizId,
        'answer': answer,
        'isCorrect': isCorrect,
        'pointsEarned': pointsEarned,
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (isCorrect) {
        // Mettre à jour les statistiques utilisateur
        await _firestore.collection('users').doc(userId).update({
          'stats.quizzesCompleted': FieldValue.increment(1),
          'stats.totalPoints': FieldValue.increment(pointsEarned),
        });
      }
    } catch (e) {
      Logger.error('Erreur sauvegarde réponse quiz', e);
      rethrow;
    }
  }

  /// Récupère les statistiques utilisateur pour les quiz
  Future<Map<String, dynamic>> getUserQuizStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_quiz_answers')
          .where('userId', isEqualTo: userId)
          .get();

      int correct = 0;
      int total = snapshot.docs.length;
      int totalPoints = 0;

      for (var doc in snapshot.docs) {
        if (doc['isCorrect'] == true) correct++;
        totalPoints += (doc['pointsEarned'] as num?)?.toInt() ?? 0;
      }

      return {
        'totalAnswers': total,
        'correctAnswers': correct,
        'accuracy': total > 0
            ? (correct / total * 100).toStringAsFixed(1)
            : '0',
        'totalPoints': totalPoints,
      };
    } catch (e) {
      Logger.error('Erreur récupération stats quiz', e);
      return {
        'totalAnswers': 0,
        'correctAnswers': 0,
        'accuracy': '0',
        'totalPoints': 0,
      };
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

      Logger.info('Défi complété: $challengeId');
    } catch (e) {
      Logger.error('Erreur complétion défi quotidien', e);
      rethrow;
    }
  }

  /// Récupère tous les quiz
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      final snapshot = await _firestore.collection('quizzes').get();
      return snapshot.docs.map((doc) => Quiz.fromJson(doc.data())).toList();
    } catch (e) {
      Logger.error('Erreur récupération quiz par ID', e);
      return []; // Return empty list instead of null
    }
  }

  /// Récupère un quiz par ID
  Future<Quiz?> getQuizById(String quizId) async {
    try {
      final snapshot = await _firestore.collection('quizzes').doc(quizId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return Quiz.fromJson(snapshot.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Erreur récupération quiz par ID', e);
      return null;
    }
  }

  /// Stream de tous les quiz
  Stream<List<Quiz>> streamAllQuizzes() {
    return _firestore
        .collection('quizzes')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Quiz.fromJson(doc.data())).toList(),
        )
        .handleError((error) {
          Logger.error('Erreur stream quiz', error);
          return <Quiz>[];
        });
  }
}
