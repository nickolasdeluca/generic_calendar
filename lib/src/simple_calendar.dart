import 'package:flutter/material.dart';

/// Called when the visible month changes.
///
/// The supplied date is always the first day of the new month.
typedef MonthChangedCallback = void Function(DateTime month);

/// A compact, dependency-free month calendar.
///
/// Dates passed to and returned by this widget are normalized to local calendar
/// dates (year, month, day); their time component is discarded.
class SimpleCalendar extends StatefulWidget {
  /// Creates a simple month calendar.
  SimpleCalendar({
    super.key,
    this.onSelect,
    this.selectedDate,
    this.initialMonth,
    this.eventDates = const <DateTime>[],
    this.hasEvent,
    this.firstDate,
    this.lastDate,
    this.onMonthChanged,
    this.startWeekOnMonday,
    this.showAdjacentMonthDates = true,
    this.accentColor,
    this.eventIndicatorColor,
    this.backgroundColor,
    this.foregroundColor,
    this.selectedTextColor,
    this.borderRadius = 20,
    this.monthNames,
    this.weekdayNames,
  }) : assert(
         monthNames == null || monthNames.length == 12,
         'monthNames must contain exactly 12 entries.',
       ),
       assert(
         weekdayNames == null || weekdayNames.length == 7,
         'weekdayNames must contain exactly 7 entries, starting with Monday.',
       ),
       assert(
         firstDate == null ||
             lastDate == null ||
             !DateTime(
               firstDate.year,
               firstDate.month,
               firstDate.day,
             ).isAfter(DateTime(lastDate.year, lastDate.month, lastDate.day)),
         'firstDate must be on or before lastDate.',
       );

  /// English month labels for clients that prefer explicit labels.
  static const List<String> defaultMonthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// English weekday labels, ordered Monday through Sunday.
  static const List<String> defaultWeekdayNames = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Called with the selected local calendar date.
  ///
  /// When omitted, the calendar still updates its internal selection without
  /// notifying an external listener.
  final ValueChanged<DateTime>? onSelect;

  /// The selected date.
  ///
  /// The widget updates its own selection immediately. When this value changes,
  /// the external value replaces the internal selection.
  final DateTime? selectedDate;

  /// Month displayed initially. Defaults to [selectedDate], then today.
  final DateTime? initialMonth;

  /// Dates that receive an event indicator. Time components are ignored.
  final Iterable<DateTime> eventDates;

  /// Optional dynamic event lookup.
  ///
  /// A date is marked when it is in [eventDates] or this returns true.
  final bool Function(DateTime date)? hasEvent;

  /// Earliest selectable date, inclusive.
  final DateTime? firstDate;

  /// Latest selectable date, inclusive.
  final DateTime? lastDate;

  /// Called after month navigation.
  final MonthChangedCallback? onMonthChanged;

  /// Whether the first weekday is Monday. If false, Sunday is first.
  ///
  /// When null, the convention of the current app locale is used.
  final bool? startWeekOnMonday;

  /// Whether dates from neighboring months are shown in the grid.
  final bool showAdjacentMonthDates;

  /// Selection and navigation color. Defaults to the color scheme primary.
  final Color? accentColor;

  /// Event indicator color. Defaults to [accentColor].
  final Color? eventIndicatorColor;

  /// Card background. Defaults to the color scheme surface.
  final Color? backgroundColor;

  /// Month title, weekday label, and date text color.
  ///
  /// Disabled and adjacent-month dates use subdued variants of this color.
  /// Defaults to the color scheme on-surface color.
  final Color? foregroundColor;

  /// Text and event-dot color for the selected date.
  ///
  /// Defaults to the color scheme on-primary color.
  final Color? selectedTextColor;

  /// Corner radius of the calendar card.
  final double borderRadius;

  /// Optional month label override, containing twelve entries from January.
  ///
  /// By default, month names and the year are formatted using the current
  /// [MaterialLocalizations].
  final List<String>? monthNames;

  /// Optional weekday label override, containing seven entries from Monday.
  ///
  /// By default, localized narrow weekday names are used.
  final List<String>? weekdayNames;

  @override
  State<SimpleCalendar> createState() => _SimpleCalendarState();
}

class _SimpleCalendarState extends State<SimpleCalendar> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnlyOrNull(widget.selectedDate);
    final initial =
        widget.initialMonth ?? widget.selectedDate ?? DateTime.now();
    _visibleMonth = DateTime(initial.year, initial.month);
    _clampVisibleMonth();
  }

  @override
  void didUpdateWidget(SimpleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameNullableDate(widget.selectedDate, oldWidget.selectedDate)) {
      _selectedDate = _dateOnlyOrNull(widget.selectedDate);
      if (_selectedDate != null) {
        _visibleMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
      }
    }
    _clampVisibleMonth();
  }

  void _clampVisibleMonth() {
    final firstMonth = _monthOnly(widget.firstDate);
    final lastMonth = _monthOnly(widget.lastDate);
    if (firstMonth != null && _visibleMonth.isBefore(firstMonth)) {
      _visibleMonth = firstMonth;
    }
    if (lastMonth != null && _visibleMonth.isAfter(lastMonth)) {
      _visibleMonth = lastMonth;
    }
  }

  bool _canNavigate(int monthDelta) {
    final target = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + monthDelta,
    );
    final firstMonth = _monthOnly(widget.firstDate);
    final lastMonth = _monthOnly(widget.lastDate);
    return (firstMonth == null || !target.isBefore(firstMonth)) &&
        (lastMonth == null || !target.isAfter(lastMonth));
  }

  void _changeMonth(int monthDelta) {
    if (!_canNavigate(monthDelta)) return;
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + monthDelta,
      );
    });
    widget.onMonthChanged?.call(_visibleMonth);
  }

  void _select(DateTime date) {
    if (!_isEnabled(date)) return;
    final changesMonth =
        date.month != _visibleMonth.month || date.year != _visibleMonth.year;
    setState(() {
      _selectedDate = date;
      if (changesMonth) {
        _visibleMonth = DateTime(date.year, date.month);
      }
    });
    if (changesMonth) widget.onMonthChanged?.call(_visibleMonth);
    widget.onSelect?.call(date);
  }

  bool _isEnabled(DateTime date) {
    final first = _dateOnlyOrNull(widget.firstDate);
    final last = _dateOnlyOrNull(widget.lastDate);
    return (first == null || !date.isBefore(first)) &&
        (last == null || !date.isAfter(last));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final accent = widget.accentColor ?? colors.primary;
    final eventColor = widget.eventIndicatorColor ?? accent;
    final textColor = widget.foregroundColor ?? colors.onSurface;
    final selectedTextColor = widget.selectedTextColor ?? colors.onPrimary;
    final eventKeys = widget.eventDates.map(_dateKey).toSet();
    final firstWeekdayIndex = switch (widget.startWeekOnMonday) {
      true => 1,
      false => 0,
      null => localizations.firstDayOfWeekIndex,
    };
    final firstCell = _firstGridDate(firstWeekdayIndex);
    final sundayFirstWeekdays = widget.weekdayNames == null
        ? localizations.narrowWeekdays
        : <String>[widget.weekdayNames!.last, ...widget.weekdayNames!.take(6)];
    final weekdays = List<String>.generate(
      DateTime.daysPerWeek,
      (index) =>
          sundayFirstWeekdays[(firstWeekdayIndex + index) %
              DateTime.daysPerWeek],
    );
    final monthTitle = widget.monthNames == null
        ? localizations.formatMonthYear(_visibleMonth)
        : '${widget.monthNames![_visibleMonth.month - 1]} ${_visibleMonth.year}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Material(
          color: widget.backgroundColor ?? colors.surface,
          elevation: 2,
          shadowColor: colors.shadow.withAlpha(60),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            side: BorderSide(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CalendarHeader(
                  title: monthTitle,
                  accentColor: accent,
                  textColor: textColor,
                  previousMonthTooltip: localizations.previousMonthTooltip,
                  nextMonthTooltip: localizations.nextMonthTooltip,
                  canGoBack: _canNavigate(-1),
                  canGoForward: _canNavigate(1),
                  onBack: () => _changeMonth(-1),
                  onForward: () => _changeMonth(1),
                ),
                const SizedBox(height: 8),
                Row(
                  children: weekdays
                      .map(
                        (label) => Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final date = DateTime(
                      firstCell.year,
                      firstCell.month,
                      firstCell.day + index,
                    );
                    final inMonth = date.month == _visibleMonth.month;
                    final isVisible = inMonth || widget.showAdjacentMonthDates;
                    if (!isVisible) return const SizedBox.shrink();
                    return _CalendarDay(
                      date: date,
                      isSelected: _sameDate(date, _selectedDate),
                      isToday: _sameDate(date, DateTime.now()),
                      isInMonth: inMonth,
                      isEnabled: _isEnabled(date),
                      hasEvent:
                          eventKeys.contains(_dateKey(date)) ||
                          (widget.hasEvent?.call(date) ?? false),
                      accentColor: accent,
                      eventColor: eventColor,
                      textColor: textColor,
                      selectedTextColor: selectedTextColor,
                      semanticLabel: localizations.formatFullDate(date),
                      onTap: () => _select(date),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _firstGridDate(int firstWeekdayIndex) {
    final first = _visibleMonth;
    final weekdayIndex = first.weekday % DateTime.daysPerWeek;
    final offset = (weekdayIndex - firstWeekdayIndex) % DateTime.daysPerWeek;
    return first.subtract(Duration(days: offset));
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.title,
    required this.accentColor,
    required this.textColor,
    required this.previousMonthTooltip,
    required this.nextMonthTooltip,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String title;
  final Color accentColor;
  final Color textColor;
  final String previousMonthTooltip;
  final String nextMonthTooltip;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      IconButton(
        tooltip: previousMonthTooltip,
        visualDensity: VisualDensity.compact,
        color: accentColor,
        onPressed: canGoBack ? onBack : null,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      IconButton(
        tooltip: nextMonthTooltip,
        visualDensity: VisualDensity.compact,
        color: accentColor,
        onPressed: canGoForward ? onForward : null,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isInMonth,
    required this.isEnabled,
    required this.hasEvent,
    required this.accentColor,
    required this.eventColor,
    required this.textColor,
    required this.selectedTextColor,
    required this.semanticLabel,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isInMonth;
  final bool isEnabled;
  final bool hasEvent;
  final Color accentColor;
  final Color eventColor;
  final Color textColor;
  final Color selectedTextColor;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? selectedTextColor
        : !isEnabled
        ? textColor.withAlpha(65)
        : isInMonth
        ? textColor
        : textColor.withAlpha(130);

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          key: ValueKey<String>('calendar-day-${_dateKey(date)}'),
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? accentColor : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: accentColor.withAlpha(150))
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                if (hasEvent)
                  Positioned(
                    bottom: 5,
                    child: DecoratedBox(
                      key: ValueKey<String>('calendar-event-${_dateKey(date)}'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? selectedTextColor : eventColor,
                      ),
                      child: const SizedBox.square(dimension: 4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime? _dateOnlyOrNull(DateTime? date) =>
    date == null ? null : DateTime(date.year, date.month, date.day);

DateTime? _monthOnly(DateTime? date) =>
    date == null ? null : DateTime(date.year, date.month);

bool _sameDate(DateTime date, DateTime? other) =>
    other != null &&
    date.year == other.year &&
    date.month == other.month &&
    date.day == other.day;

bool _sameNullableDate(DateTime? first, DateTime? second) =>
    first == null && second == null ||
    first != null && second != null && _sameDate(first, second);

int _dateKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;
