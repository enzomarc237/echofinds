class WebSource {
  final String title;
  final String url;
  final String snippet;

  WebSource({
    required this.title,
    required this.url,
    required this.snippet,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'snippet': snippet,
  };

  factory WebSource.fromJson(Map<String, dynamic> json) => WebSource(
    title: json['title'] ?? '',
    url: json['url'] ?? '',
    snippet: json['snippet'] ?? '',
  );
}