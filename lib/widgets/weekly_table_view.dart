import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import 'package:soumia_journey/models/task_model.dart';
import 'package:soumia_journey/services/number_helper.dart';

class WeeklyTableView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Task> tasks;

  const WeeklyTableView({
    super.key,
    required this.focusedDate,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate week start (Monday) and end (Sunday) based on focusedDate
    // Assuming week starts on Monday as per previous app behavior
    final startOfWeek = focusedDate.subtract(
      Duration(days: focusedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    final timeSlots = [
      PrayerTimeSlot.general,
      PrayerTimeSlot.fajr,
      PrayerTimeSlot.sunrise,
      PrayerTimeSlot.dhuhr,
      PrayerTimeSlot.asr,
      PrayerTimeSlot.maghrib,
      PrayerTimeSlot.isha,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 20, // Increased spacing
                horizontalMargin: 16,
                border: TableBorder(
                  verticalInside: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(50),
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(50),
                    width: 1,
                  ),
                ),
                headingRowColor: WidgetStateProperty.all(
                  isDark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Theme.of(context).colorScheme.primaryContainer
                            .withAlpha(80), // Slightly darker header
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  // Zebra striping could be done if we had index, but map doesn't give it easily.
                  // For now, let's just ensure it contrasts well.
                  return null; // Default behavior is usually transparent, causing background to show.
                }),
                columns: [
                  DataColumn(
                    label: Text(
                      l10n.days, // Changed label to Date since rows are days now
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...timeSlots.map(
                    (slot) => DataColumn(
                      label: Text(
                        // Shorten labels for column headers if needed, using existing helper but centering
                        _getSlotLabel(context, slot),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: weekDays.map((date) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'E',
                                Localizations.localeOf(context).languageCode,
                              ).format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              date.day.toString().toLatinNumbers(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...timeSlots.map((slot) {
                        final tasksInSlot = tasks
                            .where(
                              (t) =>
                                  t.date.year == date.year &&
                                  t.date.month == date.month &&
                                  t.date.day == date.day &&
                                  (t.timeSlot == slot ||
                                      (slot == PrayerTimeSlot.general &&
                                          t.timeSlot == null)),
                            )
                            .toList();

                        return DataCell(
                          _buildTaskIndicator(context, tasksInSlot),
                          onTap: () {
                            // Future: Show dialog with tasks?
                          },
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getSlotLabel(BuildContext context, String slot) {
    final l10n = AppLocalizations.of(context)!;
    switch (slot) {
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
      default:
        return l10n.generalTasks;
    }
  }

  Widget _buildTaskIndicator(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Show up to 3 dots, or a number if more
    if (tasks.length > 3) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          tasks.length.toString().toLatinNumbers(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Tooltip(
      message: '${tasks.length} ${l10n.generalTasks}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: tasks.map((task) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? colorScheme.primary
                  : (isDark
                        ? colorScheme.surfaceContainerHigh
                        : colorScheme.primary.withAlpha(60)),
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted
                    ? Colors.transparent
                    : colorScheme.primary,
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
