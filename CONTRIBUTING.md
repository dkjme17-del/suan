# 🤝 Guide de Contribution - Suan

Merci de vouloir contribuer à Suan! Ce guide vous explique comment participer au projet.

## 🎯 Comment Contribuer

### 1. Signaler un Bug 🐛

#### Avant de créer un issue
- [ ] Vérifier que le bug n'existe pas déjà
- [ ] Tester sur la dernière version
- [ ] Essayer de reproduire le bug

#### Format du bug report
```markdown
## Description
[Description claire du bug]

## Reproduction
Étapes pour reproduire:
1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

## Résultat attendu
[Comportement attendu]

## Résultat réel
[Comportement réel]

## Environnement
- Device: [ex: iPhone 13 Pro]
- OS: [ex: iOS 15.2]
- App Version: [ex: 1.0.0]
- Flutter Version: [ex: 3.11.1]

## Screenshots/Videos
[Si applicable]
```

### 2. Proposer une Feature 💡

#### Template
```markdown
## Description
[Description claire de la feature]

## Rationale
Pourquoi cette feature est-elle importante?

## Exemple d'Utilisation
[Comment les users l'utiliseraient]

## Cas d'Utilisation
- [ ] Use case 1
- [ ] Use case 2

## Alternatives Considérées
[Si applicable]

## Contexte Additionnel
[Si applicable]
```

### 3. Soumettre du Code 💻

#### Setup Développement
```bash
# 1. Fork le repo
git clone https://github.com/VOTRE_USERNAME/suan.git
cd suan

# 2. Créer une branche feature
git checkout -b feature/nom-feature

# 3. Installer dépendances
flutter pub get

# 4. Vérifier que tout marche
flutter test
```

#### Workflow de Développement
```bash
# 1. Créer des tests
# test/features/example/example_test.dart

# 2. Développer la feature
# lib/features/example/...

# 3. Tester manuellement
flutter run

# 4. Assurer la qualité du code
flutter analyze
dart format lib/

# 5. Commit avec bon message
git add .
git commit -m "feat: description de la feature"

# 6. Push
git push origin feature/nom-feature

# 7. Créer Pull Request
```

#### Commit Messages
```
feat: Une nouvelle feature
fix: Correction d'un bug
docs: Changements de documentation
style: Formatage, missing semicolons, etc
refactor: Refactoring de code
test: Ajout/modification de tests
chore: Mise à jour de dépendances, etc

Examples:
- feat: add pronunciation checker
- fix: fix crash on quiz submission
- docs: update README with setup instructions
- refactor: improve lesson loading logic
```

#### Code Style

**Dart/Flutter Conventions**
```dart
// Classes
class MyAwesomeClass extends StatelessWidget {
  const MyAwesomeClass({Key? key}) : super(key: key);
}

// Methods
void myMethod() {
  // Implementation
}

// Variables
final String myVariable = 'value';
late final String lateVar;

// Constants
static const String APP_NAME = 'Suan';

// Formatting
dart format lib/

// Linting
flutter analyze
```

**File Organization**
```
feature/
├── presentation/
│   ├── pages/
│   │   ├── feature_page.dart
│   │   └── detail_page.dart
│   ├── viewmodels/
│   │   └── feature_viewmodel.dart
│   └── widgets/
│       └── feature_widget.dart
└── domain/
    └── entities/
        └── entity.dart
```

### 4. Améliorer la Documentation 📚

#### Types de Documentation
- [ ] README amélioré
- [ ] Documentations de code
- [ ] Guides d'installation
- [ ] API docs
- [ ] Tutorials

#### Format Markdown
```markdown
# Heading 1
## Heading 2
### Heading 3

**Bold** and *italic*

- List item 1
- List item 2

1. Numbered item
2. Another item

[Link text](https://example.com)

```code block```

> Quote
```

### 5. Traduire l'App 🌍

#### Comment aider
- Traduire les strings en baoulé
- Vérifier les traductions
- Ajouter de nouvelles langues

#### Current Languages
- Français 🇫🇷
- Baoulé 🇨🇮 (in progress)

#### Comment Traduire
```dart
// Avant (hardcoded)
Text('Hello')

// Après (localized)
// À spécifier avec i18n package
```

---

## 📋 Pull Request Process

### Avant de soumettre
- [ ] Fork du repo
- [ ] Branche feature créée
- [ ] Code bien formaté
- [ ] Tests passent
- [ ] Pas de breaking changes
- [ ] Documentation à jour

### Format del PR

```markdown
## Description
[Description courte de ce qui change]

## Type de Changement
- [ ] Nouvelle feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Refactoring

## Related Issues
Fixes #123

## Testing
Comment j'ai testé les changements?

## Checklist
- [ ] Code formaté (dart format)
- [ ] Pas de lint warnings
- [ ] Tests ajoutés/updatés
- [ ] Tests passent
- [ ] Documentation à jour
- [ ] Pas de breaking changes
```

### Revue de Code
- Répondre aux commentaires
- Faire les changements demandés
- Re-request review si changements majeurs

---

## 🏆 Merging Process

### Critères de Merge
✅ Tous les tests passent  
✅ Code review approuvée  
✅ Pas de conflicts  
✅ Documentation à jour  
✅ Commit messages clairs  

### Après Merge
- [ ] Issue liée peut être fermée
- [ ] Mention dans CHANGELOG
- [ ] Rebase si nécessaire

---

## 🎓 Ressources pour Développeurs

### Apprendre Flutter
- [Official Flutter Docs](https://flutter.dev/docs)
- [CodeWithChris Flutter Tutorials](https://www.youtube.com/@CodeWithChris)
- [Dart Language Guide](https://dart.dev/guides)

### Architecture & Patterns
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)
- [MVVM Pattern Guide](https://www.geeksforgeeks.org/mvvm-model-view-viewmodel-architecture-pattern-in-android/)
- [Provider Pattern](https://pub.dev/packages/provider)

### Debugging
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools)
- [Dart Observatory](https://dart.dev/tools/observatory)

---

## 💬 Communication

### Channels
- **Issues**: Bug reports et features
- **Discussions**: Questions et ideas (si disponible)
- **Discord**: Community chat (si disponible)

### Code of Conduct

Nous accueillons et encourageons la participation de tous. Tous les contributeurs doivent adhérer à notre [Code of Conduct](CODE_OF_CONDUCT.md).

**Respectez les principes:**
- Be respectful
- Be inclusive
- Be collaborative
- Give credit
- No harassment

---

## 🎯 Domaines où Aider

### Manpower Needed
- [ ] **Développement** - Flutter/Dart features
- [ ] **Design** - UX/UI improvements
- [ ] **QA Testing** - Bug hunting
- [ ] **Contenu** - Leçons et vocabulaire
- [ ] **Documentation** - Manuals et guides
- [ ] **Traduction** - Nouvelles langues
- [ ] **Marketing** - Promotion

### Idées de Features
1. Chatbot conversationnel
2. Système d'amis
3. Leaderboards
4. Daily challenges
5. Histoires interactives
6. Jeux éducatifs
7. Certificats
8. Mode offline complet

---

## 🚀 Contribution Workflow (Résumé)

```
1. Fork repo
   ↓
2. Create feature branch
   ↓
3. Make changes
   ↓
4. Commit with good messages
   ↓
5. Push to your fork
   ↓
6. Create Pull Request
   ↓
7. Address review comments
   ↓
8. Merged! 🎉
```

---

## 🙏 Merci!

Chaque contribution, grande ou petite, est appréciée!

### Formes de Contribution
- Code fixes
- Bug reports
- Feature ideas
- Documentation
- Translations
- Testing
- Feedback
- Morale support

**Votre aide nous permet de faire croître Suan et de préserver la langue Baoulé pour les générations futures!** ❤️

---

## 📞 Questions?

- Ouvrir une issue
- Discuter dans les discussions
- Rejoindre notre communauté
- Contacter les mainteneurs

**Merci d'être un awesome contributor!** 🌟

---

*Last updated: March 9, 2026*
*Maintenu par: Équipe Suan*
