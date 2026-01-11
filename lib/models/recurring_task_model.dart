import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'recurrence_rule.dart';

part 'recurring_task_model.g.dart';

@HiveType(typeId: 1)
class RecurringTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  String? timeSlot;

  @HiveField(4)
  RecurrenceRule recurrenceRule;

  RecurringTask({
    String? id,
    required this.title,
    required this.startDate,
    this.timeSlot,
    required this.recurrenceRule,
  }) : id = id ?? const Uuid().v4();
}
