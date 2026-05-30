import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/common_widgets.dart';
import '../viewmodels/learning_viewmodel.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;

  const LessonDetailPage({super.key, required this.lessonId});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<LearningViewModel>(
          context,
          listen: false,
        ).selectLesson(widget.lessonId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Détail de la leçon',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<LearningViewModel>(
        builder: (context, learningVM, _) {
          final lesson = learningVM.currentLesson;

          if (lesson == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec image
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: AppTheme.primaryColor,
                    child: Center(
                      child: Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre et badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LevelBadge(
                                    level: int.tryParse(lesson.level) ?? 1,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    lesson.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displaySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                learningVM.isFavorite(lesson.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: learningVM.isFavorite(lesson.id)
                                    ? AppTheme.accentColor
                                    : AppTheme.textSecondaryColor,
                              ),
                              onPressed: () {
                                learningVM.toggleFavorite(lesson);
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Description
                        Text(
                          lesson.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        SizedBox(height: 24),

                        // Contenu
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contenu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 12),
                              Text(
                                lesson.content,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Vocabulaire
                        if (lesson.vocabulary.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vocabulaire',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: lesson.vocabulary
                                    .map(
                                      (word) => Chip(
                                        label: Text(word),
                                        backgroundColor: AppTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                        labelStyle: TextStyle(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),

                        // Durée
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppTheme.textSecondaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${lesson.durationMinutes} minutes',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32),

                        // Boutons d'action
                        PrimaryButton(
                          label: 'Leçon terminée',
                          onPressed: () async {
                            await learningVM.completeLesson(lesson.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Leçon complétée! +10 points'),
                                ),
                              );
                            }
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
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
