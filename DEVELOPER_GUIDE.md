# Guide de Développement - Suan

## 📋 Table des matières
1. [Architecture](#architecture)
2. [Conventions](#conventions)
3. [Workflow](#workflow)
4. [Ajouter une Feature](#ajouter-une-feature)
5. [Testing](#testing)
6. [Debugging](#debugging)

## Architecture

### Structure Clean Architecture

```
feature/
├── data/                    # Couche données
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                  # Couche métier
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/            # Couche présentation
    ├── pages/
    ├── widgets/
    └── viewmodels/
```

### Principes MVVM

```
      UI (Page/Widget)
           ↓
      ChangeNotifier (ViewModel)
           ↓
      Services / Repositories
           ↓
      Data (Local/Remote)
```

## Conventions

### 1. Nommage des fichiers
```dart
// Pages
lesson_detail_page.dart
home_page.dart

// ViewModels
auth_viewmodel.dart
learning_viewmodel.dart

// Services
auth_service.dart
lesson_service.dart

// Models
user.dart
lesson.dart

// Widgets
common_widgets.dart
custom_card.dart
```

### 2. Nommage des classes
```dart
class LessonDetailPage extends StatefulWidget { }
class AuthViewModel extends ChangeNotifier { }
class AuthService { }
class User { }
class CustomCard extends StatelessWidget { }
```

### 3. Nommage des variables
```dart
// Privées
final String _authToken;
late String _userName;

// Publiques
final String name;
final int totalPoints;

// Getters pour logique
String get fullName => '$firstName $lastName';
```

## Workflow

### 1. Avant de coder
```bash
# Mettre à jour les dépendances
flutter pub upgrade

# Vérifier les erreurs
flutter analyze

# Formater le code
dart format lib/
```

### 2. Créer une branche
```bash
git checkout -b feature/nom-de-la-feature
```

### 3. Développer
- Écrire des tests d'abord (TDD)
- Implémenter la feature
- Formater le code

### 4. Commit
```bash
git add .
git commit -m "feat: description courte"
# Types: feat, fix, docs, style, refactor, test
```

### 5. Push et PR
```bash
git push origin feature/nom-de-la-feature
# Créer une Pull Request
```

## Ajouter une Feature

### Exemple: Ajouter un module d'amis

#### 1. Structure
```
features/
└── friends/
    ├── domain/
    │   ├── entities/
    │   │   └── friend.dart
    │   └── repositories/
    │       └── friend_repository.dart
    ├── data/
    │   ├── models/
    │   │   └── friend_model.dart
    │   ├── datasources/
    │   │   └── friend_datasource.dart
    │   └── repositories/
    │       └── friend_repository_impl.dart
    └── presentation/
        ├── pages/
        │   ├── friends_page.dart
        │   └── add_friend_page.dart
        ├── viewmodels/
        │   └── friends_viewmodel.dart
        └── widgets/
            └── friend_card.dart
```

#### 2. Créer l'entité
```dart
// domain/entities/friend.dart
class Friend {
  final String id;
  final String name;
  final String avatar;
  final int level;

  Friend({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
  });
}
```

#### 3. Créer le service
```dart
// shared/services/friend_service.dart
class FriendService {
  Future<List<Friend>> getFriends() async {}
  Future<void> addFriend(String userId) async {}
  Future<void> removeFriend(String friendId) async {}
}
```

#### 4. Créer le ViewModel
```dart
// presentation/viewmodels/friends_viewmodel.dart
class FriendsViewModel extends ChangeNotifier {
  final FriendService friendService;
  
  List<Friend> _friends = [];
  bool _isLoading = false;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _friends = await friendService.getFriends();
    } catch (e) {
      print('Erreur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### 5. Créer la Page/UI
```dart
// presentation/pages/friends_page.dart
class FriendsPage extends StatefulWidget {
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FriendsViewModel>(context, listen: false).loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Amis'),
      body: Consumer<FriendsViewModel>(
        builder: (context, friendsVM, _) {
          return ListView.builder(
            itemCount: friendsVM.friends.length,
            itemBuilder: (context, index) {
              final friend = friendsVM.friends[index];
              return FriendCard(friend: friend);
            },
          );
        },
      ),
    );
  }
}
```

#### 6. Enregistrer dans main.dart
```dart
// main.dart
ChangeNotifierProvider(
  create: (context) => FriendsViewModel(
    friendService: context.read<FriendService>(),
  ),
),
```

## Testing

### Tests unitaires
```dart
// test/services/auth_service_test.dart
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      authService = AuthService(storageService: mockStorageService);
    });

    test('Login doit retourner true avec des credentials valides', () async {
      // Arrange
      when(mockStorageService.saveJson(any, any))
          .thenAnswer((_) async => true);

      // Act
      final result = await authService.login('test@test.com', 'password');

      // Assert
      expect(result, true);
    });
  });
}
```

### Tests de Widget
```dart
// test/widgets/custom_card_test.dart
void main() {
  group('CustomCard Widget', () {
    testWidgets('Affiche le contenu correctement', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
```

## Debugging

### Debug print
```dart
Logger.debug('Message de debug');
Logger.info('Informations');
Logger.warning('Attention');
Logger.error('Erreur', exception, stackTrace);
```

### Devtools
```bash
flutter pub global activate devtools
flutter pub global run devtools

# Puis accéder à http://localhost:9100
```

### Lancer en mode debug
```bash
flutter run --verbose
```

### Analyser les performances
```bash
flutter run --profile

# ou

flutter run --release
```

## Bonnes pratiques

### ❌ À éviter
```dart
// Logique métier dans les widgets
if (user.points > 100) {
  setState(() => showBadge = true);
}

// Variables globales
String globalUserName;

// Catch générique
try {
  ...
} catch (e) {
  print('Erreur');
}

// Hardcoder les valeurs
Container(height: 100, width: 200)
```

### ✅ À faire
```dart
// Déléguer au ViewModel
userVM.checkBadgeEligibility();

// Injection de dépendances
class MyViewModel {
  MyViewModel({required this.authService});
  final AuthService authService;
}

// Gestion d'erreur spécifique
try {
  ...
} catch (AuthException e) {
  Logger.error('Erreur d\'authentification', e);
} catch (Exception e) {
  Logger.error('Erreur non gérée', e);
}

// Utiliser des constantes
static const double _defaultHeight = 100;
static const double _defaultWidth = 200;
Container(height: _defaultHeight, width: _defaultWidth)
```

## Ressources utiles

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides/language)
- [Provider Package](https://pub.dev/packages/provider)
- [Clean Architecture Flutter](https://resocoder.com/flutter-clean-architecture)

---

**Questions?** Créez une issue ou contactez l'équipe de développement.
