import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/theme.dart';

/// Settings page.
///
/// Phase 12: fully localized with language switching. The user can choose
/// between English, 简体中文, or follow the system locale.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final localePref = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _SettingsGroup(
            title: l.appearance,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: Text(l.theme),
                subtitle: Text('${l.light} / ${l.dark} / ${l.system}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Theme switching will be wired up in a future phase.
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: l.language,
            children: [
              ListTile(
                leading: Icon(
                  localePref.code == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(l.system),
                onTap: () => ref.read(localeProvider.notifier).setLanguage(null),
              ),
              ListTile(
                leading: Icon(
                  localePref.code == 'en'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(l.english),
                onTap: () => ref.read(localeProvider.notifier).setLanguage('en'),
              ),
              ListTile(
                leading: Icon(
                  localePref.code == 'zh'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(l.chinese),
                onTap: () => ref.read(localeProvider.notifier).setLanguage('zh'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: l.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.version),
                subtitle: const Text('1.0.0 (Phase 12)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(l.openSource),
                subtitle: Text(l.exerciseDataGifs),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl2),
          Center(
            child: Text(
              l.gymVisualCopyright,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// A grouped settings section with a header label.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.lgAll,
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: theme.dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
