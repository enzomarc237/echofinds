import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:echofinds/utils/constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedPricingModels;
  final List<String> selectedPlatforms;
  final String selectedSortOption;
  final Function(List<String>, List<String>, String) onApplyFilters;
  
  const FilterBottomSheet({
    super.key,
    required this.selectedPricingModels,
    required this.selectedPlatforms,
    required this.selectedSortOption,
    required this.onApplyFilters,
  });
  
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedPricingModels;
  late List<String> _selectedPlatforms;
  late String _selectedSortOption;
  
  @override
  void initState() {
    super.initState();
    _selectedPricingModels = List.from(widget.selectedPricingModels);
    _selectedPlatforms = List.from(widget.selectedPlatforms);
    _selectedSortOption = widget.selectedSortOption;
  }
  
  void _clearFilters() {
    setState(() {
      _selectedPricingModels.clear();
      _selectedPlatforms.clear();
      _selectedSortOption = AppConstants.sortOptions.first;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filter Results',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Sort Options
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.sortOptions.map((option) =>
                  ChoiceChip(
                    label: Text(option),
                    selected: _selectedSortOption == option,
                    onSelected: (_) => setState(() => _selectedSortOption = option),
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    selectedColor: cs.primaryContainer,
                    labelStyle: TextStyle(
                      color: _selectedSortOption == option
                          ? cs.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Pricing Models
              Text(
                'Pricing Models',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.pricingModels.map((model) =>
                  FilterChip(
                    label: Text(model),
                    selected: _selectedPricingModels.contains(model),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPricingModels.add(model);
                        } else {
                          _selectedPricingModels.remove(model);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    selectedColor: cs.secondaryContainer,
                    showCheckmark: false,
                  ),
                ).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Platforms
              Text(
                'Platforms',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.platforms.map((platform) =>
                  FilterChip(
                    label: Text(platform),
                    selected: _selectedPlatforms.contains(platform),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPlatforms.add(platform);
                        } else {
                          _selectedPlatforms.remove(platform);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    selectedColor: cs.tertiaryContainer,
                    showCheckmark: false,
                  ),
                ).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      _selectedPricingModels,
                      _selectedPlatforms,
                      _selectedSortOption,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}