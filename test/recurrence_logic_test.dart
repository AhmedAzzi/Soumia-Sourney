import 'package:flutter_test/flutter_test.dart';
import 'package:soumia_journey/models/recurrence_rule.dart';
import 'package:soumia_journey/models/recurring_task_model.dart';
import 'package:soumia_journey/providers/task_provider.dart';

void main() {
  group('Recurrence Logic Tests', () {
    final provider = TaskProvider();

    test('Daily recurrence every 2 days', () {
      final rt = RecurringTask(
        id: 'daily-rule-1',
        title: 'Test',
        startDate: DateTime(2026, 1, 1),
        recurrenceRule: RecurrenceRule(frequency: Frequency.daily, interval: 2),
      );

      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 1)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 2)), false);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 3)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 5)), true);
    });

    test('Weekly recurrence on Mon and Wed', () {
      final rt = RecurringTask(
        id: 'weekly-rule-2',
        title: 'Test',
        startDate: DateTime(2026, 1, 1), // Thursday
        recurrenceRule: RecurrenceRule(
          frequency: Frequency.weekly,
          interval: 1,
          daysOfWeek: [1, 3], // Mon, Wed
        ),
      );

      expect(
        provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 1)),
        false,
      ); // Thu
      expect(
        provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 5)),
        true,
      ); // Mon
      expect(
        provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 7)),
        true,
      ); // Wed
      expect(
        provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 12)),
        true,
      ); // Next Mon
    });

    test('Monthly recurrence every 2 months', () {
      final rt = RecurringTask(
        id: 'monthly-rule-3',
        title: 'Test',
        startDate: DateTime(2026, 1, 1),
        recurrenceRule: RecurrenceRule(
          frequency: Frequency.monthly,
          interval: 2,
        ),
      );

      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 1)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 2, 1)), false);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 3, 1)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 5, 1)), true);
    });

    test('Recurrence with end date', () {
      final rt = RecurringTask(
        id: 'daily-rule-4',
        title: 'Test',
        startDate: DateTime(2026, 1, 1),
        recurrenceRule: RecurrenceRule(
          frequency: Frequency.daily,
          endDate: DateTime(2026, 1, 5),
        ),
      );

      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 1)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 5)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 6)), false);
    });

    test('Recurrence with max occurrences (N times)', () {
      final rt = RecurringTask(
        id: 'rule1',
        title: 'Test',
        startDate: DateTime(2026, 1, 1),
        recurrenceRule: RecurrenceRule(
          frequency: Frequency.daily,
          maxOccurrences: 2,
        ),
      );

      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 1)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 2)), true);
      expect(provider.doesRecurringTaskApply(rt, DateTime(2026, 1, 3)), false);
    });

    test('Visibility in date range (Week view)', () {
      final rt = RecurringTask(
        id: 'weekly-rule',
        title: 'Weekly Task',
        startDate: DateTime(2026, 1, 1), // Thu
        recurrenceRule: RecurrenceRule(
          frequency: Frequency.weekly,
          interval: 1,
          daysOfWeek: [1, 3], // Mon, Wed
        ),
      );
      provider.getRecurringTasks().add(rt);

      final weekStart = DateTime(2026, 1, 5); // Monday
      final weekEnd = DateTime(2026, 1, 11); // Sunday

      final tasks = provider.getTasksInRange(weekStart, weekEnd);

      // Should find Mon (5th) and Wed (7th)
      final virtualTasks = tasks
          .where((t) => t.id.startsWith('virtual_weekly-rule_'))
          .toList();
      expect(virtualTasks.length, 2);
      expect(virtualTasks.any((t) => t.date.day == 5), true);
      expect(virtualTasks.any((t) => t.date.day == 7), true);
    });
  });
}

// Helper to access members
extension TaskProviderTest on TaskProvider {
  List<RecurringTask> getRecurringTasks() => recurringTasks;
}
