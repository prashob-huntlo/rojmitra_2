import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../core/ui/app_shimmer.dart';
import '../theme/app_styles.dart';
import 'availability_chip.dart';
import 'worker.dart';
import 'workers_provider.dart';

class CompanyDetailPage extends ConsumerWidget {
  const CompanyDetailPage({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncList = ref.watch(workersProvider);

    return asyncList.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.company)),
        body: const WorkersListSkeleton(showHeader: false, itemCount: 4),
      ),
      error: (error, _) {
        final message = error is ApiError ? error.error : 'Something went wrong';
        return Scaffold(
          appBar: AppBar(title: Text(l10n.company)),
          body: Center(child: Text(message)),
        );
      },
      data: (workers) {
        final links = workersByCompany(companyId, workers);
        final title = companyNameForId(companyId, workers) ?? l10n.company;

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: links.isEmpty
              ? Center(child: Text(l10n.noWorkHistory))
              : ListView.separated(
                  padding: AppStyles.detailPadding,
                  itemCount: links.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final link = links[index];
                    final personal = link.worker.personal;
                    final experience = link.worker.experience;
                    return Card(
                      child: ListTile(
                        onTap: () => context.push('/worker/${link.worker.id}'),
                        title: Text(personal.fullName),
                        subtitle: Text(
                          link.isCurrent
                              ? '${experience.primaryTrade}\n${l10n.stillWorking}'
                              : experience.primaryTrade,
                        ),
                        isThreeLine: link.isCurrent,
                        trailing: AvailabilityChip(
                          isAvailable: link.worker.isReadyToWork,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
