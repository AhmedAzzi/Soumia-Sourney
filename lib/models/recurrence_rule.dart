import 'package:hive/hive.dart';

part 'recurrence_rule.g.dart';

@HiveType(typeId: 2)
enum Frequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
}

@HiveType(typeId: 3)
class RecurrenceRule {
  @HiveField(0)
  final Frequency frequency;

  @HiveField(1)
  final int interval; // e.g., every 2 weeks

  @HiveField(2)
  final List<int>? daysOfWeek; // 1 (Mon) to 7 (Sun)

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final int? maxOccurrences;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.endDate,
    this.maxOccurrences,
  });

  RecurrenceRule copyWith({
    Frequency? frequency,
    int? interval,
    List<int>? daysOfWeek,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
    );
  }
}
