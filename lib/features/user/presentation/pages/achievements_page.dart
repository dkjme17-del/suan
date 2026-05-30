import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/shared/services/gamification_service.dart';
import 'package:suan/features/user/presentation/viewmodels/user_realtime_viewmodel.dart';

/// Page Achievements & Gamification Avancée
/// 
/// Affiche en temps réel:
/// - Achievements débloqués (Firestore)
/// - Badges gagnés
/// - Défis quotidiens
/// - Progression visuelle

class AchievementsPage extends StatefulWidget {
  final String? userId; // ID utilisateur pour charger ses achievements

  const AchievementsPage({Key? key, this.userId}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late GamificationService _gamificationService;
  late TabController _tabController;
  
  // State variables for async data
  List<Badge> _badges = [];
  List<Map<String, dynamic>> _challenges = [];
  DailyProgress? _dailyProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
    _gamificationService.initialize();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialiser le ViewModel avec l'ID utilisateur
    if (widget.userId != null) {
      Future.microtask(() {
        context.read<UserRealtimeViewModel>().initialize(widget.userId!);
      });
    }
    
    // Load data async
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load badges
      final badgesData = await _gamificationService.getAllBadges();
      
      // Load daily challenges  
      final challengesData = await _gamificationService.getDailyChallenges();
      
      // Load daily progress with userId
      final userId = widget.userId ?? 'current_user_id';
      final progressData = await _gamificationService.getDailyProgress(userId);
      
      setState(() {
        _badges = badgesData.map((data) => Badge(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          icon: data['icon'] ?? '',
          rarity: data['rarity'] ?? 'common',
          isUnlocked: data['isUnlocked'] ?? false,
        )).toList();
        
        _challenges = challengesData;
        _dailyProgress = progressData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏅 Achievements'),
        elevation: 0,
        backgroundColor: const Color(0xFFD97706),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Achievements', icon: Icon(Icons.star_outline)),
            Tab(text: 'Badges', icon: Icon(Icons.card_giftcard)),
            Tab(text: 'Défis', icon: Icon(Icons.task_alt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementsTab(),
          _buildBadgesTab(),
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: context.read<UserRealtimeViewModel>().streamAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final achievementDocs = snapshot.data?.docs ?? [];
        final unlockedCount = achievementDocs.where((doc) {
          final data = doc.data();
          return data['isUnlocked'] == true;
        }).length;

        if (achievementDocs.isEmpty) {
          return const Center(
            child: Text('Aucun achievement trouvé'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Progress header
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$unlockedCount / ${achievementDocs.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(unlockedCount / achievementDocs.length * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: unlockedCount / achievementDocs.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD97706),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              // Achievements grid - Real-time from Firestore
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: achievementDocs.length,
                  itemBuilder: (context, index) {
                    final achievementDoc = achievementDocs[index];
                    final data = achievementDoc.data();
                    return _buildFirestoreAchievementCard(data);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build achievement card from Firestore data (Map<String, dynamic>)
  Widget _buildFirestoreAchievementCard(Map<String, dynamic> data) {
    final isUnlocked = data['isUnlocked'] ?? false;
    final icon = data['icon'] ?? '🏆';
    final title = data['name'] ?? data['title'] ?? 'Achievement';
    final reward = data['points'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.amber.withValues(alpha: 0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: isUnlocked
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '+$reward',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Verrouillé',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final unlockedBadges = _badges.where((b) => b.isUnlocked).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Badges déverrouillés
          if (unlockedBadges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎖️ Badges Gagnés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: unlockedBadges.length,
                    itemBuilder: (context, index) {
                      return _buildBadgeCard(unlockedBadges[index]);
                    },
                  ),
                ],
              ),
            ),
          // Badges verrouillés
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔒 Badges Verrouillés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._badges
                    .where((b) => !b.isUnlocked)
                    .map((badge) => _buildLockedBadgeItem(badge))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    final rarityColors = {
      'common': Colors.grey,
      'rare': Colors.blue,
      'epic': Colors.purple,
      'legendary': Colors.amber,
    };

    return Container(
      decoration: BoxDecoration(
        color: (rarityColors[badge.rarity] ?? Colors.grey)
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColors[badge.rarity] ?? Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (rarityColors[badge.rarity] ?? Colors.grey)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge.rarity.toString().capitalize(),
              style: TextStyle(
                fontSize: 10,
                color: rarityColors[badge.rarity] ?? Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadgeItem(Badge badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  badge.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final progress = _dailyProgress ?? DailyProgress(
      completed: 0,
      total: 10,
      totalReward: 100,
      earnedReward: 0,
      progressPercent: 0,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Défis du Jour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${progress.completed} / ${progress.total} complétés',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${progress.earnedReward}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          '/ ${progress.totalReward} points',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.progressPercent / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD97706),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          // Challenges list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _challenges.isEmpty
                  ? [const Text('Aucun défi disponible')]
                  : _challenges
                      .map((challenge) => _buildChallengeCard(challenge))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (challenge['isCompleted'] ?? false)
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: (challenge['isCompleted'] ?? false)
            ? Border.all(color: Colors.green, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Text(challenge['icon']?.toString() ?? '⭐', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title']?.toString() ?? 'Défi',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  challenge['description']?.toString() ?? 'Description',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(challenge['difficulty']?.toString() ?? 'easy')
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (challenge['difficulty']?.toString() ?? 'easy').capitalize(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDifficultyColor(challenge['difficulty']?.toString() ?? 'easy'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${challenge['reward'] ?? 0}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
              if (challenge['isCompleted'] ?? false)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                const Icon(Icons.circle_outlined, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gamificationService.dispose();
    super.dispose();
  }
}

extension StringCapitalization on String {
  String capitalize() =>
      '${isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : ''}';
}
