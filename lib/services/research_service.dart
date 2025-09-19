import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:echofinds/models/web_source.dart';

/// Lightweight web research client with pluggable providers.
/// Providers supported: 'tavily', 'serpapi'. Defaults to 'tavily'.
class ResearchService {
  static Future<List<WebSource>> search({
    required String query,
    required String category,
    required String provider,
    required String apiKey,
    int maxResults = 6,
  }) async {
    if (apiKey.trim().isEmpty) return [];

    switch (provider.toLowerCase()) {
      case 'serpapi':
        return _searchSerpApi(query: query, apiKey: apiKey, maxResults: maxResults);
      case 'tavily':
      default:
        return _searchTavily(query: query, apiKey: apiKey, maxResults: maxResults, category: category);
    }
  }

  static Future<List<WebSource>> _searchTavily({
    required String query,
    required String apiKey,
    required int maxResults,
    required String category,
  }) async {
    final uri = Uri.parse('https://api.tavily.com/search');
    final body = jsonEncode({
      'api_key': apiKey,
      'query': '$query alternatives in category: $category. Provide authoritative sources.',
      'max_results': maxResults,
      'include_answer': false,
      'include_images': false,
      'search_depth': 'advanced',
    });

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (resp.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final results = (data['results'] as List? ?? [])
        .map((e) => WebSource(
              title: (e['title'] ?? '').toString(),
              url: (e['url'] ?? '').toString(),
              snippet: (e['content'] ?? e['snippet'] ?? '').toString(),
            ))
        .where((w) => w.url.isNotEmpty && w.title.isNotEmpty)
        .toList();

    return results.take(maxResults).toList();
  }

  static Future<List<WebSource>> _searchSerpApi({
    required String query,
    required String apiKey,
    required int maxResults,
  }) async {
    final uri = Uri.https('serpapi.com', '/search.json', {
      'engine': 'google',
      'q': '$query alternatives',
      'api_key': apiKey,
      'num': '$maxResults',
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final organic = (data['organic_results'] as List? ?? []);

    final results = organic
        .map((e) => WebSource(
              title: (e['title'] ?? '').toString(),
              url: (e['link'] ?? '').toString(),
              snippet: (e['snippet'] ?? '').toString(),
            ))
        .where((w) => w.url.isNotEmpty && w.title.isNotEmpty)
        .toList();

    return results.take(maxResults).toList();
  }
}
