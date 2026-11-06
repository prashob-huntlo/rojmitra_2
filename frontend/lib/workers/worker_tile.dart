import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'availability_actions.dart';
import 'availability_chip.dart';
import 'worker.dart';

class WorkerTile extends ConsumerWidget {
  const WorkerTile({super.key, required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final personal = worker.personal;
    final experience = worker.experience;
    final current = personal.currentAddress;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        onTap: () => context.push('/worker/${worker.id}'),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Text(personal.fullName, style: textTheme.titleMedium),
        subtitle: Text(
          '${experience.primaryTrade} · ${experience.yearsOfExperience} yrs\n'
          '${current.district}, ${current.state}',
        ),
        isThreeLine: true,
        trailing: AvailabilityChip(
          isAvailable: worker.isReadyToWork,
          onTap: () => changeAvailability(context, ref, worker),
        ),
      ),
    );
  }
}
