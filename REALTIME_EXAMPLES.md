# Exemples d'utilisation: Données en temps réel

## 1. Afficher les données en temps réel dans un widget

### Exemple simple avec StreamBuilder

```dart
// Dans votre page
StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  stream: FirebaseService().streamUserProfile(userId),
  builder: (context, snapshot) {
    // États de la connexion
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('Erreur: ${snapshot.error}');
    }
    
    // Les données se mettent à jour automatiquement ici
    final userData = snapshot.data?.data();
    return Text('Points: ${userData?['totalPoints']}');
  },
)
```

## 2. Scénarios en temps réel

### A. Mise à jour immédiate du profil utilisateur

**Code:**
```dart
// Quand l'utilisateur gagne des points
await firebaseService.updateUserStats(
  userId: userId,
  totalPoints: newPoints,
  lessonsCompleted: lessonsCount,
  quizzesCompleted: quizzesCount,
  streakDays: currentStreak,
);

// Le widget StreamBuilder se met à jour AUTOMATIQUEMENT
// car il écoute le stream sur le même document
```

**Résultat:** 
- Les points s'affichent immédiatement sur la page d'accueil
- Le leaderboard se met à jour pour tous les utilisateurs
- Les achievements se débloquent en temps réel

### B. Leaderboard avec actualisations en live

**Code:**
```dart
ListView.builder(
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    final entry = snapshot.data!.docs[index];
    final rank = index + 1; // Le rang se met à jour si quelqu'un dépasse
    
    return ListTile(
      title: Text('#$rank ${entry['username']}'),
      trailing: Text('${entry['totalPoints']} pts'),
    );
  },
);

// À chaque fois qu'un utilisateur gagne des points,
// Le leaderboard se trie automatiquement grâce à la query Firestore
```

### C. Commentaires qui apparaissent en temps réel

**Code:**
```dart
// Utilisateur 1 ajoute un commentaire
await firebaseService.addComment(
  userId: 'user_1',
  username: 'Alice',
  content: 'Excellent contenu!',
  lessonId: 'lesson_123',
);

// Utilisateurs 2, 3, 4... voient le nouveau commentaire
// s'afficher automatiquement dans leur StreamBuilder
```

## 3. Sync bidirectionnel (Afficher + Modifier)

### Quiz en temps réel

**Configuration:**
```dart
// ViewModel Quiz
class QuizViewModel extends ChangeNotifier {
  Stream<QuerySnapshot> streamCurrentQuizzes() {
    return FirebaseService().streamQuizzesByLevel(level);
  }
  
  // Quand l'utilisateur complète un quiz
  Future<void> completeQuiz(String quizId, int score) async {
    await FirebaseService().saveQuizResult(
      userId: userId,
      quizId: quizId,
      score: score,
      totalPoints: 100,
      timeSpent: timeSpent,
    );
    
    // Déclencher la mise à jour du profil
    await updateUserPoints();
  }
}
```

**Dans la page:**
```dart
// Voir les quiz disponibles
StreamBuilder(stream: quizViewModel.streamCurrentQuizzes(), ...),

// Quand l'utilisateur complète → le score s'ajoute à Firestore
// Les autres pages voient les scores mises à jour en temps réel
```

## 4. Cas d'usage complexe: Système de défis

### Configuration complète

```dart
// Page des défis
class ChallengesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserRealtimeViewModel>();
    
    return Column(
      children: [
        // Défis disponibles (depuis Firestore)
        StreamBuilder(
          stream: FirebaseService().streamDailyChallenges(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final challenge = snapshot.data!.docs[index];
                
                return ChallengeCard(
                  title: challenge['title'],
                  reward: challenge['points'],
                  onComplete: () {
                    // Marquer le défi comme complété
                    userViewModel.progressChallenge(challenge.id);
                    
                    // Ajouter les points
                    userViewModel.addPoints(challenge['points']);
                    
                    // Les changements se propagent à travers l'app
                  },
                );
              },
            );
          },
        ),
        
        // Afficher les points actuels (mis à jour en temps réel)
        StreamBuilder(
          stream: userViewModel.streamUserProfile(),
          builder: (context, snapshot) {
            final points = snapshot.data?['totalPoints'] ?? 0;
            return Text('Points: $points');
          },
        ),
      ],
    );
  }
}
```

## 5. Patterns recommandés

### ✅ Pattern 1: Une source de vérité (Firestore)

```dart
// ❌ Mauvais: Stocker les données localement ET dans Firestore
localData = loadFromSharedPreferences();
userPoints = localData['points']; // ❌ Peut être obsolète

// ✅ Bon: Lire directement de Firestore via stream
StreamBuilder(
  stream: firebaseService.streamUserProfile(userId),
  builder: (context, snapshot) {
    final userPoints = snapshot.data?['totalPoints'];
  },
)
```

### ✅ Pattern 2: Cache local + Firestore

```dart
class OptimizedViewModel extends ChangeNotifier {
  final FirebaseService _fire = FirebaseService();
  Map<String, dynamic> _localCache = {};
  
  Stream<DocumentSnapshot> streamUserData(String userId) {
    // Retourner le stream Firestore
    // Firestore gère automatiquement la persistance locale
    return _fire.streamUserProfile(userId);
  }
  
  Future<void> updateData(String userId, Map data) async {
    // Mise à jour optimiste: afficher tout de suite
    _localCache = data;
    notifyListeners();
    
    // Sauvegarder dans Firestore
    try {
      await _fire.updateUserStats(...);
    } catch (e) {
      // Revert si erreur
      print('Erreur: $e');
    }
  }
}
```

### ✅ Pattern 3: Combiner plusieurs streams

```dart
// Afficher l'utilisateur + ses achievements + son leaderboard
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stream 1: Profil utilisateur
        StreamBuilder(
          stream: firebaseService.streamUserProfile(userId),
          builder: (context, userSnapshot) {
            // Stream 2: Achievements (dépend de l'utilisateur)
            return StreamBuilder(
              stream: firebaseService.streamUserAchievements(userId),
              builder: (context, achievementSnapshot) {
                // Stream 3: Position dans le leaderboard
                return StreamBuilder(
                  stream: firebaseService.streamGlobalLeaderboard(),
                  builder: (context, leaderboardSnapshot) {
                    // Tous les streams se mettent à jour en temps réel
                    return DashboardContent(
                      userData: userSnapshot.data?.data(),
                      achievements: achievementSnapshot.data?.docs,
                      leaderboard: leaderboardSnapshot.data?.docs,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
```

## 6. Gestion des erreurs

```dart
StreamBuilder<DocumentSnapshot>(
  stream: firebaseService.streamUserProfile(userId),
  builder: (context, snapshot) {
    // 1. État de chargement
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingWidget();
    }
    
    // 2. Erreur réseau
    if (snapshot.hasError) {
      return ErrorWidget(
        error: snapshot.error,
        retry: () => setState(() {}),
      );
    }
    
    // 3. Pas de données
    if (!snapshot.hasData) {
      return const EmptyWidget();
    }
    
    // 4. Données valides
    return ContentWidget(data: snapshot.data!);
  },
)
```

## 7. Performance et optimisation

### Limiter les résultats
```dart
// Au lieu de:
firebaseService.streamGlobalLeaderboard() // Charge les 100 premiers

// Utiliser:
firebaseService.streamGlobalLeaderboard(limit: 10) // Charge seulement 10
```

### Pagination
```dart
// Première page
streamGlobalLeaderboard(limit: 20)

// Deuxième page (gérer manuellement avec le ViewModel)
streamGlobalLeaderboard(limit: 40)
```

### Indexation Firestore
```
Pour les requêtes complexes, créer des index composites:
- collection: leaderboard
- fields: totalPoints (Descending), username (Ascending)
```

## 8. Debug: Voir les streams en action

```dart
// Ajouter du logging
Stream<DocumentSnapshot> debugStream(String userId) {
  return firebaseService.streamUserProfile(userId)
    .map((snapshot) {
      print('📨 Nouvelle donnée reçue: ${snapshot.data()}');
      return snapshot;
    });
}

// Ou avec StreamBuilder
StreamBuilder(
  stream: debugStream(userId),
  builder: (context, snapshot) {
    print('🔄 Rebuild avec: ${snapshot.data}');
    return MyWidget();
  },
)
```

## 9. Checklist pour implémenter les données en temps réel

- [ ] Service Firebase créé avec tous les streams
- [ ] ViewModels avec Provider configurés
- [ ] MultiProvider ajouté au main.dart
- [ ] Pages mises à jour avec StreamBuilder
- [ ] Tests avec Firestore emulator local
- [ ] Règles de sécurité Firestore configurées
- [ ] Authentification Firebase intégrée
- [ ] Cache hors-ligne activé (Settings)
- [ ] Monitoring avec Firebase Analytics
- [ ] Performance testée (paginer si besoin)
