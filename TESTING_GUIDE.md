# 🧪 Guide de Test - Suan

## Quick Start Tests (5 minutes)

### Avant de tester
```bash
cd d:\tp crypto1.2\suan
flutter pub get
flutter run
```

---

## 📱 Test Scenarios

### Scenario 1: Inscription & Premier Accès (2 min)

1. **Page de login** affichée
   - ✓ Vérifier le logo Suan
   - ✓ Email et password fields visibles
   - ✓ Boutons "Se connecter" et "Créer un compte"

2. **Cliquer "Créer un compte"**
   - ✓ Naviguer vers page d'inscription
   - ✓ Voir les champs: Nom, Email, Password, Confirmation
   - ✓ Voir les conditions d'utilisation

3. **Remplir le formulaire**
   ```
   Nom: Jean Dupont
   Email: jean@test.com
   Password: Password123
   Confirmation: Password123
   Checkbox: Coché
   ```

4. **Cliquer "S'inscrire"**
   - ✓ Formulaire validé
   - ✓ Naviguer vers "Mode d'apprentissage"
   - ✓ Pas de crash

5. **Sélectionner un mode**
   - ✓ Voir 3 options: Classique, Ludique, Non-alphabétisé
   - ✓ Sélectionner "Mode Classique"
   - ✓ Naviguer vers Accueil

---

### Scenario 2: Navigation & Leçons (2 min)

1. **Accueil affichée**
   - ✓ Greeting "Bienvenue"
   - ✓ Cards avec Points, Séries, Jours
   - ✓ Boutons de niveau (Débutant/Intermédiaire/Avancé)
   - ✓ Liste des leçons

2. **Sélectionner un niveau**
   - ✓ Cliquer "Intermédiaire"
   - ✓ Les leçons de ce niveau s'affichent
   - ✓ Le bouton est highlighté

3. **Cliquer sur une leçon**
   - ✓ Naviguer vers "Détail de Leçon"
   - ✓ Voir le titre, description, contenu
   - ✓ Voir vocabulaire en chips
   - ✓ Voir durée estimée
   - ✓ Voir bouton "Cœur" (favoris)

4. **Ajouter aux favoris**
   - ✓ Cliquer le cœur vide
   - ✓ Il devient rouge plein
   - ✓ Message de confirmation (optionnel)

5. **Compléter la leçon**
   - ✓ Cliquer "Leçon terminée"
   - ✓ Snackbar: "+10 points"
   - ✓ Revenir à l'accueil

---

### Scenario 3: Quiz (2 min)

1. **Aller aux Quiz**
   - ✓ De l'Accueil, cliquer "Quiz"
   - ✓ Voir liste des quizzes disponibles
   - ✓ Voir niveau, nombre de questions

2. **Sélectionner un quiz**
   - ✓ Cliquer sur le quiz
   - ✓ Voir la première question
   - ✓ Barre de progression en haut
   - ✓ 4 options de réponse

3. **Répondre à une question**
   - ✓ Cliquer une option
   - ✓ L'option se highlight
   - ✓ Voir les boutons "Précédent" et "Suivant"

4. **Progresser dans le quiz**
   - ✓ Cliquer "Suivant"
   - ✓ Aller à la question suivante
   - ✓ La barre de progression avance
   - ✓ Bouton "Précédent" marche aussi

5. **Terminer le quiz**
   - ✓ À la dernière question, bouton "Terminer"
   - ✓ Cliquer "Terminer"
   - ✓ Voir un dialog avec les résultats
   - ✓ Afficher: Score, Pourcentage, Points
   - ✓ Bouton "Retour"

6. **Voir résultats**
   ```
   Exemple:
   ✓ 9/10 questions correctes
   ✓ 90%
   ✓ +90 points
   ```

---

### Scenario 4: Paramètres & Profil (1.5 min)

1. **Ouvrir les Paramètres**
   - ✓ Cliquer l'icône engrenage en haut à droite de l'Accueil
   - ✓ Voir la page des Paramètres

2. **Voir le Profil**
   - ✓ Avatar avec première lettre du nom
   - ✓ Nom et email affichés
   - ✓ Badge du niveau actuel

3. **Voir les Statistiques**
   - ✓ Points totaux affichés
   - ✓ Séries affichées
   - ✓ Cards avec icons

4. **Voir autres options**
   - ✓ Notifications
   - ✓ Langue
   - ✓ À propos

5. **Déconnexion**
   - ✓ Cliquer "Se déconnecter"
   - ✓ Dialog de confirmation
   - ✓ Cliquer "Confirmer"
   - ✓ Retour à la page de login
   - ✓ Session effacée

---

### Scenario 5: Reconnexion (1 min)

1. **Après déconnexion**
   - ✓ Page de login affichée

2. **Connexion directe**
   - ✓ Email: jean@test.com
   - ✓ Password: Password123
   - ✓ Cliquer "Se connecter"
   - ✓ Retour immédiat à l'Accueil

---

## 🐛 Bug Testing Checklist

### Authentification
- [ ] Inscription avec email invalide -> Error message
- [ ] Passwords qui ne correspondent pas -> Error message
- [ ] Email déjà utilisé -> Error message
- [ ] Connexion avec mauvaise password -> Error message
- [ ] Champs vides -> Error message

### Leçons
- [ ] Cliquer rapide sur plusieurs leçons -> Pas de crash
- [ ] Scroller la liste -> Smooth
- [ ] Favoris persistants -> Rester après refresh
- [ ] Bouton "Cœur" toggle correctement

### Quiz
- [ ] Cliquer rapidement prev/next -> Pas de crash
- [ ] Revenir en arrière et changer réponse -> OK
- [ ] Timer countdown -> OK (si implémenté)
- [ ] Affichage du résultat correct -> Verify math

### Général
- [ ] Pas de memory leaks pendant 5 min
- [ ] Pas de crash au changement d'orientation
- [ ] Pas de lag au scroll
- [ ] Images load correctement
- [ ] Textes lisibles sur tous les décrans

---

## 📊 Performance Testing

### App Launch
- [ ] Démarrage: < 2 secondes
- [ ] Pas de freeze
- [ ] Pas de memory spike excessif

### Scrolling
- [ ] FPS: > 60
- [ ] Pas de jank/lag
- [ ] Smooth animations

### Navigation
- [ ] Transitions fluides
- [ ] Pop animation OK
- [ ] Back button fonctionne

---

## 🌐 Responsive Testing

### Téléphones
- [ ] iPhone SE (4.7")
- [ ] iPhone 13 Pro (6.1")
- [ ] iPhone Max (6.7")
- [ ] Android petit (5")
- [ ] Android grand (6.5"+)

### Tablettes
- [ ] iPad 10" portrait
- [ ] iPad 10" landscape
- [ ] Android tablet 7"
- [ ] Android tablet 10"

### Points à checker
- [ ] Layouts responsive
- [ ] Pas de overflow
- [ ] Textes readable
- [ ] Boutons clickables
- [ ] Images scaled correctement

---

## 🎨 UI/UX Testing

### Couleurs
- [ ] Contraste texte/fond OK
- [ ] Couleurs cohérentes
- [ ] Accents visibles

### Fonts
- [ ] Textes lisibles
- [ ] Hiérarchie claire
- [ ] Pas trop petit/grand

### Interactions
- [ ] Touchable areas >= 48dp
- [ ] Feedback visuel au clique
- [ ] Hover states (Web)
- [ ] Loading states clairs

---

## 📝 Test Report Template

```
Date: [Date]
Tester: [Nom]
Device: [Model & OS]
Build: [Version]

=== PASSED ===
- [Feature]
- [Feature]

=== FAILED ===
- [Feature]: [Description]
  - Steps: ...
  - Expected: ...
  - Actual: ...
  - Severity: [Critical/High/Medium/Low]

=== NOTES ===
- Performance OK
- No crashes detected
- Ready for prod: YES/NO
```

---

## 🚀 Test Coverage Checklist

### Core Features (Must Pass)
- [ ] Login/Register
- [ ] Mode selection
- [ ] Home page
- [ ] Lessons
- [ ] Quiz
- [ ] Settings
- [ ] Logout

### Secondary Features (Should Pass)
- [ ] Favorites
- [ ] Level switching
- [ ] Progress tracking
- [ ] Error handling

### Edge Cases (Nice to Pass)
- [ ] Network offline
- [ ] Deep linking
- [ ] App backgrounding
- [ ] Memory pressure

---

**Bon testing! 🎉**

Si vous trouvez un bug, créez une issue avec:
1. Steps to reproduce
2. Expected result
3. Actual result
4. Screenshots/Videos
5. Device info
