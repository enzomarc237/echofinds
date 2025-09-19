import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      tween: Tween(begin: 1.0, end: isSelected ? 1.05 : 1.0),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onTap(),
            backgroundColor: Colors.grey.withValues(alpha: 0.08),
            selectedColor: cs.primaryContainer,
            side: BorderSide(
              color: isSelected ? cs.primary.withValues(alpha: 0.5) : Colors.transparent,
            ),
            labelStyle: TextStyle(
              color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            elevation: isSelected ? 1.5 : 0,
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
