class AppConstants {
  // App Categories
  static const List<String> categories = [
    'All',
    'Software',
    'Websites',
    'Services', 
    'Mobile Apps',
    'Tools',
    'Productivity',
    'Design',
    'Development',
    'Communication',
    'Entertainment',
    'Business',
  ];
  
  // Pricing Models
  static const List<String> pricingModels = [
    'Free',
    'Freemium',
    'One-time Purchase',
    'Subscription',
    'Open Source',
    'Enterprise',
  ];
  
  // Platforms
  static const List<String> platforms = [
    'Web',
    'Windows',
    'macOS', 
    'Linux',
    'Android',
    'iOS',
    'Cross-platform',
  ];
  
  // Filter Options
  static const List<String> sortOptions = [
    'Relevance',
    'Popularity',
    'Name (A-Z)',
    'Name (Z-A)',
    'Rating',
  ];
  
  // Storage Keys
  static const String favoritesKey = 'favorites';
  static const String searchHistoryKey = 'search_history';
  static const String userSettingsKey = 'user_settings';
  
  // Export/Import
  static const String exportFileName = 'altfinder_data.json';
  static const int maxSearchHistory = 100;
}