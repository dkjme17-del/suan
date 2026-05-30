import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/features/community/presentation/viewmodels/community_realtime_viewmodel.dart';

/// ÉCRAN 9: Leaderboard Communauté - TEMPS RÉEL FIRESTORE
class CommunityLeaderboardPage extends StatefulWidget {
  const CommunityLeaderboardPage({Key? key}) : super(key: key);

  @override
  State<CommunityLeaderboardPage> createState() =>
      _CommunityLeaderboardPageState();
}

class _CommunityLeaderboardPageState extends State<CommunityLeaderboardPage> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    // Initialiser le ViewModel pour les données Firestore
    Future.microtask(() {
      context.read<CommunityRealtimeViewModel>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: context.read<CommunityRealtimeViewModel>().streamGlobalLeaderboard(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final leaderboardDocs = snapshot.data?.docs ?? [];

          if (leaderboardDocs.isEmpty) {
            return const Center(
              child: Text('Aucun utilisateur trouvé'),
            );
          }

          // Afficher les top 3
          final topThree = leaderboardDocs.take(3).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with top 3
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (topThree.length > 1)
                            _buildPodiumPlaceFromFirestore(
                              context: context,
                              userData: topThree[1].data(),
                              rank: 2,
                              height: 80,
                              medal: '🥈',
                            )
                          else
                            const SizedBox(width: 60),
                          if (topThree.isNotEmpty)
                            _buildPodiumPlaceFromFirestore(
                              context: context,
                              userData: topThree[0].data(),
                              rank: 1,
                              height: 120,
                              medal: '🥇',
                            )
                          else
                            const SizedBox(width: 60),
                          if (topThree.length > 2)
                            _buildPodiumPlaceFromFirestore(
                              context: context,
                              userData: topThree[2].data(),
                              rank: 3,
                              height: 60,
                              medal: '🥉',
                            )
                          else
                            const SizedBox(width: 60),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPeriodChip('Jour', 'day'),
                          _buildPeriodChip('Semaine', 'week'),
                          _buildPeriodChip('Mois', 'month'),
                          _buildPeriodChip('Tout', 'all'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Leaderboard list - Tous les utilisateurs en temps réel
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: leaderboardDocs.length,
                  itemBuilder: (context, index) {
                    final userData = leaderboardDocs[index].data();
                    final rank = (userData['rank'] as num?)?.toInt() ?? (index + 1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLeaderboardItemFromFirestore(context, userData, rank),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPlaceFromFirestore({
    required BuildContext context,
    required Map<String, dynamic> userData,
    required int rank,
    required double height,
    required String medal,
  }) {
    final name = userData['username'] ?? userData['name'] ?? 'Utilisateur';
    final points = (userData['totalPoints'] as num?)?.toInt() ?? 0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          medal,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$points pts',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItemFromFirestore(
      BuildContext context, Map<String, dynamic> userData, int rank) {
    final medalEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '';
    final level = userData['level'] ?? userData['currentLevel'] ?? 'beginner';
    
    Color getColorByLevel(String level) {
      if (rank <= 3) return AppTheme.accentColor;
      if (level == 'advanced') return AppTheme.primaryColor;
      if (level == 'intermediate') return AppTheme.secondaryColor;
      return Colors.grey;
    }

    final color = getColorByLevel(level);
    final name = userData['username'] ?? userData['name'] ?? 'Utilisateur';
    final points = (userData['totalPoints'] as num?)?.toInt() ?? 0;
    final streak = (userData['streak'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? color : Colors.grey[200]!,
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (rank <= 3)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(medalEmoji, style: const TextStyle(fontSize: 24)),
            ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
              ),
            ),
            child: Center(
              child: Text(
                userData['avatar'] ?? '👤',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '🔥 $streak jours',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$points pts',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final int points;
  final String level;
  final String avatar;
  final int streak;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.points,
    required this.level,
    required this.avatar,
    required this.streak,
  });
}
