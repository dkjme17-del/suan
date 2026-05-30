// Clés de localStorage
class StorageKeys {
  static const String userKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String lessonProgressKey = 'lesson_progress';
  static const String quizResultsKey = 'quiz_results';
  static const String favoritesKey = 'favorites';
  static const String settingsKey = 'settings';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String lastSyncKey = 'last_sync';
}

// Messages d'erreur
class ErrorMessages {
  static const String networkError = 'Erreur réseau. Vérifiez votre connexion.';
  static const String invalidEmail = 'Email invalide';
  static const String weakPassword =
      'Le mot de passe doit contenir au moins 6 caractères';
  static const String passwordMismatch =
      'Les mots de passe ne correspondent pas';
  static const String userNotFound = 'Utilisateur non trouvé';
  static const String invalidCredentials = 'Identifiants invalides';
  static const String unknownError = 'Une erreur inconnue s\'est produite';
}

// Messages de succès
class SuccessMessages {
  static const String registrationSuccess = 'Inscription réussie!';
  static const String loginSuccess = 'Connexion réussie!';
  static const String lessonCompleted = 'Leçon complétée! +10 points';
  static const String quizCompleted = 'Quiz complété!';
  static const String profileUpdated = 'Profil mis à jour';
}
