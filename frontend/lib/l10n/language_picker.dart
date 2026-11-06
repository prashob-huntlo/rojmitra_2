import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'locale_provider.dart';

const nativeLanguageNames = <String, String>{
  'en': 'English',
  'hi': 'हिन्दी',
  'gu': 'ગુજરાતી',
};

String nativeLanguageName(Locale locale) {
  return nativeLanguageNames[locale.languageCode] ?? locale.languageCode;
}

bool _sameLocale(Locale? a, Locale? b) {
  if (a == null || b == null) {
    return a == b;
  }
  return a.languageCode == b.languageCode;
}

Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final selected = ref.read(localeProvider).locale;
  final usingSystemDefault = !ref.read(localeProvider).hasSavedLanguage;

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.language, style: textTheme.titleMedium),
              ),
            ),
            ListTile(
              title: Text(l10n.systemDefault),
              trailing: usingSystemDefault ? const Icon(Icons.check) : null,
              onTap: () async {
                await ref.read(localeProvider.notifier).useSystemDefault();
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            for (final locale in AppLocalizations.supportedLocales)
              ListTile(
                title: Text(nativeLanguageName(locale)),
                trailing: !usingSystemDefault && _sameLocale(selected, locale)
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await ref.read(localeProvider.notifier).setLocale(locale);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
