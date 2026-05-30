import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suan/shared/services/firebase_service.dart';

/// ViewModel pour la communauté en temps réel
class CommunityRealtimeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  String _userId = '';
  List<String> _friends = [];

  void initialize(String userId) {
    _userId = userId;
    notifyListeners();
  }

  /// Stream du leaderboard global
  Stream<QuerySnapshot<Map<String, dynamic>>> streamGlobalLeaderboard({int limit = 100}) {
    return _firebaseService.streamGlobalLeaderboard(limit: limit);
  }

  /// Stream des amis de l'utilisateur
  Stream<QuerySnapshot<Map<String, dynamic>>> streamFriends() {
    if (_userId.isEmpty) {
      return const Stream.empty();
    }
    return _firebaseService.streamUserFriends(_userId);
  }

  /// Ajouter un ami
  Future<void> addFriend(String friendId) async {
    try {
      await _firebaseService.addFriend(
        userId: _userId,
        friendId: friendId,
      );
      print('✅ Ami ajouté');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur ajout ami: $e');
    }
  }

  /// Stream des actualités
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNews({bool featuredOnly = false}) {
    return _firebaseService.streamNews(featuredOnly: featuredOnly);
  }

  /// Ajouter une actualité (admin)
  Future<void> addNews({
    required String title,
    required String content,
    String? imageUrl,
    bool featured = false,
  }) async {
    try {
      await _firebaseService.addNews(
        title: title,
        content: content,
        imageUrl: imageUrl,
        featured: featured,
      );
      print('✅ Actualité ajoutée');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur ajout actualité: $e');
    }
  }

  /// Obtenir la liste des amis
  List<String> get friends => _friends;
}
