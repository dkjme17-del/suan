import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _selectedLevel = 'débutant';
  String _selectedMode = 'classique';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprendre'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildLessonsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveau',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['débutant', 'intermédiaire', 'avancé'].map((level) {
                final isSelected = _selectedLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(level.capitalize()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLevel = level;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mode d\'apprentissage',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildModeChip('classique', FontAwesomeIcons.book),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeChip('ludique', FontAwesomeIcons.gamepad),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeChip(
                  'non alphabétisé',
                  FontAwesomeIcons.volumeUp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              mode,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    // Mapper le niveau sélectionné vers le champ 'level' utilisé dans Firestore
    String firestoreLevel;
    switch (_selectedLevel) {
      case 'débutant':
        firestoreLevel = 'beginner';
        break;
      case 'intermédiaire':
        firestoreLevel = 'intermediate';
        break;
      case 'avancé':
        firestoreLevel = 'advanced';
        break;
      default:
        firestoreLevel = 'beginner';
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('lessons')
          .where('level', isEqualTo: firestoreLevel)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.bookOpen,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune leçon disponible pour ce niveau.',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vérifiez vos leçons dans Firestore (collection "lessons").',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final lessons = docs.map((doc) {
          final data = doc.data();
          return Lesson(
            id: doc.id,
            title: data['title']?.toString() ?? 'Sans titre',
            description: data['description']?.toString() ?? '',
            duration: data['duration']?.toString() ?? '15 min',
            difficulty: _selectedLevel,
            isLocked: data['isLocked'] as bool? ?? false,
            isCompleted: data['isCompleted'] as bool? ?? false,
            progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
            icon: FontAwesomeIcons.bookOpen,
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildLessonCard(lesson),
            );
          },
        );
      },
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return Container(
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
      child: InkWell(
        onTap: lesson.isLocked
            ? null
            : () {
                Navigator.pushNamed(context, '/lesson', arguments: lesson.id);
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: lesson.isLocked
                      ? Colors.grey[300]
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  lesson.icon,
                  size: 24,
                  color: lesson.isLocked
                      ? Colors.grey[500]
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: lesson.isLocked
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (lesson.isCompleted)
                          Icon(
                            FontAwesomeIcons.checkCircle,
                            color: Colors.green,
                            size: 16,
                          ),
                        if (lesson.isLocked)
                          Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.grey,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.duration,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(lesson.difficulty),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            lesson.difficulty,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!lesson.isLocked && lesson.progress > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: lesson.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                color: lesson.isLocked ? Colors.grey[300] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'débutant':
        return Colors.green;
      case 'intermédiaire':
        return Colors.orange;
      case 'avancé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final bool isLocked;
  final bool isCompleted;
  final double progress;
  final IconData icon;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.isLocked,
    required this.isCompleted,
    required this.progress,
    required this.icon,
  });
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
