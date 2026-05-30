import 'dart:async';

/// Service Analytics pour tracker et analyser les actions utilisateur
/// 
/// Gère:
/// - Event tracking
/// - User behavior analytics
/// - Performance metrics
/// - Engagement tracking

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final List<AnalyticEvent> _events = [];
  final StreamController<AnalyticEvent> _eventStream =
      StreamController<AnalyticEvent>.broadcast();
  
  String _userId = '';
  DateTime? _sessionStart;

  /// Initialiser le service analytics
  void initialize(String userId) {
    _userId = userId;
    _sessionStart = DateTime.now();
    logEvent('session_start', {
      'userId': userId,
      'timestamp': _sessionStart!.toIso8601String(),
    });
  }

  /// Logger un événement
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    final event = AnalyticEvent(
      name: eventName,
      userId: _userId,
      timestamp: DateTime.now(),
      parameters: parameters,
    );

    _events.add(event);
    _eventStream.add(event);

    print('📊 Event logged: $eventName');
  }

  /// Logger une action d'apprentissage
  void logLessonCompleted({
    required String lessonId,
    required String title,
    required int durationSeconds,
    required String level,
  }) {
    logEvent('lesson_completed', {
      'lesson_id': lessonId,
      'title': title,
      'duration_seconds': durationSeconds,
      'level': level,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger la complétion d'un quiz
  void logQuizCompleted({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeSeconds,
    required String difficulty,
  }) {
    logEvent('quiz_completed', {
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': (score / totalQuestions * 100).toInt(),
      'time_seconds': timeSeconds,
      'difficulty': difficulty,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger la prononciation pratiquée
  void logPronunciationPractice({
    required String word,
    required double score,
    required int recordedDuration,
  }) {
    logEvent('pronunciation_practice', {
      'word': word,
      'score': score.toStringAsFixed(2),
      'recorded_duration': recordedDuration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger un défi quotidien complété
  void logDailyChallengeCompleted({
    required String challengeId,
    required String title,
    required int rewardPoints,
  }) {
    logEvent('daily_challenge_completed', {
      'challenge_id': challengeId,
      'title': title,
      'reward_points': rewardPoints,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger un achievement déverrouillé
  void logAchievementUnlocked({
    required String achievementId,
    required String title,
    required int reward,
  }) {
    logEvent('achievement_unlocked', {
      'achievement_id': achievementId,
      'title': title,
      'reward': reward,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger une interaction utilisateur
  void logUserInteraction({
    required String screen,
    required String action,
    String? elementId,
  }) {
    logEvent('user_interaction', {
      'screen': screen,
      'action': action,
      'element_id': elementId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Logger une erreur
  void logError({
    required String errorType,
    required String message,
    String? stackTrace,
  }) {
    logEvent('error', {
      'error_type': errorType,
      'message': message,
      'stack_trace': stackTrace,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Obtenir un stream des événements
  Stream<AnalyticEvent> getEventStream() => _eventStream.stream;

  /// Obtenir les statistiques de session
  SessionStats getSessionStats() {
    final lessonEvents = _events.where((e) => e.name == 'lesson_completed');
    final quizEvents = _events.where((e) => e.name == 'quiz_completed');
    final challengeEvents =
        _events.where((e) => e.name == 'daily_challenge_completed');

    final totalLessons = lessonEvents.length;
    final totalQuizzes = quizEvents.length;
    final totalChallenges = challengeEvents.length;

    final totalTimeSeconds = lessonEvents.fold<int>(
      0,
      (sum, e) => sum + (e.parameters['duration_seconds'] as int? ?? 0),
    );

    final avgQuizScore = quizEvents.isEmpty
        ? 0
        : quizEvents.fold<int>(
              0,
              (sum, e) =>
                  sum + (e.parameters['percentage'] as int? ?? 0),
            ) ~/
            quizEvents.length;

    final sessionDuration =
        DateTime.now().difference(_sessionStart!).inSeconds;

    return SessionStats(
      totalLessons: totalLessons,
      totalQuizzes: totalQuizzes,
      totalChallenges: totalChallenges,
      totalTimeSeconds: totalTimeSeconds,
      sessionDurationSeconds: sessionDuration,
      averageQuizScore: avgQuizScore,
    );
  }

  /// Obtenir les statistiques détaillées par catégorie
  Map<String, dynamic> getDetailedStats() {
    final stats = <String, dynamic>{};

    // Lessons par niveau
    Map<String, int> lessonsByLevel = {};
    for (var event in _events.where((e) => e.name == 'lesson_completed')) {
      final level = event.parameters['level'] as String? ?? 'unknown';
      lessonsByLevel[level] = (lessonsByLevel[level] ?? 0) + 1;
    }
    stats['lessons_by_level'] = lessonsByLevel;

    // Quizzes par difficulté
    Map<String, int> quizzesByDifficulty = {};
    for (var event in _events.where((e) => e.name == 'quiz_completed')) {
      final difficulty =
          event.parameters['difficulty'] as String? ?? 'unknown';
      quizzesByDifficulty[difficulty] =
          (quizzesByDifficulty[difficulty] ?? 0) + 1;
    }
    stats['quizzes_by_difficulty'] = quizzesByDifficulty;

    // Défis complétés par jour
    Map<String, int> challengesByDay = {};
    for (var event
        in _events.where((e) => e.name == 'daily_challenge_completed')) {
      final date = event.timestamp.toString().split(' ')[0];
      challengesByDay[date] = (challengesByDay[date] ?? 0) + 1;
    }
    stats['challenges_by_day'] = challengesByDay;

    // Achievements déverrouillés par jour
    Map<String, int> achievementsByDay = {};
    for (var event
        in _events.where((e) => e.name == 'achievement_unlocked')) {
      final date = event.timestamp.toString().split(' ')[0];
      achievementsByDay[date] = (achievementsByDay[date] ?? 0) + 1;
    }
    stats['achievements_by_day'] = achievementsByDay;

    return stats;
  }

  /// Exporter les événements en format JSON pour upload
  Map<String, dynamic> exportEventsAsJson() {
    return {
      'userId': _userId,
      'sessionStart': _sessionStart?.toIso8601String(),
      'exportTime': DateTime.now().toIso8601String(),
      'totalEvents': _events.length,
      'events': _events.map((e) => e.toMap()).toList(),
    };
  }

  /// Nettoyer les événements anciens (> 30 jours)
  void cleanOldEvents({int daysOld = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    _events.removeWhere((e) => e.timestamp.isBefore(cutoffDate));
    print('🧹 Cleaned events older than $daysOld days');
  }

  void dispose() {
    logEvent('session_end', {
      'userId': _userId,
      'sessionDuration': DateTime.now().difference(_sessionStart!).inSeconds,
      'totalEvents': _events.length,
    });
    _eventStream.close();
  }
}

/// Modèle pour un événement analytics
class AnalyticEvent {
  final String name;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;

  AnalyticEvent({
    required this.name,
    required this.userId,
    required this.timestamp,
    required this.parameters,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'parameters': parameters,
      };

  @override
  String toString() =>
      'AnalyticEvent(name: $name, userId: $userId, timestamp: $timestamp)';
}

/// Modèle pour les statistiques de session
class SessionStats {
  final int totalLessons;
  final int totalQuizzes;
  final int totalChallenges;
  final int totalTimeSeconds;
  final int sessionDurationSeconds;
  final int averageQuizScore;

  SessionStats({
    required this.totalLessons,
    required this.totalQuizzes,
    required this.totalChallenges,
    required this.totalTimeSeconds,
    required this.sessionDurationSeconds,
    required this.averageQuizScore,
  });

  String get formattedTotalTime {
    final hours = totalTimeSeconds ~/ 3600;
    final minutes = (totalTimeSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedSessionDuration {
    final hours = sessionDurationSeconds ~/ 3600;
    final minutes = (sessionDurationSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toMap() => {
        'total_lessons': totalLessons,
        'total_quizzes': totalQuizzes,
        'total_challenges': totalChallenges,
        'total_time_seconds': totalTimeSeconds,
        'session_duration_seconds': sessionDurationSeconds,
        'average_quiz_score': averageQuizScore,
      };
}
