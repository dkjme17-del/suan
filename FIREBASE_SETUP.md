# Guide Firebase Firestore pour SUAN

## Structure de Base de Données Firestore

### Collections principales

#### 1. **users/** - Profils utilisateur
```json
users/{userId}
{
  "username": "Apprenant Baoulé",
  "email": "user@example.com",
  "level": 3,
  "totalPoints": 5000,
  "streakDays": 7,
  "avatar": "url_avatar",
  "friends": ["user_2", "user_3"],
  "stats": {
    "lessonsCompleted": 15,
    "quizzesCompleted": 8,
    "averageScore": 85
  },
  "createdAt": "2026-03-10T10:00:00Z",
  "updatedAt": "2026-03-10T15:30:00Z"
}
```

#### 2. **lessons/** - Contenu des leçons
```json
lessons/{lessonId}
{
  "title": "Salutations Baoulés",
  "content": "Bonjour = Gninwahi",
  "level": 1,
  "language": "baoulé",
  "duration": 10,
  "audioUrl": "url_audio",
  "imageUrl": "url_image",
  "tags": ["salutations", "débutant"],
  "views": 250,
  "createdAt": "2026-02-01T10:00:00Z"
}
```

#### 3. **quizzes/** - Quiz et évaluations
```json
quizzes/{quizId}
{
  "title": "Quiz Niveau 1",
  "level": 1,
  "questions": [
    {
      "id": "q1",
      "text": "Comment dit-on bonjour?",
      "options": ["Gninwahi", "M'blo", "Ayé", "Oya"],
      "correctAnswer": 0,
      "points": 10
    }
  ],
  "totalPoints": 100,
  "timeLimit": 300,
  "createdAt": "2026-02-01T10:00:00Z"
}
```

#### 4. **quiz_results/** - Résultats des quiz
```json
quiz_results/{resultId}
{
  "userId": "user_123",
  "quizId": "quiz_456",
  "score": 85,
  "totalPoints": 100,
  "pointsEarned": 50,
  "timeSpent": 245,
  "answers": ["0", "2", "1"],
  "completedAt": "2026-03-10T14:30:00Z"
}
```

#### 5. **leaderboard/** - Classement global
```json
leaderboard/{userId}
{
  "username": "Apprenant Baoulé",
  "totalPoints": 5000,
  "level": 3,
  "rank": 1,
  "updatedAt": "2026-03-10T15:30:00Z"
}
```

#### 6. **comments/** - Commentaires sur les leçons
```json
comments/{commentId}
{
  "userId": "user_123",
  "username": "Apprenant Baoulé",
  "lessonId": "lesson_456",
  "content": "Très utile!",
  "likes": 5,
  "replies": 2,
  "createdAt": "2026-03-10T14:30:00Z"
}
```

#### 7. **news/** - Actualités et annonces
```json
news/{newsId}
{
  "title": "Nouvelle leçon disponible",
  "content": "Découvrez notre nouvelle leçon...",
  "imageUrl": "url_image",
  "featured": true,
  "views": 350,
  "createdAt": "2026-03-10T10:00:00Z",
  "updatedAt": "2026-03-10T15:00:00Z"
}
```

#### 8. **achievements/** - Réussissements
```json
achievements/{achievementId}
{
  "title": "Maître des quiz",
  "description": "Réussir 10 quiz avec 90%+",
  "icon": "🏆",
  "points": 500,
  "requirement": 10,
  "type": "quiz_mastery"
}
```

#### 9. **user_achievements/** - Achievements déverrouillés par utilisateur
```json
user_achievements/{userId}/{achievementId}
{
  "achievementId": "achievement_123",
  "title": "Maître des quiz",
  "unlockedAt": "2026-03-10T14:30:00Z",
  "progress": 100
}
```

## Règles de Sécurité Firestore

Ajoutez ces règles dans Firebase Console → Firestore → Règles :

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permettre la lecture de tous les documents publics
    match /lessons/{document=**} {
      allow read;
      allow write: if request.auth != null && request.auth.uid == resource.data.createdBy;
    }
    
    // Les utilisateurs peuvent lire/écrire leurs propres données
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Quiz et résultats
    match /quizzes/{document=**} {
      allow read;
    }
    match /quiz_results/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Commentaires
    match /comments/{document=**} {
      allow read;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Leaderboard (lecture publique)
    match /leaderboard/{document=**} {
      allow read;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // News (lecture publique)
    match /news/{document=**} {
      allow read;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Achievements
    match /achievements/{document=**} {
      allow read;
    }
    match /user_achievements/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Utilisation dans le code

### 1. Créer un utilisateur
```dart
await firebaseService.createUserProfile(
  userId: user.uid,
  username: 'Mon Nom',
  email: user.email,
  level: 1,
  totalPoints: 0,
);
```

### 2. Écouter les mises à jour en temps réel
```dart
Stream<DocumentSnapshot> userStream = firebaseService.streamUserProfile(userId);
userStream.listen((doc) {
  // Mettre à jour l'UI avec les nouvelles données
  print(doc.data());
});
```

### 3. Récupérer le leaderboard
```dart
Stream<QuerySnapshot> leaderboard = firebaseService.streamGlobalLeaderboard();
```

### 4. Ajouter un commentaire
```dart
await firebaseService.addComment(
  userId: userId,
  username: 'Mon Nom',
  content: 'Excellent contenu!',
  lessonId: lessonId,
);
```

## Intégration avec Provider

```dart
// Dans votre ViewModel
Stream<DocumentSnapshot> get userProfileStream => 
  FirebaseService().streamUserProfile(_userId);

// Dans le widget
StreamBuilder(
  stream: viewModel.userProfileStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final userData = snapshot.data!.data() as Map;
      return Text('Points: ${userData['totalPoints']}');
    }
    return const CircularProgressIndicator();
  },
)
```

## Structure recommandée des fichiers

```
lib/
├── shared/
│   └── services/
│       ├── firebase_service.dart      # Service principal
│       ├── auth_service.dart          # Authentification Firebase
│       ├── lesson_service.dart        # Gestion des leçons
│       └── quiz_service.dart          # Gestion des quiz
├── features/
│   ├── learning/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── lesson.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── lesson_repository.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       └── pages/
│   ├── quiz/
│   │   └── ...
│   └── leaderboard/
│       └── ...
```

## Bonnes pratiques

1. **Authentification**: Utilisez Firebase Authentication pour sécuriser les données
2. **Indexation**: Créez des index Firestore pour les requêtes complexes
3. **Cache local**: Utilisez Hive ou Sqflite pour le cache hors-ligne
4. **Pagination**: Implémentez la pagination pour les listes longues
5. **Monitoring**: Utilisez Cloud Monitoring pour surveiller l'utilisation
6. **Coûts**: Utilisez les index composites avec prudence (coûts de lecture/écriture)

## Déploiement

1. Firebase Deploy (Firestore auto-déployée)
2. Sauvegardes: Configurez les sauvegardes automatiques dans Firebase Console
3. Monitoring: Utilisez Firebase Analytics pour suivre l'utilisation

