import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/context_l10n.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAbout;
  final VoidCallback onSkills;
  final VoidCallback onProjects;
  final VoidCallback onContact;

  const CustomAppBar({
    super.key,
    required this.onAbout,
    required this.onSkills,
    required this.onProjects,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      title: Text(context.l10n.appTitle),
      elevation: 4,
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        _navButton(context, title: context.l10n.navAbout,    tooltip: context.l10n.navAboutTooltip,    onPressed: onAbout),
        _navButton(context, title: context.l10n.navSkills,   tooltip: context.l10n.navSkillsTooltip,   onPressed: onSkills),
        _navButton(context, title: context.l10n.navProjects, tooltip: context.l10n.navProjectsTooltip, onPressed: onProjects),
        _navButton(context, title: context.l10n.navContact,  tooltip: context.l10n.navContactTooltip,  onPressed: onContact),
        Tooltip(
          message: themeProvider.isDarkMode ? context.l10n.toggleToLight : context.l10n.toggleToDark,
          child: IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context,
      {required String title, required String tooltip, required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
