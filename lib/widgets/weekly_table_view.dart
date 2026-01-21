import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import 'package:soumia_journey/models/task_model.dart';
import 'package:soumia_journey/providers/task_provider.dart';
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

    // Calculate week start (Saturday) based on focusedDate
    // focusedDate.weekday: Mon=1, ..., Sat=6, Sun=7
    // We want Sat to be the start (index 0).
    // Days since last Saturday:
    // Sat(6) -> 0
    // Sun(7) -> 1
    // Mon(1) -> 2
    // ...
    // Fri(5) -> 6
    // Formula: (focusedDate.weekday % 7) + 1  <- NO.
    // Let's verify:
    // Sat(6): 6 % 7 = 6.
    // Sun(7): 7 % 7 = 0.
    // Mon(1): 1 % 7 = 1.
    // This maps Sat->6, Sun->0. That's Sunday start.
    //
    // We want Saturday start.
    // (focusedDate.weekday + 1) % 7
    // Sat(6): (6+1)%7 = 0.
    // Sun(7): (7+1)%7 = 1.
    // Mon(1): (1+1)%7 = 2.
    // Fri(5): (5+1)%7 = 6.
    // This is correct.

    final startOfWeek = focusedDate.subtract(
      Duration(days: (focusedDate.weekday + 1) % 7),
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
        // Calculate row height to fit exactly within the available height
        // 8 rows total: 1 header row + 7 date rows
        final rowHeight = constraints.maxHeight / 8;

        return Table(
          border: TableBorder.all(
            color: Theme.of(context).dividerColor.withAlpha(50),
            width: 1,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(0.8), // Date column
            1: FlexColumnWidth(1), // General
            2: FlexColumnWidth(1), // Fajr
            3: FlexColumnWidth(1), // Sunrise
            4: FlexColumnWidth(1), // Dhuhr
            5: FlexColumnWidth(1), // Asr
            6: FlexColumnWidth(1), // Maghrib
            7: FlexColumnWidth(1), // Isha
          },
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withAlpha(80),
              ),
              children: [
                _buildHeaderCell(context, l10n.days, height: rowHeight),
                ...timeSlots.map(
                  (slot) => _buildHeaderCell(
                    context,
                    _getSlotLabel(context, slot),
                    height: rowHeight,
                  ),
                ),
              ],
            ),
            // Data Rows
            ...weekDays.map((date) {
              return TableRow(
                children: [
                  _buildDateCell(context, date, height: rowHeight),
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

                    return _buildTaskCell(
                      context,
                      tasksInSlot,
                      date,
                      slot,
                      height: rowHeight,
                    );
                  }),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    String text, {
    required double height,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateCell(
    BuildContext context,
    DateTime date, {
    required double height,
  }) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat(
              'E',
              Localizations.localeOf(context).languageCode,
            ).format(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            date.day.toString().toLatinNumbers(),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCell(
    BuildContext context,
    List<Task> tasks,
    DateTime date,
    String slot, {
    required double height,
  }) {
    return InkWell(
      onTap: () => _showTasksDialog(context, tasks, date, slot),
      child: Container(
        height: height,
        alignment: Alignment.center,
        child: _buildTaskIndicator(context, tasks),
      ),
    );
  }

  void _showTasksDialog(
    BuildContext context,
    List<Task> tasks,
    DateTime date,
    String slot,
  ) {
    if (tasks.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat(
      'EEEE, d MMMM',
      Localizations.localeOf(context).languageCode,
    ).format(date).toLatinNumbers();
    final slotLabel = _getSlotLabel(context, slot);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slotLabel, style: Theme.of(context).textTheme.titleLarge),
            Text(dateStr, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              // Refresh tasks list from provider to show updates immediately
              final currentTasks = provider
                  .getTasksInRange(date, date)
                  .where(
                    (t) =>
                        (t.timeSlot == slot ||
                        (slot == PrayerTimeSlot.general && t.timeSlot == null)),
                  )
                  .toList();

              // Sort by title then ID to ensure stable order
              currentTasks.sort((a, b) {
                final titleCmp = a.title.compareTo(b.title);
                if (titleCmp != 0) return titleCmp;
                return a.id.compareTo(b.id);
              });

              if (currentTasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l10n.noTasks),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: currentTasks.length,
                itemBuilder: (context, index) {
                  final task = currentTasks[index];
                  return CheckboxListTile(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      provider.toggleTaskStatus(task.id);
                    },
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    checkboxShape: const CircleBorder(),
                    activeColor: Theme.of(context).colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () =>
                          _showDeleteConfirmation(context, task, provider),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Task task,
    TaskProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isRecurring = task.recurrenceId != null;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.deleteTask,
              style: TextStyle(color: colorScheme.primary, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isRecurring ? l10n.deleteTaskOptions : l10n.deleteTaskConfirmation,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isRecurring) ...[
                  TextButton(
                    onPressed: () {
                      provider.deleteTask(task.id);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.deleteThisInstance,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.deleteRecurringTaskForWeek(
                        task.recurrenceId!,
                        task.date,
                      );
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.deleteAllWeek,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.deleteTask(task.id, deleteSeries: true);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.deleteEntireSeries,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                ] else
                  TextButton(
                    onPressed: () {
                      provider.deleteTask(task.id);
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.delete,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: '${tasks.length} ${l10n.generalTasks}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: tasks.take(5).map((task) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? Colors.green : colorScheme.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
}
