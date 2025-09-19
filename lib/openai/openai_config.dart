import 'dart:convert';
import 'dart:io';
import 'package:echofinds/models/alternative.dart';

class GeminiService {
  static const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
  static const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');
  
  static Future<List<Alternative>> findAlternatives(
    String productName,
    String category, {
    String? researchContext,
  }) async {
    return []; // Dummy implementation for now
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