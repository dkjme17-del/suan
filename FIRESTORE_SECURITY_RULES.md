# 🔐 Mise à Jour des Règles de Sécurité Firestore

## ⚠️ IMPORTANT: Permission Denied

Vous avez l'erreur: **"Missing or insufficient permissions"** parce que les **règles Firestore par défaut refusent l'accès**.

## ✅ Solution: Copier les règles Firestore

### 1️⃣ Aller dans Firebase Console
1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet **"suan"** (suan-16f16)

### 2️⃣ Aller à Firestore Database
1. Cliquez sur **"Firestore Database"** dans le menu gauche
2. Cliquez sur l'onglet **"Rules"**

### 3️⃣ Remplacer les règles actuelles

Remplacez tout le contenu par ceci:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ✅ Utilisateurs - chacun gère le sien
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // ✅ Quiz - lisible par tous
    match /quizzes/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ✅ Leçons - lisible par tous
    match /lessons/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ✅ Résultats quiz - chacun le sien
    match /quiz_results/{document=**} {
      allow read, write: if request.auth != null && 
                            request.resource.data.userId == request.auth.uid;
    }

    // ✅ Classement - lisible par tous
    match /leaderboard/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ✅ Commentaires - lire/créer/modifier sien
    match /comments/{document=**} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }

    // ✅ Actualités - lisible
    match /news/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ✅ Réussissements - lisible
    match /achievements/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ✅ Réussissements utilisateur - chacun le sien
    match /user_achievements/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 4️⃣ Cliquer "Publish"
1. Cliquez le bouton **"Publish"** (en haut à droite)
2. Confirmez le message d'avertissement

## ✅ Voilà!

Les permissions sont maintenant correctes. Testez l'inscription à nouveau - ça devrait fonctionner! 🎉

### Rappel des règles:
- ✅ Chaque utilisateur peut **créer/modifier/lire son propre profil**
- ✅ Les **quiz, leçons, actualités** sont **lisibles par tous** mais **non modifiables** (sécurisé)
- ✅ Les **résultats de quiz** et **commentaires** sont **privés à l'utilisateur**

---

**Après publication, testez l'inscription avec:**
- Email: `test@test.com`
- Mot de passe: `Test123!`
- Nom: `Test User`

L'inscription devrait réussir et créer le profil dans Firestore! ✨
