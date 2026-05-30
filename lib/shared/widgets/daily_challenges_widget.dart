import 'package:flutter/material.dart';
import 'package:suan/shared/services/gamification_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget Défis Quotidiens
///
/// Affiche les 4 défis du jour avec:
/// - Progression
/// - Badges de difficulté
/// - Éléments interactifs pour compléter
/// - Points gagnés
class DailyChallengesWidget extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;
  final VoidCallback? onViewAllChallenges;

  const DailyChallengesWidget({
    super.key,
    this.onChallengeCompleted,
    this.onViewAllChallenges,
  });

  @override
  State<DailyChallengesWidget> createState() => _DailyChallengesWidgetState();
}

class _DailyChallengesWidgetState extends State<DailyChallengesWidget> {
  late GamificationService _gamificationService;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
    _gamificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _gamificationService.getDailyChallenges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final challenges = snapshot.data!;
        final progressFuture = _gamificationService.getDailyProgress(
          'current_user_id',
        );

        return FutureBuilder(
          future: progressFuture,
          builder: (context, progressSnapshot) {
            if (!progressSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final progress = progressSnapshot.data!;
            final completed = progress.completed;
            final total = progress.total;
            final earnedReward = progress.earnedReward;
            final totalReward = progress.totalReward;
            final progressPercent = progress.progressPercent;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD97706).withValues(alpha: 0.1),
                    const Color(0xFFD97706).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completed/$total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+$earnedReward/$totalReward pts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercent / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD97706),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        return _buildChallengeCard(challenge);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (challenge['progress'] ?? 0.0) == 1.0
                  ? Colors.green.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(challenge['icon'] ?? 'star'),
              color: (challenge['progress'] ?? 0.0) == 1.0
                  ? Colors.green
                  : Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] ?? 'Défi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge['description'] ?? 'Description',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (challenge['progress'] ?? 0.0) is double
                      ? (challenge['progress'] ?? 0.0)
                      : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (challenge['progress'] ?? 0.0) == 1.0
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${challenge['reward'] ?? 0}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (challenge['progress'] ?? 0.0) == 1.0
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'points',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'star':
        return FontAwesomeIcons.star;
      case 'trophy':
        return FontAwesomeIcons.trophy;
      case 'fire':
        return FontAwesomeIcons.fire;
      case 'book':
        return FontAwesomeIcons.book;
      case 'graduation-cap':
        return FontAwesomeIcons.graduationCap;
      default:
        return FontAwesomeIcons.circle;
    }
  }
}
