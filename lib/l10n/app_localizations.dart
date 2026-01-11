import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Soumia\'s Diary'**
  String get appTitle;

  /// No description provided for @viewTodayJourney.
  ///
  /// In en, this message translates to:
  /// **'View Today\'s Tasks'**
  String get viewTodayJourney;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Allah, keep her in my heart ... Bless those who say Amen'**
  String get quote;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @whatsOnYourJourney.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your tasks?'**
  String get whatsOnYourJourney;

  /// No description provided for @updateYourTask.
  ///
  /// In en, this message translates to:
  /// **'Update your task'**
  String get updateYourTask;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @repeatDuration.
  ///
  /// In en, this message translates to:
  /// **'Repeat Duration'**
  String get repeatDuration;

  /// No description provided for @todayOnly.
  ///
  /// In en, this message translates to:
  /// **'Today Only'**
  String get todayOnly;

  /// No description provided for @days3.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get days3;

  /// No description provided for @week1.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get week1;

  /// No description provided for @month1.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get month1;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today.'**
  String get noTasks;

  /// No description provided for @addGentleGoals.
  ///
  /// In en, this message translates to:
  /// **'Add some gentle goals to your day.'**
  String get addGentleGoals;

  /// No description provided for @timeSlotMode.
  ///
  /// In en, this message translates to:
  /// **'Day Division'**
  String get timeSlotMode;

  /// No description provided for @hourlyMode.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get hourlyMode;

  /// No description provided for @prayerMode.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerMode;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @selectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeSlot;

  /// No description provided for @noTasksInSlot.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasksInSlot;

  /// No description provided for @addTaskToSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTaskToSlot;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @afterIsha.
  ///
  /// In en, this message translates to:
  /// **'After Isha'**
  String get afterIsha;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weeklyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyFrequency;

  /// No description provided for @monthlyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyFrequency;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get until;

  /// No description provided for @forCount.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forCount;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @forever.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get forever;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get daysOfWeek;

  /// No description provided for @monday_short.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday_short;

  /// No description provided for @tuesday_short.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday_short;

  /// No description provided for @wednesday_short.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday_short;

  /// No description provided for @thursday_short.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday_short;

  /// No description provided for @friday_short.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday_short;

  /// No description provided for @saturday_short.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday_short;

  /// No description provided for @sunday_short.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday_short;

  /// No description provided for @deleteThisInstance.
  ///
  /// In en, this message translates to:
  /// **'This once'**
  String get deleteThisInstance;

  /// No description provided for @deleteEntireSeries.
  ///
  /// In en, this message translates to:
  /// **'All series'**
  String get deleteEntireSeries;

  /// No description provided for @deleteTaskOptions.
  ///
  /// In en, this message translates to:
  /// **'How would you like to delete this task?'**
  String get deleteTaskOptions;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @generalTasks.
  ///
  /// In en, this message translates to:
  /// **'General Tasks'**
  String get generalTasks;

  /// No description provided for @deleteAllWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get deleteAllWeek;

  /// No description provided for @deleteAllMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get deleteAllMonth;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
