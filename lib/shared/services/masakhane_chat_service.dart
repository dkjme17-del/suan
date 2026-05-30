import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MasakhaneChatService {
  static final Map<String, String> _replyCache = {};

  final http.Client _httpClient = http.Client();
  static const String _endpoint =
      'https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta';
  static const String _defaultApiKey = String.fromEnvironment('HF_TOKEN');
  static const String _defaultBackendUrl = String.fromEnvironment(
    'MASAKHANE_BACKEND_URL',
  );

  final String apiKey;
  final String backendUrl;
  final String model;

  MasakhaneChatService({String? apiKey, String? backendUrl})
    : apiKey = apiKey ?? _resolveApiKey(),
      backendUrl = backendUrl ?? _resolveBackendUrl(),
      model = 'HuggingFaceH4/zephyr-7b-beta';

  static String _resolveApiKey() {
    if (_defaultApiKey.isNotEmpty) return _defaultApiKey;
    return dotenv.env['HF_TOKEN']?.trim() ?? '';
  }

  static String _resolveBackendUrl() {
    if (_defaultBackendUrl.isNotEmpty) return _defaultBackendUrl;
    return dotenv.env['MASAKHANE_BACKEND_URL']?.trim() ?? '';
  }

  bool get hasApiKey => apiKey.trim().isNotEmpty;
  bool get hasBackend => backendUrl.trim().isNotEmpty;
  bool get canUseAi => hasBackend || hasApiKey;

  String get configurationInfo {
    if (hasBackend) return 'Masakhane backend configuré';
    if (hasApiKey) return 'HF_TOKEN configuré';
    return 'IA non configurée - définis MASAKHANE_BACKEND_URL ou HF_TOKEN';
  }

  String get _systemPrompt => '''
Tu es AKWABA, tuteur EXPERT de BAOULÉ (Côte d'Ivoire) pour apprenants francophones.

RÈGLES STRICTES:
- **BAOULÉ en MAJUSCULES** avec diacritiques: ɔ, ɛ, ɩ, ŋ, ɓ, ɗ
- Ne jamais inventer de forme baoulé. Si tu n'es pas sûr, réponds "je suis incertain".
- Décomposer chaque mot important: français → BAOULÉ littéral → BAOULÉ naturel.
- Toujours inclure au moins un exemple concret.
- Si tu corriges, donner: verdict + correction + brève explication + petit exercice.
- Si tu traduis, donner: français, BAOULÉ littéral, BAOULÉ naturel.
- Si tu fais un quiz, limiter à 3 questions et exposer les réponses après "Réponses:".
- Préférer des réponses courtes et pédagogiques, mais complètes.

EXEMPLES:
1) Traduction:
Français: Bonjour, comment ça va ?
BAOULÉ littéral: I NI SƆGƆ, N KA FƐ? 
BAOULÉ naturel: I NI SƆGƆ, N KA FƐ?

2) Correction:
Phrase erronée: *I ni sogô.*
Correction: *I NI SƆGƆ.*
Explication: «SOGÔ» doit être en majuscules avec le ton approprié.

3) Mini quiz:
Question: Comment dit-on «merci» en Baoulé ?
Réponse: **MƐDA ASE**.

CONTEXTE APPRENTISSAGE:
- Apprenant francophone débutant
- Focus: conversation quotidienne, salutations, famille, marché, proverbes
- Culture Akan/Baoulé intégrée

Langue: français + BAOULÉ mis en évidence.
''';

  Future<String> generateReply({
    required String userInput,
    String? context,
  }) async {
    if (!canUseAi) {
      return 'Configure MASAKHANE_BACKEND_URL ou HF_TOKEN pour activer le tuteur IA.';
    }

    final cacheKey = _cacheKey(userInput, context);
    if (_replyCache.containsKey(cacheKey)) {
      return _replyCache[cacheKey]!;
    }

    if (hasBackend) {
      final backendReply = await _generateReplyViaBackend(userInput: userInput, context: context);
      _replyCache[cacheKey] = backendReply;
      return backendReply;
    }

    final fullPrompt = context != null
        ? '$_systemPrompt\nContexte: $context\n'
        : _systemPrompt;

    final payload = {
      'inputs': fullPrompt + userInput,
      'parameters': {
        'temperature': 0.25,
        'top_p': 0.9,
        'repetition_penalty': 1.08,
        'max_new_tokens': 320,
        'return_full_text': false,
      }
    };

    try {
      final response = await _httpClient.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generated = data[0]?['generated_text']?.toString() ?? '';

        return generated.trim().isNotEmpty
            ? generated.trim()
            : '🤖 Réponse Masakhane reçue.';
      }

      return _handleError(response.statusCode, response.body);
    } catch (e) {
      debugPrint('❌ Masakhane error: $e');
      return 'Erreur réseau. Vérifiez connexion/HF_TOKEN.';
    }
  }

  Future<String> _generateReplyViaBackend({
    required String userInput,
    String? context,
  }) async {
    try {
      final cacheKey = _cacheKey(userInput, context);
      final base = backendUrl.trim().replaceAll(RegExp(r'/$'), '');
      final uri = Uri.parse('$base/chat');
      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': userInput},
          ],
          if (context != null && context.trim().isNotEmpty) 'context': context,
        }),
      ).timeout(const Duration(seconds: 60));

      final Object? data = _tryDecodeJson(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final generated = (data is Map<String, dynamic>)
            ? (data['response']?.toString() ?? '')
            : '';
        final result = generated.trim().isNotEmpty
            ? generated.trim()
            : 'Réponse Masakhane reçue.';
        _replyCache[cacheKey] = result;
        return result;
      }

      if (data is Map<String, dynamic>) {
        return data['error']?.toString() ??
            'Erreur backend Masakhane (${response.statusCode}).';
      }
      return 'Erreur backend Masakhane (${response.statusCode}).';
    } catch (e) {
      debugPrint('❌ Backend Masakhane error: $e');
      return _formatBackendFetchFailure(
        error: e,
        backendUrl: backendUrl,
      );
    }
  }

  static Object? _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static String _formatBackendFetchFailure({
    required Object error,
    required String backendUrl,
  }) {
    final base = backendUrl.trim().replaceAll(RegExp(r'/$'), '');
    final uri = Uri.tryParse('$base/chat');
    final host = uri?.host.toLowerCase() ?? '';
    final isLocalhost = host == 'localhost' || host == '127.0.0.1';
    final errorText = error.toString();
    final looksLikeCorsOrBrowserBlock = kIsWeb &&
        (errorText.contains('Failed to fetch') ||
            errorText.contains('NetworkError') ||
            errorText.contains('XMLHttpRequest') ||
            errorText.contains('CORS'));
    final looksLikeMixedContent = kIsWeb &&
        (errorText.contains('Mixed Content') ||
            (uri?.scheme == 'http' &&
                (Uri.base.scheme == 'https' || Uri.base.scheme == 'chrome-extension')));

    String envHint;
    if (kIsWeb) {
      envHint =
          "Flutter Web: `localhost` est OK si le backend tourne sur la même machine que Chrome, mais le navigateur peut bloquer la requête (CORS / Mixed Content).";
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          envHint = isLocalhost
              ? "Android emulator: remplace `localhost` par `10.0.2.2` (ex: `http://10.0.2.2:3000`)."
              : "Android: vérifie que l'hôte/port est joignable depuis l'app.";
          break;
        case TargetPlatform.iOS:
          envHint = isLocalhost
              ? "iOS simulator: `localhost` vise la machine hôte; sur device physique utilise une IP LAN."
              : "iOS: vérifie que l'hôte/port est joignable depuis l'app.";
          break;
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
          envHint =
              "Desktop: `localhost` vise bien cette machine; vérifie que le backend écoute sur le bon port.";
          break;
        case TargetPlatform.fuchsia:
          envHint = "Vérifie que l'hôte/port est joignable depuis l'app.";
          break;
      }
    }

    final target = uri != null ? uri.toString() : '$base/chat';
    return [
      '❌ Impossible de joindre le backend Masakhane.',
      'URL: $target',
      '',
      'Causes probables:',
      '- Backend non démarré / mauvais port',
      '- `localhost` inaccessible depuis l’appareil (emulator/device)',
      if (looksLikeCorsOrBrowserBlock) '- Blocage navigateur (CORS / preflight OPTIONS / headers non autorisés)',
      if (looksLikeMixedContent) '- Mixed Content: page en https → backend en http bloqué par le navigateur',
      '- Pare-feu / backend lié à 127.0.0.1 seulement',
      '',
      'À essayer:',
      '- Lance le backend et teste `GET /health` ou `POST /chat` depuis cette machine',
      '- Si device physique: utilise une IP LAN (ex: `http://192.168.x.x:3000`) et assure-toi que le backend écoute sur `0.0.0.0`',
      if (looksLikeCorsOrBrowserBlock)
        '- CORS: autorise l’origine de ton app web (ex: `http://localhost:xxxx`) + `Content-Type` et répond à `OPTIONS /chat`',
      if (looksLikeMixedContent)
        '- Mixed Content: sers le backend en https, ou lance l’app web en http (dev), ou utilise un reverse-proxy https→http',
      '- $envHint',
      '',
      'Détail: $error',
    ].join('\n');
  }

  String _handleError(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return '❌ HF_TOKEN invalide. huggingface.co/settings/tokens';
      case 429:
        return '⏳ HF gratuit saturé. Réessayez dans 1min.';
      case 503:
        return '⚠️ Modèle Masakhane en chargement (1-2min).';
      default:
        return 'Erreur HF ($statusCode).';
    }
  }

  String _cacheKey(String userInput, String? context) {
    return '${userInput.trim()}||${context?.trim() ?? ''}';
  }

  // Chat history compatible method
  Future<String> chat({required List<Map<String, String>> messages}) async {
    final context = messages
        .map((m) => '${m['role']}: ${m['content']}')
        .join('\n');
    return generateReply(userInput: context);
  }
}
