import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/premium_widgets.dart';

/// ÉCRAN 8: Quiz Visuel (Image Quiz)
class QuizVisualPage extends StatefulWidget {
  const QuizVisualPage({Key? key}) : super(key: key);

  @override
  State<QuizVisualPage> createState() => _QuizVisualPageState();
}

class _QuizVisualPageState extends State<QuizVisualPage> {
  int _currentQuestion = 0;
  int _score = 0;
  List<String> _userAnswers = [];
  List<VisualQuizQuestion> _questions = [];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    if (_currentQuestion >= _questions.length) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.primaryColor,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz Visuel Terminé!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Score: $_score/${_questions.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pourcentage: ${((_score / _questions.length) * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Dashboard',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentQuestion = 0;
                            _score = 0;
                            _userAnswers = [];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Recommencer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quiz Visuel'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProgressIndicator(
              current: _currentQuestion + 1,
              total: _questions.length,
            ),
            const SizedBox(height: 32),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Image/Emoji
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  question.imageEmoji,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Options Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected =
                    option == _userAnswers.getOrNull(_currentQuestion);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_userAnswers.length <= _currentQuestion) {
                        _userAnswers.add(option);
                      } else {
                        _userAnswers[_currentQuestion] = option;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (_userAnswers.length <= _currentQuestion) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner une réponse'),
                    ),
                  );
                  return;
                }

                if (_userAnswers[_currentQuestion] == question.correctAnswer) {
                  _score++;
                }

                setState(() {
                  _currentQuestion++;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _currentQuestion == _questions.length - 1
                        ? 'Terminer'
                        : 'Suivant',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisualQuizQuestion {
  final String id;
  final String question;
  final String imageEmoji;
  final List<String> options;
  final String correctAnswer;

  VisualQuizQuestion({
    required this.id,
    required this.question,
    required this.imageEmoji,
    required this.options,
    required this.correctAnswer,
  });
}

extension on List {
  getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
