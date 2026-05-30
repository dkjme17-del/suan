import 'package:flutter/material.dart';
import 'package:suan/shared/services/quiz_service.dart';
import 'package:suan/features/quiz/domain/entities/quiz.dart' as quiz_entity;
import '../../../../core/utils/logger.dart';

class QuizViewModel extends ChangeNotifier {
  final QuizService quizService;

  List<quiz_entity.Quiz> _quizzes = [];
  quiz_entity.Quiz? _currentQuiz;
  bool _isLoading = false;
  Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;

  QuizViewModel({required this.quizService});

  // Getters
  List<quiz_entity.Quiz> get quizzes => _quizzes;
  quiz_entity.Quiz? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get answers => _answers;

  int get totalQuestions => _currentQuiz?.questions.length ?? 0;
  quiz_entity.Question? get currentQuestion =>
      _currentQuestionIndex < (_currentQuiz?.questions.length ?? 0)
      ? _currentQuiz!.questions[_currentQuestionIndex]
      : null;

  Future<void> init() async {
    await loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load quizzes from Firestore using QuizService and convert to domain entity
      final serviceQuizzes = await quizService.getAllQuizzes();
      _quizzes = serviceQuizzes.map((q) => quiz_entity.Quiz(
        id: q.id,
        title: q.title,
        description: q.description,
        categoryId: q.categoryId,
        questions: q.questions.map((question) => quiz_entity.Question(
          id: question.id,
          question: question.question,
          options: question.options,
          correctAnswer: question.correctAnswer,
          explanation: question.explanation,
        )).toList(),
        difficulty: q.difficulty,
        createdAt: q.createdAt,
      )).toList();
      Logger.info('Quiz chargés: ${_quizzes.length}');
    } catch (e) {
      Logger.error('Erreur lors du chargement des quiz', e);
      _quizzes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startQuiz(String quizId) async {
    try {
      // Load quiz from Firestore using QuizService
      final serviceQuiz = await quizService.getQuizById(quizId);
      
      if (serviceQuiz != null) {
        _currentQuiz = quiz_entity.Quiz(
          id: serviceQuiz.id,
          title: serviceQuiz.title,
          description: serviceQuiz.description,
          categoryId: serviceQuiz.categoryId,
          questions: serviceQuiz.questions.map((question) => quiz_entity.Question(
            id: question.id,
            question: question.question,
            options: question.options,
            correctAnswer: question.correctAnswer,
            explanation: question.explanation,
          )).toList(),
          difficulty: serviceQuiz.difficulty,
          createdAt: serviceQuiz.createdAt,
        );
      } else {
        // Fallback if quiz not found
        _currentQuiz = quiz_entity.Quiz(
          id: quizId,
          title: 'Quiz en cours',
          description: '',
          questions: [],
          createdAt: DateTime.now(),
        );
      }
      
      _answers = {};
      _currentQuestionIndex = 0;
      notifyListeners();
    } catch (e) {
      Logger.error('Erreur lors du démarrage du quiz', e);
      // Still set a basic quiz to prevent null errors
      _currentQuiz = quiz_entity.Quiz(
        id: quizId,
        title: 'Quiz en cours',
        description: '',
        questions: [],
        createdAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void selectAnswer(String questionId, String answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  bool get isLastQuestion {
    if (_currentQuiz == null) return true;
    return _currentQuestionIndex >= _currentQuiz!.questions.length - 1;
  }

  String? getCurrentQuestionText() {
    if (_currentQuiz == null ||
        _currentQuestionIndex >= _currentQuiz!.questions.length) {
      return null;
    }
    return _currentQuiz!.questions[_currentQuestionIndex].question;
  }

  List<String> getCurrentQuestionOptions() {
    if (_currentQuiz == null ||
        _currentQuestionIndex >= _currentQuiz!.questions.length) {
      return [];
    }
    return _currentQuiz!.questions[_currentQuestionIndex].options;
  }

  String? getCurrentQuestionCorrectAnswer() {
    if (_currentQuiz == null ||
        _currentQuestionIndex >= _currentQuiz!.questions.length) {
      return null;
    }
    return _currentQuiz!.questions[_currentQuestionIndex].correctAnswer;
  }

  double getProgress() {
    if (_currentQuiz == null) return 0.0;
    final totalQuestions = _currentQuiz!.questions.length;
    final answeredQuestions = _answers.length;
    return totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;
  }

  Future<void> submitQuiz() async {
    if (_currentQuiz == null) return;

    int correctAnswers = 0;
    int totalPoints = 0;

    for (int i = 0; i < _currentQuiz!.questions.length; i++) {
      final question = _currentQuiz!.questions[i];
      final userAnswer = _answers[question.id];
      if (userAnswer == question.correctAnswer) {
        correctAnswers++;
        totalPoints += 10; // 10 points par bonne réponse
      }
    }

    final accuracy = _currentQuiz!.questions.length > 0
        ? (correctAnswers / _currentQuiz!.questions.length * 100).round()
        : 0;

    // Sauvegarder le résultat
    try {
      await quizService.saveQuizAnswer(
        userId: 'current_user_id', // À remplacer avec l'ID utilisateur réel
        quizId: _currentQuiz!.id,
        answer: 'completed',
        isCorrect: true,
        pointsEarned: totalPoints,
      );

      Logger.info(
        'Quiz complété: ${_currentQuiz!.id}, Score: $totalPoints/$accuracy%',
      );
    } catch (e) {
      Logger.error('Erreur sauvegarde quiz', e);
    }

    // Réinitialiser pour le prochain quiz
    _currentQuiz = null;
    _answers = {};
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  int getScore() {
    int score = 0;
    for (final answer in _answers.values) {
      if (answer.isNotEmpty) score += 10;
    }
    return score;
  }
}
