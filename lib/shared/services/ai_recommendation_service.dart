import 'dart:convert';

import 'package:suan/shared/services/openai_chat_service.dart';

class AiRecommendation {
  final String title;
  final String message;
  final String actionRoute;
  final Map<String, dynamic>? actionArgs;

  const AiRecommendation({
    required this.title,
    required this.message,
    required this.actionRoute,
    this.actionArgs,
  });
}

class AiRecommendationService {
  final OpenAIChatService _openAI;

  AiRecommendationService({OpenAIChatService? openAI})
      : _openAI = openAI ?? OpenAIChatService();

  Future<AiRecommendation> getDailyRecommendation({
    required double progress,
    required String level,
    required int streakDays,
    required int favoritesCount,
    required int lessonsCount,
    required int completedCount,
  }) async {
    // Try OpenAI first when available.
    if (_openAI.canUseAi) {
      final prompt =
          'Génère UNE recommandation courte et actionnable pour apprendre le baoulé.\n'
          'Contraintes:\n'
          '- Réponds en JSON strict avec les clés: title, message, actionRoute, actionArgs\n'
          "- actionRoute doit être '/chatbot'\n"
          "- actionArgs doit contenir {\"scenario\": \"salutations\"|\"marché\"|\"famille\"}\n"
          '- message en français, 1-2 phrases.\n\n'
          'Données utilisateur:\n'
          '- progress: $progress\n'
          '- level: $level\n'
          '- streakDays: $streakDays\n'
          '- favoritesCount: $favoritesCount\n'
          '- lessonsCount: $lessonsCount\n'
          '- completedCount: $completedCount\n';

      final raw = await _openAI.generateReply(userInput: prompt, scenario: 'recommendations');

      if (!raw.startsWith('Erreur')) {
        final jsonStart = raw.indexOf('{');
        final jsonEnd = raw.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          final decoded = jsonDecode(raw.substring(jsonStart, jsonEnd + 1))
              as Map<String, dynamic>;
          final title = (decoded['title'] as String?)?.trim();
          final message = (decoded['message'] as String?)?.trim();
          final actionRoute = (decoded['actionRoute'] as String?)?.trim();
          final actionArgs = decoded['actionArgs'] as Map<String, dynamic>?;

          if (title != null &&
              title.isNotEmpty &&
              message != null &&
              message.isNotEmpty &&
              actionRoute == '/chatbot') {
            return AiRecommendation(
              title: title,
              message: message,
              actionRoute: actionRoute!,
              actionArgs: actionArgs,
            );
          }
        }
      }
    }

    // Fallback "IA" locale (heuristique): toujours utile et cohérente.
    final scenario = (progress < 0.34)
        ? 'salutations'
        : (level == 'beginner')
            ? 'marché'
            : 'famille';

    final title = 'Suggestion du jour';
    final message = (scenario == 'salutations')
        ? "Révise les salutations: écris 3 façons de dire bonjour et réponds au bot."
        : (scenario == 'marché')
            ? "Entraîne-toi au marché: demande le prix et remercie en baoulé."
            : "Parle de ta famille: présente ta mère, ton père et ton enfant en baoulé.";

    return AiRecommendation(
      title: title,
      message: message,
      actionRoute: '/chatbot',
      actionArgs: {'scenario': scenario},
    );
  }
}

