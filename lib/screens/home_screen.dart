import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:soumia_journey/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';

import 'daily_tasks_screen.dart';
import 'weekly_tasks_screen.dart';
import 'monthly_tasks_screen.dart';
import 'package:intl/intl.dart';
import '../services/number_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppBar(
              toolbarHeight: 50,
              leading: Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return IconButton(
                    icon: Icon(
                      settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      settings.toggleTheme();
                    },
                    tooltip: settings.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  );
                },
              ),
              title: Center(
                child: Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final isArabic = settings.locale.languageCode == 'ar';
                    return GestureDetector(
                      onTap: () {
                        settings.toggleLanguage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          isArabic ? 'EN' : 'AR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Header Quote
              _AnimatedSection(
                fadeAnimation: _fadeAnimations[0],
                slideAnimation: _slideAnimations[0],
                child: const _HeaderQuoteSection(),
              ),

              // 2. Progress Section
              _AnimatedSection(
                fadeAnimation: _fadeAnimations[1],
                slideAnimation: _slideAnimations[1],
                child: const _StatsSection(),
              ),

              // 3. Calendar
              _AnimatedSection(
                fadeAnimation: _fadeAnimations[2],
                slideAnimation: _slideAnimations[2],
                child: const _CalendarSection(),
              ),

              // 4. Action Button
              _AnimatedSection(
                fadeAnimation: _fadeAnimations[3],
                slideAnimation: _slideAnimations[3],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _GradientButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyTasksScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.viewTodayJourney,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget child;

  const _AnimatedSection({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GradientButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CalendarSection extends StatefulWidget {
  const _CalendarSection();

  @override
  State<_CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<_CalendarSection> {
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.primaryContainer.withAlpha(26),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              locale: Localizations.localeOf(context).languageCode,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: provider.focusedDate,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              rowHeight: 32,
              daysOfWeekHeight: 24,
              selectedDayPredicate: (day) =>
                  isSameDay(provider.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                final now = DateTime.now();
                if (_lastTappedDay != null &&
                    isSameDay(selectedDay, _lastTappedDay) &&
                    _lastTapTime != null &&
                    now.difference(_lastTapTime!) <
                        const Duration(milliseconds: 300)) {
                  // Double tap detected
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyTasksScreen(),
                    ),
                  );
                } else {
                  provider.setSelectedDate(selectedDay);
                  setState(() {
                    _lastTappedDay = selectedDay;
                    _lastTapTime = now;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                provider.setFocusedDate(focusedDay);
              },
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(2),
                todayDecoration: BoxDecoration(
                  color: colorScheme.secondary.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(102),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                markerDecoration: BoxDecoration(
                  color: colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: colorScheme.primary.withAlpha(204),
                  fontSize: 13,
                ),
                defaultTextStyle: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                headerPadding: const EdgeInsets.symmetric(vertical: 6),
                titleTextStyle: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainer
                        : colorScheme.primaryContainer.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainer
                        : colorScheme.primaryContainer.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withAlpha(
                          isDark ? 77 : 102,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isDark ? Colors.white : colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withAlpha(77),
                        fontSize: 13,
                      ),
                    ),
                  );
                },
                headerTitleBuilder: (context, day) {
                  final text = DateFormat.yMMMM(
                    Localizations.localeOf(context).languageCode,
                  ).format(day).toLatinNumbers();
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final dailyPerc = provider.getDailyCompletionPercentage(
          provider.selectedDate,
        );
        final weeklyPerc = provider.getWeeklyCompletionPercentage(
          provider.focusedDate,
        );
        final monthlyPerc = provider.getMonthlyCompletionPercentage(
          provider.focusedDate,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.primaryContainer.withAlpha(38),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: []),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyTasksScreen(),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: l10n.today,
                        percentage: dailyPerc,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeeklyTasksScreen(),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: l10n.weekly,
                        percentage: weeklyPerc,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MonthlyTasksScreen(),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: l10n.monthly,
                        percentage: monthlyPerc,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderQuoteSection extends StatelessWidget {
  const _HeaderQuoteSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(31),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Container(width: 40, height: 1, color: colorScheme.secondary),
              const SizedBox(height: 16),
              _buildQuoteWithHeart(
                l10n.quote,
                Localizations.localeOf(context).languageCode,
                context,
              ),
              const SizedBox(height: 16),
              Container(width: 40, height: 1, color: colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteWithHeart(
    String quote,
    String languageCode,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!quote.contains('...')) {
      return Text(
        quote,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: languageCode == 'en' ? 14 : 16,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      );
    }

    final parts = quote.split('...');
    // Ensure we handle cases safely
    if (parts.length < 2) return Text(quote);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts[0].trim()),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.favorite, color: colorScheme.primary, size: 14),
            ),
          ),
          TextSpan(text: parts[1].trim()),
        ],
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: languageCode == 'en' ? 12 : 14,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.2,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _StatItem({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 42.0,
          lineWidth: 5.0,
          backgroundWidth: 10.0,
          percent: percentage,
          center: Text(
            "${(percentage * 100).toInt()}%".toLatinNumbers(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          progressColor: color,
          backgroundColor: isDark
              ? Colors.grey.withAlpha(51)
              : colorScheme.primaryContainer.withAlpha(51),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 800,
          animateFromLastPercent: true,
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
