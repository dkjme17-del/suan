import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/features/user/presentation/viewmodels/user_realtime_viewmodel.dart';

/// Page d'accueil avec statistiques utilisateur en temps réel
class HomePageRealtime extends StatefulWidget {
  final String userId;

  const HomePageRealtime({super.key, required this.userId});

  @override
  State<HomePageRealtime> createState() => _HomePageRealtimeState();
}

class _HomePageRealtimeState extends State<HomePageRealtime> {
  @override
  void initState() {
    super.initState();
    // Initialiser le ViewModel au chargement
    Future.microtask(() {
      if (mounted) {
        context.read<UserRealtimeViewModel>().initialize(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Accueil'),
        backgroundColor: const Color(0xFFD97706),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: context.read<UserRealtimeViewModel>().streamUserProfile(),
        builder: (context, snapshot) {
          // État de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD97706),
              ),
            );
          }

          // Erreur
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('❌ Erreur de chargement'),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          // Pas de données
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Créez votre profil pour commencer'),
            );
          }

          final userData = snapshot.data!.data() ?? {};
          final username = userData['username'] ?? 'Apprenant';
          final totalPoints = (userData['totalPoints'] ?? 0) as int;
          final level = (userData['level'] ?? 1) as int;
          final streakDays = (userData['streakDays'] ?? 0) as int;
          final stats = userData['stats'] as Map<String, dynamic>? ?? {};
          final lessonsCompleted = (stats['lessonsCompleted'] ?? 0) as int;
          final quizzesCompleted = (stats['quizzesCompleted'] ?? 0) as int;
          final averageScore = (stats['averageScore'] ?? 0) as double;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salutation avec données en temps réel
                  Text(
                    'Bienvenue, $username! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Niveau $level • $totalPoints points',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progression au prochain niveau
                  _buildProgressCard(totalPoints, level),
                  const SizedBox(height: 24),

                  // Série d'activité en temps réel
                  _buildStreakCard(streakDays),
                  const SizedBox(height: 24),

                  // Statistiques globales
                  _buildStatsGrid(
                    lessonsCompleted,
                    quizzesCompleted,
                    averageScore,
                    totalPoints,
                  ),
                  const SizedBox(height: 24),

                  // Achievements (stream dynamique)
                  _buildAchievementsSection(context),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.book),
                          label: const Text('Leçons'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.quiz),
                          label: const Text('Quiz'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Carte de progression au prochain niveau
  Widget _buildProgressCard(int points, int currentLevel) {
    const int pointsPerLevel = 500;
    final int progressPoints = points % pointsPerLevel;
    final double progress = progressPoints / pointsPerLevel;

    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.9), secondary.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Niveau ${currentLevel + 1}',
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: onPrimary.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(onPrimary.withValues(alpha: 0.9)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progressPoints.toStringAsFixed(0)}/$pointsPerLevel points',
            style: TextStyle(
              color: onPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte de série d'activité
  Widget _buildStreakCard(int streakDays) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final error = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.1),
        border: Border.all(color: error),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Série d\'activité',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Text(
                '$streakDays jours consécutifs',
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Grille de statistiques
  Widget _buildStatsGrid(
    int lessons,
    int quizzes,
    double avgScore,
    int points,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: '📚',
          label: 'Leçons',
          value: lessons.toString(),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: '🎯',
          label: 'Quiz',
          value: quizzes.toString(),
          color: Colors.green,
        ),
        _buildStatCard(
          icon: '⭐',
          label: 'Score moy.',
          value: '${avgScore.toStringAsFixed(0)}%',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: '💎',
          label: 'Points',
          value: points.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  /// Carte statistique unique
  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Section achievements avec stream
  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réussissements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: context.read<UserRealtimeViewModel>().streamAchievements(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Complétez des défis pour débloquer...');
            }

            final achievements = snapshot.data!.docs;

            if (achievements.isEmpty) {
              return const Text('Pas encore de réussissements');
            }

            return Wrap(
              spacing: 8,
              children: achievements.take(6).map((doc) {
                final achievement = doc.data();
                return Chip(
                  avatar: Text(
                    achievement['icon'] ?? '🏆',
                    style: const TextStyle(fontSize: 16),
                  ),
                  label: Text(achievement['title'] ?? 'Unknown'),
                  backgroundColor:
                      const Color(0xFFD97706).withValues(alpha: 0.2),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
