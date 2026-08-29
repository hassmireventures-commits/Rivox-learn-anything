import 'package:flutter/material.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/guidance/tour_steps.dart';
import '../../core/theme/app_theme.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentBranchIndex,
    required this.onBranchSelected,
  });

  final int currentBranchIndex;
  final ValueChanged<int> onBranchSelected;

  static const int homeBranch = 0;
  static const int learnBranch = 1;
  static const int historyBranch = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinations = <({GlobalKey key, IconData icon, IconData selectedIcon, String label})>[
      (
        key: tourHomeTabKey,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
      ),
      (
        key: tourLearnTabKey,
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
        label: l10n.navLearn,
      ),
      (
        key: tourHistoryTabKey,
        icon: Icons.history_outlined,
        selectedIcon: Icons.history,
        label: l10n.navHistory,
      ),
    ];

    final navHeight = Theme.of(context).navigationBarTheme.height ?? 72;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24) : AppTheme.cardSurface,
        boxShadow: AppTheme.bottomNavShadow,
      ),
      child: SizedBox(
        height: navHeight,
        child: NavigationBar(
          selectedIndex: currentBranchIndex.clamp(0, destinations.length - 1),
          onDestinationSelected: onBranchSelected,
          backgroundColor: isDark ? const Color(0xFF1A1A24) : AppTheme.cardSurface,
          indicatorColor: AppTheme.purpleStart.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon, key: d.key),
                selectedIcon: Icon(d.selectedIcon, color: AppTheme.purpleStart),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}
