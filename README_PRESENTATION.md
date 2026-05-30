# 🎓 Baoulé Tutor - Assistant IA Culturel

**Une application d'apprentissage du Baoulé potentialisée par l'IA** | Déployée en production ✨

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture générale](#architecture-générale)
3. [Fonctionnalités principales](#fonctionnalités-principales)
4. [Déploiement en production](#déploiement-en-production)
5. [Configuration](#configuration)
6. [Guide de démonstration](#guide-de-démonstration)

---

## 🌍 Vue d'ensemble

**Baoulé Tutor** est une plateforme web d'apprentissage de la langue et culture Baoulé (Côte d'Ivoire) utilisant une **IA multimodal** pour :

- 📚 **Enseigner le Baoulé** : vocabulaire, grammaire, prononciation
- 🎯 **Gamifier l'apprentissage** : quiz, défis quotidiens, leaderboard
- 💬 **Assister les utilisateurs** : chatbot tuteur expert en Baoulé (AKWABA)
- 🎨 **Documenter la culture** : catalogue des artefacts culturels avec full-screen image viewer
- 🌐 **Fonctionner en temps réel** : synchronisation Firebase en direct

**URL de production :** https://suan-16f16.web.app

---

## 🏗️ Architecture générale

```
┌─────────────────────────────────────────────────────────────┐
│                    UTILISATEUR (Web Browser)                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
    ┌───▼──────┐  ┌──▼────────┐ ┌─▼────────────┐
    │ Firebase │  │ Render API │ │ Firestore DB │
    │ Hosting  │  │ (Backend)  │ │              │
    │(Flutter) │  │            │ │ (Real-time)  │
    └──────────┘  └──┬─────────┘ └──────────────┘
                     │
              ┌──────▼─────────┐
              │ Google Gemini  │
              │   AI Model     │
              └────────────────┘
```

### 📱 **Frontend : Flutter Web**
- **Framework** : Flutter 3.x
- **Hébergement** : Firebase Hosting
- **URL** : https://suan-16f16.web.app
- **État** : Provider, ChangeNotifier
- **UI** : Material Design 3 + Design System Baoulé custom

### ⚙️ **Backend : Node.js/Express sur Render**
- **Language** : Node.js + Express
- **Hébergement** : Render (https://render.com)
- **IA** : Google Gemini API (migré d'Anthropic)
- **Endpoints** : `/chat`, `/health`
- **Base de données** : Firestore (temps réel)

### 🗄️ **Base de données : Firestore (Firebase)**
- **Collections** : `users`, `lessons`, `quizzes`, `community_posts`, `leaderboard`
- **Règles de sécurité** : Authentification Firebase + Règles Firestore
- **Type** : NoSQL temps réel (WebSocket)

---

## ✨ Fonctionnalités principales

### 1. 💬 **Chatbot Tuteur (AKWABA)**
- **Rôle** : Expert en Baoulé avec prononciation et traductions
- **Capacités** :
  - Répond en Baoulé avec explications en français
  - Enseigne vocabulaire avec pronunciations (diacritiques : ɔ, ɛ, ɩ, ŋ, ɓ, ɗ)
  - Propose des exemples et exercices
  - Cache intelligent pour réponses rapides
- **Backend** : Powered by Google Gemini
- **Status** : ✅ Opérationnel sur https://suan-16f16.web.app/#/chatbot

**Message système AKWABA :**
```
Tu es AKWABA, tuteur EXPERT de BAOULÉ pour apprenants francophones.
- Réponds TOUJOURS en Baoulé (littéral et naturel) avec diacritiques
- Prononciation : ex. "ɔfɔ" (se prononce : oh-foh)
- Structuration : Baoulé → Traduction FR → Explication
```

### 2. 📚 **Catalogue Culturel**
- **Contenu** : Masques, textiles, vidéos, artefacts Baoulé
- **Interaction** : 
  - Clic sur image → Full-screen viewer
  - Zoom/Pan avec InteractiveViewer (1.0x à 4.0x)
  - Informations détaillées avec footer interactif
- **Tabs** : Masques | Textiles | Vidéos

### 3. 🎯 **Quiz & Gamification**
- **Types de quiz** : Visuels, écrits, audio
- **Système de points** : XP, badges, achievements
- **Leaderboard** : Classement temps réel Firebase
- **Défis quotidiens** : Missions avec récompenses

### 4. 👥 **Community**
- **Forum** : Posts et commentaires en direct
- **Partage culturel** : Contenu utilisateur modéré
- **Temps réel** : Firestore listeners pour synchronisation

### 5. 📊 **Statistiques & Profil**
- **Suivi** : Leçons complétées, score, achievements
- **Profil** : Avatar, bio, statistiques personnelles
- **Historique** : Visualisation des progrès

---

## 🚀 Déploiement en production

### Frontend (Firebase Hosting)
```
✅ Application déployée
📍 URL: https://suan-16f16.web.app
📦 40 fichiers statiques uploadés
🔄 Auto-deploy depuis Git (via CI/CD)
```

**Commande de déploiement :**
```bash
cd suan
npx firebase deploy --only hosting
```

### Backend (Render)
```
✅ API Node.js en ligne
📍 URL: https://baoule-backend-*.onrender.com
🔌 Endpoints: /chat, /health
🤖 Intégration Gemini API
```

**Déploiement :**
```bash
cd baoule-backend
git push origin main  # Auto-deploy via Render
```

### Database (Firestore)
```
✅ Firestore active
🔒 Règles de sécurité compilées
🔐 Authentification Firebase
⚡ Real-time listeners configurés
```

---

## ⚙️ Configuration

### Variables d'environnement requises

#### **Frontend (.env dans suan/)**
```env
# Backend API
MASAKHANE_BACKEND_URL=https://baoule-backend-*.onrender.com

# OU fallback direct (HuggingFace)
HF_TOKEN=hf_YOUR_TOKEN_HERE

# Firebase credentials
# (Automatiquement configurés via firebase_options.dart)
```

#### **Backend (.env dans baoule-backend/)**
```env
# Google Gemini API
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-1.5-pro

# Server config
PORT=3000
NODE_ENV=production
```

### Activation des variables (Flutter)
Pour passer les variables au runtime Flutter :
```bash
flutter run -d chrome \
  --dart-define=MASAKHANE_BACKEND_URL=https://baoule-backend-*.onrender.com \
  --dart-define=HF_TOKEN=hf_your_token
```

---

## 🎤 Guide de démonstration

### Scénario 1 : Chatbot tuteur
1. Accéder à https://suan-16f16.web.app
2. Naviguer vers **Chatbot**
3. Écrire : `"Di veut dire quoi en baoulé ?"`
4. Voir réponse : 
   ```
   BAOULÉ LITTÉRAL: Di → MANGER
   BAOULÉ NATUREL: MANGER
   Explication: En Baoulé, "DI" désigne l'action de manger.
   Prononciation: di
   ```

### Scénario 2 : Catalogue culturel
1. Depuis home, aller à **Statistiques** → **Catalogue**
2. Cliquer sur une image de masque
3. L'image s'ouvre en **full-screen**
4. Utiliser 2 doigts pour **zoomer** (1.0x à 4.0x)
5. Voir infos : titre, sous-titre, description complète

### Scénario 3 : Quiz interactif
1. Aller à **Quiz**
2. Sélectionner type : Visuel / Écrit / Audio
3. Répondre à 5 questions
4. Voir score et points XP
5. Vérifier **Leaderboard** pour ranking

### Scénario 4 : Community
1. Aller à **Community**
2. Créer un post ou laisser un commentaire
3. Voir mise à jour **en temps réel** (Firebase)
4. Consulter leaderboard temps réel

---

## 📊 Métriques techniques

| Aspect | Détails |
|--------|---------|
| **Framework Frontend** | Flutter 3.x |
| **Backend** | Node.js + Express |
| **IA** | Google Gemini 1.5 Pro |
| **Database** | Firestore (NoSQL) |
| **Hébergement** | Firebase Hosting + Render |
| **Authentication** | Firebase Auth |
| **Architecture** | Microservices (Frontend + Backend) |
| **Real-time** | WebSocket via Firestore |
| **Sécurité** | HTTPS + Règles Firestore |

---

## 🔄 Flux de requête (Exemple: Chat)

```
1. Utilisateur tape dans chat
                ↓
2. Flutter app → POST /chat (Render backend)
                ↓
3. Backend reçoit message
                ↓
4. Backend → Google Gemini API
                ↓
5. Gemini retourne réponse (Baoulé)
                ↓
6. Backend → Firestore (cache + historique)
                ↓
7. Frontend → WebSocket Firestore (mise à jour instantanée)
                ↓
8. Message s'affiche dans UI
```

---

## 🎨 Design System

### Couleurs Baoulé
```dart
- Gold: #D4A574 (Or traditionnel)
- Red-Orange: #E74C3C (Textile)
- Deep Black: #1A1A1A (Profondeur)
- Cream: #F5F1E8 (Neutral)
```

### Typographie
- **Titles** : Google Sans (w700-w900)
- **Body** : Roboto (w400-w600)
- **Diacritiques** : Support Unicode (ɔ, ɛ, ɩ, ŋ, ɓ, ɗ)

---

## 📚 Ressources

| Resource | Link |
|----------|------|
| **GitHub** | https://github.com/dkjme17-del/suan |
| **Firebase Console** | https://console.firebase.google.com/project/suan-16f16 |
| **Render Dashboard** | https://dashboard.render.com |
| **Google Gemini API** | https://ai.google.dev |
| **Firebase Docs** | https://firebase.google.com/docs |

---

## 🚀 Prochaines étapes

### Court terme
- [ ] Configurer Cloud Functions (plan Blaze)
- [ ] Ajouter push notifications
- [ ] Implémenter offline mode

### Moyen terme
- [ ] Intégration Masakhane pour modèles locaux
- [ ] Support speech-to-text Baoulé
- [ ] Mode apprentissage collaboratif

### Long terme
- [ ] App native iOS/Android
- [ ] API publique pour intégrations
- [ ] Documentation académique

---

## 👥 Équipe

- **Architecture** : Full-stack Flutter + Node.js
- **IA** : Google Gemini
- **Infrastructure** : Firebase + Render
- **Design** : Material Design 3 + Baoulé custom

---

## 📄 Licence

Projet éducatif - Préservation culturelle Baoulé

---

**Status: ✅ Production Ready**  
**Déployé:** 30 Mai 2026  
**Dernière mise à jour:** 2026-05-30

---

## 💡 Questions fréquentes

**Q: Le chatbot peut-il fonctionner hors-ligne ?**  
R: Non, actuellement il nécessite une connexion Internet (API Gemini cloud).

**Q: Comment ajouter plus de contenu culturel ?**  
R: Via l'admin panel ou directement dans Firestore (collection `cultural_items`).

**Q: Combien de translations supporte Baoulé Tutor ?**  
R: Actuellement Baoulé ↔ Français, avec extensibilité pour autres langues.

**Q: Comment déployer localement ?**  
R: `flutter run -d chrome` depuis `suan/` avec `.env` configuré.

---

**Questions ? Consultez le GitHub ou contactez l'équipe ! 🎓**
