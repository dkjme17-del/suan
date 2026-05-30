import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/learning_viewmodel.dart';
import 'object_recognition_widget_entry.dart';
import '../../../../shared/services/ai_recommendation_service.dart';
import '../../../../core/theme/baule_colors.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  Future<AiRecommendation>? _recommendationFuture;

  Future<AiRecommendation> _getRecommendation(LearningViewModel learningVM) {
    final lessons = learningVM.lessons;
    final completedCount = lessons.where((l) => l.isCompleted).length;

    return AiRecommendationService().getDailyRecommendation(
      progress: learningVM.progressPercentage,
      level: learningVM.currentLevel,
      streakDays: learningVM.currentUser?.streakDays ?? 0,
      favoritesCount: learningVM.favorites.length,
      lessonsCount: lessons.length,
      completedCount: completedCount,
    );
  }

  @override
  void initState() {
    super.initState();
    // S'assurer que les données d'apprentissage sont chargées
    Future.microtask(() {
      final learningVM = Provider.of<LearningViewModel>(context, listen: false);
      learningVM.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<LearningViewModel>(
          builder: (context, learningVM, _) {
            _recommendationFuture ??= _getRecommendation(learningVM);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(learningVM),
                  const SizedBox(height: 24),
                  _buildProgressCard(learningVM),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildRecommendations(),
                  const SizedBox(height: 24),
                  const ObjectRecognitionWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(LearningViewModel learningVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${learningVM.currentUser?.username ?? 'Apprenant'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prêt à apprendre le baoulé aujourd\'hui?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            FontAwesomeIcons.fire,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(LearningViewModel learningVM) {
    final progress = learningVM.progressPercentage;
    final currentLevel = learningVM.currentUser?.level ?? 1;
    final streak = learningVM.currentUser?.streakDays ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau $currentLevel',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.fire,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak jours',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Progression',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% complété',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: FontAwesomeIcons.play,
                label: 'Continuer',
                color: Theme.of(context).primaryColor,
                onTap: () {
                  final learningVM = Provider.of<LearningViewModel>(
                    context,
                    listen: false,
                  );
                  final lessons = learningVM.lessons;
                  if (lessons.isEmpty) return;
                  // Pour l'instant on prend la première leçon disponible.
                  final current = lessons.first;
                  Navigator.pushNamed(
                    context,
                    '/lesson',
                    arguments: current.id,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: FontAwesomeIcons.microphone,
                label: 'Pratiquer',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/pronunciation-practice');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<LearningViewModel>(
      builder: (context, learningVM, _) {
        final user = learningVM.currentUser;
        // For now, we'll show empty friends list since RealCommunityService doesn't have this method
        final friends = <dynamic>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  icon: FontAwesomeIcons.book,
                  value: '${user?.totalPoints ?? 0}',
                  label: 'Points totaux',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.userFriends,
                  value: '${friends.length}',
                  label: 'Amis',
                  color: Colors.purple,
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.trophy,
                  value: '${user?.level ?? 1}',
                  label: 'Niveau',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.clock,
                  value: '${user?.streakDays ?? 0}',
                  label: 'Jours consécutifs',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Culture baoulé',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCultureCard(
                    title: 'Masques Goli',
                    subtitle: 'Rituels festifs',
                    color: BauleColors.gold,
                    icon: FontAwesomeIcons.masksTheater,
                    onTap: () {
                      Navigator.pushNamed(context, '/catalogue-baoule');
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildCultureCard(
                    title: 'Textiles',
                    subtitle: 'Motifs géométriques',
                    color: BauleColors.redOrange,
                    icon: FontAwesomeIcons.shirt,
                    onTap: () {
                      Navigator.pushNamed(context, '/catalogue-baoule');
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildCultureCard(
                    title: 'Danses',
                    subtitle: 'Vidéos immersives',
                    color: BauleColors.darkGold,
                    icon: FontAwesomeIcons.drum,
                    onTap: () {
                      Navigator.pushNamed(context, '/catalogue-baoule');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCultureCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: BauleColors.darken(color), size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations IA',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder<AiRecommendation>(
          future: _recommendationFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final rec = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.robot,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec?.title ?? 'Suggestion du jour',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rec?.message ??
                        'Génération de votre recommandation personnalisée…',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: rec == null
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              rec.actionRoute,
                              arguments: rec.actionArgs,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Commencer'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
