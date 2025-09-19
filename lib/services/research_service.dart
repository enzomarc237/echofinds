import 'dart:convert';
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
    return []; // Dummy implementation for now
  }

  static Future<List<WebSource>> _searchTavily({
    required String query,
    required String apiKey,
    required int maxResults,
    required String category,
  }) async {
    return []; // Dummy implementation for now
  }

  static Future<List<WebSource>> _searchSerpApi({
    required String query,
    required String apiKey,
    required int maxResults,
  }) async {
    return []; // Dummy implementation for now
  }
}
