import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/learning/domain/entities/user.dart';
import 'firebase_service.dart';
import 'profile_update_service.dart';
import '../../core/utils/logger.dart';

/// Service d'authentification utilisant Firebase Auth + Firestore
class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileUpdateService _profileUpdateService = ProfileUpdateService();

  // Inscription avec email/password
  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('📧 Inscription: $email');

      // Créer l'utilisateur dans Firebase Auth
      final credentialResult = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = credentialResult.user;
      if (firebaseUser == null) {
        throw Exception('Impossible de créer le compte utilisateur');
      }

      // Mettre à jour le nom d'affichage de l'utilisateur
      await firebaseUser.updateDisplayName(name);

      // Utiliser le service de mise à jour de profil pour une configuration complète
      await _profileUpdateService.updateProfileAfterRegistration(
        userId: firebaseUser.uid,
        name: name,
        email: email,
      );

      // Ajouter automatiquement l'utilisateur à la communauté
      await _addUserToCommunity(userId: firebaseUser.uid, username: name);

      Logger.info(
        '✅ Inscription réussie: ${firebaseUser.uid} - Nom d\'utilisateur: $name',
      );
      return true;
    } on auth.FirebaseAuthException catch (e) {
      String errorMsg = 'Erreur d\'inscription';

      if (e.code == 'email-already-in-use') {
        errorMsg = 'Cet email est déjà utilisé';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Le mot de passe est trop faible';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Email invalide';
      } else if (e.code == 'operation-not-allowed') {
        errorMsg = 'L\'inscription n\'est pas autorisée';
      }

      Logger.error('❌ Erreur Firebase Auth: ${e.code} - ${e.message}');
      throw Exception(errorMsg);
    } catch (e) {
      Logger.error('❌ Erreur d\'inscription', e);
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  // Connexion avec email/password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('🔐 Connexion: $email');

      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('Impossible de vous connecter');
      }

      Logger.info('✅ Connexion réussie: ${result.user!.uid}');

      // Mettre à jour le profil après la connexion
      await _updateProfileAfterLogin(result.user!.uid);

      return true;
    } on auth.FirebaseAuthException catch (e) {
      String errorMsg = 'Erreur de connexion';

      if (e.code == 'user-not-found') {
        errorMsg = 'Utilisateur non trouvé';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Mot de passe incorrect';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Email invalide';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'Ce compte a été désactivé';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Trop de tentatives. Réessayez plus tard';
      }

      Logger.error('❌ Erreur connexion: ${e.code} - ${e.message}');
      throw Exception(errorMsg);
    } catch (e) {
      Logger.error('❌ Erreur de connexion', e);
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      Logger.info('👋 Déconnexion');

      // Mettre à jour le statut en ligne avant de se déconnecter
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'isOnline': false,
          'lastLogoutAt': FieldValue.serverTimestamp(),
        });
      }

      await _firebaseAuth.signOut();
      Logger.info('✅ Déconnexion réussie');
    } catch (e) {
      Logger.error('❌ Erreur déconnexion', e);
    }
  }

  /// Mettre à jour le profil utilisateur après la connexion
  Future<void> _updateProfileAfterLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': true,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
      });

      Logger.info('✅ Profil mis à jour après connexion');
    } catch (e) {
      Logger.error('⚠️ Erreur mise à jour profil après connexion', e);
      // Ne pas faire échouer la connexion si la mise à jour du profil échoue
    }
  }

  // Récupère l'utilisateur actuel (données complètes depuis Firestore)
  User? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      Logger.info('ℹ️ Aucun utilisateur connecté');
      return null;
    }

    // Retourner à minima l'utilisateur, les données complètes seront chargées via streamCurrentUser()
    return User(
      id: firebaseUser.uid,
      name:
          firebaseUser.displayName ??
          firebaseUser.email?.split('@')[0] ??
          'User',
      email: firebaseUser.email ?? '',
      learningMode: 'classic',
      currentLevel: 'beginner',
      totalPoints: 0,
      currentStreak: 0,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Stream de l'utilisateur connecté avec données complètes depuis Firestore
  Stream<User?> streamCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        // Récupérer les données complètes depuis Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          // Créer le profil s'il n'existe pas
          await _firebaseService.createUserProfile(
            userId: firebaseUser.uid,
            username:
                firebaseUser.displayName ??
                firebaseUser.email?.split('@')[0] ??
                'User',
            email: firebaseUser.email ?? '',
            level: 1,
            totalPoints: 0,
          );
        }

        return User(
          id: firebaseUser.uid,
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'User',
          email: firebaseUser.email ?? '',
          learningMode:
              (userDoc.data()?['learningMode'] as String?) ?? 'classic',
          currentLevel:
              (userDoc.data()?['currentLevel'] as String?) ?? 'beginner',
          totalPoints: userDoc.data()?['totalPoints'] ?? 0,
          currentStreak: userDoc.data()?['currentStreak'] ?? 0,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          favorites: List<String>.from(userDoc.data()?['favorites'] ?? []),
        );
      } catch (e) {
        Logger.error('❌ Erreur lors de la récupération du profil', e);
        return null;
      }
    });
  }

  // Vérifie si l'utilisateur est connecté
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Récupère l'ID de l'utilisateur actuel
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      Logger.info('📬 Envoi de lien de réinitialisation à: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Logger.info('✅ Email envoyé');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      Logger.error('❌ Erreur: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      Logger.error('❌ Erreur', e);
      return false;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? learningMode,
    String? currentLevel,
    String? avatar,
    String? bio,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      // Mettre à jour Firebase Auth
      if (displayName != null && displayName.isNotEmpty) {
        await user?.updateDisplayName(displayName);
        await user?.reload();
      }

      // Mettre à jour Firestore avec tous les champs disponibles
      await _firestore.collection('users').doc(userId).set({
        if (displayName != null && displayName.isNotEmpty)
          'username': displayName,
        if (learningMode != null && learningMode.isNotEmpty)
          'learningMode': learningMode,
        if (currentLevel != null && currentLevel.isNotEmpty)
          'currentLevel': currentLevel,
        'profile': {
          if (bio != null && bio.isNotEmpty) 'bio': bio,
          if (avatar != null && avatar.isNotEmpty) 'avatarUrl': avatar,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Logger.info('✅ Profil mis à jour');
      return true;
    } catch (e) {
      Logger.error('❌ Erreur mise à jour profil', e);
      return false;
    }
  }

  /// Mettre à jour les statistiques de l'utilisateur
  Future<void> updateUserStats({
    required String userId,
    int? totalPoints,
    int? lessonsCompleted,
    int? quizzesCompleted,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (totalPoints != null) {
        updateData['totalPoints'] = totalPoints;
      }
      if (currentLevel != null) {
        updateData['level'] = currentLevel;
      }
      if (currentStreak != null) {
        updateData['currentStreak'] = currentStreak;
      }
      if (longestStreak != null) {
        updateData['longestStreak'] = longestStreak;
      }

      // Mettre à jour les statistiques imbriquées
      if (lessonsCompleted != null || quizzesCompleted != null) {
        if (lessonsCompleted != null) {
          updateData['stats.lessonsCompleted'] = lessonsCompleted;
        }
        if (quizzesCompleted != null) {
          updateData['stats.quizzesCompleted'] = quizzesCompleted;
        }
      }

      if (updateData.length > 1) {
        await _firestore.collection('users').doc(userId).update(updateData);
        Logger.info('✅ Statistiques utilisateur mises à jour');
      }
    } catch (e) {
      Logger.error('❌ Erreur mise à jour statistiques', e);
    }
  }

  // Supprime le compte utilisateur
  Future<bool> deleteAccount(String userId) async {
    try {
      // Supprimer les données Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Supprimer le compte Firebase Auth
      await _firebaseAuth.currentUser?.delete();

      Logger.info('✅ Compte supprimé');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      Logger.error('❌ Erreur suppression compte: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      Logger.error('❌ Erreur', e);
      return false;
    }
  }

  /// Ajoute automatiquement l'utilisateur à la communauté lors de son inscription
  Future<void> _addUserToCommunity({
    required String userId,
    required String username,
  }) async {
    try {
      // Créer un post de bienvenue dans la communauté avec le nom d'utilisateur
      await _firestore.collection('community').add({
        'authorId': userId,
        'authorName':
            username, // Utiliser le nom comme nom d'utilisateur dans le post
        'content':
            'Salut! Je suis $username, nouveau sur SUAN et j\'ai hâte d\'apprendre le baoulé! 🎉',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
        'imageUrl': null,
        'tags': ['nouveau', 'introduction'],
      });

      Logger.info(
        '✅ Utilisateur $username ajouté à la communauté avec son nom',
      );
    } catch (e) {
      Logger.error('⚠️ Erreur ajout utilisateur à la communauté', e);
      // Ne pas faire échouer l'inscription si la création du post échoue
    }
  }
}
