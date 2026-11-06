import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../l10n/language_picker.dart';
import '../l10n/locale_provider.dart';
import '../theme/app_styles.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeState = ref.watch(localeProvider);
    final currentLanguage = localeState.hasSavedLanguage && localeState.locale != null
        ? nativeLanguageName(localeState.locale!)
        : l10n.systemDefault;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.preferences)),
      body: ListView(
        padding: AppStyles.detailPadding,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(currentLanguage),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLanguagePicker(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
