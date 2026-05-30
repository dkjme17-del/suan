import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/premium_widgets.dart';
import 'package:suan/features/learning/presentation/viewmodels/lesson_realtime_viewmodel.dart';

/// ÉCRAN 4: Sélection des Leçons - TEMPS RÉEL FIRESTORE
class LessonSelectionPage extends StatefulWidget {
  const LessonSelectionPage({Key? key}) : super(key: key);

  @override
  State<LessonSelectionPage> createState() => _LessonSelectionPageState();
}

class _LessonSelectionPageState extends State<LessonSelectionPage> {
  String _selectedLevel = 'beginner';
  bool _isFavoriteOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Leçons'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _selectedLevel == 'all'
          ? context.read<LessonRealtimeViewModel>().streamAllLessons()
          : context.read<LessonRealtimeViewModel>().streamLessonsByLevel(_selectedLevel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          var lessonDocs = snapshot.data?.docs ?? [];
          
          // Filtrer par favoris si nécessaire
          if (_isFavoriteOnly) {
            lessonDocs = lessonDocs.where((doc) {
              final data = doc.data();
              return data['isFavorite'] == true;
            }).toList();
          }

          if (lessonDocs.isEmpty) {
            return const Center(
              child: Text('Aucune leçon trouvée'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveaux',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Tous', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Débutant', 'beginner'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Intermédiaire', 'intermediate'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Avancé', 'advanced'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _isFavoriteOnly,
                            onChanged: (value) {
                              setState(() {
                                _isFavoriteOnly = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          const Text('Afficher uniquement les favoris'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Leçons - Données temps réel Firestore
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lessonDocs.length,
                  itemBuilder: (context, index) {
                    final lessonData = lessonDocs[index].data();
                    final lessonId = lessonDocs[index].id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLessonCardFromFirestore(
                        context,
                        lessonData,
                        lessonId,
                      ),
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

  Widget _buildLessonCardFromFirestore(
    BuildContext context,
    Map<String, dynamic> lessonData,
    String lessonId,
  ) {
    final title = lessonData['title'] ?? 'Sans titre';
    final description = lessonData['description'] ?? '';
    final level = lessonData['level'] ?? 'beginner';
    final duration = (lessonData['duration'] as num?)?.toInt() ?? 10;
    final isFavorite = lessonData['isFavorite'] ?? false;
    final iconString = lessonData['icon'] ?? 'book';
    
    // Map icon string to IconData
    IconData getIcon(String iconName) {
      switch (iconName) {
        case 'waving_hand': return Icons.waving_hand;
        case 'numbers': return Icons.numbers;
        case 'people': return Icons.people;
        case 'restaurant': return Icons.restaurant;
        case 'auto_stories': return Icons.auto_stories;
        default: return Icons.book;
      }
    }

    return ModernLessonCard(
      title: title,
      description: description,
      level: level,
      duration: duration,
      isFavorite: isFavorite,
      onTap: () {
        Navigator.pushNamed(
          context,
          '/lesson-detail',
          arguments: lessonId,
        );
      },
      onFavoriteTap: () {
        // Mettre à jour le statut favori dans Firestore
        context.read<LessonRealtimeViewModel>().toggleFavoriteLessonInFirestore(
          lessonId,
          !isFavorite,
        );
      },
      icon: getIcon(iconString),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedLevel == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String level; // beginner, intermediate, advanced
  final int duration; // minutes
  bool isFavorite;
  final IconData icon;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.duration,
    required this.isFavorite,
    required this.icon,
  });
}
