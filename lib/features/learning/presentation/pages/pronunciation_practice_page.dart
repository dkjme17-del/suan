import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/pronunciation_widget.dart';

class PronunciationPracticePage extends StatefulWidget {
  const PronunciationPracticePage({super.key});

  @override
  State<PronunciationPracticePage> createState() =>
      _PronunciationPracticePageState();
}

class _PronunciationPracticePageState extends State<PronunciationPracticePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double _overallScore = 0.0;
  int _completedPhrases = 0;

  // Phrases de pratique organisées par niveau
  final List<Map<String, dynamic>> _beginnerPhrases = [
    {
      'baoule': 'I ni sôgô',
      'french': 'Bonjour',
      'difficulty': 'Facile',
      'category': 'Salutations',
    },
    {
      'baoule': 'I ni woulê',
      'french': 'Au revoir',
      'difficulty': 'Facile',
      'category': 'Salutations',
    },
    {
      'baoule': 'An ni sran',
      'french': 'Comment ça va ?',
      'difficulty': 'Moyen',
      'category': 'Questions',
    },
    {
      'baoule': 'Kôlôsi bôlô',
      'french': 'Merci beaucoup',
      'difficulty': 'Facile',
      'category': 'Politesse',
    },
  ];

  final List<Map<String, dynamic>> _intermediatePhrases = [
    {
      'baoule': 'Mi bê ti kôlôsi',
      'french': 'Je veux de l\'eau',
      'difficulty': 'Moyen',
      'category': 'Quotidien',
    },
    {
      'baoule': 'A ka kôlôsi man',
      'french': 'Il n\'y a pas d\'eau',
      'difficulty': 'Difficile',
      'category': 'Négation',
    },
  ];

  final List<Map<String, dynamic>> _advancedPhrases = [
    {
      'baoule': 'Mi bê ti kôlôsi walê ti sran fla',
      'french': 'Je veux de l\'eau et trois personnes',
      'difficulty': 'Difficile',
      'category': 'Complexe',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onScoreUpdate(double score) {
    setState(() {
      _overallScore =
          (_overallScore * _completedPhrases + score) / (_completedPhrases + 1);
      _completedPhrases++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratique de prononciation'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_overallScore.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Débutant'),
            Tab(text: 'Intermédiaire'),
            Tab(text: 'Avancé'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPhraseList(_beginnerPhrases, 'Débutant'),
            _buildPhraseList(_intermediatePhrases, 'Intermédiaire'),
            _buildPhraseList(_advancedPhrases, 'Avancé'),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseList(List<Map<String, dynamic>> phrases, String level) {
    if (phrases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.tools, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Contenu $level en préparation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Bientôt disponible !',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques du niveau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getLevelColor(level).withValues(alpha: 0.1),
                  _getLevelColor(level).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getLevelColor(level).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getLevelIcon(level),
                  color: _getLevelColor(level),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau $level',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${phrases.length} phrases disponibles',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(level),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Liste des phrases
          ...phrases.map(
            (phrase) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PronunciationWidget(
                baouleText: phrase['baoule'],
                frenchText: phrase['french'],
                audioPath: phrase['audioPath'],
                onScoreUpdate: _onScoreUpdate,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton pour recommencer
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _overallScore = 0.0;
                  _completedPhrases = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pratique recommencée !'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(FontAwesomeIcons.rotateLeft),
              label: const Text('Recommencer la pratique'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Débutant':
        return Colors.green;
      case 'Intermédiaire':
        return Colors.orange;
      case 'Avancé':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'Débutant':
        return FontAwesomeIcons.seedling;
      case 'Intermédiaire':
        return FontAwesomeIcons.chartLine;
      case 'Avancé':
        return FontAwesomeIcons.crown;
      default:
        return FontAwesomeIcons.circleQuestion;
    }
  }
}
