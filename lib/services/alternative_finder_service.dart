import 'package:echofinds/models/alternative.dart';
import 'package:echofinds/models/web_source.dart';
import 'package:echofinds/openai/openai_config.dart';
import 'package:echofinds/services/research_service.dart';
import 'package:echofinds/services/storage_service.dart';

/// Orchestrates web research + AI generation to produce up-to-date alternatives.
class AlternativeFinderService {
  /// Finds alternatives using LLM, optionally augmented with live web research
  /// based on user settings stored locally.
  static Future<List<Alternative>> findAlternatives(String query, String category) async {
    final settings = await StorageService.getUserSettings();

    List<WebSource> sources = [];
    if (settings.useWebResearch && settings.researchApiKey.trim().isNotEmpty) {
      sources = await ResearchService.search(
        query: query,
        category: category,
        provider: settings.researchProvider,
        apiKey: settings.researchApiKey,
        maxResults: settings.maxWebResults,
      );
    }

    // Build a concise research context string for the LLM
    final context = _buildResearchContext(sources);

    // Delegate to the existing OpenAI/GPT service with context
    return GeminiService.findAlternatives(query, category, researchContext: context);
  }

  static String? _buildResearchContext(List<WebSource> sources) {
    if (sources.isEmpty) return null;
    final buf = StringBuffer();
    buf.writeln('Recent web findings (use as ground truth and cite via URLs):');
    for (final s in sources.take(12)) {
      buf.writeln('- ${s.title} — ${s.url}\n  ${s.snippet}');
    }
    return buf.toString();
  }
}
