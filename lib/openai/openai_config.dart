import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:echofinds/models/alternative.dart';

class GeminiService {
  static const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
  static const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');
  
  static Future<List<Alternative>> findAlternatives(
    String productName,
    String category, {
    String? researchContext,
  }) async {
    try {
      final prompt = _buildPrompt(productName, category, researchContext: researchContext);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert in software alternatives and recommendations. Always return your response as a valid JSON object with an "alternatives" array.'
            },
            {
              'role': 'user', 
              'content': prompt,
            }
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode != 200) {
        throw HttpException('API request failed: ${response.statusCode}');
      }
      
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      
      if (data['choices'] == null || data['choices'].isEmpty) {
        throw FormatException('Invalid API response format');
      }
      
      final content = data['choices'][0]['message']['content'];
      final alternativesData = jsonDecode(content);
      
      if (alternativesData['alternatives'] == null) {
        throw FormatException('No alternatives found in response');
      }
      
      final alternatives = <Alternative>[];
      for (final item in alternativesData['alternatives']) {
        try {
          alternatives.add(Alternative.fromJson(item));
        } catch (e) {
          // Skip malformed items but continue processing
          continue;
        }
      }
      
      return alternatives;
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get alternatives: $e');
    }
  }
  
  static String _buildPrompt(String productName, String category, {String? researchContext}) {
    final research = (researchContext == null || researchContext.trim().isEmpty)
        ? ''
        : '\nUse the following up-to-date web research as context. Prefer these sources for facts and links, and ensure URLs are current. If conflicts arise, trust the sources below.\\n$researchContext\n';

    return '''
Find alternatives to "$productName" in the $category category. Return exactly 8-12 alternatives in JSON format.
$research
Required JSON structure:
{
  "alternatives": [
    {
      "name": "Alternative Name",
      "description": "Brief description (50-100 words)",
      "websiteUrl": "https://website.com",
      "tags": ["tag1", "tag2", "tag3"],
      "category": "$category",
      "pricingModel": "Free|Freemium|One-time Purchase|Subscription|Open Source|Enterprise",
      "platforms": ["Web", "Windows", "macOS", "Linux", "Android", "iOS"],
      "rating": 4.5,
      "isPopular": true
    }
  ]
}

Focus on:
- Well-known, actively maintained alternatives (verified via the research context when available)
- Diverse pricing models (free, paid, open source)
- Different platforms and use cases
- Accurate and current website URLs
- Relevant tags and descriptions
- Realistic ratings (3.0-5.0)
- Mark 2-3 most popular as "isPopular": true

Ensure all URLs are valid and accessible.
''';
  }
}