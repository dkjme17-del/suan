# Guide d'intégration Firebase Realtime avec Provider

## 1. Configuration dans main.dart

### Importer les packages
```dart
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/user/presentation/viewmodels/user_realtime_viewmodel.dart';
import 'features/quiz/presentation/viewmodels/quiz_realtime_viewmodel.dart';
import 'features/learning/presentation/viewmodels/lesson_realtime_viewmodel.dart';
import 'features/community/presentation/viewmodels/community_realtime_viewmodel.dart';
```

### Configuration des providers
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModels en temps réel
        ChangeNotifierProvider(create: (_) => UserRealtimeViewModel()),
        ChangeNotifierProvider(create: (_) => QuizRealtimeViewModel()),
        ChangeNotifierProvider(create: (_) => LessonRealtimeViewModel()),
        ChangeNotifierProvider(create: (_) => CommunityRealtimeViewModel()),
        
        // Services
        Provider<StorageService>(create: (_) => storageService),
      ],
      child: MaterialApp(
        title: 'SUAN',
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
        // ... reste de la config
      ),
    );
  }
}
```

## 2. Utilisation dans les pages

### Afficher le profil utilisateur en temps réel

```dart
class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Initialiser le ViewModel avec l'ID utilisateur
    context.read<UserRealtimeViewModel>().initialize(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: context.read<UserRealtimeViewModel>().streamUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Pas de données'));
          }

          final userData = snapshot.data!.data() ?? {};
          
          return Column(
            children: [
              Text('Nom: ${userData['username']}'),
              Text('Niveau: ${userData['level']}'),
              Text('Points: ${userData['totalPoints']}'),
              Text('Série: ${userData['streakDays']} jours 🔥'),
              
              // Stats
              if (userData['stats'] != null) ...[
                Text('Leçons: ${userData['stats']['lessonsCompleted']}'),
                Text('Quiz: ${userData['stats']['quizzesCompleted']}'),
              ]
            ],
          );
        },
      ),
    );
  }
}
```

### Afficher les leçons en temps réel

```dart
class LessonsPage extends StatelessWidget {
  const LessonsPage();

  @override
  Widget build(BuildContext context) {
    context.read<LessonRealtimeViewModel>().initialize('user_123', level: 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Leçons')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: context.read<LessonRealtimeViewModel>().streamCurrentLevelLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Pas de leçons'));
          }

          final lessons = snapshot.data!.docs;

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index].data();
              return LessonCard(
                title: lesson['title'] ?? 'Sans titre',
                content: lesson['content'] ?? '',
                level: lesson['level'] ?? 1,
                onTap: () {
                  context.read<LessonRealtimeViewModel>()
                      .selectLesson(lessons[index].id);
                  // Naviguer vers la page de détail
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

### Afficher les quiz avec résultats en temps réel

```dart
class QuizzesPage extends StatelessWidget {
  const QuizzesPage();

  @override
  Widget build(BuildContext context) {
    context.read<QuizRealtimeViewModel>().initialize('user_123', level: 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Column(
        children: [
          // Liste des quiz
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<QuizRealtimeViewModel>().streamCurrentLevelQuizzes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quizzes = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index].data();
                    return QuizCard(
                      title: quiz['title'] ?? 'Quiz',
                      totalPoints: quiz['totalPoints'] ?? 100,
                      onStart: () {
                        // Lancer le quiz
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Résultats récents
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<QuizRealtimeViewModel>().streamUserQuizResults(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final results = snapshot.data!.docs.take(5);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Résultats récents'),
                    ...results.map((doc) {
                      final result = doc.data();
                      return Text(
                        'Score: ${result['score']}/${result['totalPoints']}',
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Afficher le leaderboard en temps réel

```dart
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage();

  @override
  Widget build(BuildContext context) {
    context.read<CommunityRealtimeViewModel>().initialize('user_123');

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: context.read<CommunityRealtimeViewModel>().streamGlobalLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final data = entries[index].data();
              final rank = index + 1;
              final medal = ['🥇', '🥈', '🥉'];
              
              return ListTile(
                leading: Text(
                  rank <= 3 ? medal[rank - 1] : '#$rank',
                  style: const TextStyle(fontSize: 20),
                ),
                title: Text(data['username'] ?? 'Anonyme'),
                subtitle: Text('Level ${data['level']}'),
                trailing: Text(
                  '${data['totalPoints']} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Ajouter des commentaires en temps réel

```dart
class LessonDetailsPage extends StatelessWidget {
  final String lessonId;

  const LessonDetailsPage({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Contenu de la leçon...
          
          // Commentaires en temps réel
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<LessonRealtimeViewModel>()
                  .streamLessonComments(lessonId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data();
                    return CommentCard(
                      username: comment['username'],
                      content: comment['content'],
                      likes: comment['likes'] ?? 0,
                      onLike: () {
                        context.read<LessonRealtimeViewModel>()
                            .likeComment(comments[index].id);
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Champ pour ajouter un commentaire
          Padding(
            padding: const EdgeInsets.all(16),
            child: CommentInputField(
              onSubmit: (content) {
                context.read<LessonRealtimeViewModel>().addComment(
                  lessonId: lessonId,
                  username: 'Utilisateur',
                  content: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 3. Observer les changements avec Consumer

Pour accéder aux données du ViewModel et avoir un accès plus direct :

```dart
Consumer<UserRealtimeViewModel>(
  builder: (context, userViewModel, child) {
    return StreamBuilder(
      stream: userViewModel.streamUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data?.data();
          return Text('Points: ${userData?['totalPoints']}');
        }
        return const CircularProgressIndicator();
      },
    );
  },
)
```

## 4. Bonnes pratiques

### ✅ À faire
- Initialiser les ViewModels une seule fois
- Utiliser StreamBuilder pour les données temps réel
- Afficher un loading pendant les appels Firestore
- Gérer les erreurs correctement
- Mettre à jour le leaderboard après chaque action

### ❌ À éviter
- Créer plusieurs instances de ViewModels
- Faire des requêtes Firestore à chaque build
- Ignorer les états de connexion
- Garder les StreamBuilders ouverts inutilement

## 5. Structure de fichiers recommandée

```
lib/
├── features/
│   ├── user/
│   │   ├── presentation/
│   │   │   ├── viewmodels/
│   │   │   │   └── user_realtime_viewmodel.dart
│   │   │   └── pages/
│   │   │       └── user_profile_page.dart
│   ├── quiz/
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── quiz_realtime_viewmodel.dart
│   │       └── pages/
│   ├── learning/
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── lesson_realtime_viewmodel.dart
│   │       └── pages/
│   └── community/
│       └── presentation/
│           ├── viewmodels/
│           │   └── community_realtime_viewmodel.dart
│           └── pages/
└── shared/
    └── services/
        └── firebase_service.dart
```

## 6. Fonctionnalité: Sync automatique

Pour synchroniser les données automatiquement après une action :

```dart
// Après un quiz complété
await quizViewModel.saveQuizResult(...);
// Le leaderboard se met à jour automatiquement via le stream

// Après complétion d'une leçon
await lessonViewModel.addComment(...);
// Les commentaires s'affichent immédiatement via le stream
```

Tout est synchronisé grâce aux **Streams Firebase** ! 🚀
