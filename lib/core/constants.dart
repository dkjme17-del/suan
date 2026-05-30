// Constantes de l'application
class AppConstants {
  // Modes d'apprentissage
  static const String LEARNING_MODE_CLASSIC = 'classic';
  static const String LEARNING_MODE_LUDIQUE = 'ludique';
  static const String LEARNING_MODE_NON_ALPHABETIC = 'non_alphabetic';

  // Niveaux
  static const String LEVEL_BEGINNER = 'beginner';
  static const String LEVEL_INTERMEDIATE = 'intermediate';
  static const String LEVEL_ADVANCED = 'advanced';

  // Durée des leçons (secondes)
  static const int LESSON_DURATION = 5 * 60; // 5 minutes

  // Espace storage Hive
  static const String HIVE_BOX_USER = 'user_box';
  static const String HIVE_BOX_LESSONS = 'lessons_box';
  static const String HIVE_BOX_PROGRESS = 'progress_box';

  // Points de gamification
  static const int POINTS_LESSON_COMPLETE = 10;
  static const int POINTS_QUIZ_CORRECT = 5;
  static const int POINTS_PRONUNCIATION_GOOD = 8;
}
