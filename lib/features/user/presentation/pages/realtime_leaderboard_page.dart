import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/shared/services/firebase_service.dart';

/// Page Leaderboard temps réel
/// 
/// Affiche:
/// - Top 50 joueurs globaux
/// - Rafraîchissement temps réel 
/// - Position personnelle
/// - Profils joueurs

class RealtimeLeaderboardPage extends StatefulWidget {
  const RealtimeLeaderboardPage({super.key});

  @override
  State<RealtimeLeaderboardPage> createState() =>
      _RealtimeLeaderboardPageState();
}

class _RealtimeLeaderboardPageState extends State<RealtimeLeaderboardPage> {
  late FirebaseService _firebaseService;
  int _userRank = 0;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Leaderboard Global'),
        elevation: 0,
        backgroundColor: const Color(0xFFD97706),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firebaseService.streamGlobalLeaderboard(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD97706)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Pas de données leaderboard'));
          }

          final leaderboard = snapshot.data!.docs;

          return Column(
            children: [
              // Votre position
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Votre Rang',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('#$_userRank',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Vos Points',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(_userPoints.toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Joueurs Actifs',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(leaderboard.length.toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Liste leaderboard
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final doc = leaderboard[index];
                    final data = doc.data();
                    final rank = index + 1;
                    final isMedal = rank <= 3;
                    final medalEmoji = ['🥇', '🥈', '🥉'][rank - 1];

                    return _buildLeaderboardCard(data, rank, isMedal, medalEmoji);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardCard(
    Map<String, dynamic> data,
    int rank,
    bool isMedal,
    String medalEmoji,
  ) {
    final username = data['username'] ?? 'Anonyme';
    final totalPoints = data['totalPoints'] ?? 0;
    final level = data['level'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMedal ? Colors.amber.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isMedal ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rang
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isMedal ? Colors.amber : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isMedal ? medalEmoji : '#$rank',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info joueur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Level $level',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalPoints.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
                const Text(
                  'points',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
