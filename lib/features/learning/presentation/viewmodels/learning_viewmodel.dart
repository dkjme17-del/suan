import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/lesson_service.dart';
import 'package:suan/features/learning/domain/entities/lesson.dart';
import '../../../community/domain/services/real_community_service.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/utils/logger.dart';

class LearningViewModel extends ChangeNotifier {
  final LessonService lessonService;
  final RealCommunityService? communityService;
  final StorageService storageService;

  List<Lesson> _lessons = [];
  List<Lesson> _favorites = [];
  Lesson? _currentLesson;
  bool _isLoading = false;
  String _currentLevel = 'beginner';
  UserProfile? _currentUser;

  LearningViewModel({
    required this.lessonService,
    required this.communityService,
    required this.storageService,
  });

  // Getters
  List<Lesson> get lessons => _lessons;
  List<Lesson> get favorites => _favorites;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String get currentLevel => _currentLevel;
  UserProfile? get currentUser => _currentUser;

  double get progressPercentage {
    if (_lessons.isEmpty) return 0.0;

    final completedLessons = _lessons
        .where((lesson) => lesson.isCompleted)
        .length;
    return completedLessons / _lessons.length;
  }

  Future<void> init() async {
    await loadUserProgress();
    await loadLessonsByLevel('beginner');
  }

  // Charger l'utilisateur actuel
  Future<void> loadUserProgress() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Charger les stats depuis le stockage local
      final stats = storageService.getJson('user_stats') ?? {};
      final totalPoints = stats['totalPoints'] as int? ?? 0;
      final streakDays = stats['streakDays'] as int? ?? 0;

      // Calcul simple de niveau à partir des points
      final level = 1 + (totalPoints ~/ 500);

      // Récupérer le nom de l'utilisateur connecté depuis Firebase Auth
      String userName = 'Apprenant Baoulé'; // Valeur par défaut
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null &&
          currentUser.displayName != null &&
          currentUser.displayName!.isNotEmpty) {
        userName = currentUser.displayName!;
      } else {
        // Fallback vers le stockage local si Firebase Auth n'est pas disponible
        final userData = storageService.getJson('user_data');
        if (userData != null &&
            userData['name'] != null &&
            userData['name'].toString().isNotEmpty) {
          userName = userData['name'] as String;
        }
      }

      _currentUser = UserProfile(
        id: 'current_user',
        username: userName,
        level: level,
        totalPoints: totalPoints,
        streakDays: streakDays,
        avatarUrl: null,
        friends: const [],
        createdAt: DateTime.now(),
        bio: null,
        lessonsCompleted: 0,
        quizzesCompleted: 0,
        averageScore: 0.0,
      );

      if (communityService != null) {
        communityService!.setCurrentUser(_currentUser!);
      }
    } catch (e) {
      Logger.error('Erreur lors du chargement du profil', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonsByLevel(String level) async {
    _isLoading = true;
    _currentLevel = level;
    notifyListeners();

    try {
      _lessons = lessonService.getLessonsByLevel(level);
      await Future.delayed(Duration(milliseconds: 500)); // Simulation
    } catch (e) {
      Logger.error('Erreur lors du chargement des leçons', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectLesson(String lessonId) async {
    _currentLesson = lessonService.getLessonById(lessonId);
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    await lessonService.completeLesson(lessonId);
    notifyListeners();
  }

  void toggleFavorite(Lesson lesson) {
    if (_favorites.any((l) => l.id == lesson.id)) {
      _favorites.removeWhere((l) => l.id == lesson.id);
    } else {
      _favorites.add(lesson);
    }
    notifyListeners();
  }

  bool isFavorite(String lessonId) {
    return _favorites.any((l) => l.id == lessonId);
  }
}
