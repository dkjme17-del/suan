# 📊 Guide Complet - Mise à Jour du Profil Utilisateur

## Vue d'ensemble

Le système de mise à jour du profil utilisateur est **automatisé et en temps réel**. Les profils se synchronisent avec Firestore lors de la connexion, déconnexion, et à chaque changement de statistiques.

---

## 🔄 Flux Automatique (Sans Code)

### 1️⃣ À la Connexion (`login`)
```dart
// Automatique! Le service fait:
// ✅ isOnline = true
// ✅ lastLoginAt = server timestamp
// ✅ loginCount++
await authViewModel.login(email, password);
```

### 2️⃣ À la Déconnexion (`logout`)
```dart
// Automatique! Le service fait:
// ✅ isOnline = false
// ✅ lastLogoutAt = server timestamp
await authViewModel.logout();
```

### 3️⃣ Stream en Temps Réel
```dart
// L'interface se met à jour automatiquement
StreamBuilder<User?>(
  stream: FirebaseAuthService().streamCurrentUser(),
  builder: (context, snapshot) {
    final user = snapshot.data;
    if (user != null) {
      return Text('EN LIGNE: ${user.name}');  // Met à jour automatiquement
    }
    return Text('NON CONNECTÉ');
  },
);
```

---

## 📝 Méthodes Disponibles

### A. Mettre à Jour le Profil Général

```dart
final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

// Mettre à jour le nom, le mode d'apprentissage, etc.
await firebaseAuthService.updateUserProfile(
  userId: userId,
  displayName: 'Jean Dupont',
  learningMode: 'interactive',  // 'classic', 'interactive', 'gamified'
  currentLevel: 'intermediate',  // 'beginner', 'intermediate', 'advanced'
  avatar: 'https://example.com/avatar.jpg',
  bio: 'Passionné par l\'apprentissage',
);
```

### B. Mettre à Jour les Statistiques (Recommandé ViewModel)

```dart
// Depuis n'importe quelle page avec Provider
final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

// Option 1: Toutes les stats
await authViewModel.updateUserStats(
  totalPoints: 1250,
  currentLevel: 3,
  currentStreak: 15,
  longestStreak: 42,
);

// Option 2: Ajouter des points
await authViewModel.addPoints(50);  // Ajoute 50 points

// Option 3: Augmenter la série
await authViewModel.increaseStreak();  // Augmente de 1

// Option 4: Réinitialiser la série
await authViewModel.resetStreak();  // Remet à 0
```

### C. Accès Direct au Service

```dart
final authService = FirebaseAuthService();

// Mise à jour des stats
await authService.updateUserStats(
  userId: userId,
  totalPoints: 500,
  currentStreak: 10,
  longestStreak: 25,
);

// Récupérer le profil actuel
User? currentUser = authService.getCurrentUser();

// Stream en temps réel
authService.streamCurrentUser().listen((user) {
  print('Profil: ${user?.name} - Points: ${user?.totalPoints}');
});
```

---

## 🎯 Exemples d'Implémentation

### Exemple 1: Quiz Screen - Ajouter des points après un quiz

```dart
class QuizResultScreen extends StatelessWidget {
  final int score;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    return Scaffold(
      body: Column(
        children: [
          Text('Score: $score/100'),
          ElevatedButton(
            onPressed: () async {
              // Ajouter des points au score
              int points = (score * 10); // 100 points par question juste
              await authViewModel.addPoints(points);
              
              // Augmenter la série quotidienne
              await authViewModel.increaseStreak();
              
              Navigator.pop(context);
            },
            child: Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
```

### Exemple 2: Profile Screen - Afficher et Mettre à Jour

```dart
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuthService().streamCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text('Nom'),
                subtitle: Text(user.name),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    // Modifier le nom
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Modifier le nom'),
                        content: TextField(
                          controller: TextEditingController(text: user.name),
                          onChanged: (val) => newName = val,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, user.name),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, newName),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );

                    if (newName != null && newName != user.name) {
                      await FirebaseAuthService().updateUserProfile(
                        userId: user.id,
                        displayName: newName,
                      );
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Points'),
                subtitle: Text('${user.totalPoints ?? 0}'),
              ),
              ListTile(
                title: Text('Série'),
                subtitle: Text('${user.currentStreak ?? 0} jours'),
              ),
              ListTile(
                title: Text('Statut'),
                subtitle: Text(
                  // Le statut se met à jour en temps réel
                  user.isOnline ?? false ? '🟢 EN LIGNE' : '⚫ HORS LIGNE',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Exemple 3: Achievement Unlock - Débloquer une achievement

```dart
class AchievementService {
  final authViewModel = AuthViewModel();
  
  Future<void> unlockAchievement(String achievementId, int rewardPoints) async {
    // Ajouter les points de récompense
    await authViewModel.addPoints(rewardPoints);
    
    // Afficher une notification
    print('🏆 Achievement débloquée! +$rewardPoints points');
  }
}
```

---

## 🔌 Architecture Firestore

### Structure de Collection `users`

```json
{
  "users": {
    "user_id_123": {
      "id": "user_id_123",
      "username": "Jean Dupont",
      "email": "jean@example.com",
      "learningMode": "interactive",
      "currentLevel": "intermediate",
      "totalPoints": 1250,
      "loginCount": 42,
      "currentStreak": 15,
      "longestStreak": 42,
      "isOnline": true,
      "lastLoginAt": "2024-01-15T10:30:00Z",
      "lastLogoutAt": "2024-01-14T22:15:00Z",
      "avatar": "https://...",
      "bio": "Passionné par l'apprentissage",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

---

## 🚀 Best Practices

### ✅ À FAIRE

```dart
// ✅ Utiliser le ViewModel pour les mises à jour
final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
await authViewModel.addPoints(50);

// ✅ Utiliser les Streams pour l'affichage
StreamBuilder<User?>(
  stream: firebaseAuthService.streamCurrentUser(),
  builder: (context, snapshot) { ... },
);

// ✅ Attendre les mises à jour avant de naviguer
await authViewModel.addPoints(100);
Navigator.pop(context);
```

### ❌ À NE PAS FAIRE

```dart
// ❌ Ne pas utiliser print() - utiliser Logger
print('Points ajoutés');  // ❌ MAUVAIS

// ❌ Ne pas oublier await
authViewModel.addPoints(50);  // ❌ MAUVAIS (pas d'await)

// ❌ Ne pas construire sans Stream
if (user != null) { ... }  // ❌ Les données peuvent changer!

// ❌ Ne pas faire plusieurs mises à jour rapides
await authViewModel.updateUserStats(...);  // ❌ Peut créer des conflits
```

---

## 📱 Widget d'Exemple - Afficheur de Profil Temps Réel

```dart
class UserProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuthService().streamCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }

        final user = snapshot.data;
        if (user == null) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Non connecté'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.avatar ?? ''),
                      radius: 30,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.isOnline ?? false ? '🟢 En ligne' : '⚫ Hors ligne',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Points', user.totalPoints.toString()),
                    _buildStatCard('Niveau', user.currentLevel),
                    _buildStatCard('Série', '${user.currentStreak} j'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
```

---

## 🐛 Dépannage

### Q: Le profil ne se met pas à jour après la connexion?
**R:** Vérifiez que:
1. `FirebaseAuthService` appelle `_updateProfileAfterLogin()` ✅
2. Vous utilisez `StreamBuilder` pour l'affichage, pas juste `getCurrentUser()` 
3. Les règles de sécurité Firestore permettent les updates sur la collection `users`

### Q: Les points ne s'affichent pas en temps réel?
**R:** Utilisez `streamCurrentUser()` au lieu de `getCurrentUser()`:
```dart
// ❌ MAUVAIS - une seule lecture
User? user = firebaseAuthService.getCurrentUser();

// ✅ BON - stream temps réel
StreamBuilder<User?>(
  stream: firebaseAuthService.streamCurrentUser(),
  ...
);
```

### Q: Comment réinitialiser la série chaque jour?
**R:** Utilisez un job quotidien:
```dart
// Ajouter à votre main() ou app initialization
Future<void> checkDailyStreak() async {
  final user = FirebaseAuthService().getCurrentUser();
  if (user?.lastLoginAt?.day != DateTime.now().day) {
    await authViewModel.resetStreak();
  }
}
```

---

## 📊 Métriques Capturées

| Métrique | Mis à jour | Événement |
|----------|-----------|----------|
| `isOnline` | Automatique | Login/Logout |
| `lastLoginAt` | Automatique | Login |
| `lastLogoutAt` | Automatique | Logout |
| `loginCount` | Automatique | Login |
| `totalPoints` | Manuel | `addPoints()` ou `updateUserStats()` |
| `currentLevel` | Manuel | `updateUserStats()` |
| `currentStreak` | Manuel | `increaseStreak()` ou `resetStreak()` |
| `longestStreak` | Manuel | `updateUserStats()` |
| `updatedAt` | Automatique | À chaque update |

---

## ✅ Checklist Implémentation

- [ ] ✅ FirebaseAuthService mise en à jour avec auto-update profil
- [ ] ✅ AuthViewModel a les méthodes `addPoints()`, `increaseStreak()`, `resetStreak()`
- [ ] ✅ Les pages utilisent `StreamBuilder` avec `streamCurrentUser()`
- [ ] ✅ Les règles de sécurité Firestore permettent les updates
- [ ] ✅ Collection `users` est créée avec les champs nécessaires
- [ ] ✅ Logger est utilisé au lieu de print()

---

**Créé avec ❤️ - Système de Profil Temps Réel SUAN**
