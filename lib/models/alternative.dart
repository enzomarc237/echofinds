class Alternative {
  final String name;
  final String description;
  final String websiteUrl;
  final List<String> tags;
  final String category;
  final String pricingModel;
  final List<String> platforms;
  final double? rating;
  final bool isPopular;
  
  Alternative({
    required this.name,
    required this.description,
    required this.websiteUrl,
    required this.tags,
    required this.category,
    required this.pricingModel,
    required this.platforms,
    this.rating,
    this.isPopular = false,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'websiteUrl': websiteUrl,
    'tags': tags,
    'category': category,
    'pricingModel': pricingModel,
    'platforms': platforms,
    'rating': rating,
    'isPopular': isPopular,
  };
  
  factory Alternative.fromJson(Map<String, dynamic> json) => Alternative(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    websiteUrl: json['websiteUrl'] ?? '',
    tags: List<String>.from(json['tags'] ?? []),
    category: json['category'] ?? '',
    pricingModel: json['pricingModel'] ?? '',
    platforms: List<String>.from(json['platforms'] ?? []),
    rating: json['rating']?.toDouble(),
    isPopular: json['isPopular'] ?? false,
  );
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alternative &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          websiteUrl == other.websiteUrl;
  
  @override
  int get hashCode => name.hashCode ^ websiteUrl.hashCode;
}