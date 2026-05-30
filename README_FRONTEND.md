# 🎓 Baoulé Tutor - Frontend

**Application Flutter Web** - Tuteur IA pour la langue et culture Baoulé

## 🚀 Démarrage rapide

### Installation
```bash
# Cloner le projet
git clone https://github.com/dkjme17-del/suan.git
cd suan

# Installer les dépendances
flutter pub get

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos clés API
```

### Lancement local
```bash
# Web (Chrome)
flutter run -d chrome

# OU avec variables d'environnement
flutter run -d chrome \
  --dart-define=MASAKHANE_BACKEND_URL=https://your-backend.com \
  --dart-define=HF_TOKEN=hf_your_token
```

## 📱 Architecture Frontend

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── theme/
│   │   ├── baule_colors.dart         # Palette couleurs custom
│   │   └── app_theme.dart             # Material Theme
│   ├── routes/
│   │   └── app_routes.dart            # Navigation routing
│   └── config/
│       └── firebase_config.dart       # Firebase init
├── features/
│   ├── auth/                          # Login, Register
│   ├── learning/                      # Lessons, Pronunciation
│   ├── quiz/                          # Quiz types (visual, audio, written)
│   ├── chatbot/                       # Chat interface + AI tuteur
│   ├── community/                     # Forums & posts
│   ├── user/
│   │   └── presentation/pages/
│   │       └── statistics_page.dart  # 📌 Catalogue images + detail viewer
│   └── cultural/                      # Cultural content
└── shared/
    ├── services/
    │   ├── masakhane_chat_service.dart  # Chat logic
    │   ├── firebase_service.dart        # Firestore sync
    │   └── auth_service.dart            # Authentication
    └── widgets/
        ├── baule_decoration.dart        # Custom design
        └── common_widgets.dart          # Réutilisables
```

## 🎨 Caractéristiques UI

### Catalogue culturel (statistics_page.dart)
```dart
_CatalogueItem {
  String title;
  String subtitle;
  String imageUrl;
  String description;
  bool isFavorite;
}

// Interactions:
- Clic image → _FullscreenImagePage
- Zoom/Pan: InteractiveViewer (1.0x - 4.0x)
- Hero animation: Transition fluide
- Info footer: Titre + sous-titre + description
```

### Chatbot (chat_screen.dart)
```dart
// AKWABA - Expert tuteur Baoulé
- Input: Question utilisateur
- Output: Baoulé + prononciation + traduction FR + explication
- Cache: Réponses en-mémoire (Map<String, String>)
- Real-time: Firestore WebSocket pour historique
```

## 🔧 Configuration

### Variables d'environnement (.env)
```env
# Backend API (recommandé)
MASAKHANE_BACKEND_URL=https://baoule-backend-*.onrender.com

# OU Direct HuggingFace (fallback)
HF_TOKEN=hf_YOUR_HF_TOKEN_HERE

# Firebase (auto-configuré via firebase_options.dart)
# Pas besoin de déclarer ici
```

### Firebase Configuration
```dart
// firebase_options.dart généré automatiquement
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

## 📊 State Management

### Provider Pattern
```dart
// Service di
final authService = AuthService();
final lessonService = LessonService();
final chatService = MasakhaneChatService();

// ChangeNotifiers
class LearningViewModel extends ChangeNotifier {
  List<Lesson> lessons = [];
  
  void fetchLessons() async {
    lessons = await lessonService.getAllLessons();
    notifyListeners();
  }
}
```

### Real-time Firestore
```dart
// Listeners automatiques
FirebaseFirestore.instance
  .collection('community_posts')
  .orderBy('timestamp', descending: true)
  .limit(50)
  .snapshots()
  .listen((snapshot) {
    setState(() => posts = snapshot.docs);
  });
```

## 🎯 Pages principales

| Page | Route | Fonction |
|------|-------|----------|
| Home | `/` | Dashboard + stats |
| Catalogue | `/statistics` | Images + détails + full-screen |
| Chatbot | `/chatbot` | AKWABA tuteur IA |
| Quiz | `/quiz` | Questions gamifiées |
| Community | `/community` | Forum temps réel |
| Profile | `/profile` | Stats utilisateur |

## 🎨 Design System

### Couleurs
```dart
class BauleColors {
  static const gold = Color(0xFFD4A574);
  static const redOrange = Color(0xFFE74C3C);
  static const deepBlack = Color(0xFF1A1A1A);
  static const cream = Color(0xFFF5F1E8);
}
```

### Typographie
```dart
textTheme: TextTheme(
  titleLarge: GoogleFonts.googleSans(fontSize: 32, fontWeight: FontWeight.w900),
  bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400),
);
```

## 🔍 Exemple: Full-screen Image Viewer

### Code clé (statistics_page.dart)
```dart
// Classe pour full-screen
class _FullscreenImagePage extends StatefulWidget {
  final _CatalogueItem item;
  const _FullscreenImagePage({required this.item});
  
  @override
  State<_FullscreenImagePage> createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<_FullscreenImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hero image avec InteractiveViewer
          Hero(
            tag: widget.item.key,
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: true,
              child: Image.network(widget.item.imageUrl),
            ),
          ),
          
          // Info footer
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.title, style: Theme.of(context).textTheme.titleLarge),
                Text(widget.item.subtitle, style: TextStyle(color: BauleColors.redOrange)),
                Text(widget.item.description),
                Text('Glisser pour déplacer. Pincer pour zoomer.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🧪 Tests

```bash
# Analyser le code
flutter analyze

# Lancer les tests unitaires
flutter test

# Build pour web
flutter build web --release
```

## 📦 Build & Déploiement

### Build Web
```bash
flutter build web --release
# Sortie: build/web/
```

### Déploiement Firebase
```bash
# Depuis le dossier racine
cd ..
npx firebase deploy --only hosting

# URL: https://suan-16f16.web.app
```

## 🐛 Troubleshooting

### Chatbot dit "IA non configurée"
- Vérifier `.env` a `MASAKHANE_BACKEND_URL` OU `HF_TOKEN`
- Relancer avec `flutter run` ou `flutter clean && flutter pub get`

### Images ne se chargent pas en full-screen
- Vérifier URL du backend
- Contrôler CORS dans backend

### Firebase authentication fail
- Vérifier `firebase_options.dart` est à jour
- Relancer `firebase login` si nécessaire

## 📚 Dépendances clés

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0              # State management
  firebase_core: ^2.24.0        # Firebase init
  cloud_firestore: ^4.13.0      # Database
  firebase_auth: ^4.10.0        # Authentication
  http: ^1.1.0                  # HTTP requests
  flutter_dotenv: ^5.1.0        # Environment variables
  video_player: ^2.7.0          # Video playback
  url_launcher: ^6.1.0          # Link opening
```

## 🔐 Sécurité

- ✅ Variables sensibles dans `.env` (non versionné)
- ✅ HTTPS partout
- ✅ Firestore Rules strict
- ✅ Firebase Auth obligatoire
- ✅ Pas de secrets dans git

## 📖 Documentation

- [Flutter docs](https://flutter.dev/docs)
- [Firebase docs](https://firebase.google.com/docs)
- [Provider](https://pub.dev/packages/provider)
- [Google Fonts](https://pub.dev/packages/google_fonts)

## 🎓 Prochaines étapes

- [ ] Offline sync (Hive cache)
- [ ] Push notifications
- [ ] Voice input pour chatbot
- [ ] Analytics avancées

---

**Status: ✅ Production**  
**URL:** https://suan-16f16.web.app
