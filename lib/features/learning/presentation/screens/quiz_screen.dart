import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:suan/shared/services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeux'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Quiz'),
            Tab(text: 'Défis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildQuizTab(), _buildChallengesTab()],
      ),
    );
  }

  Widget _buildQuizTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: QuizService().streamQuizCategories(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final data = snapshot.data ?? [];

        final categories = data.map((raw) {
          return QuizCategory(
            id: raw['id']?.toString() ?? '',
            name: raw['name']?.toString() ?? 'Sans titre',
            icon: FontAwesomeIcons.circleQuestion,
            color: Theme.of(context).primaryColor,
            description: raw['description']?.toString() ?? '',
            quizCount:
                (raw['quizCount'] as num?)?.toInt() ??
                (raw['questionCount'] as num?)?.toInt() ??
                0,
          );
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakCard(),
              const SizedBox(height: 24),
              Text(
                'Catégories de quiz',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                Center(child: Text('Erreur: ${snapshot.error}'))
              else if (categories.isEmpty)
                const Center(
                  child: Text('Aucune catégorie disponible (depuis Firestore)'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final category = categories[index];
                    return Builder(
                      builder: (BuildContext ctx) =>
                          _buildCategoryCard(ctx, category),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesTab() {
    // Les défis chargent depuis Firestore (voir quiz_service)
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: QuizService().streamDailyChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final dailyChallenges = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeeklyProgress(),
              const SizedBox(height: 24),
              Text(
                'Défis quotidiens',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (dailyChallenges.isEmpty)
                const Center(
                  child: Text(
                    'Aucun défi disponible (données depuis Firestore)',
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyChallenges.length,
                  itemBuilder: (_, index) {
                    final challenge = dailyChallenges[index];
                    return Builder(
                      builder: (BuildContext ctx) =>
                          _buildChallengeCardFromMap(ctx, challenge),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.fire,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Série actuelle: 5 jours',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Continuez votre progression !',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, QuizCategory category) {
    return InkWell(
      onTap: () {
        // Ouvrir la liste de quiz filtrée par catégorie
        Navigator.pushNamed(
          context,
          '/quiz',
          arguments: category
              .id, // ex: 'conversation', 'culture', 'grammar', 'vocabulary'
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: category.color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: category.color, size: 32),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: category.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.quizCount} quiz',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression hebdomadaire',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '65% complété',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                '13/20 quiz',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildChallengeCardFromMap(
  BuildContext context,
  Map<String, dynamic> challenge,
) {
  final title = challenge['title'] ?? 'Défi';
  final description = challenge['description'] ?? '';
  final points = challenge['points'] ?? 0;
  final icon = challenge['icon'] ?? 'trophy';
  final progress = (challenge['progress'] as num?)?.toDouble() ?? 0.0;

  IconData iconData;
  switch (icon) {
    case 'book':
      iconData = Icons.book;
      break;
    case 'calculator':
      iconData = Icons.calculate;
      break;
    case 'users':
      iconData = Icons.people;
      break;
    case 'trophy':
    default:
      iconData = Icons.emoji_events;
      break;
  }

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
            color: progress == 1.0
                ? Colors.green.withValues(alpha: 0.1)
                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData,
            color: progress == 1.0
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
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '$points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: progress == 1.0
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
  );
}

class QuizCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final int quizCount;

  QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.quizCount,
  });
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final double progress;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.progress,
  });
}
