import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_styles.dart';
import 'language_picker.dart';
import 'locale_provider.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.chooseLanguage, style: textTheme.headlineMedium),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final locale in AppLocalizations.supportedLocales) ...[
                      Material(
                        color: Colors.white,
                        shape: AppStyles.cardShape,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppStyles.radius),
                          onTap: () async {
                            await ref.read(localeProvider.notifier).setLocale(locale);
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 28,
                            ),
                            child: Text(
                              nativeLanguageName(locale),
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
