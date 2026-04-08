import 'package:flutter/material.dart';
import '../../../core/models/difficulty.dart';
import '../../../core/theme/app_theme.dart';

class DifficultyFilter extends StatelessWidget {
  final Difficulty? selected;
  final ValueChanged<Difficulty?> onSelect;

  const DifficultyFilter({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            activeColor: AppTheme.ink,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...Difficulty.values.map(
            (d) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: d.label,
                isSelected: selected == d,
                activeColor: d.color,
                onTap: () => onSelect(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.inkFaint,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.tagLabel.copyWith(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.inkMuted,
          ),
        ),
      ),
    );
  }
}
