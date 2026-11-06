import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../core/errors/api_error.dart';
import '../features/catalog/models/catalog_company.dart';
import '../features/catalog/presentation/company_search_field.dart';
import 'worker.dart';
import 'workers_provider.dart';

Future<void> changeAvailability(
  BuildContext context,
  WidgetRef ref,
  Worker worker,
) async {
  final l10n = AppLocalizations.of(context)!;

  if (!worker.isReadyToWork) {
    await _confirmLeaveJob(context, ref, worker, l10n);
  } else {
    await _confirmStartJob(context, ref, worker, l10n);
  }
}

void _showError(BuildContext context, Object error) {
  final message = error is ApiError ? error.error : error.toString();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _confirmLeaveJob(
  BuildContext context,
  WidgetRef ref,
  Worker worker,
  AppLocalizations l10n,
) async {
  WorkEntry? current;
  for (final entry in worker.workHistory) {
    if (entry.companyName != null || entry.companyId != null) {
      current = entry;
      break;
    }
  }
  final companyName =
      current == null ? 'current job' : resolveCompanyName(current);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.leaveJobTitle),
        content: Text(l10n.leaveJobBody(companyName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.markAvailable),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(workersProvider.notifier).setAvailability(
          worker.id,
          isReadyToWork: true,
        );
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

Future<void> _confirmStartJob(
  BuildContext context,
  WidgetRef ref,
  Worker worker,
  AppLocalizations l10n,
) async {
  CatalogCompany? selectedCompany;

  final confirmed = await showDialog<CatalogCompany>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.markOnJobTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.markOnJobBody),
                  const SizedBox(height: 12),
                  CompanySearchField(
                    onSelected: (company) {
                      setState(() => selectedCompany = company);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: selectedCompany == null
                    ? null
                    : () => Navigator.pop(context, selectedCompany),
                child: Text(l10n.markOnJob),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed == null || !context.mounted) return;

  try {
    // Availability API only stores isReadyToWork; company is selected for partner context.
    await ref.read(workersProvider.notifier).setAvailability(
          worker.id,
          isReadyToWork: false,
        );
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}
