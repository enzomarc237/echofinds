class SearchHistory {
  final String query;
  final String category;
  final DateTime timestamp;
  final int resultsCount;
  
  SearchHistory({
    required this.query,
    required this.category,
    required this.timestamp,
    required this.resultsCount,
  });
  
  Map<String, dynamic> toJson() => {
    'query': query,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    'resultsCount': resultsCount,
  };
  
  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
    query: json['query'] ?? '',
    category: json['category'] ?? '',
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    resultsCount: json['resultsCount'] ?? 0,
  );
}