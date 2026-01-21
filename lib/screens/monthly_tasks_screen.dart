import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

import '../services/number_helper.dart';
import '../services/time_slot_helper.dart';
import '../widgets/heartbeat_animation.dart';
import '../widgets/monthly_calendar_view.dart';
import '../widgets/view_toggle_button.dart';

class MonthlyTasksScreen extends StatefulWidget {
  const MonthlyTasksScreen({super.key});

  @override
  State<MonthlyTasksScreen> createState() => _MonthlyTasksScreenState();
}

class _MonthlyTasksScreenState extends State<MonthlyTasksScreen> {
  bool _isCalendarView = true;

  @override
  void initState() {
    super.initState();
    _updateOrientation();
  }

  void _updateOrientation() {
    if (_isCalendarView) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _toggleView() {
    setState(() {
      _isCalendarView = !_isCalendarView;
    });
    _updateOrientation();
  }

  @override
  void dispose() {
    // Reset to portrait when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.getTasksForMonth(provider.focusedDate);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final newDate = DateTime(
                      provider.focusedDate.year,
                      provider.focusedDate.month - 1,
                      1,
                    );
                    provider.setFocusedDate(newDate);
                  },
                ),
                Text(
                  DateFormat(
                    'MMMM yyyy',
                    Localizations.localeOf(context).languageCode,
                  ).format(provider.focusedDate).toLatinNumbers(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final newDate = DateTime(
                      provider.focusedDate.year,
                      provider.focusedDate.month + 1,
                      1,
                    );
                    provider.setFocusedDate(newDate);
                  },
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ViewToggleButton(
                  isTableView: _isCalendarView,
                  onToggle: _toggleView,
                ),
              ),
            ],
          ),
          body: _isCalendarView
              ? MonthlyCalendarView(
                  focusedDate: provider.focusedDate,
                  tasks: tasks,
                )
              : _MonthlyListView(tasks: tasks),
        );
      },
    );
  }
}

class _MonthlyListView extends StatelessWidget {
  final List<Task> tasks;
  const _MonthlyListView({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (tasks.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    // Group tasks by date
    final groupedTasks = <DateTime, List<Task>>{};
    for (var task in tasks) {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      groupedTasks.putIfAbsent(dateKey, () => []).add(task);
    }

    final sortedDates = groupedTasks.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateTasks = groupedTasks[date]!;
        return _DateGroupCard(date: date, tasks: dateTasks);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeartbeatAnimation(
            child: Icon(
              Icons.volunteer_activism,
              size: 64,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTasks,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGroupCard extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  const _DateGroupCard({required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEEE, d MMMM',
      Localizations.localeOf(context).languageCode,
    ).format(date).toLatinNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(77)
                : colorScheme.primaryContainer.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainer
                  : colorScheme.secondary.withAlpha(38),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...tasks.map((task) => _TaskTile(task: task)),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      leading: GestureDetector(
        onTap: () {
          Provider.of<TaskProvider>(
            context,
            listen: false,
          ).toggleTaskStatus(task.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(4),
          child: Icon(
            task.isCompleted ? Icons.favorite : Icons.favorite_border,
            size: 24,
            color: task.isCompleted
                ? colorScheme.tertiary
                : colorScheme.tertiary.withAlpha(isDark ? 102 : 128),
          ),
        ),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      subtitle: task.timeSlot != null
          ? Text(
              formatTimeSlot(context, task.timeSlot!),
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, size: 20, color: colorScheme.primary),
        onPressed: () => _showDeleteConfirmation(context, task),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
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
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteTask(task.id);
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
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteRecurringTaskForMonth(
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
                      l10n.deleteAllMonth,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteTask(task.id, deleteSeries: true);
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
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteTask(task.id);
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
}
