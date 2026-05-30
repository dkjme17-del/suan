import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../shared/services/groq_chat_service.dart';
import '../../../../shared/services/masakhane_chat_service.dart';

class ChatbotService with ChangeNotifier {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  final ValueNotifier<List<ChatMessage>> messagesNotifier =
      ValueNotifier<List<ChatMessage>>([]);

  List<ChatMessage> _conversationHistory = [];

  FlutterTts? _flutterTts;
  SpeechToText? _speechToText;

  bool _isListening = false;
  bool _isSpeaking = false;

  // =============================
  // 🔊 TTS SETTINGS (persistées)
  // =============================
  static const String _prefsKeyTtsAutoSpeak = 'tts_auto_speak';
  static const String _prefsKeyTtsRate = 'tts_rate';
  static const String _prefsKeyTtsPitch = 'tts_pitch';
  static const String _prefsKeyTtsVolume = 'tts_volume';
  static const String _prefsKeyTtsVoiceName = 'tts_voice_name';
  static const String _prefsKeyTtsVoiceLocale = 'tts_voice_locale';
  static const String _prefsKeyTtsBaouleStrategy = 'tts_baoule_strategy';

  bool _ttsAutoSpeak = false;
  double _ttsRate = 0.5;
  double _ttsPitch = 1.0;
  double _ttsVolume = 1.0;
  String? _ttsVoiceName;
  String? _ttsVoiceLocale;
  BaouleTtsStrategy _baouleTtsStrategy = BaouleTtsStrategy.frenchOnly;
  List<TtsVoice> _availableVoices = const [];

  // Masakhane AI Service (backend URL or token loaded from app configuration)
  final MasakhaneChatService _masakhaneService = MasakhaneChatService();
  final GroqChatService _groqService = GroqChatService();

  bool get isAiEnabled => _masakhaneService.canUseAi || _groqService.canUseAi;

  String get aiStatus {
    if (_masakhaneService.canUseAi && _groqService.canUseAi) {
      return 'Masakhane + Groq configurés';
    }
    if (_masakhaneService.canUseAi) {
      return _masakhaneService.configurationInfo;
    }
    if (_groqService.canUseAi) {
      return 'Groq API configuré';
    }
    return 'IA non configurée - définis MASAKHANE_BACKEND_URL, HF_TOKEN ou GROQ_API_KEY';
  }

  static const int _maxHistoryMessages = 24;
  static const int _contextWindowMessages = 8;

  static const List<String> _practicePrompts = [
    'Traduis: Bonjour, comment vas-tu ?',
    'Corrige ma phrase: I ni sogô',
    'Donne-moi 5 mots du marché en Baoulé',
    'Fais-moi un mini quiz sur la famille',
  ];

  // =============================
  // INIT VOIX
  // =============================
  Future<void> initializeVoiceServices() async {
    try {
      _flutterTts = FlutterTts();
      _speechToText = SpeechToText();

      await _loadTtsSettings();
      await _loadAvailableVoices();

      await _flutterTts?.setLanguage('fr-FR');
      await _applyTtsSettings();

      _flutterTts?.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts?.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      await _speechToText?.initialize();
    } catch (e) {
      debugPrint("Erreur init voix: $e");
    }
  }

  Future<void> _loadTtsSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ttsAutoSpeak = prefs.getBool(_prefsKeyTtsAutoSpeak) ?? false;
      _ttsRate = prefs.getDouble(_prefsKeyTtsRate) ?? 0.5;
      _ttsPitch = prefs.getDouble(_prefsKeyTtsPitch) ?? 1.0;
      _ttsVolume = prefs.getDouble(_prefsKeyTtsVolume) ?? 1.0;
      _ttsVoiceName = prefs.getString(_prefsKeyTtsVoiceName);
      _ttsVoiceLocale = prefs.getString(_prefsKeyTtsVoiceLocale);

      final strategyRaw = prefs.getString(_prefsKeyTtsBaouleStrategy);
      _baouleTtsStrategy = BaouleTtsStrategy.values
          .cast<BaouleTtsStrategy?>()
          .firstWhere(
            (v) => v?.name == strategyRaw,
            orElse: () => BaouleTtsStrategy.frenchOnly,
          )!;
    } catch (e) {
      debugPrint('Erreur load TTS settings: $e');
    }
  }

  Future<void> _persistTtsSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyTtsAutoSpeak, _ttsAutoSpeak);
      await prefs.setDouble(_prefsKeyTtsRate, _ttsRate);
      await prefs.setDouble(_prefsKeyTtsPitch, _ttsPitch);
      await prefs.setDouble(_prefsKeyTtsVolume, _ttsVolume);
      if (_ttsVoiceName != null) {
        await prefs.setString(_prefsKeyTtsVoiceName, _ttsVoiceName!);
      } else {
        await prefs.remove(_prefsKeyTtsVoiceName);
      }
      if (_ttsVoiceLocale != null) {
        await prefs.setString(_prefsKeyTtsVoiceLocale, _ttsVoiceLocale!);
      } else {
        await prefs.remove(_prefsKeyTtsVoiceLocale);
      }
      await prefs.setString(
        _prefsKeyTtsBaouleStrategy,
        _baouleTtsStrategy.name,
      );
    } catch (e) {
      debugPrint('Erreur save TTS settings: $e');
    }
  }

  Future<void> _applyTtsSettings() async {
    try {
      await _flutterTts?.setSpeechRate(_ttsRate);
      await _flutterTts?.setPitch(_ttsPitch);
      await _flutterTts?.setVolume(_ttsVolume);

      // Applique la voix sauvegardée si elle existe sur l'appareil.
      if (_ttsVoiceName != null || _ttsVoiceLocale != null) {
        final voice = _availableVoices.cast<TtsVoice?>().firstWhere(
              (v) =>
                  v != null &&
                  (_ttsVoiceName == null || v.name == _ttsVoiceName) &&
                  (_ttsVoiceLocale == null || v.locale == _ttsVoiceLocale),
              orElse: () => null,
            );
        if (voice != null) {
          await _flutterTts?.setVoice(voice.toFlutterTtsVoice());
        }
      }
    } catch (e) {
      debugPrint('Erreur apply TTS settings: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadAvailableVoices() async {
    try {
      final raw = await _flutterTts?.getVoices;
      final list = (raw is List) ? raw : const [];

      final voices = <TtsVoice>[];
      for (final v in list) {
        if (v is Map) {
          final name = (v['name'] ?? v['Name'])?.toString();
          final locale =
              (v['locale'] ?? v['Locale'] ?? v['language'])?.toString();
          if (name != null && locale != null) {
            voices.add(TtsVoice(name: name, locale: locale));
          }
        }
      }

      voices.sort(
        (a, b) => '${a.locale}|${a.name}'.compareTo('${b.locale}|${b.name}'),
      );
      _availableVoices = List.unmodifiable(voices);
    } catch (e) {
      debugPrint('Erreur getVoices: $e');
      _availableVoices = const [];
    } finally {
      notifyListeners();
    }
  }

  // =============================
  // MICRO
  // =============================
  Future<void> toggleListening() async {
    try {
      if (_isListening) {
        await _speechToText?.stop();
        _isListening = false;
      } else {
        bool available = await _speechToText?.initialize() ?? false;

        if (!available) {
          debugPrint("Micro non disponible");
          return;
        }

        await _speechToText?.listen(
          onResult: (result) {
            if (result.finalResult) {
              final text = result.recognizedWords;
              _sendVoiceMessage(text);
            }
          },
        );

        _isListening = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur micro: $e");
    }
  }

  Future<void> _sendVoiceMessage(String text) async {
    if (text.trim().isNotEmpty) {
      await sendMessage(text);
    }
  }

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  // =============================
  // 🔊 TTS
  // =============================
  Future<void> speakMessage(String text) async {
    if (text.trim().isEmpty || _isSpeaking) return;

    try {
      await _flutterTts?.stop(); // stop ancien audio
      final toSpeak = _prepareTextForTts(text);
      if (toSpeak.trim().isEmpty) return;
      await _flutterTts?.speak(toSpeak);
    } catch (e) {
      debugPrint("Erreur TTS: $e");
    }
  }

  String _prepareTextForTts(String raw) {
    // Stratégie minimale: éviter que la voix FR tente de lire le BAOULÉ en MAJUSCULES
    // (et caractères spéciaux), car ça dégrade fortement l'expérience.
    switch (_baouleTtsStrategy) {
      case BaouleTtsStrategy.frenchOnly:
        return _stripBaouleLikeSegments(raw);
      case BaouleTtsStrategy.frenchThenSpell:
        final fr = _stripBaouleLikeSegments(raw).trim();
        final baoule = _extractBaouleLikeSegments(raw).trim();
        if (baoule.isEmpty) return fr;
        if (fr.isEmpty) return _spellForFrenchVoice(baoule);
        return '$fr. ${_spellForFrenchVoice(baoule)}';
      case BaouleTtsStrategy.tryAltVoiceIfAvailable:
        // Fallback simple: on lit seulement le français (évite les sons "cassés").
        // On laisse le choix d'une voix/locale alternative via les réglages.
        return _stripBaouleLikeSegments(raw);
    }
  }

  String _stripBaouleLikeSegments(String raw) {
    final lines = raw.split('\n');
    final kept = <String>[];
    for (final line in lines) {
      // Enlève les mots MAJUSCULES (forme BAOULÉ) + mots contenant caractères IPA.
      final cleaned = line
          .replaceAll(_baouleUpperTokenRegex, '')
          .replaceAll(_baouleSpecialCharsRegex, '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
      if (cleaned.isNotEmpty) kept.add(cleaned);
    }
    return kept.join('\n');
  }

  String _extractBaouleLikeSegments(String raw) {
    final matches = <String>[];
    for (final m in _baouleUpperTokenRegex.allMatches(raw)) {
      final token = raw.substring(m.start, m.end).trim();
      if (token.isNotEmpty) matches.add(token);
    }
    for (final m in _baouleSpecialCharsRegex.allMatches(raw)) {
      final token = raw.substring(m.start, m.end).trim();
      if (token.isNotEmpty) matches.add(token);
    }
    return matches.toSet().join(' ');
  }

  String _spellForFrenchVoice(String raw) {
    // Normalisation légère pour éviter les caractères que certaines voix lisent mal.
    return raw
        .replaceAll('ɔ', 'o')
        .replaceAll('ɛ', 'è')
        .replaceAll('ɩ', 'i')
        .replaceAll('ŋ', 'ng')
        .replaceAll('ɓ', 'b')
        .replaceAll('ɗ', 'd')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim()
        .split('')
        .join(' ');
  }

  static final RegExp _baouleUpperTokenRegex =
      RegExp(r"\b[A-ZÀ-ÖØ-Þ]{2,}(?:['’\-][A-ZÀ-ÖØ-Þ]{2,})*\b");
  static final RegExp _baouleSpecialCharsRegex = RegExp(r'[ɔɛɩŋɓɗ]');

  // =============================
  // ENVOI MESSAGE
  // =============================
  Future<void> sendMessage(String text) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty) return;

    final userMessage = ChatMessage(
      text: cleanedText,
      isBot: false,
      timestamp: DateTime.now(),
    );

    _conversationHistory.add(userMessage);
    _updateUI();

    if (_conversationHistory.length > _maxHistoryMessages) {
      _conversationHistory = _conversationHistory.sublist(
        _conversationHistory.length - _contextWindowMessages,
      );
    }

    final botResponse = await _generateBotResponse(cleanedText);

    _conversationHistory.add(botResponse);
    _updateUI();

    // 🔊 LECTURE AUTOMATIQUE DU BOT
    if (_ttsAutoSpeak) {
      await speakMessage(botResponse.text);
    }

    await _saveConversation();
  }

  void _updateUI() {
    messagesNotifier.value = List.from(_conversationHistory);
    notifyListeners();
  }

  // =============================
  // SAUVEGARDE
  // =============================
  Future<void> _saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = jsonEncode(
        _conversationHistory.map((msg) {
          return {
            'text': msg.text,
            'isBot': msg.isBot,
            'timestamp': msg.timestamp.toIso8601String(),
          };
        }).toList(),
      );

      await prefs.setString('chat_history', data);
    } catch (e) {
      debugPrint("Erreur save: $e");
    }
  }

  Future<void> loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('chat_history');

      if (data != null) {
        final List decoded = jsonDecode(data);

        _conversationHistory = decoded.map((e) {
          return ChatMessage(
            text: e['text'],
            isBot: e['isBot'],
            timestamp: DateTime.parse(e['timestamp']),
          );
        }).toList();

        _updateUI();
      }
    } catch (e) {
      debugPrint("Erreur load: $e");
    }
  }

  Future<void> clearHistory() async {
    _conversationHistory.clear();
    _updateUI();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
  }

  // =============================
  // IA GROQ
  // =============================
  Future<ChatMessage> _generateBotResponse(String userInput) async {
    // L'utilisateur a demandé de ne plus utiliser de données locales:
    // on s'appuie uniquement sur Masakhane (fallback Groq), sinon message de configuration.
    if (!_masakhaneService.canUseAi && !_groqService.canUseAi) {
      return ChatMessage(
        text:
            'Le chatbot IA n\'est pas configuré.\n\n'
            '- Configure `MASAKHANE_BACKEND_URL` (recommandé) ou `HF_TOKEN`.\n'
            '- (Optionnel) Configure `GROQ_API_KEY` en fallback.\n\n'
            'Ensuite je pourrai répondre en mode tuteur Baoulé.',
        isBot: true,
        timestamp: DateTime.now(),
      );
    }

    // Build conversation context (last 5 exchanges)
    final recentHistory = _conversationHistory.length > _contextWindowMessages
        ? _conversationHistory.sublist(
            _conversationHistory.length - _contextWindowMessages,
          )
        : _conversationHistory;
    final context = recentHistory
        .map((msg) => '${msg.isBot ? 'Akwaba:' : 'Toi:'} ${msg.text}')
        .join('\n');

    final intent = _detectIntent(userInput);
    final fullPrompt = _buildExpertPrompt(
      userInput: userInput,
      context: context,
      intent: intent,
    );

    // Priorité: Masakhane (réponses Baoulé), fallback Groq.
    if (_masakhaneService.canUseAi) {
      try {
        final response = await _masakhaneService.generateReply(
          userInput: fullPrompt,
        );
        final normalized = response.trim();
        if (! _isMasakhaneError(normalized) && normalized.isNotEmpty) {
          return ChatMessage(
            text: normalized,
            isBot: true,
            timestamp: DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('❌ Masakhane exception: $e');
      }
    }

    if (_groqService.canUseAi) {
      try {
        final groqResponse = await _groqService.generateReply(
          userInput: fullPrompt,
          scenario: intent,
        );
        final groqNormalized = groqResponse.trim();
        if (groqNormalized.isNotEmpty && !_isGroqError(groqNormalized)) {
          return ChatMessage(
            text: groqNormalized,
            isBot: true,
            timestamp: DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('❌ Groq exception: $e');
      }
    }

    return ChatMessage(
      text:
          'Je suis incertain pour le moment.\n\n'
          'Assure-toi que `MASAKHANE_BACKEND_URL` ou `HF_TOKEN` est bien configuré '
          'pour obtenir des réponses Baoulé fiables.',
      isBot: true,
      timestamp: DateTime.now(),
    );
  }

  String _detectIntent(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('corrige') ||
        lower.contains('correct') ||
        lower.contains('erreur')) {
      return 'correction';
    }
    if (lower.contains('traduis') ||
        lower.contains('traduire') ||
        lower.contains('comment dit')) {
      return 'traduction';
    }
    if (lower.contains('prononce') ||
        lower.contains('prononciation') ||
        lower.contains('audio')) {
      return 'prononciation';
    }
    if (lower.contains('quiz') ||
        lower.contains('exercice') ||
        lower.contains('teste')) {
      return 'quiz';
    }
    if (lower.contains('culture') ||
        lower.contains('proverbe') ||
        lower.contains('akan')) {
      return 'culture';
    }
    return 'tutorat';
  }

  String _buildExpertPrompt({
    required String userInput,
    required String context,
    required String intent,
  }) {
    return '''
MISSION: Tu es AKWABA, tuteur expert de BAOULÉ pour apprenants francophones.

DOMAINE STRICT:
- Enseigner le Baoulé de Côte d'Ivoire: conversation, vocabulaire, grammaire simple, prononciation, culture Akan/Baoulé.
- Si tu n'es pas sûr d'une forme baoulé, réponds précisément "je suis incertain".
- Ne jamais inventer de forme, surtout pour les mots ou expressions Baoulé.

STYLE DE RÉPONSE:
- Utilise du français clair et des formes BAOULÉ en MAJUSCULES.
- Réponse structurée et pédagogique.
- Toujours inclure au moins un exemple concret.
- Pour une traduction: donner Français → BAOULÉ littéral → BAOULÉ naturel.
- Pour une correction: verdict, correction exacte, explication courte, petit exercice.
- Pour la prononciation: découper en syllabes, noter les sons spéciaux ɔ, ɛ, ɩ, ŋ, ɓ, ɗ.
- Pour un quiz: 3 questions max, puis écrire "Réponses:" et les solutions.

INTENTION DÉTECTÉE: $intent
CONTEXTE RÉCENT:
$context

DEMANDE APPRENANT:
$userInput

Réponds maintenant comme un tuteur exigeant mais encourageant.
''';
  }

  bool _isMasakhaneError(String response) {
    final lower = response.toLowerCase();
    return response.startsWith('❌') ||
        response.startsWith('Erreur') ||
        response.startsWith('⚠️') ||
        lower.contains('hf_token') ||
        lower.contains('réponse invalide') ||
        lower.contains('backend masakhane') ||
        lower.contains('erreur hf');
  }

  bool _isGroqError(String response) {
    final lower = response.toLowerCase();
    return response.startsWith('❌') ||
        response.startsWith('Erreur') ||
        response.startsWith('⚠️') ||
        lower.startsWith('erreur groq') ||
        lower.startsWith('erreur réseau');
  }

  // =============================
  // GETTERS
  // =============================
  List<ChatMessage> get messages => messagesNotifier.value;
  ValueListenable<List<ChatMessage>> get messagesListenable => messagesNotifier;

  bool get ttsAutoSpeak => _ttsAutoSpeak;
  double get ttsRate => _ttsRate;
  double get ttsPitch => _ttsPitch;
  double get ttsVolume => _ttsVolume;
  BaouleTtsStrategy get baouleTtsStrategy => _baouleTtsStrategy;
  List<TtsVoice> get availableVoices => _availableVoices;
  TtsVoice? get selectedVoice =>
      (_ttsVoiceName == null || _ttsVoiceLocale == null)
          ? null
          : TtsVoice(name: _ttsVoiceName!, locale: _ttsVoiceLocale!);

  Future<void> setTtsAutoSpeak(bool value) async {
    _ttsAutoSpeak = value;
    await _persistTtsSettings();
    notifyListeners();
  }

  Future<void> setTtsRate(double value) async {
    _ttsRate = value.clamp(0.1, 1.0);
    await _applyTtsSettings();
    await _persistTtsSettings();
  }

  Future<void> setTtsPitch(double value) async {
    _ttsPitch = value.clamp(0.5, 2.0);
    await _applyTtsSettings();
    await _persistTtsSettings();
  }

  Future<void> setTtsVolume(double value) async {
    _ttsVolume = value.clamp(0.0, 1.0);
    await _applyTtsSettings();
    await _persistTtsSettings();
  }

  Future<void> setBaouleTtsStrategy(BaouleTtsStrategy value) async {
    _baouleTtsStrategy = value;
    await _persistTtsSettings();
    notifyListeners();
  }

  Future<void> setSelectedVoice(TtsVoice? voice) async {
    _ttsVoiceName = voice?.name;
    _ttsVoiceLocale = voice?.locale;
    await _applyTtsSettings();
    await _persistTtsSettings();
  }
}

// =============================
// MODEL MESSAGE
// =============================
class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

enum BaouleTtsStrategy {
  /// Lit uniquement la partie française et ignore les segments BAOULÉ (MAJUSCULES/IPA).
  frenchOnly,

  /// Lit le français, puis épèle les segments BAOULÉ.
  frenchThenSpell,

  /// Lit le français (fallback), mais permet à l'utilisateur de choisir une voix/locale.
  tryAltVoiceIfAvailable,
}

class TtsVoice {
  final String name;
  final String locale;

  const TtsVoice({
    required this.name,
    required this.locale,
  });

  Map<String, String> toFlutterTtsVoice() => {'name': name, 'locale': locale};
}
