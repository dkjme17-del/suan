import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../audio/domain/services/audio_service.dart';

class PronunciationWidget extends StatefulWidget {
  final String baouleText;
  final String frenchText;
  final String? audioPath;
  final Function(String)? onRecordingComplete;
  final Function(double)? onScoreUpdate;

  const PronunciationWidget({
    Key? key,
    required this.baouleText,
    required this.frenchText,
    this.audioPath,
    this.onRecordingComplete,
    this.onScoreUpdate,
  }) : super(key: key);

  @override
  State<PronunciationWidget> createState() => _PronunciationWidgetState();
}

class _PronunciationWidgetState extends State<PronunciationWidget>
    with TickerProviderStateMixin {
  late AudioService _audioService;
  bool _isRecording = false;
  bool _isPlaying = false;
  double _pronunciationScore = 0.0;
  String _recordingStatus = 'Prêt à enregistrer';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.08),
            Colors.purple.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isRecording
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.blue.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isRecording ? Colors.red : Colors.blue).withValues(
              alpha: 0.1,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTextSection(),
          const SizedBox(height: 24),
          _buildAudioControls(),
          if (_pronunciationScore > 0) ...[
            const SizedBox(height: 24),
            _buildScoreSection(),
          ],
          const SizedBox(height: 20),
          _buildRecordingStatus(),
          if (_pronunciationScore > 0) ...[
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            FontAwesomeIcons.microphone,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pratique de prononciation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                'Écoute • Enregistre • Compare',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (_pronunciationScore > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getScoreColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(_getScoreIcon(), color: _getScoreColor(), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_pronunciationScore.toInt()}%',
                  style: TextStyle(
                    color: _getScoreColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.language, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Baoulé',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.baouleText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.language,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Français',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.frenchText,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[900]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Contrôles audio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isPlaying
                    ? FontAwesomeIcons.pause
                    : FontAwesomeIcons.play,
                label: 'Écouter',
                color: Colors.blue,
                onTap: _isPlaying ? null : _playAudio,
                isActive: _isPlaying,
              ),
              _buildRecordButton(),
              _buildControlButton(
                icon: FontAwesomeIcons.hourglassHalf,
                label: 'Lent',
                color: Colors.purple,
                onTap: _playSlowAudio,
                subtitle: '0.8x',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Étape 1: Écoute • Étape 2: Enregistre • Étape 3: Compare',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    String? subtitle,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: onTap == null
                    ? [Colors.grey[300]!, Colors.grey[400]!]
                    : isActive
                    ? [color.withValues(alpha: 0.8), color]
                    : [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: onTap == null ? Colors.grey[500] : Colors.grey[800],
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [Colors.red[400]!, Colors.red[600]!]
                      : [Colors.red[500]!, Colors.red[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(
                      alpha: _isRecording ? 0.5 : 0.3,
                    ),
                    blurRadius: _isRecording ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _isRecording
                        ? FontAwesomeIcons.stop
                        : FontAwesomeIcons.microphone,
                    color: Colors.white,
                    size: 28,
                  ),
                  if (_isRecording)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording ? 'Arrêter' : 'Enregistrer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          if (_isRecording)
            Text(
              'En cours...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    Color scoreColor;
    String scoreText;

    if (_pronunciationScore >= 80) {
      scoreColor = Colors.green;
      scoreText = 'Excellent !';
    } else if (_pronunciationScore >= 60) {
      scoreColor = Colors.orange;
      scoreText = 'Bien !';
    } else {
      scoreColor = Colors.red;
      scoreText = 'À améliorer';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score de prononciation',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_pronunciationScore.toInt()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _pronunciationScore / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            scoreText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isRecording
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isRecording
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isRecording
                ? FontAwesomeIcons.circle
                : FontAwesomeIcons.infoCircle,
            color: _isRecording ? Colors.red : Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _recordingStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isRecording ? Colors.red : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions supplémentaires',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: FontAwesomeIcons.rotateRight,
                label: 'Recommencer',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _pronunciationScore = 0;
                    _recordingStatus = 'Prêt à enregistrer';
                  });
                },
              ),
              _buildActionButton(
                icon: FontAwesomeIcons.lightbulb,
                label: 'Conseils',
                color: Colors.amber,
                onTap: () {
                  _showTipsDialog();
                },
              ),
              _buildActionButton(
                icon: FontAwesomeIcons.chartLine,
                label: 'Statistiques',
                color: Colors.teal,
                onTap: () {
                  _showStatsDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Conseils de prononciation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Parlez lentement et clairement'),
            Text('• Articulez bien chaque syllabe'),
            Text('• Écoutez d\'abord l\'exemple'),
            Text('• Enregistrez-vous plusieurs fois'),
            Text('• Concentrez-vous sur les sons difficiles'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris !'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score actuel: ${_pronunciationScore.toInt()}%'),
            const SizedBox(height: 8),
            Text('Phrases pratiquées: 1'),
            const SizedBox(height: 8),
            Text('Temps d\'exercice: 2 min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio() async {
    setState(() {
      _isPlaying = true;
    });

    try {
      bool audioPlayed = false;
      if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
        audioPlayed = await _audioService.playLocalAudio(widget.audioPath!);
      }

      // Si l'audio n'a pas pu être joué ou n'existe pas, utiliser la synthèse vocale
      if (!audioPlayed) {
        await _audioService.speakBaoule(widget.baouleText);
      }
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
      // Fallback vers TTS en cas d'erreur
      try {
        await _audioService.speakBaoule(widget.baouleText);
      } catch (ttsError) {
        print('Erreur TTS fallback: $ttsError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erreur de lecture audio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _playSlowAudio() async {
    setState(() {
      _isPlaying = true;
    });

    try {
      // Lecture lente (0.8x vitesse)
      await _audioService.speakBaoule(widget.baouleText, slowMode: true);
    } catch (e) {
      print('Erreur lors de la lecture lente: $e');
    }

    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordingStatus = 'Enregistrement en cours...';
    });

    try {
      _pulseController.repeat(reverse: true);

      // Démarrer l'enregistrement
      await _audioService.startListening();

      // Simuler un enregistrement de 3 secondes
      await Future.delayed(const Duration(seconds: 3));

      await _stopRecording();
    } catch (e) {
      print('Erreur lors de l\'enregistrement: $e');
      setState(() {
        _isRecording = false;
        _recordingStatus = 'Erreur d\'enregistrement';
      });
    }
  }

  Color _getScoreColor() {
    if (_pronunciationScore >= 80) return Colors.green;
    if (_pronunciationScore >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon() {
    if (_pronunciationScore >= 80) return FontAwesomeIcons.checkCircle;
    if (_pronunciationScore >= 60) return FontAwesomeIcons.exclamationTriangle;
    return FontAwesomeIcons.timesCircle;
  }

  Future<void> _stopRecording() async {
    try {
      _pulseController.stop();

      await _audioService.stopListening();

      // Get the pronunciation score from the AudioService (which was set in the onResult callback)
      final score = _audioService.pronunciationScore;

      setState(() {
        _isRecording = false;
        _pronunciationScore = score;
        _recordingStatus = score >= 60
            ? 'Enregistrement terminé avec succès !'
            : 'Enregistrement terminé. Essayez encore.';
      });

      widget.onScoreUpdate?.call(score);
      // Pass the score as a string representation for the callback
      widget.onRecordingComplete?.call(score.toStringAsFixed(1));
    } catch (e) {
      print('Erreur lors de l\'arrêt de l\'enregistrement: $e');
      setState(() {
        _isRecording = false;
        _recordingStatus = 'Erreur lors de l\'arrêt';
      });
    }
  }
}
