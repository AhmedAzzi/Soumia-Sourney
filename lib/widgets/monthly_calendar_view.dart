import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import '../models/task_model.dart';
import '../services/number_helper.dart';
import '../services/time_slot_helper.dart'; // For formatting time if needed in dialog
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class MonthlyCalendarView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Task> tasks;

  const MonthlyCalendarView({
    super.key,
    required this.focusedDate,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaysHeader(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildCalendarGrid(context, constraints);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaysHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.saturday,
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, BoxConstraints constraints) {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final daysInMonth = DateTime(
      focusedDate.year,
      focusedDate.month + 1,
      0,
    ).day;

    // Calculate offset for Saturday start
    // Sat=0, Sun=1, ... Fri=6
    // DateTime.weekday: Mon=1, ... Sat=6, Sun=7
    final firstDayWeekday = firstDayOfMonth.weekday;
    final offset = (firstDayWeekday + 1) % 7;

    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    // Calculate cell size to fit exactly
    final cellHeight = constraints.maxHeight / rows;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return SizedBox(
          height: cellHeight,
          child: Row(
            children: List.generate(7, (colIndex) {
              final dayIndex = rowIndex * 7 + colIndex - offset;
              final day = dayIndex + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(focusedDate.year, focusedDate.month, day);
              final dayTasks = tasks
                  .where((t) => isSameDay(t.date, date))
                  .toList();

              return Expanded(
                child: _CalendarCell(
                  date: date,
                  tasks: dayTasks,
                  height: cellHeight,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CalendarCell extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final double height;

  const _CalendarCell({
    required this.date,
    required this.tasks,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isToday =
        DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return InkWell(
      onTap: () => _showDayTasksDialog(context, date, tasks),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? colorScheme.primaryContainer.withAlpha(50)
              : isDark
              ? colorScheme.surfaceContainer
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.black.withAlpha(10),
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}'.toLatinNumbers(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? colorScheme.primary : colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 4),
              if (height > 60) // Only show progress bar if enough height
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.primary.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0 ? Colors.green : colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    minHeight: 4,
                  ),
                )
              else // Show dots for smaller cells
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: tasks.take(5).map((task) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDayTasksDialog(
    BuildContext context,
    DateTime date,
    List<Task> tasks,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DayTasksDialog(date: date, tasks: tasks),
    );
  }
}

class _DayTasksDialog extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  const _DayTasksDialog({required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat(
      'EEEE, d MMMM',
      Localizations.localeOf(context).languageCode,
    ).format(date).toLatinNumbers();

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final currentTasks = provider.getTasksInRange(date, date);

        // Sort tasks: By title, then by ID to keep position stable when checking
        final sortedTasks = List<Task>.from(currentTasks);
        sortedTasks.sort((a, b) {
          // Remove sorting by isCompleted so items don't jump when checked
          /*
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          */
          final titleCmp = a.title.compareTo(b.title);
          if (titleCmp != 0) return titleCmp;
          return a.id.compareTo(b.id);
        });

        return AlertDialog(
          title: Text(dateStr),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: sortedTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(l10n.noTasks),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
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
                          subtitle: task.timeSlot != null
                              ? Text(
                                  formatTimeSlot(context, task.timeSlot!),
                                  style: const TextStyle(fontSize: 12),
                                )
                              : null,
                          checkboxShape: const CircleBorder(),
                          activeColor: Theme.of(context).colorScheme.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
