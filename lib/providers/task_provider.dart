import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../models/recurrence_rule.dart';
import '../models/recurring_task_model.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<RecurringTask> _recurringTasks = [];
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _focusedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<Task> get tasks => _tasks;
  List<RecurringTask> get recurringTasks => _recurringTasks;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;

  RecurringTask? getRecurringTaskById(String id) {
    try {
      return _recurringTasks.firstWhere((rt) => rt.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Task> get tasksForSelectedDate {
    return getTasksInRange(_selectedDate, _selectedDate);
  }

  List<Task> getTasksInRange(DateTime start, DateTime end) {
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);

    final allTasks = <Task>[];

    // 1. One-off tasks
    allTasks.addAll(
      _tasks.where((task) {
        if (task.recurrenceId != null) return false;
        final d = _normalizeDate(task.date);
        return (d.isAtSameMomentAs(normalizedStart) ||
                d.isAfter(normalizedStart)) &&
            (d.isAtSameMomentAs(normalizedEnd) || d.isBefore(normalizedEnd));
      }),
    );

    // 2. Persistent recurrence instances (completed or deleted)
    final recurrenceInstances = _tasks.where((task) {
      if (task.recurrenceId == null || task.instanceDate == null) return false;
      final d = _normalizeDate(task.instanceDate!);
      return (d.isAtSameMomentAs(normalizedStart) ||
              d.isAfter(normalizedStart)) &&
          (d.isAtSameMomentAs(normalizedEnd) || d.isBefore(normalizedEnd));
    }).toList();

    // Add non-deleted ones to result
    allTasks.addAll(recurrenceInstances.where((t) => !t.isDeleted));

    // 3. Virtual tasks from rules
    for (final rt in _recurringTasks) {
      DateTime current = normalizedStart;
      while (current.isBefore(normalizedEnd) ||
          current.isAtSameMomentAs(normalizedEnd)) {
        if (doesRecurringTaskApply(rt, current)) {
          // Check if instance already exists (completed or deleted)
          bool exists = recurrenceInstances.any((t) {
            final instDate = _normalizeDate(t.instanceDate!);
            return t.recurrenceId == rt.id &&
                instDate.isAtSameMomentAs(current);
          });

          if (!exists) {
            allTasks.add(
              Task(
                id: 'virtual_${rt.id}_${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}',
                title: rt.title,
                date: current,
                timeSlot: rt.timeSlot,
                recurrenceId: rt.id,
                instanceDate: current,
              ),
            );
          }
        }
        current = DateTime(current.year, current.month, current.day + 1);
      }
    }

    return allTasks;
  }

  bool doesRecurringTaskApply(RecurringTask rt, DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final normalizedStart = _normalizeDate(rt.startDate);

    if (normalizedDate.isBefore(normalizedStart)) {
      return false;
    }

    final rule = rt.recurrenceRule;

    // Check end date
    if (rule.endDate != null) {
      final normalizedEnd = _normalizeDate(rule.endDate!);
      if (normalizedDate.isAfter(normalizedEnd)) {
        return false;
      }
    }

    // Check max occurrences
    if (rule.maxOccurrences != null) {
      // For simple frequencies (daily) we can calculate count directly
      // For complex (weekly with daysOfWeek) we use the loop but optimize it
      if (rule.frequency == Frequency.daily && rule.daysOfWeek == null) {
        final hoursDiff = normalizedDate.difference(normalizedStart).inHours;
        final daysDiff = (hoursDiff / 24).round();
        final count = (daysDiff / rule.interval).floor() + 1;
        return count <= rule.maxOccurrences! && daysDiff % rule.interval == 0;
      } else {
        int count = 0;
        DateTime current = normalizedStart;
        while (current.isBefore(normalizedDate) ||
            current.isAtSameMomentAs(normalizedDate)) {
          if (doesRuleApplyOnSpecificDate(rt, current)) {
            count++;
            if (count > rule.maxOccurrences!) return false;
          }
          current = DateTime(current.year, current.month, current.day + 1);
        }
      }
    }

    return doesRuleApplyOnSpecificDate(rt, normalizedDate);
  }

  bool doesRuleApplyOnSpecificDate(RecurringTask rt, DateTime date) {
    final rule = rt.recurrenceRule;
    final normalizedStart = DateTime(
      rt.startDate.year,
      rt.startDate.month,
      rt.startDate.day,
    );
    final normalizedDate = DateTime(date.year, date.month, date.day);

    switch (rule.frequency) {
      case Frequency.daily:
        final daysDiff =
            (normalizedDate.difference(normalizedStart).inHours / 24).round();
        return daysDiff % rule.interval == 0;

      case Frequency.weekly:
        final daysDiff =
            (normalizedDate.difference(normalizedStart).inHours / 24).round();
        if (daysDiff % (rule.interval * 7) >= 7) return false;

        if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty) {
          return rule.daysOfWeek!.contains(date.weekday);
        }
        // If no days specified, it means repeat every X weeks on the same weekday as start date
        return date.weekday == rt.startDate.weekday;

      case Frequency.monthly:
        // Simplistic monthly: same day of month
        if (normalizedDate.day != normalizedStart.day) return false;
        final monthsDiff =
            (normalizedDate.year - normalizedStart.year) * 12 +
            normalizedDate.month -
            normalizedStart.month;
        return monthsDiff % rule.interval == 0;
    }
  }

  // Get tasks for a specific time slot on selected date
  List<Task> getTasksForTimeSlot(String timeSlot) {
    final tasks = tasksForSelectedDate
        .where((task) => task.timeSlot == timeSlot)
        .toList();

    // Sort by title then ID to ensure stable order when task status changes
    tasks.sort((a, b) {
      final titleCmp = a.title.compareTo(b.title);
      if (titleCmp != 0) return titleCmp;
      return a.id.compareTo(b.id);
    });

    return tasks;
  }

  // Get current time slots based on mode (fixed to prayer)
  List<String> get currentTimeSlots => PrayerTimeSlot.all;

  void loadTasks() {
    _tasks = StorageService.getAllTasks();
    _recurringTasks = StorageService.getAllRecurringTasks();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _focusedDate = date; // Also update focus when a day is selected
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Future<void> addTask(String title, DateTime date, {String? timeSlot}) async {
    final normalizedDate = _normalizeDate(date);
    final newTask = Task(
      title: title,
      date: normalizedDate,
      timeSlot: timeSlot,
    );
    _tasks.add(newTask);
    await StorageService.addTask(newTask);
    notifyListeners();
  }

  Future<void> addSmartRecurringTask({
    required String title,
    required DateTime startDate,
    required Frequency frequency,
    int interval = 1,
    List<int>? daysOfWeek,
    DateTime? endDate,
    int? maxOccurrences,
    String? timeSlot,
  }) async {
    final rule = RecurrenceRule(
      frequency: frequency,
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
    );
    final normalizedStartDate = _normalizeDate(startDate);
    final rt = RecurringTask(
      title: title,
      startDate: normalizedStartDate,
      timeSlot: timeSlot,
      recurrenceRule: rule,
    );
    _recurringTasks.add(rt);
    await StorageService.addRecurringTask(rt);
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String id, {DateTime? date}) async {
    // 1. Handle Virtual Tasks (generated from recurrence rules)
    if (id.startsWith('virtual_')) {
      try {
        final parts = id.split('_');
        if (parts.length >= 3) {
          final rtId = parts[1];
          // date part is likely YYYY-MM-DD, which DateTime.parse handles if it's valid ISO 8601 partial
          // But our format in getTasksInRange is:
          // virtual_${rt.id}_${current.year}-${current.month...}-${current.day...}
          // e.g. virtual_abc_2025-01-07
          final dateStr = parts[2];
          final taskDate = DateTime.parse(dateStr);

          // Find the rule
          final rt = _recurringTasks.firstWhere((r) => r.id == rtId);

          // Create the real task instance
          final newTask = Task(
            title: rt.title,
            date: taskDate,
            isCompleted: true,
            timeSlot: rt.timeSlot,
            recurrenceId: rtId,
            instanceDate: taskDate,
          );

          _tasks.add(newTask);
          await StorageService.addTask(newTask);
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Error toggling virtual task: $e');
      }
    }

    // 2. Handle Existing Tasks
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      await StorageService.updateTask(_tasks[taskIndex]);
      notifyListeners();
    }
    // 3. Fallback (Legacy/Safety)
    else {
      final normalizedDate = date != null
          ? _normalizeDate(date)
          : _selectedDate;
      for (final rt in _recurringTasks) {
        if (doesRecurringTaskApply(rt, normalizedDate)) {
          // Only create if we couldn't parse a virtual ID
          final newTask = Task(
            title: rt.title,
            date: normalizedDate,
            isCompleted: true,
            timeSlot: rt.timeSlot,
            recurrenceId: rt.id,
            instanceDate: normalizedDate,
          );
          _tasks.add(newTask);
          await StorageService.addTask(newTask);
          notifyListeners();
          return;
        }
      }
    }
  }

  Future<void> updateTask(
    String id,
    String newTitle, {
    String? timeSlot,
  }) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].title = newTitle;
      if (timeSlot != null) {
        _tasks[taskIndex].timeSlot = timeSlot;
      }
      await StorageService.updateTask(_tasks[taskIndex]);
      notifyListeners();
    }
  }

  Future<void> updateRecurringTask(
    String rtId, {
    required String title,
    required Frequency frequency,
    required List<int>? daysOfWeek,
    required String? timeSlot,
  }) async {
    final rtIndex = _recurringTasks.indexWhere((rt) => rt.id == rtId);
    if (rtIndex != -1) {
      final rt = _recurringTasks[rtIndex];
      rt.title = title;
      rt.timeSlot = timeSlot;
      rt.recurrenceRule = rt.recurrenceRule.copyWith(
        frequency: frequency,
        daysOfWeek: daysOfWeek,
      );

      await StorageService.updateRecurringTask(rt);

      // Also update any existing instances that haven't been completed/deleted?
      // Or just let user know it applies to the series.
      // Usually, updating the rule is enough as virtual tasks are generated from it.
      // But we should update the title/timeSlot of existing instances if they belong to this series and are NOT yet completed/deleted.
      for (var i = 0; i < _tasks.length; i++) {
        if (_tasks[i].recurrenceId == rtId) {
          _tasks[i].title = title;
          _tasks[i].timeSlot = timeSlot;
          await StorageService.updateTask(_tasks[i]);
        }
      }

      notifyListeners();
    }
  }

  Future<void> deleteTask(String id, {bool deleteSeries = false}) async {
    if (id.startsWith('virtual_')) {
      // Deleting a virtual task means creating an "exclusion" instance
      final parts = id.split('_');
      if (parts.length >= 3) {
        final rtId = parts[1];
        final date = DateTime.parse(parts[2]);
        final rt = _recurringTasks.firstWhere((element) => element.id == rtId);

        if (deleteSeries) {
          await deleteRecurringTask(rtId);
        } else {
          final exclusion = Task(
            title: rt.title,
            date: date,
            isDeleted: true,
            timeSlot: rt.timeSlot,
            recurrenceId: rtId,
            instanceDate: date,
          );
          _tasks.add(exclusion);
          await StorageService.addTask(exclusion);
          notifyListeners();
        }
      }
      return;
    }

    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      if (deleteSeries && task.recurrenceId != null) {
        await deleteRecurringTask(task.recurrenceId!);
      } else {
        if (task.recurrenceId != null) {
          // Instead of removing, mark as deleted to prevent virtual task from reappearing
          task.isDeleted = true;
          await StorageService.updateTask(task);
        } else {
          _tasks.removeAt(taskIndex);
          await StorageService.deleteTask(id);
        }
        notifyListeners();
      }
    }
  }

  Future<void> deleteRecurringTask(String rtId) async {
    // 1. Find all instances of this recurring task and delete them from storage
    final instancesToDelete = _tasks
        .where((t) => t.recurrenceId == rtId)
        .toList();
    for (final instance in instancesToDelete) {
      await StorageService.deleteTask(instance.id);
    }

    // 2. Remove the rule from state and storage
    _recurringTasks.removeWhere((rt) => rt.id == rtId);
    await StorageService.deleteRecurringTask(rtId);

    // 3. Remove all instances from local state
    _tasks.removeWhere((t) => t.recurrenceId == rtId);

    notifyListeners();
  }

  Future<void> deleteRecurringTaskRange(
    String rtId,
    DateTime start,
    DateTime end,
  ) async {
    final rt = _recurringTasks.firstWhere((element) => element.id == rtId);

    DateTime current = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);

    while (current.isBefore(normalizedEnd) ||
        current.isAtSameMomentAs(normalizedEnd)) {
      if (doesRecurringTaskApply(rt, current)) {
        // Check if it's already a real task in state
        final taskIndex = _tasks.indexWhere(
          (t) =>
              t.recurrenceId == rtId &&
              _normalizeDate(t.date).isAtSameMomentAs(current),
        );

        if (taskIndex != -1) {
          final task = _tasks[taskIndex];
          if (!task.isDeleted) {
            task.isDeleted = true;
            await StorageService.updateTask(task);
          }
        } else {
          // Create exclusion
          final exclusion = Task(
            title: rt.title,
            date: current,
            isDeleted: true,
            timeSlot: rt.timeSlot,
            recurrenceId: rtId,
            instanceDate: current,
          );
          _tasks.add(exclusion);
          await StorageService.addTask(exclusion);
        }
      }
      current = current.add(const Duration(days: 1));
    }
    notifyListeners();
  }

  Future<void> deleteRecurringTaskForWeek(String rtId, DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final weekStart = normalizedDate.subtract(
      Duration(days: normalizedDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    await deleteRecurringTaskRange(rtId, weekStart, weekEnd);
  }

  Future<void> deleteRecurringTaskForMonth(String rtId, DateTime date) async {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    await deleteRecurringTaskRange(rtId, firstDay, lastDay);
  }

  // Helper to strip time component
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Percentage Calculations
  double getDailyCompletionPercentage(DateTime date) {
    final dailyTasks = getTasksInRange(date, date);
    if (dailyTasks.isEmpty) return 0.0;
    final completed = dailyTasks.where((t) => t.isCompleted).length;
    return completed / dailyTasks.length;
  }

  double getWeeklyCompletionPercentage(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final weekStart = normalizedDate.subtract(
      Duration(days: normalizedDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weeklyTasks = getTasksInRange(weekStart, weekEnd);
    if (weeklyTasks.isEmpty) return 0.0;
    final completed = weeklyTasks.where((t) => t.isCompleted).length;
    return completed / weeklyTasks.length;
  }

  double getMonthlyCompletionPercentage(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    final monthlyTasks = getTasksInRange(firstDay, lastDay);
    if (monthlyTasks.isEmpty) return 0.0;
    final completed = monthlyTasks.where((t) => t.isCompleted).length;
    return completed / monthlyTasks.length;
  }

  List<Task> getTasksForWeek(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final weekStart = normalizedDate.subtract(
      Duration(days: normalizedDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    return getTasksInRange(weekStart, weekEnd)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Task> getTasksForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    return getTasksInRange(firstDay, lastDay)
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
