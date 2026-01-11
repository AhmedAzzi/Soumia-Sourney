import 'package:flutter/material.dart';

class ViewToggleButton extends StatelessWidget {
  final bool isTableView;
  final VoidCallback onToggle;

  const ViewToggleButton({
    super.key,
    required this.isTableView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            icon: Icons.list_rounded,
            isSelected: !isTableView,
            onTap: isTableView ? onToggle : null,
          ),
          _buildOption(
            context,
            icon: Icons.grid_view_rounded,
            isSelected: isTableView,
            onTap: !isTableView ? onToggle : null,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withAlpha(150),
        ),
      ),
    );
  }
}
