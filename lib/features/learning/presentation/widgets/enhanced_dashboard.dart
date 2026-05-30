import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../viewmodels/learning_viewmodel.dart';
import '../../../community/domain/services/real_community_service.dart'
    as community_models;
import '../../../../shared/services/firebase_auth_service.dart';
import 'gamification_widget.dart';
import 'object_recognition_widget_entry.dart';

class EnhancedDashboard extends StatefulWidget {
  const EnhancedDashboard({super.key});

  @override
  State<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Démarrer les animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningViewModel>(
      builder: (context, learningVM, _) {
        final user = learningVM.currentUser;
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(user),
                      const SizedBox(height: 24),
                      _buildGamificationSection(user),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildAIRecommendations(),
                      const SizedBox(height: 24),
                      _buildDailyChallenge(),
                      const SizedBox(height: 24),
                      _buildProgressOverview(learningVM),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeSection(community_models.UserProfile? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: const Icon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, ${user?.username ?? "Apprenant"}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prêt à continuer votre aventure baoulé?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWelcomeStat(
                icon: FontAwesomeIcons.fire,
                label: 'Streak',
                value: '${user?.streakDays ?? 0}',
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildWelcomeStat(
                icon: FontAwesomeIcons.trophy,
                label: 'Niveau',
                value: 'N${user?.level ?? 1}',
                color: Colors.amber,
              ),
              const SizedBox(width: 16),
              _buildWelcomeStat(
                icon: FontAwesomeIcons.coins,
                label: 'Points',
                value: '${user?.totalPoints ?? 0}',
                color: Colors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFriendsStat(),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationSection(community_models.UserProfile? user) {
    return GamificationWidget(
      points: user?.totalPoints ?? 0,
      streak: user?.streakDays ?? 0,
      level: user?.level ?? 1,
      onAchievementTap: () => _showAchievementsDialog(),
    );
  }

  /// Statistique "Amis" mise à jour en temps réel depuis Firestore
  Widget _buildFriendsStat() {
    final userId = FirebaseAuthService().getCurrentUserId();

    if (userId == null) {
      return Row(
        children: [
          _buildWelcomeStat(
            icon: FontAwesomeIcons.userFriends,
            label: 'Amis',
            value: '0',
            color: Colors.lightBlueAccent,
          ),
        ],
      );
    }

    final communityService = community_models.RealCommunityService();

    return StreamBuilder<List<String>>(
      stream: communityService.streamFriends(userId),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;

        return Row(
          children: [
            _buildWelcomeStat(
              icon: FontAwesomeIcons.userFriends,
              label: 'Amis',
              value: '$count',
              color: Colors.lightBlueAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.bolt,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.fire,
                    color: Theme.of(context).primaryColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '8 actions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Actions principales (2x2 grid) avec animation
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 500),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildEnhancedQuickActionCard(
                icon: FontAwesomeIcons.book,
                title: 'Continuer l\'apprentissage',
                subtitle: 'Reprendre là où vous vous êtes arrêté',
                color: Colors.blue,
                onTap: () => _navigateToLearning(),
                badge: 'Nouveau',
                badgeColor: Colors.green,
              ),
              _buildEnhancedQuickActionCard(
                icon: FontAwesomeIcons.microphone,
                title: 'Pratiquer la prononciation',
                subtitle: 'Exercices vocaux interactifs',
                color: Colors.green,
                onTap: () => _navigateToPronunciation(),
                badge: 'IA',
                badgeColor: Colors.purple,
              ),
              _buildEnhancedQuickActionCard(
                icon: FontAwesomeIcons.gamepad,
                title: 'Quiz quotidien',
                subtitle: 'Tester vos connaissances',
                color: Colors.purple,
                onTap: () => _navigateToQuiz(),
                badge: '5 min',
                badgeColor: Colors.orange,
              ),
              _buildEnhancedQuickActionCard(
                icon: FontAwesomeIcons.camera,
                title: 'Reconnaissance d\'objets',
                subtitle: 'Apprendre avec votre caméra',
                color: Colors.orange,
                onTap: () => _navigateToObjectRecognition(),
                badge: 'AR',
                badgeColor: Colors.red,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Actions secondaires avec titre amélioré
        Row(
          children: [
            Icon(
              FontAwesomeIcons.ellipsisH,
              color: Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Plus d\'actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste horizontale avec indicateur de scroll
        SizedBox(
          height: 100,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSecondaryActionCard(
                    icon: FontAwesomeIcons.users,
                    title: 'Communauté',
                    subtitle: 'Voir le classement',
                    color: Colors.teal,
                    onTap: () => _navigateToCommunity(),
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryActionCard(
                    icon: FontAwesomeIcons.chartBar,
                    title: 'Statistiques',
                    subtitle: 'Vos progrès',
                    color: Colors.indigo,
                    onTap: () => _navigateToStatistics(),
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryActionCard(
                    icon: FontAwesomeIcons.trophy,
                    title: 'Défis',
                    subtitle: 'Objectifs quotidiens',
                    color: Colors.amber,
                    onTap: () => _navigateToChallenges(),
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryActionCard(
                    icon: FontAwesomeIcons.gear,
                    title: 'Paramètres',
                    subtitle: 'Personnaliser',
                    color: Colors.grey,
                    onTap: () => _navigateToSettings(),
                  ),
                  const SizedBox(width: 24), // Espace pour l'effet de fondu
                ],
              ),
            ),
          ),
        ),

        // Indicateur de swipe pour la liste horizontale
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.grey[500],
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Faites défiler pour voir plus',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.grey[500],
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (badgeColor ?? color).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendations() {
    final firestore = FirebaseFirestore.instance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.robot,
                color: Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recommandations IA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('lessons').snapshots(),
            builder: (context, snap) {
              final count = snap.data?.size ?? 0;
              return _buildRecommendationCard(
                title: 'Leçons',
                description: '$count leçons disponibles',
                icon: FontAwesomeIcons.bookOpen,
                color: Colors.amber,
                progress: count == 0 ? 0.0 : 1.0,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('quizzes').snapshots(),
            builder: (context, snap) {
              final count = snap.data?.size ?? 0;
              return _buildRecommendationCard(
                title: 'Quiz',
                description: '$count quiz disponibles',
                icon: FontAwesomeIcons.circleQuestion,
                color: Colors.green,
                progress: count == 0 ? 0.0 : 1.0,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .collection('daily_challenges')
                .where('active', isEqualTo: true)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.size ?? 0;
              return _buildRecommendationCard(
                title: 'Défis',
                description: '$count défis actifs',
                icon: FontAwesomeIcons.flagCheckered,
                color: Colors.orange,
                progress: count == 0 ? 0.0 : 1.0,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('community').snapshots(),
            builder: (context, snap) {
              final count = snap.data?.size ?? 0;
              return _buildRecommendationCard(
                title: 'Actualités',
                description: '$count posts communauté',
                icon: FontAwesomeIcons.newspaper,
                color: Colors.blue,
                progress: count == 0 ? 0.0 : 1.0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.red.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.fire,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Défi du jour',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Traduisez 5 expressions de salutation',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Récompense: 100 points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _startDailyChallenge(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Commencer le défi'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              FontAwesomeIcons.clock,
              color: Colors.orange,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(LearningViewModel learningVM) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu de la progression',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  title: 'Leçons complétées',
                  value: '12',
                  total: '20',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  title: 'Quiz réussis',
                  value: '8',
                  total: '15',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  title: 'Temps d\'étude',
                  value: '15h',
                  total: '30h',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  title: 'Mots appris',
                  value: '156',
                  total: '500',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required String value,
    required String total,
    required Color color,
  }) {
    final currentValue = double.tryParse(value) ?? 0;
    final totalValue = double.tryParse(total) ?? 1;
    final percentage = (currentValue / totalValue).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value/$total',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Vos succès et accomplissements!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _navigateToLearning() {
    final learningVM =
        Provider.of<LearningViewModel>(context, listen: false);
    if (learningVM.lessons.isNotEmpty) {
      final firstLesson = learningVM.lessons.first;
      Navigator.pushNamed(
        context,
        '/lesson',
        arguments: firstLesson.id,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune leçon disponible pour le moment.'),
        ),
      );
    }
  }

  void _navigateToPronunciation() {
    Navigator.pushNamed(context, '/pronunciation-practice');
  }

  void _navigateToQuiz() {
    Navigator.pushNamed(context, '/quiz');
  }

  void _navigateToObjectRecognition() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('La reconnaissance d\'objets n\'est pas disponible sur le web.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Reconnaissance d\'objets'),
          ),
          body: const SafeArea(
            child: ObjectRecognitionWidget(),
          ),
        ),
      ),
    );
  }

  void _navigateToCommunity() {
    // Naviguer vers l'écran communauté (déjà dans la navigation principale)
    // Cette méthode peut être utilisée pour des actions spécifiques
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers la communauté...'),
      ),
    );
  }

  void _navigateToStatistics() {
    Navigator.pushNamed(context, '/statistics');
  }

  void _navigateToChallenges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Défis quotidiens - Bientôt disponible !'),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _startDailyChallenge() {
    // Démarrer le défi quotidien
  }
}
