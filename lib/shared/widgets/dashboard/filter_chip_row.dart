import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Horizontally scrollable pill filters for recommendation sheets.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _chipColors = [
    AppTheme.coralStart,
    AppTheme.accentBlue,
    AppTheme.accentPink,
    AppTheme.accentOrange,
    AppTheme.purpleStart,
    AppTheme.accentGreen,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          final color = _chipColors[index % _chipColors.length];
          return FilterChip(
            label: Text(
              labels[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.chipLabel(
                color: selected ? Colors.white : color,
              ),
            ),
            selected: selected,
            onSelected: (_) => onSelected(index),
            showCheckmark: false,
            backgroundColor: color.withValues(alpha: 0.12),
            selectedColor: color,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
