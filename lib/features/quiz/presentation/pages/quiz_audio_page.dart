import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/premium_widgets.dart';

/// ÉCRAN 7: Quiz Audio
class QuizAudioPage extends StatefulWidget {
  const QuizAudioPage({Key? key}) : super(key: key);

  @override
  State<QuizAudioPage> createState() => _QuizAudioPageState();
}

class _QuizAudioPageState extends State<QuizAudioPage>
    with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int _score = 0;
  List<String> _userAnswers = [];
  late AnimationController _playButtonController;
  bool _isPlaying = false;
  List<AudioQuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    super.dispose();
  }

  void _playAudio() {
    _playButtonController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _playButtonController.reverse();
      });
    });

    setState(() {
      _isPlaying = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

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
                    Icons.music_note,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz Audio Terminé!',
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
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
        title: const Text('Quiz Audio'),
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
            const SizedBox(height: 48),
            Text(
              'Écoutez et sélectionnez la traduction',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Audio Play Button
            GestureDetector(
              onTap: _playAudio,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.1)
                    .animate(_playButtonController),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Options
            Column(
              children: question.options.map((option) {
                final isSelected =
                    option == _userAnswers.getOrNull(_currentQuestion);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.secondaryColor : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.secondaryColor
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.secondaryColor
                                    : Colors.grey[400]!,
                              ),
                              color:
                                  isSelected ? AppTheme.secondaryColor : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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

class AudioQuizQuestion {
  final String id;
  final String audioLabel;
  final List<String> options;
  final String correctAnswer;

  AudioQuizQuestion({
    required this.id,
    required this.audioLabel,
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
