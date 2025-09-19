class UserSettings {
  final bool isDarkMode;
  final String defaultCategory;
  final bool saveSearchHistory;
  final int maxHistoryItems;
  final List<String> preferredPricingModels;
  final List<String> preferredPlatforms;

  // Web research settings
  final bool useWebResearch; // when true, augment AI with live web results
  final String researchProvider; // 'tavily' | 'serpapi'
  final String researchApiKey; // stored locally in SharedPreferences
  final int maxWebResults;

  UserSettings({
    this.isDarkMode = false,
    this.defaultCategory = 'All',
    this.saveSearchHistory = true,
    this.maxHistoryItems = 50,
    this.preferredPricingModels = const [],
    this.preferredPlatforms = const [],
    this.useWebResearch = false,
    this.researchProvider = 'tavily',
    this.researchApiKey = '',
    this.maxWebResults = 6,
  });
  
  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'defaultCategory': defaultCategory,
    'saveSearchHistory': saveSearchHistory,
    'maxHistoryItems': maxHistoryItems,
    'preferredPricingModels': preferredPricingModels,
    'preferredPlatforms': preferredPlatforms,
    'useWebResearch': useWebResearch,
    'researchProvider': researchProvider,
    'researchApiKey': researchApiKey,
    'maxWebResults': maxWebResults,
  };
  
  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    isDarkMode: json['isDarkMode'] ?? false,
    defaultCategory: json['defaultCategory'] ?? 'All',
    saveSearchHistory: json['saveSearchHistory'] ?? true,
    maxHistoryItems: json['maxHistoryItems'] ?? 50,
    preferredPricingModels: List<String>.from(json['preferredPricingModels'] ?? []),
    preferredPlatforms: List<String>.from(json['preferredPlatforms'] ?? []),
    useWebResearch: json['useWebResearch'] ?? false,
    researchProvider: json['researchProvider'] ?? 'tavily',
    researchApiKey: json['researchApiKey'] ?? '',
    maxWebResults: json['maxWebResults'] ?? 6,
  );
  
  UserSettings copyWith({
    bool? isDarkMode,
    String? defaultCategory,
    bool? saveSearchHistory,
    int? maxHistoryItems,
    List<String>? preferredPricingModels,
    List<String>? preferredPlatforms,
    bool? useWebResearch,
    String? researchProvider,
    String? researchApiKey,
    int? maxWebResults,
  }) => UserSettings(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    defaultCategory: defaultCategory ?? this.defaultCategory,
    saveSearchHistory: saveSearchHistory ?? this.saveSearchHistory,
    maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
    preferredPricingModels: preferredPricingModels ?? this.preferredPricingModels,
    preferredPlatforms: preferredPlatforms ?? this.preferredPlatforms,
    useWebResearch: useWebResearch ?? this.useWebResearch,
    researchProvider: researchProvider ?? this.researchProvider,
    researchApiKey: researchApiKey ?? this.researchApiKey,
    maxWebResults: maxWebResults ?? this.maxWebResults,
  );
}