import 'package:flutter/material.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';

/// Formats a time slot key to its localized display name
String formatTimeSlot(BuildContext context, String timeSlot) {
  final l10n = AppLocalizations.of(context)!;
  switch (timeSlot) {
    case 'fajr':
      return l10n.fajr;
    case 'sunrise':
      return l10n.sunrise;
    case 'dhuhr':
      return l10n.dhuhr;
    case 'asr':
      return l10n.asr;
    case 'maghrib':
      return l10n.maghrib;
    case 'isha':
      return l10n.isha;
    case 'general':
      return l10n.generalTasks;
    default:
      return timeSlot;
  }
}
