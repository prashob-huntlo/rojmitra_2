import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'worker.dart';

IconData documentTypeIcon(DocumentType type) {
  switch (type) {
    case DocumentType.aadhaar:
      return Icons.badge_outlined;
    case DocumentType.pan:
      return Icons.credit_card_outlined;
    case DocumentType.bankPassbook:
      return Icons.account_balance_outlined;
    case DocumentType.drivingLicence:
      return Icons.directions_car_outlined;
    case DocumentType.photo:
      return Icons.person_outline;
  }
}

String documentTypeLabel(AppLocalizations l10n, DocumentType type) {
  switch (type) {
    case DocumentType.aadhaar:
      return l10n.aadhaar;
    case DocumentType.pan:
      return l10n.pan;
    case DocumentType.bankPassbook:
      return l10n.bankPassbook;
    case DocumentType.drivingLicence:
      return l10n.drivingLicence;
    case DocumentType.photo:
      return l10n.photo;
  }
}

String documentLabel(AppLocalizations l10n, WorkerDocument document) {
  final base = documentTypeLabel(l10n, document.type);
  switch (document.side) {
    case DocumentSide.front:
      return '$base (${l10n.idFront})';
    case DocumentSide.back:
      return '$base (${l10n.idBack})';
    case null:
      return base;
  }
}
