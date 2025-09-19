import 'package:flutter/material.dart';
import 'package:echofinds/models/user_settings.dart';
import 'package:echofinds/services/storage_service.dart';
import 'package:echofinds/services/export_service.dart';
import 'package:echofinds/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettings _settings = UserSettings();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final settings = await StorageService.getUserSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveSettings(UserSettings newSettings) async {
    setState(() => _settings = newSettings);
    await StorageService.saveUserSettings(newSettings);
  }
  
  Future<void> _exportData() async {
    try {
      await ExportService.shareData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _importData() async {
    // Note: In a real app, you'd use a file picker here
    // For now, we'll show a dialog explaining the process
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'To import data:\n\n'
          '1. Share your exported JSON file to this app\n'
          '2. Or paste the JSON content into a text file\n'
          '3. Use the file picker to select the JSON file\n\n'
          'This feature requires additional file handling permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _clearAllData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your favorites, search history, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (shouldClear == true) {
      await StorageService.clearAllData();
      await _loadSettings(); // Reload default settings
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Search Settings
          _buildSection('Search Settings', [
            SwitchListTile(
              title: const Text('Save search history'),
              subtitle: const Text('Keep track of your recent searches'),
              value: _settings.saveSearchHistory,
              onChanged: (value) => _saveSettings(
                _settings.copyWith(saveSearchHistory: value),
              ),
            ),
            ListTile(
              title: const Text('Maximum history items'),
              subtitle: Text('${_settings.maxHistoryItems} searches'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHistoryLimitDialog(),
            ),
            ListTile(
              title: const Text('Default category'),
              subtitle: Text(_settings.defaultCategory),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDefaultCategoryDialog(),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Filter Preferences
          _buildSection('Filter Preferences', [
            ListTile(
              title: const Text('Preferred pricing models'),
              subtitle: Text(
                _settings.preferredPricingModels.isEmpty
                    ? 'None selected'
                    : _settings.preferredPricingModels.join(', '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPricingModelsDialog(),
            ),
            ListTile(
              title: const Text('Preferred platforms'),
              subtitle: Text(
                _settings.preferredPlatforms.isEmpty
                    ? 'None selected'
                    : _settings.preferredPlatforms.join(', '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlatformsDialog(),
            ),
          ]),
          
          const SizedBox(height: 16),

          // Web Research (Beta)
          _buildSection('Web Research (Beta)', [
            SwitchListTile(
              title: const Text('Use web research for up-to-date results'),
              subtitle: const Text('Augment AI with live search (requires API key)'),
              value: _settings.useWebResearch,
              onChanged: (v) => _saveSettings(_settings.copyWith(useWebResearch: v)),
            ),
            if (_settings.useWebResearch) ...[
              ListTile(
                title: const Text('Provider'),
                subtitle: Text(_settings.researchProvider == 'serpapi' ? 'SerpAPI' : 'Tavily'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showProviderPicker(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API Key'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _settings.researchApiKey),
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your provider API key',
                      ),
                      onChanged: (v) => _saveSettings(_settings.copyWith(researchApiKey: v)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Max web results'),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _settings.maxWebResults,
                          items: const [3, 6, 8, 10, 12]
                              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              _saveSettings(_settings.copyWith(maxWebResults: v));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your API key is stored only on this device and used directly from the app.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ]),
          
          const SizedBox(height: 16),
          
          // Data Management
          _buildSection('Data Management', [
            ListTile(
              title: const Text('Export data'),
              subtitle: const Text('Share your favorites and settings'),
              leading: const Icon(Icons.upload),
              onTap: _exportData,
            ),
            ListTile(
              title: const Text('Import data'),
              subtitle: const Text('Restore from backup'),
              leading: const Icon(Icons.download),
              onTap: _importData,
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Clear search history'),
              subtitle: const Text('Remove all search history'),
              leading: Icon(Icons.history, color: Colors.orange.shade700),
              onTap: () async {
                await StorageService.clearSearchHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared')),
                );
              },
            ),
            ListTile(
              title: const Text('Clear all data'),
              subtitle: const Text('Delete everything (cannot be undone)'),
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              onTap: _clearAllData,
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // About
          _buildSection('About', [
            ListTile(
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('About AltFinder'),
              subtitle: const Text('Discover alternatives powered by AI'),
              leading: const Icon(Icons.help_outline),
              onTap: () => _showAboutDialog(),
            ),
          ]),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _showHistoryLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10, 25, 50, 100].map((limit) =>
            RadioListTile<int>(
              title: Text('$limit searches'),
              value: limit,
              groupValue: _settings.maxHistoryItems,
              onChanged: (value) {
                if (value != null) {
                  _saveSettings(_settings.copyWith(maxHistoryItems: value));
                  Navigator.pop(context);
                }
              },
            ),
          ).toList(),
        ),
      ),
    );
  }
  
  void _showProviderPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tavily (recommended)'),
              value: 'tavily',
              groupValue: _settings.researchProvider,
              onChanged: (v) {
                if (v != null) {
                  _saveSettings(_settings.copyWith(researchProvider: v));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('SerpAPI'),
              value: 'serpapi',
              groupValue: _settings.researchProvider,
              onChanged: (v) {
                if (v != null) {
                  _saveSettings(_settings.copyWith(researchProvider: v));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDefaultCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.categories.map((category) =>
            RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _settings.defaultCategory,
              onChanged: (value) {
                if (value != null) {
                  _saveSettings(_settings.copyWith(defaultCategory: value));
                  Navigator.pop(context);
                }
              },
            ),
          ).toList(),
        ),
      ),
    );
  }
  
  void _showPricingModelsDialog() {
    List<String> selectedModels = List.from(_settings.preferredPricingModels);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preferred Pricing Models'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppConstants.pricingModels.map((model) =>
                CheckboxListTile(
                  title: Text(model),
                  value: selectedModels.contains(model),
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        selectedModels.add(model);
                      } else {
                        selectedModels.remove(model);
                      }
                    });
                  },
                ),
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveSettings(_settings.copyWith(preferredPricingModels: selectedModels));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPlatformsDialog() {
    List<String> selectedPlatforms = List.from(_settings.preferredPlatforms);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preferred Platforms'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppConstants.platforms.map((platform) =>
                CheckboxListTile(
                  title: Text(platform),
                  value: selectedPlatforms.contains(platform),
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        selectedPlatforms.add(platform);
                      } else {
                        selectedPlatforms.remove(platform);
                      }
                    });
                  },
                ),
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveSettings(_settings.copyWith(preferredPlatforms: selectedPlatforms));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'AltFinder',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.search,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'AltFinder helps you discover better alternatives to any software, app, or service using AI-powered recommendations.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• AI-powered alternative discovery\n'
          '• Smart filtering and sorting\n'
          '• Favorites management\n'
          '• Search history\n'
          '• Data export/import\n'
          '• Cross-platform recommendations',
        ),
      ],
    );
  }
}