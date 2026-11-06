import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../core/errors/api_error.dart';
import '../features/legal/data/legal_repository.dart';
import '../theme/app_styles.dart';

/// Fetches privacy / terms from the API (Mongo-backed).
class LegalDocumentPage extends ConsumerWidget {
  const LegalDocumentPage({
    super.key,
    required this.slug,
    required this.fallbackTitle,
  });

  final String slug;
  final String fallbackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDoc = ref.watch(legalDocumentProvider(slug));
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(fallbackTitle)),
      body: asyncDoc.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final message =
              error is ApiError ? error.error : 'Could not load document';
          return Center(
            child: Padding(
              padding: AppStyles.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  FilledButton(
                    onPressed: () => ref.invalidate(legalDocumentProvider(slug)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (doc) {
          final updated = doc.updatedAt;
          final updatedLabel = updated == null
              ? null
              : 'Last updated: ${updated.day.toString().padLeft(2, '0')}/'
                  '${updated.month.toString().padLeft(2, '0')}/'
                  '${updated.year}';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(legalDocumentProvider(slug));
              await ref.read(legalDocumentProvider(slug).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyles.detailPadding,
              children: [
                Text(
                  doc.title.isEmpty ? fallbackTitle : doc.title,
                  style: textTheme.headlineSmall,
                ),
                if (updatedLabel != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    updatedLabel,
                    style: textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
                SizedBox(height: 20.h),
                for (final paragraph in doc.paragraphs) ...[
                  Text(
                    paragraph,
                    style: textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      slug: 'privacy',
      fallbackTitle: AppLocalizations.of(context)!.privacyPolicy,
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      slug: 'terms',
      fallbackTitle: AppLocalizations.of(context)!.termsAndConditions,
    );
  }
}
