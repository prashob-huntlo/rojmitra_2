import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'worker.dart';
import 'work_date_format.dart';

class WorkHistoryTile extends StatelessWidget {
  const WorkHistoryTile({
    super.key,
    required this.entry,
    this.onEndCurrent,
  });

  final WorkEntry entry;
  final VoidCallback? onEndCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companyName = resolveCompanyName(entry);
    final start = formatWorkDate(context, entry.startDate);
    final end = entry.endDate == null
        ? l10n.now
        : formatWorkDate(context, entry.endDate!);
    final tradeLine = entry.trade?.trim().isNotEmpty == true
        ? entry.trade!
        : '';

    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: entry.companyId == null || onEndCurrent != null
                ? null
                : () => context.push('/company/${entry.companyId}'),
            title: Text(companyName),
            subtitle: Text(
              [
                if (tradeLine.isNotEmpty) tradeLine,
                '$start - $end',
              ].join('\n'),
            ),
            isThreeLine: tradeLine.isNotEmpty,
            trailing: entry.companyId == null || onEndCurrent != null
                ? null
                : const Icon(Icons.chevron_right),
          ),
          if (entry.isCurrent && onEndCurrent != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onEndCurrent,
                child: Text(l10n.endThisWork),
              ),
            ),
        ],
      ),
    );
  }
}
