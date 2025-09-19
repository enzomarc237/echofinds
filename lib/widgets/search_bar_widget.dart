import 'dart:ui';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final bool isLoading;
  final bool showClearButton;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Search for alternatives...',
    this.onSearch,
    this.onClear,
    this.isLoading = false,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
    final borderColor = Colors.grey.withValues(alpha: 0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSearch?.call(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  if (showClearButton && controller.text.isNotEmpty && !isLoading)
                    IconButton(
                      onPressed: () {
                        controller.clear();
                        onClear?.call();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade600,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (!isLoading)
                    IconButton(
                      onPressed: onSearch,
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 16),
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
    );
  }
}
