import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/recurrence_rule.dart';
import '../models/recurring_task_model.dart';

class StorageService {
  static const String _tasksBoxName = 'tasks_box';
  static const String _recurringTasksBoxName = 'recurring_tasks_box';
  static const String _settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(FrequencyAdapter());
    Hive.registerAdapter(RecurrenceRuleAdapter());
    Hive.registerAdapter(RecurringTaskAdapter());
    await Hive.openBox<Task>(_tasksBoxName);
    await Hive.openBox<RecurringTask>(_recurringTasksBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  static Box<Task> getTasksBox() {
    return Hive.box<Task>(_tasksBoxName);
  }

  static List<Task> getAllTasks() {
    return getTasksBox().values.toList();
  }

  static Future<void> addTask(Task task) async {
    await getTasksBox().put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await getTasksBox().put(task.id, task);
  }

  static Future<void> deleteTask(String id) async {
    await getTasksBox().delete(id);
  }

  static Box<RecurringTask> getRecurringTasksBox() {
    return Hive.box<RecurringTask>(_recurringTasksBoxName);
  }

  static List<RecurringTask> getAllRecurringTasks() {
    return getRecurringTasksBox().values.toList();
  }

  static Future<void> addRecurringTask(RecurringTask task) async {
    await getRecurringTasksBox().put(task.id, task);
  }

  static Future<void> updateRecurringTask(RecurringTask task) async {
    await getRecurringTasksBox().put(task.id, task);
  }

  static Future<void> deleteRecurringTask(String id) async {
    await getRecurringTasksBox().delete(id);
  }

  // Settings
  static Box getSettingsBox() {
    return Hive.box(_settingsBoxName);
  }

  static bool getIsDarkMode() {
    return getSettingsBox().get('isDarkMode', defaultValue: false);
  }

  static Future<void> saveIsDarkMode(bool isDark) async {
    await getSettingsBox().put('isDarkMode', isDark);
  }

  static String getLanguageCode() {
    return getSettingsBox().get('languageCode', defaultValue: 'ar');
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    await getSettingsBox().put('languageCode', languageCode);
  }
}
