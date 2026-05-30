class User {
  final String id;
  final String name;
  final String email;
  final String? avatar; // URL de l'avatar
  final bool isOnline; // Statut en ligne
  final String learningMode; // classic, ludique, non_alphabetic
  final String currentLevel; // beginner, intermediate, advanced
  final int totalPoints;
  final int currentStreak;
  final int longestStreak; // Meilleure série
  final int loginCount; // Nombre de connexions
  final DateTime createdAt;
  final DateTime? lastLoginAt; // Dernière connexion
  final DateTime? lastLogoutAt; // Dernière déconnexion
  final List<String> favorites;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.isOnline = false,
    required this.learningMode,
    required this.currentLevel,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.loginCount = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.lastLogoutAt,
    this.favorites = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      isOnline: json['isOnline'] ?? false,
      learningMode: json['learningMode'] ?? 'classic',
      currentLevel: json['currentLevel'] ?? 'beginner',
      totalPoints: json['totalPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      loginCount: json['loginCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      lastLogoutAt: json['lastLogoutAt'] != null 
          ? DateTime.parse(json['lastLogoutAt']) 
          : null,
      favorites: List<String>.from(json['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'isOnline': isOnline,
      'learningMode': learningMode,
      'currentLevel': currentLevel,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'loginCount': loginCount,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastLogoutAt': lastLogoutAt?.toIso8601String(),
      'favorites': favorites,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    bool? isOnline,
    String? learningMode,
    String? currentLevel,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? loginCount,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastLogoutAt,
    List<String>? favorites,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      learningMode: learningMode ?? this.learningMode,
      currentLevel: currentLevel ?? this.currentLevel,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      loginCount: loginCount ?? this.loginCount,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLogoutAt: lastLogoutAt ?? this.lastLogoutAt,
      favorites: favorites ?? this.favorites,
    );
  }
}


