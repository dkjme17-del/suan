import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GroqChatService {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  static const _defaultApiKey = String.fromEnvironment('GROQ_API_KEY');

  // ✅ Modèle actuel valide
  static const _defaultModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  // ✅ Fallback sécurisé (même modèle pour éviter erreurs)
  static const _fallbackModel = 'llama-3.3-70b-versatile';

  static final Map<String, String> _replyCache = {};

  final String apiKey;
  final String model;
  final http.Client _httpClient = http.Client();

  GroqChatService({String? apiKey, String? model})
      : apiKey = apiKey ?? _defaultApiKey,
        model = model ?? _defaultModel;

  bool get hasApiKey => apiKey.trim().isNotEmpty;
  bool get canUseAi => hasApiKey;

  String get _systemPrompt =>
      'Tu es un tuteur EXPERT ET EXIGEANT de baoulé (langue de Côte d\'Ivoire), '
      'qui s\'adresse à un apprenant francophone. '
      'Contexte/scénario: enseigner un baoulé CORRECT et NATUREL. '
      'Réponds en français + baoulé avec exemples, corrections et petits exercices.';

  Future<String> generateReply({
    required String userInput,
    String? scenario,
  }) async {
    if (!canUseAi) {
      return 'Le mode Groq n\'est pas configuré. Ajoutez la clé GROQ_API_KEY.';
    }

    final contextText = scenario != null && scenario.isNotEmpty
        ? 'Scénario: $scenario. '
        : '';

    final cacheKey = _cacheKey(userInput, scenario);
    if (_replyCache.containsKey(cacheKey)) {
      return _replyCache[cacheKey]!;
    }

    final payload = {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content': '$_systemPrompt $contextText',
        },
        {
          'role': 'user',
          'content': userInput,
        }
      ],
      'temperature': 0.5,
      'max_tokens': 320,
      'top_p': 0.95,
    };

    Future<http.Response> sendRequest(String modelName) {
      debugPrint("🔵 Appel Groq avec modèle: $modelName");

      final localPayload = Map<String, dynamic>.from(payload);
      localPayload['model'] = modelName;

      return _httpClient.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(localPayload),
      );
    }

    try {
      var response = await sendRequest(model);

      // 🔁 Gestion fallback si modèle mort
      if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        final message =
            (body['error']?['message'] ?? '').toString().toLowerCase();

        if (message.contains('decommissioned') ||
            message.contains('not supported') ||
            message.contains('not found')) {
          debugPrint("⚠️ Modèle invalide → fallback activé");
          response = await sendRequest(_fallbackModel);
        }
      }

      // ✅ Succès
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;

        if (choices == null || choices.isEmpty) {
          return 'La réponse Groq est vide. Réessayez.';
        }

        final content =
            choices.first['message']?['content'] as String?;

        if (content == null || content.trim().isEmpty) {
          return 'La réponse Groq est vide. Réessayez.';
        }

        final result = content.trim();
        _replyCache[cacheKey] = result;
        return result;
      }

      // ❌ Gestion erreurs
      String apiMessage;
      try {
        final data = jsonDecode(response.body);
        apiMessage = data['error']?['message'] ?? '';
      } catch (_) {
        apiMessage = '';
      }

      if (response.statusCode == 401) {
        return "Erreur Groq (401). Clé API invalide.";
      }

      if (response.statusCode == 429) {
        return apiMessage.isEmpty
            ? "Erreur Groq (429). Trop de requêtes."
            : "Erreur Groq (429). $apiMessage";
      }

      return apiMessage.isEmpty
          ? 'Erreur Groq (${response.statusCode}).'
          : 'Erreur Groq (${response.statusCode}). $apiMessage';
    } catch (e) {
      debugPrint("❌ Exception Groq: $e");
      return "Erreur réseau. Vérifie ta connexion Internet.";
    }
  }

  String _cacheKey(String userInput, String? scenario) {
    return '${userInput.trim()}||${scenario?.trim() ?? ''}';
  }
}