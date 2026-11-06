import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/app_logo.dart';
import '../features/auth/presentation/auth_notifier.dart';
import 'auth_fields.dart';

class RejectedPage extends ConsumerWidget {
  const RejectedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final partner = switch (authState) {
      Rejected(:final partner) => partner,
      _ => null,
    };

    return Scaffold(
      body: AuthPageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AppLogo.hero(width: 180)),
            const SizedBox(height: 28),
            Icon(Icons.block_outlined, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Account rejected',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              partner?.rejectionReason?.isNotEmpty == true
                  ? partner!.rejectionReason!
                  : 'Your account was rejected. Contact support if you need help.',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (partner != null) ...[
              const SizedBox(height: 16),
              Text(
                '+91 ${partner.phoneNumber}',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: Text(l10n.logIn),
            ),
          ],
        ),
      ),
    );
  }
}
