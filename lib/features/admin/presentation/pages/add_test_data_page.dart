import 'package:flutter/material.dart';
import 'package:suan/shared/services/test_data_service.dart';

class AddTestDataPage extends StatefulWidget {
  const AddTestDataPage({super.key});

  @override
  State<AddTestDataPage> createState() => _AddTestDataPageState();
}

class _AddTestDataPageState extends State<AddTestDataPage> {
  bool _isLoading = false;
  String _status = '';
  Map<String, dynamic> _stats = {
    'lessons': 0,
    'quizQuestions': 0,
    'challenges': 0,
    'users': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final testDataService = TestDataService();
      final stats = await testDataService.getTestDataStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }
  }

  Future<void> _verifyFirestoreData() async {
    setState(() {
      _isLoading = true;
      _status = 'Vérification des données Firestore en cours...';
    });

    try {
      final testDataService = TestDataService();
      await testDataService.verifyFirestoreData();

      setState(() {
        _status =
            '✅ Vérification terminée !\n\n'
            'Consultez les logs de la console pour voir le détail des données trouvées dans Firestore.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur lors de la vérification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des données de test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistiques actuelles depuis Firestore
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Données actuelles dans Firestore',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('📚', '${_stats['lessons']}', 'Leçons'),
                      _buildStatItem(
                        '🧠',
                        '${_stats['quizQuestions']}',
                        'Quiz',
                      ),
                      _buildStatItem('🏆', '${_stats['challenges']}', 'Défis'),
                      _buildStatItem(
                        '👥',
                        '${_stats['users']}',
                        'Utilisateurs',
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Actions de diagnostic :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Console de débogage',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les résultats de vérification apparaissent dans la console de développement Flutter.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildContentItem(
              '📚',
              'Leçons',
              '${_stats['lessons']} existantes + 6 nouvelles',
            ),
            _buildContentItem(
              '🧠',
              'Quiz',
              '${_stats['quizQuestions']} existantes + 7 nouvelles',
            ),
            _buildContentItem(
              '🏆',
              'Défis',
              '${_stats['challenges']} existants + 6 nouveaux',
            ),
            _buildContentItem(
              '👥',
              'Utilisateurs',
              '${_stats['users']} existants + 2 nouveaux',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addTestData,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter les données'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isLoading ? null : _loadStats,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rafraîchir les statistiques',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _verifyFirestoreData,
                icon: const Icon(Icons.search),
                label: const Text('Vérifier les données Firestore'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _status.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status.contains('✅')
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.contains('✅')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Ajout des données de test en cours...';
    });

    try {
      final testDataService = TestDataService();
      await testDataService.addTestData();

      // Recharger les statistiques après ajout
      await _loadStats();

      setState(() {
        _status =
            '✅ Données de test ajoutées avec succès !\n\n'
            'Les statistiques ont été mises à jour.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur lors de l\'ajout des données: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildContentItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
