import 'dart:async';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final List<UserProfile> _users = [];
  final List<CommunityPost> _posts = [];

  // Utilisateur courant (simulation)
  UserProfile? _currentUser;

  // Initialiser le service
  void initialize() {
    // Les données sont chargées depuis Firestore
  }

  // Définir l'utilisateur courant
  void setCurrentUser(UserProfile user) {
    _currentUser = user;
    if (!_users.contains(user)) {
      _users.add(user);
    }
  }

  // Obtenir le classement communautaire
  List<UserProfile> getLeaderboard({int limit = 10}) {
    final sortedUsers = List<UserProfile>.from(_users);
    sortedUsers.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return sortedUsers.take(limit).toList();
  }

  // Ajouter un ami
  Future<bool> addFriend(String userId) async {
    try {
      if (_currentUser == null) return false;

      final friend = _users.firstWhere(
        (user) => user.id == userId,
        orElse: () => UserProfile(
          id: userId,
          username: 'Utilisateur_$userId',
          level: 1,
          totalPoints: 0,
          streakDays: 0,
        ),
      );

      if (!_users.contains(friend)) {
        _users.add(friend);
      }

      if (!_currentUser!.friends.contains(friend.id)) {
        _currentUser!.friends.add(friend.id);
        return true;
      }

      return false;
    } catch (e) {
      print('Erreur ajout ami: $e');
      return false;
    }
  }

  // Obtenir la liste d'amis
  List<UserProfile> getFriends() {
    if (_currentUser == null) return [];

    return _users
        .where((user) => _currentUser!.friends.contains(user.id))
        .toList();
  }

  // Publier dans la communauté
  Future<bool> createPost(String content, {String? imageUrl}) async {
    try {
      if (_currentUser == null) return false;

      final post = CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: _currentUser!.id,
        authorName: _currentUser!.username,
        content: content,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        likes: 0,
        comments: [],
      );

      _posts.insert(0, post);
      return true;
    } catch (e) {
      print('Erreur création post: $e');
      return false;
    }
  }

  // Aimer un post
  Future<bool> likePost(String postId) async {
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.likes++;
      return true;
    } catch (e) {
      print('Erreur like post: $e');
      return false;
    }
  }

  // Commenter un post
  Future<bool> commentOnPost(String postId, String comment) async {
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.comments.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: _currentUser?.id ?? 'anonymous',
          authorName: _currentUser?.username ?? 'Anonyme',
          content: comment,
          timestamp: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      print('Erreur commentaire: $e');
      return false;
    }
  }

  // Obtenir les posts communautaires
  List<CommunityPost> getPosts({int limit = 20}) {
    return _posts.take(limit).toList();
  }

  // Mettre à jour les points de l'utilisateur
  void updateUserPoints(int points) {
    if (_currentUser != null) {
      _currentUser!.totalPoints += points;
      _checkLevelUp();
    }
  }

  // Mettre à jour le streak
  void updateStreak() {
    if (_currentUser != null) {
      _currentUser!.streakDays++;
    }
  }

  // Vérifier le passage au niveau supérieur
  void _checkLevelUp() {
    if (_currentUser == null) return;

    final requiredPoints = _currentUser!.level * 100;
    if (_currentUser!.totalPoints >= requiredPoints) {
      _currentUser!.level++;
    }
  }



  // Obtenir l'utilisateur courant
  UserProfile? get currentUser => _currentUser;
}

class UserProfile {
  final String id;
  final String username;
  int level;
  int totalPoints;
  int streakDays;
  String? bio;
  String? avatar;
  List<String> friends;
  int lessonsCompleted;
  int quizzesCompleted;
  double averageScore;

  UserProfile({
    required this.id,
    required this.username,
    required this.level,
    required this.totalPoints,
    required this.streakDays,
    this.bio,
    this.avatar,
    List<String>? friends,
    this.lessonsCompleted = 0,
    this.quizzesCompleted = 0,
    this.averageScore = 0.0,
  }) : friends = friends ?? [];
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  int likes;
  List<Comment> comments;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });
}

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final DateTime timestamp;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.timestamp,
  });
}
