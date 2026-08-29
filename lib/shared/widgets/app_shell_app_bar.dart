import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_localizations_ext.dart';

class AppShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppShellAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        ...?actions,
        IconButton(
          tooltip: context.l10n.settingsTooltip,
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
