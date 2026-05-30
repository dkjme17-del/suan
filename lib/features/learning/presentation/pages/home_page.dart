import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/common_widgets.dart';
import '../viewmodels/learning_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<LearningViewModel>(context, listen: false).init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Suan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<LearningViewModel>(
        builder: (context, learningVM, _) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // En-tête avec progression
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Continuez votre apprentissage du baoulé',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCard(
                              label: 'Points',
                              value: '0',
                              icon: Icons.star,
                            ),
                            _StatCard(
                              label: 'Séries',
                              value: '0',
                              icon: Icons.local_fire_department,
                            ),
                            _StatCard(
                              label: 'Jours',
                              value: '0',
                              icon: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sélection de niveau
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisir un niveau',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _LevelButton(
                              label: 'Débutant',
                              isSelected: learningVM.currentLevel == 'beginner',
                              onTap: () =>
                                  learningVM.loadLessonsByLevel('beginner'),
                            ),
                            _LevelButton(
                              label: 'Intermédiaire',
                              isSelected:
                                  learningVM.currentLevel == 'intermediate',
                              onTap: () =>
                                  learningVM.loadLessonsByLevel('intermediate'),
                            ),
                            _LevelButton(
                              label: 'Avancé',
                              isSelected: learningVM.currentLevel == 'advanced',
                              onTap: () =>
                                  learningVM.loadLessonsByLevel('advanced'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Leçons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leçons',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        if (learningVM.isLoading)
                          Center(child: CircularProgressIndicator())
                        else if (learningVM.lessons.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Aucune leçon disponible'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: learningVM.lessons.length,
                            itemBuilder: (context, index) {
                              final lesson = learningVM.lessons[index];
                              final isFav = learningVM.isFavorite(lesson.id);
                              return CustomCard(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/lesson',
                                    arguments: lesson.id,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            child: LevelBadge(
                                              level:
                                                  int.tryParse(
                                                    lesson.level.toString(),
                                                  ) ??
                                                  1,
                                            ),
                                          ),
                                          Text(
                                            lesson.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            lesson.description,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '${lesson.durationMinutes} minutes',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                      ),
                                      color: isFav
                                          ? AppTheme.accentColor
                                          : AppTheme.textSecondaryColor,
                                      onPressed: () {
                                        learningVM.toggleFavorite(lesson);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Boutons d'action
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.quiz),
                            label: Text('Quiz'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/quiz');
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.games),
                            label: Text('Jeux'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Jeux disponibles bientôt'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
