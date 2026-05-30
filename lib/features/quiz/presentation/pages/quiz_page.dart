import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/common_widgets.dart';
import '../viewmodels/quiz_viewmodel.dart';

class QuizListPage extends StatefulWidget {
  final String? level;

  const QuizListPage({super.key, this.level});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  String _selectedLevel = 'beginner';

  @override
  void initState() {
    super.initState();
    if (widget.level != null) {
      _selectedLevel = widget.level!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtre de catégorie passé depuis QuizScreen (peut être null)
    final selectedCategory =
        ModalRoute.of(context)?.settings.arguments as String?;

    final quizzesStream = selectedCategory != null
        ? FirebaseFirestore.instance
              .collection('quiz_questions')
              .where('category', isEqualTo: selectedCategory)
              .snapshots()
        : FirebaseFirestore.instance.collection('quiz_questions').snapshots();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Quiz',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: quizzesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final quizDocs = (snapshot.data?.docs ?? []).where((doc) {
            final data = doc.data();
            final level = (data['level'] ?? data['difficulty'] ?? '')
                .toString()
                .toLowerCase();
            return level.isEmpty || level == _selectedLevel;
          }).toList();

          if (quizDocs.isEmpty) {
            return Center(
              child: Text(
                selectedCategory != null
                    ? 'Aucune question trouvée pour la catégorie: $selectedCategory'
                    : 'Aucune question de quiz trouvée.',
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLevelChip('Débutant', 'beginner'),
                        const SizedBox(width: 8),
                        _buildLevelChip('Intermédiaire', 'intermediate'),
                        const SizedBox(width: 8),
                        _buildLevelChip('Avancé', 'advanced'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: quizDocs.length,
                    itemBuilder: (context, index) {
                      final quizData = quizDocs[index].data();
                      final quizId = quizDocs[index].id;
                      return _buildQuizCardFromFirestore(
                        context,
                        quizData,
                        quizId,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelChip(String label, String level) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCardFromFirestore(
    BuildContext context,
    Map<String, dynamic> quizData,
    String quizId,
  ) {
    // Adaptation aux documents de la collection quiz_questions
    final title = quizData['question'] ?? quizData['title'] ?? 'Sans titre';
    final description =
        quizData['explanation'] ?? quizData['description'] ?? '';
    final questionCount =
        (quizData['questionCount'] as num?)?.toInt() ??
        (quizData['points'] as num?)?.toInt() ??
        1;
    final timeoutSeconds = 30;
    final category = (quizData['category'] ?? 'vocabulary').toString();

    return CustomCard(
      onTap: () {
        Navigator.pushNamed(context, '/quiz-play', arguments: quizId);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _CategoryBadge(label: category),
            ],
          ),
          const SizedBox(height: 8),
          if (description.isNotEmpty)
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          Text(
            '$questionCount questions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                '$timeoutSeconds secondes par question',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;

  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final displayLabel = label.trim().isEmpty ? 'quiz' : label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Text(
        displayLabel,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class QuizPlayPage extends StatefulWidget {
  final String quizId;

  const QuizPlayPage({super.key, required this.quizId});

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  late QuizViewModel _quizVM;

  int get correctAnswers {
    if (_quizVM.currentQuiz == null) return 0;
    int count = 0;
    for (final entry in _quizVM.answers.entries) {
      final question = _quizVM.currentQuiz!.questions.firstWhere(
        (q) => q.id == entry.key,
        orElse: () => _quizVM.currentQuiz!.questions.first,
      );
      if (question.correctAnswer == entry.value) {
        count++;
      }
    }
    return count;
  }

  int get totalQuestions => _quizVM.totalQuestions;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<QuizViewModel>(
        context,
        listen: false,
      ).startQuiz(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Quiz en cours',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<QuizViewModel>(
        builder: (context, quizVM, child) {
          if (quizVM.currentQuiz == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (quizVM.currentQuestionIndex + 1) / quizVM.totalQuestions,
                  minHeight: 4,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${quizVM.currentQuestionIndex + 1}/${quizVM.totalQuestions}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          quizVM.currentQuestion?.question ??
                              'Question non disponible',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        if (quizVM.currentQuestion != null)
                          _buildOptionsList(quizVM),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              if (quizVM.currentQuestionIndex > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: quizVM.previousQuestion,
                                    child: const Text('Précédent'),
                                  ),
                                ),
                              if (quizVM.currentQuestionIndex > 0)
                                const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (quizVM.isLastQuestion) {
                                      _showQuizResult(quizVM);
                                    } else {
                                      quizVM.nextQuestion();
                                    }
                                  },
                                  child: Text(
                                    quizVM.isLastQuestion
                                        ? 'Terminer'
                                        : 'Suivant',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsList(QuizViewModel quizVM) {
    final options = quizVM.currentQuestion?.options ?? <String>[];
    final questionId = quizVM.currentQuestion?.id ?? '';

    return Column(
      children: options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = quizVM.answers[questionId] == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              quizVM.selectAnswer(questionId, option);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showQuizResult(QuizViewModel quizVM) async {
    final score = quizVM.getScore();
    final totalQuestionsVal = quizVM.totalQuestions;

    int correctCount = 0;
    if (quizVM.currentQuiz != null) {
      for (final entry in quizVM.answers.entries) {
        final question = quizVM.currentQuiz!.questions.firstWhere(
          (q) => q.id == entry.key,
          orElse: () => quizVM.currentQuiz!.questions.first,
        );
        if (question.correctAnswer == entry.value) {
          correctCount++;
        }
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text('Quiz terminé!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correctCount/$totalQuestionsVal',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$score points',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+$score points',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      );
    }
  }
}
