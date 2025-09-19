# AltFinder - Software Alternatives App Architecture

## Core Features
1. **Search Interface**: Category selection + search bar for finding alternatives
2. **AI-Powered Results**: Gemini AI integration for intelligent alternative discovery
3. **Results Management**: Filtering, favoriting, and detailed views
4. **Local Storage**: Favorites, search history, and user settings
5. **Data Export/Import**: Cloud backup and JSON export functionality

## Technical Architecture

### Core Components
1. **Models** (`lib/models/`)
   - `alternative.dart` - Alternative product data model
   - `search_history.dart` - Search history model
   - `user_settings.dart` - User preferences model

2. **Services** (`lib/services/`)
   - `gemini_service.dart` - AI integration for alternatives discovery
   - `storage_service.dart` - Local storage management
   - `export_service.dart` - Data export/import functionality

3. **Screens** (`lib/screens/`)
   - `search_screen.dart` - Main search interface with category selection
   - `results_screen.dart` - Display alternatives with filtering options
   - `alternative_detail_screen.dart` - Detailed view of each alternative
   - `favorites_screen.dart` - User's saved alternatives
   - `settings_screen.dart` - App settings and data management

4. **Widgets** (`lib/widgets/`)
   - `category_chip.dart` - Category selection chips
   - `alternative_card.dart` - Alternative display card
   - `search_bar_widget.dart` - Custom search input
   - `filter_bottom_sheet.dart` - Results filtering options

5. **Utils** (`lib/utils/`)
   - `constants.dart` - App constants and categories
   - `helpers.dart` - Utility functions

### Key Features Implementation
- **Categories**: Software, Websites, Services, Mobile Apps, Tools, Productivity, Design, Development
- **Search Flow**: Category → Search Term → AI Query → Results Display
- **Filtering**: By category, popularity, pricing model, platform
- **Local Storage**: SharedPreferences for settings, JSON files for structured data
- **Export Options**: Share to cloud (Google Drive/iCloud), JSON file export

### Navigation Structure
```
HomePage (BottomNavigationBar)
├── SearchScreen (Tab 1)
│   └── ResultsScreen
│       └── AlternativeDetailScreen
├── FavoritesScreen (Tab 2)
│   └── AlternativeDetailScreen
└── SettingsScreen (Tab 3)
    ├── Export/Import Options
    └── App Preferences
```

### Data Flow
1. User selects category and enters search term
2. App constructs AI prompt with category context
3. Gemini AI returns structured alternatives list
4. Results displayed with filtering/sorting options
5. User can favorite items (stored locally)
6. Search history maintained for quick access