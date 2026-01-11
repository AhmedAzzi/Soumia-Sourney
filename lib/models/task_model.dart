import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? timeSlot;

  @HiveField(5)
  String? recurrenceId;

  @HiveField(6)
  DateTime? instanceDate;

  @HiveField(7)
  bool isDeleted;

  Task({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.isDeleted = false,
    required this.date,
    this.timeSlot,
    this.recurrenceId,
    this.instanceDate,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? date,
    String? timeSlot,
    String? recurrenceId,
    DateTime? instanceDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      instanceDate: instanceDate ?? this.instanceDate,
    );
  }
}

// Prayer-based time slots
class PrayerTimeSlot {
  static const String fajr = 'fajr';
  static const String sunrise = 'sunrise';
  static const String dhuhr = 'dhuhr';
  static const String asr = 'asr';
  static const String maghrib = 'maghrib';
  static const String isha = 'isha';
  static const String general = 'general';

  static List<String> get all => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}
