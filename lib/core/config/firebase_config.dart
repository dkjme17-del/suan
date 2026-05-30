/// Configuration Firebase pour SUAN
/// 
/// Cette classe configure Firebase Realtime Database et Cloud Services
/// pour synchroniser les données utilisateur et les leaderboards temps réel

class FirebaseConfig {
  // Configuration Firebase (à mettre à jour avec vos credentials)
  static const String projectId = 'suan-baoulé-app';
  static const String databaseUrl = 'https://suan-baoulé-app.firebaseio.com';
  static const String apiKey = 'YOUR_API_KEY';
  static const String authDomain = 'suan-baoulé-app.firebaseapp.com';
  
  // Chemins de base dans la base de données
  static const String usersPath = 'users';
  static const String leaderboardPath = 'leaderboards';
  static const String dailyChallengesPath = 'daily_challenges';
  static const String achievementsPath = 'achievements';
  static const String userStatsPath = 'user_stats';
  
  // Configuration des données
  static const int leaderboardRefreshInterval = 5000; // 5 secondes
  static const int dailyChallengeRefreshInterval = 60000; // 1 minute
  
  /// Points par activité
  static const Map<String, int> activityPoints = {
    'complete_lesson': 10,
    'complete_quiz': 50,
    'daily_login': 5,
    'daily_challenge_completed': 100,
    'achieve_streak_3': 20,
    'achieve_streak_7': 50,
    'achieve_streak_30': 200,
    'reach_level_2': 500,
    'reach_level_3': 1000,
  };
  
  /// Conditions d'achievements
  static const Map<String, int> achievementThresholds = {
    'first_lesson': 1,
    'lessons_10': 10,
    'lessons_50': 50,
    'lessons_100': 100,
    'quiz_master': 50,
    'streak_warrior': 7,
    'top_scorer': 5000,
    'community_leader': 10000,
  };
}
