# Suan - Application d'apprentissage du Baoulé

Une application mobile Flutter pour apprendre la langue **Baoulé** de manière progressive et ludique.

## 🎯 Fonctionnalités

### Authentification
- ✅ Inscription et connexion sécurisées
- ✅ Gestion du profil utilisateur
- ✅ Sélection du mode d'apprentissage

### Modes d'apprentissage
- **Mode Classique** : Leçons structurées et linéaires
- **Mode Ludique** : Apprentissage par jeux et défis
- **Mode Non-Alphabétisé** : Basé sur l'audio et les images

### Suivi des progrès
- 📊 Système de points (gamification)
- 🔥 Séries de connexion quotidiennes
- ⭐ Favoris de leçons
- 📈 Progression par niveau (Débutant, Intermédiaire, Avancé)

### Apprentissage
- 📚 Leçons courtes (micro-learning)
- 🗣️ Module audio avec natifs baoulé
- 📝 Vocabulaire structuré
- 🎯 Quiz interactifs avec feedback immédiat
- 🎮 Mini-jeux éducatifs

### Extras
- 🔊 Reconnaissance vocale pour la prononciation
- 🤖 Chatbot pour pratique en conversation
- 📷 Reconnaissance d'objets
- 📱 Mode hors ligne
- 🌙 Thème clair/sombre

## 🏗️ Architecture

```
Suan/
├── lib/
│   ├── core/               # Fichiers globaux
│   │   ├── constants.dart
│   │   └── theme/
│   ├── features/           # Features de l'app
│   │   ├── auth/           # Authentification
│   │   ├── learning/       # Apprentissage et leçons
│   │   ├── quiz/           # Quiz et évaluations
│   │   └── user/           # Profil et paramètres
│   ├── shared/             # Partagé
│   │   ├── services/       # Services (Auth, Storage, etc)
│   │   ├── widgets/        # Widgets réutilisables
│   │   └── theme/          # Configuration du thème
│   └── main.dart
└── pubspec.yaml
```

### Architecture globale
- **MVVM Pattern** : Séparation entre UI, ViewModel et Services
- **Provider** : Gestion d'état
- **Shared Preferences** : Stockage local
- **Clean Architecture** : Séparation des responsabilités

## 🚀 Installation

### Prérequis
- Flutter 3.11.1 ou supérieur
- Dart 3.11.1 ou supérieur
- Un émulateur ou appareil Android/iOS

### Étapes

```bash
# 1. Cloner le dépôt
git clone <repository>
cd suan

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers build_runner
flutter pub run build_runner build

# 4. Configurer Google Groq API (REQUIS pour le chatbot)
#    - Obtenir une clé API: https://console.groq.com/
#    - Sauvegarder votre GROQ_API_KEY

# 5. Lancer l'application
flutter run --dart-define=GROQ_API_KEY=<your_api_key>
```

### Configuration Groq API (Chatbot)

L'application utilise **Groq API** pour le chatbot d'apprentissage du Baoulé. Cette configuration est **REQUISE** pour activer la fonctionnalité chatbot.

#### Obtenir une clé API Groq

1. Accédez à [Groq Console](https://console.groq.com/)
2. Créez un compte ou connectez-vous
3. Cliquez sur "Create API Key"
4. Copiez votre clé API générée

#### Lancer avec la clé API

**Option 1: Ligne de commande (Recommandée)**
```bash
# Android/iOS/Web
flutter run --dart-define=GROQ_API_KEY=<votre_clé_ici>

# Windows
flutter run -d windows --dart-define=GROQ_API_KEY=<votre_clé_ici>

# Web (Chrome)
flutter run -d chrome --dart-define=GROQ_API_KEY=<votre_clé_ici>
```

**Option 2: Modèle personnalisé (optionnel)**
```bash
# Par défaut: llama3-8b-8192
# Pour utiliser un autre modèle:
flutter run --dart-define=GROQ_API_KEY=<clé> \
            --dart-define=GROQ_MODEL=mixtral-8x7b-32768
```

#### Vérifier la configuration

Après le lancement, naviguer vers l'écran de chatbot. Si vous voyez une réponse du chatbot (générée par Groq), la configuration est correcte.

**En cas d'erreur:**
- Message "GROQ_API_KEY not configured": Relancer avec `--dart-define=GROQ_API_KEY=<clé>`
- Erreur 401: Vérifier que votre clé API est valide et copiée correctement
- Erreur 429: Vous avez dépassé la limite de requêtes (limites gratuites: ~100 req/minute)

## 📚 Projets de dépendances

### État et Gestion
- `provider` - Gestion d'état simple et efficace
- `get` - Alternative GetX pour la navigation

### Persistance
- `shared_preferences` - Stockage clé-valeur
- `sqflite` - Base de données locale
- `hive` - Cache object-oriented

### Multimédia
- `audioplayers` - Lecture audio
- `record` - Enregistrement vocal
- `camera` - Accès à la caméra
- `image_picker` - Sélection d'images

### UI/Design
- `google_fonts` - Polices Google personnalisées
- `flutter_lints` - Linting et analyse de code

## 📱 Écrans Principaux

1. **Authentification**
   - Connexion / Inscription
   - Sélection du mode d'apprentissage

2. **Accueil**
   - Vue d'ensemble des progrès
   - Sélection du niveau
   - Liste des leçons
   - Accès rapide aux quiz et jeux

3. **Détail de Leçon**
   - Contenu détaillé
   - Vocabulaire
   - Contrôles audio
   - Bouton de completion

4. **Quiz**
   - Liste des quiz disponibles
   - Interface de jeu avec sélection unique
   - Résultats et feedback

5. **Paramètres**
   - Profil utilisateur
   - Statistiques
   - Préférences
   - Déconnexion

## 🎨 Thèmes et Couleurs

- **Primaire** : #6B4C9A (Violet)
- **Secondaire** : #00BCD4 (Cyan)
- **Accent** : #FF6B6B (Rose-Rouge)
- **Succès** : #4CAF50 (Vert)
- **Fond** : #F5F7FA (Gris clair)

## 🔧 Scripts Utiles

```bash
# Formater le code
dart format lib/

# Analyser le code
dart analyze

# Tester l'application
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## 📝 Conventions de Nommage

- **Fichiers** : `snake_case` (ex: `lesson_viewmodel.dart`)
- **Classes** : `PascalCase` (ex: `LessonDetailPage`)
- **Variables** : `camelCase` (ex: `currentLesson`)
- **Constantes** : `UPPER_SNAKE_CASE` (ex: `LESSON_DURATION`)

## 🌐 i18n (Internationalisation)

L'application supporte plusieurs langues :
- Français 🇫🇷
- Baoulé 🇨🇮
- (Extensible pour autres langues)

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir `LICENSE` pour plus de détails.

## 📧 Support

Pour toute question ou problème, contactez :
- Email: contact@suan.app
- Issues: GitHub Issues
- Discord: [Serveur Suan Discord]

## 🙏 Remerciements

- Les locuteurs natifs baoulé pour la contribution linguistique
- La communauté Flutter et Dart
- Les contributeurs et mainteneurs

---

**Suan** - Préserver et promouvoir la langue Baoulé pour les générations futures 🌍
