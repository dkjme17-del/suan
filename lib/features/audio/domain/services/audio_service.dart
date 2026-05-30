import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/utils/logger.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeechEnabled = false;
  double _pronunciationScore = 0.0;

  // Initialisation
  Future<void> initialize() async {
    // Sur le Web, speech_to_text / just_audio sont limités ou nécessitent des
    // permissions utilisateur spécifiques. On reste en mode "lecture seule"
    // et on désactive proprement l'enregistrement.
    if (kIsWeb) {
      _isSpeechEnabled = false;
    } else {
      await _speechToText.initialize();
      _isSpeechEnabled = _speechToText.isAvailable;
    }

    // Configuration TTS
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Jouer un audio local
  Future<bool> playLocalAudio(String filePath) async {
    try {
      if (kIsWeb) {
        // Sur Web, les assets sont servis en HTTP par le dev server.
        // On construit donc une URL absolue à partir de la base.
        final uri = Uri.base.resolve(
          filePath.startsWith('assets/') ? filePath : 'assets/$filePath',
        );
        await _audioPlayer.setUrl(uri.toString());
      } else {
        await _audioPlayer.setFilePath(filePath);
      }
      await _audioPlayer.play();
      return true;
    } catch (e) {
      Logger.error('Erreur lecture audio', e);
      return false;
    }
  }

  // Jouer un audio depuis URL
  Future<void> playNetworkAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      Logger.error('Erreur lecture audio réseau', e);
    }
  }

  // Synthèse vocale (texte en baoulé)
  Future<void> speakBaoule(String text, {bool slowMode = false}) async {
    try {
      await _flutterTts.setLanguage("fr-FR"); // Utiliser français comme base
      await _flutterTts.setSpeechRate(slowMode ? 0.3 : 0.5);
      await _flutterTts.speak(text);
    } catch (e) {
      Logger.error('Erreur synthèse vocale', e);
    }
  }

  // Démarrer l'enregistrement de la prononciation
  Future<bool> startListening() async {
    if (!_isSpeechEnabled || kIsWeb) return false;

    try {
      return await _speechToText.listen(
        onResult: (result) {
          _pronunciationScore = _calculatePronunciationScore(
            result.recognizedWords,
          );
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        partialResults: false,
        localeId: "fr_FR",
      );
    } catch (e) {
      Logger.error('Erreur enregistrement', e);
      return false;
    }
  }

  // Arrêter l'enregistrement
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Obtenir le score de prononciation
  double get pronunciationScore => _pronunciationScore;

  // Calculer le score de prononciation (simulation)
  double _calculatePronunciationScore(String recognizedText) {
    // Simulation d'algorithme de comparaison
    // En réalité, utiliserait ML/TensorFlow pour comparer avec la prononciation native
    return (recognizedText.length * 10.0).clamp(0.0, 100.0);
  }

  // Vérifier si le micro est disponible
  bool get isSpeechAvailable => _isSpeechEnabled;

  // Arrêter l'audio
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  // Libérer les ressources
  void dispose() {
    _audioPlayer.dispose();
    _speechToText.stop();
    _flutterTts.stop();
  }
}
