import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenAIChatService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _defaultProxyBaseUrl =
      String.fromEnvironment('OPENAI_PROXY_URL');

  final String apiKey;
  final String proxyBaseUrl;

  OpenAIChatService({String? apiKey})
      : apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
        proxyBaseUrl = _defaultProxyBaseUrl;

  bool get hasApiKey => apiKey.isNotEmpty;
  bool get hasProxy => proxyBaseUrl.trim().isNotEmpty;
  bool get canUseAi => kIsWeb ? hasProxy : (hasApiKey || hasProxy);

  Future<String> generateReply({
    required String userInput,
    String? scenario,
  }) async {
    // On Web, évite l'appel direct à OpenAI (CORS + fuite de clé).
    if (kIsWeb) {
      if (!hasProxy) {
        return "Mode Web: configure OPENAI_PROXY_URL pour appeler ton proxy (ex: http://localhost:3000).";
      }
      return _generateReplyViaProxy(userInput: userInput, scenario: scenario);
    }

    // Sur mobile/desktop: direct si clé présente, sinon proxy si configuré.
    if (apiKey.isEmpty) {
      if (hasProxy) {
        return _generateReplyViaProxy(userInput: userInput, scenario: scenario);
      }
      return "Le mode IA n'est pas configuré. Ajoutez la clé OPENAI_API_KEY (dart-define) pour activer OpenAI.";
    }

    final uri = Uri.parse(_endpoint);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'Tu es un tuteur EXPERT ET EXIGEANT de baoulé (langue de Côte d\'Ivoire), qui s\'adresse à un apprenant francophone. '
                    'Contexte/scénario actuel: ${scenario ?? "général"}. '
                    'Ton objectif principal est d\'enseigner un baoulé CORRECT et NATUREL.\n\n'
                    'FORMAT DE RÉPONSE (toujours respecter) :\n'
                    '1) Explication en français (1–2 phrases maximum, claire et précise).\n'
                    '2) Exemples : une liste de 1 à 3 phrases en baoulé avec TRADUCTION française ligne par ligne. '
                    'Forme exacte attendue :\n'
                    '- Baoulé: "…"\n'
                    '  Français: "…"\n'
                    '- Baoulé: "…"\n'
                    '  Français: "…"\n'
                    '3) Exercice : une petite consigne en français pour que l\'apprenant produise une phrase ou choisisse entre 2–3 options.\n\n'
                    'RÈGLES PÉDAGOGIQUES IMPORTANTES :\n'
                    '- Niveau par défaut : débutant. Utilise des phrases courtes, vocabulaire très fréquent (salutations, famille, nombres, marché, météo…).\n'
                    '- Si l\'apprenant écrit une phrase en baoulé :\n'
                    '  * analyse-la,\n'
                    '  * indique SANS AMBIGUÏTÉ si c\'est correct ou non,\n'
                    '  * si c\'est faux, donne la version corrigée EXACTE en baoulé + la traduction française.\n'
                    '- Ne change pas la phrase si elle est correcte, contente-toi de la valider et éventuellement proposer une variante plus naturelle.\n'
                    '- Ne réponds jamais uniquement en français : il doit toujours y avoir AU MOINS 1 phrase en baoulé dans la réponse.\n'
                    '- Si la demande dépasse ton rôle (par ex. sujet sans lien avec le baoulé), recentre gentiment vers l\'apprentissage du baoulé.',
          },
          {
            'role': 'user',
            'content': userInput,
          },
        ],
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return 'La réponse OpenAI est vide. Réessayez.';
      }
      final message = choices.first['message'] as Map<String, dynamic>;
      final content = message['content'] as String? ?? '';
      return content.trim().isEmpty
          ? 'La réponse OpenAI est vide. Réessayez.'
          : content.trim();
    } else {
      String? apiMessage;
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final err = data['error'] as Map<String, dynamic>?;
        apiMessage = err?['message'] as String?;
      } catch (_) {
        apiMessage = null;
      }

      if (response.statusCode == 401) {
        return "Erreur OpenAI (401). Clé API invalide ou non autorisée.";
      }
      if (response.statusCode == 429) {
        return apiMessage == null || apiMessage.trim().isEmpty
            ? "Erreur OpenAI (429). Trop de requêtes ou quota dépassé (vérifie ton plan/facturation)."
            : "Erreur OpenAI (429). $apiMessage";
      }

      return apiMessage == null || apiMessage.trim().isEmpty
          ? 'Erreur OpenAI (${response.statusCode}).'
          : 'Erreur OpenAI (${response.statusCode}). $apiMessage';
    }
  }

  Future<String> _generateReplyViaProxy({
    required String userInput,
    required String? scenario,
  }) async {
    final base = proxyBaseUrl.trim().replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$base/api/chat');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': userInput,
        'scenario': scenario,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final reply = data['reply'] as String? ?? '';
      return reply.trim().isEmpty ? 'Réponse vide du proxy.' : reply.trim();
    }

    final err = data['error'] as String?;
    return err == null || err.trim().isEmpty
        ? 'Erreur Proxy (${response.statusCode}).'
        : 'Erreur Proxy (${response.statusCode}). ${err.trim()}';
  }
}

