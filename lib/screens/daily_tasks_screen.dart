import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../models/recurrence_rule.dart';

import '../services/number_helper.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final dateStr = DateFormat(
          'EEEE, d MMMM',
          Localizations.localeOf(context).languageCode,
        ).format(provider.selectedDate).toLatinNumbers();

        return Scaffold(
          appBar: AppBar(
            title: Text(dateStr, style: const TextStyle(fontSize: 16)),
          ),
          body: _buildTimeSlotList(context, provider),
        );
      },
    );
  }

  Widget _buildTimeSlotList(BuildContext context, TaskProvider provider) {
    // Show General Tasks at the top, then prayer slots
    final prayerSlots = PrayerTimeSlot.all;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // General Tasks Section
        _TimeSlotCard(
          timeSlot: PrayerTimeSlot.general,
          tasks: provider.getTasksForTimeSlot(PrayerTimeSlot.general),
          isPrayerMode: false,
        ),
        const SizedBox(height: 8),
        // Prayer Slots
        ...prayerSlots.map((slot) {
          final tasks = provider.getTasksForTimeSlot(slot);
          return Column(
            children: [
              _TimeSlotCard(timeSlot: slot, tasks: tasks, isPrayerMode: true),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final String timeSlot;
  final List<Task> tasks;
  final bool isPrayerMode;

  const _TimeSlotCard({
    required this.timeSlot,
    required this.tasks,
    required this.isPrayerMode,
  });

  String _getSlotDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (timeSlot == PrayerTimeSlot.general) {
      return l10n.generalTasks;
    }

    final allSlots = PrayerTimeSlot.all;
    final currentIndex = allSlots.indexOf(timeSlot);
    final nextIndex = (currentIndex + 1) % allSlots.length;
    final nextSlot = allSlots[nextIndex];

    String getTranslatedName(String slot) {
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
          return slot;
      }
    }

    final currentName = getTranslatedName(timeSlot);
    final nextName = getTranslatedName(nextSlot);

    // Specific case for Isha to Fajr
    if (timeSlot == 'isha') {
      return l10n.afterIsha;
    }

    // Format: "From [Current] to [Next]" in a beautiful way
    return '${l10n.from} $currentName ${l10n.to} $nextName';
  }

  IconData _getSlotIcon() {
    if (timeSlot == PrayerTimeSlot.general) {
      return Icons.stars_rounded;
    }
    if (isPrayerMode) {
      switch (timeSlot) {
        case 'fajr':
          return Icons.nightlight_round;
        case 'sunrise':
          return Icons.wb_twilight;
        case 'dhuhr':
          return Icons.wb_sunny;
        case 'asr':
          return Icons.sunny_snowing;
        case 'maghrib':
          return Icons.wb_twilight;
        case 'isha':
          return Icons.nights_stay;
        default:
          return Icons.schedule;
      }
    }
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: colorScheme.primary.withAlpha(38), width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.primaryContainer.withAlpha(38),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time slot header with enhanced gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.primary.withAlpha(38)
                    : colorScheme.primaryContainer.withAlpha(77),
              ),
              child: Row(
                children: [
                  // Compact icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.primary.withAlpha(51)
                          : colorScheme.primary.withAlpha(26),
                      shape: BoxShape.circle,
                      boxShadow: null,
                    ),
                    child: Icon(
                      _getSlotIcon(),
                      color: isDark
                          ? colorScheme.primary.withAlpha(230)
                          : colorScheme.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getSlotDisplayName(context),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE0E0E0)
                            : colorScheme.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Compact add button
                  GestureDetector(
                    onTap: () => _showAddTaskDialog(context, timeSlot),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.primary.withAlpha(51)
                            : colorScheme.primary.withAlpha(26),
                        shape: BoxShape.circle,
                        border: isDark
                            ? Border.all(
                                color: colorScheme.primary.withAlpha(77),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Icon(
                        Icons.add,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tasks list - more compact
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 14,
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : colorScheme.onSurfaceVariant.withAlpha(102),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.noTasksInSlot,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFB0B0B0)
                            : colorScheme.onSurfaceVariant.withAlpha(153),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...tasks.map((task) => _TaskItem(task: task)),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, String timeSlot) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    // Simplified Recurrence State
    bool isRecurring = false;
    Frequency selectedFrequency = Frequency.daily;
    List<int> selectedDays = [];
    String selectedSlot = timeSlot;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colorScheme = Theme.of(context).colorScheme;

          Widget buildSectionTitle(String title) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withAlpha(179),
                  letterSpacing: 0.5,
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 8,
            shadowColor: colorScheme.shadow.withAlpha(51),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_task_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.addTask,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Input
                    TextField(
                      controller: controller,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainer
                            : colorScheme.primaryContainer.withAlpha(26),
                        hintText: l10n.whatsOnYourJourney,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      autofocus: true,
                    ),

                    const SizedBox(height: 8),
                    // Simple Choice: One-time or Repeating
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(l10n.todayOnly),
                          selected: !isRecurring,
                          onSelected: (val) =>
                              setState(() => isRecurring = !val),
                          selectedColor: colorScheme.primary.withAlpha(51),
                          labelStyle: TextStyle(
                            color: !isRecurring
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l10n.repeat),
                          selected: isRecurring,
                          onSelected: (val) =>
                              setState(() => isRecurring = val),
                          selectedColor: colorScheme.primary.withAlpha(51),
                          labelStyle: TextStyle(
                            color: isRecurring
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    if (isRecurring) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _QuickFreqChip(
                            label: l10n.daily,
                            isSelected: selectedFrequency == Frequency.daily,
                            onTap: () => setState(
                              () => selectedFrequency = Frequency.daily,
                            ),
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 8),
                          _QuickFreqChip(
                            label: l10n.weeklyFrequency,
                            isSelected: selectedFrequency == Frequency.weekly,
                            onTap: () => setState(
                              () => selectedFrequency = Frequency.weekly,
                            ),
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),

                      if (selectedFrequency == Frequency.weekly) ...[
                        buildSectionTitle(l10n.daysOfWeek),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            final isSelected = selectedDays.contains(day);
                            final dayLabel = [
                              l10n.monday,
                              l10n.tuesday,
                              l10n.wednesday,
                              l10n.thursday,
                              l10n.friday,
                              l10n.saturday,
                              l10n.sunday,
                            ][index];

                            return FilterChip(
                              label: Text(dayLabel),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: colorScheme.primary.withAlpha(51),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final provider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );
                    if (!isRecurring) {
                      provider.addTask(
                        controller.text,
                        provider.selectedDate,
                        timeSlot: selectedSlot,
                      );
                    } else {
                      provider.addSmartRecurringTask(
                        title: controller.text,
                        startDate: provider.selectedDate,
                        frequency: selectedFrequency,
                        interval: 1,
                        daysOfWeek: selectedFrequency == Frequency.weekly
                            ? (selectedDays.isEmpty
                                  ? [provider.selectedDate.weekday]
                                  : selectedDays)
                            : null,
                        endDate: null,
                        maxOccurrences: null,
                        timeSlot: selectedSlot,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  l10n.add,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickFreqChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _QuickFreqChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withAlpha(128),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? colorScheme.primary.withAlpha(20)
                : colorScheme.primaryContainer.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Custom heart checkbox
          GestureDetector(
            onTap: () {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskStatus(
                task.id,
                date: Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).selectedDate,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              child: Icon(
                task.isCompleted ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: task.isCompleted
                    ? colorScheme.primary
                    : colorScheme.primary.withAlpha(isDark ? 102 : 128),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: colorScheme.onSurfaceVariant,
                color: task.isCompleted
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
          // Compact action buttons
          GestureDetector(
            onTap: () => _showEditDialog(context, task),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: isDark
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withAlpha(179),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context, task),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.close,
                size: 16,
                color: isDark
                    ? colorScheme.primary
                    : colorScheme.primary.withAlpha(179),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Task task) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final rt = task.recurrenceId != null
        ? provider.getRecurringTaskById(task.recurrenceId!)
        : null;

    final controller = TextEditingController(text: rt?.title ?? task.title);
    bool isRecurring = task.recurrenceId != null;
    Frequency selectedFrequency =
        rt?.recurrenceRule.frequency ?? Frequency.daily;
    List<int> selectedDays = List<int>.from(
      rt?.recurrenceRule.daysOfWeek ?? [],
    );
    String selectedSlot =
        rt?.timeSlot ?? task.timeSlot ?? PrayerTimeSlot.general;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colorScheme = Theme.of(context).colorScheme;

          Widget buildSectionTitle(String title) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withAlpha(179),
                  letterSpacing: 0.5,
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 8,
            shadowColor: colorScheme.shadow.withAlpha(51),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.editTask,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainer
                            : colorScheme.primaryContainer.withAlpha(26),
                        hintText: l10n.whatsOnYourJourney,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      autofocus: true,
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(l10n.todayOnly),
                          selected: !isRecurring,
                          onSelected: (val) =>
                              setState(() => isRecurring = !val),
                          selectedColor: colorScheme.primary.withAlpha(51),
                          labelStyle: TextStyle(
                            color: !isRecurring
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l10n.repeat),
                          selected: isRecurring,
                          onSelected: (val) =>
                              setState(() => isRecurring = val),
                          selectedColor: colorScheme.primary.withAlpha(51),
                          labelStyle: TextStyle(
                            color: isRecurring
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    if (isRecurring) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _QuickFreqChip(
                            label: l10n.daily,
                            isSelected: selectedFrequency == Frequency.daily,
                            onTap: () => setState(
                              () => selectedFrequency = Frequency.daily,
                            ),
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 8),
                          _QuickFreqChip(
                            label: l10n.weeklyFrequency,
                            isSelected: selectedFrequency == Frequency.weekly,
                            onTap: () => setState(
                              () => selectedFrequency = Frequency.weekly,
                            ),
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                      if (selectedFrequency == Frequency.weekly) ...[
                        buildSectionTitle(l10n.daysOfWeek),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            final isSelected = selectedDays.contains(day);
                            final dayLabel = [
                              l10n.monday,
                              l10n.tuesday,
                              l10n.wednesday,
                              l10n.thursday,
                              l10n.friday,
                              l10n.saturday,
                              l10n.sunday,
                            ][index];

                            return FilterChip(
                              label: Text(dayLabel),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: colorScheme.primary.withAlpha(51),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    if (task.recurrenceId != null) {
                      if (isRecurring) {
                        // Case 1: Series -> Series (Update series)
                        await provider.updateRecurringTask(
                          task.recurrenceId!,
                          title: controller.text,
                          frequency: selectedFrequency,
                          daysOfWeek: selectedFrequency == Frequency.weekly
                              ? (selectedDays.isEmpty
                                    ? [provider.selectedDate.weekday]
                                    : selectedDays)
                              : null,
                          timeSlot: selectedSlot,
                        );
                      } else {
                        // Case 2: Series -> One-off
                        // Delete the series and create a single task for the current date
                        await provider.deleteTask(task.id, deleteSeries: true);
                        await provider.addTask(
                          controller.text,
                          task.date,
                          timeSlot: selectedSlot,
                        );
                      }
                    } else {
                      if (isRecurring) {
                        // Case 3: One-off -> Series
                        await provider.deleteTask(task.id);
                        await provider.addSmartRecurringTask(
                          title: controller.text,
                          startDate: task.date,
                          frequency: selectedFrequency,
                          interval: 1,
                          daysOfWeek: selectedFrequency == Frequency.weekly
                              ? (selectedDays.isEmpty
                                    ? [task.date.weekday]
                                    : selectedDays)
                              : null,
                          timeSlot: selectedSlot,
                        );
                      } else {
                        // Case 4: One-off -> One-off
                        await provider.updateTask(
                          task.id,
                          controller.text,
                          timeSlot: selectedSlot,
                        );
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(
                  l10n.update,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
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
