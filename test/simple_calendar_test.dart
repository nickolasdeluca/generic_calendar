import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generic_calendar/generic_calendar.dart';

void main() {
  Widget calendar({
    ValueChanged<DateTime>? onSelect,
    Iterable<DateTime> eventDates = const <DateTime>[],
    DateTime? firstDate,
    DateTime? lastDate,
  }) => MaterialApp(
    home: Scaffold(
      body: GenericCalendar(
        initialMonth: DateTime(2026, 6),
        onSelect: onSelect ?? (_) {},
        eventDates: eventDates,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ),
  );

  testWidgets('renders the requested month and weekday labels', (tester) async {
    await tester.pumpWidget(calendar());

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
  });

  testWidgets('uses the app locale for month and weekday labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('en'), Locale('pt', 'BR')],
        home: Scaffold(
          body: GenericCalendar(
            initialMonth: DateTime(2026, 6),
            onSelect: (_) {},
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(GenericCalendar));
    final localizations = MaterialLocalizations.of(context);
    expect(
      find.text(localizations.formatMonthYear(DateTime(2026, 6))),
      findsOneWidget,
    );
    expect(find.text(localizations.narrowWeekdays.first), findsOneWidget);
  });

  testWidgets('selecting a day invokes onSelect with a date-only value', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(calendar(onSelect: (date) => selected = date));

    await tester.tap(find.byKey(const ValueKey('calendar-day-20260615')));
    await tester.pump();

    expect(selected, DateTime(2026, 6, 15));
  });

  testWidgets('works without an onSelect callback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GenericCalendar(initialMonth: DateTime(2026, 6))),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-day-20260615')));
    await tester.pump();

    final dayText = tester.widget<Text>(find.text('15'));
    expect(dayText.style?.fontWeight, FontWeight.w700);
  });

  testWidgets('shows event indicators and ignores event time components', (
    tester,
  ) async {
    await tester.pumpWidget(
      calendar(eventDates: <DateTime>[DateTime(2026, 6, 8, 17, 30)]),
    );

    expect(
      find.byKey(const ValueKey('calendar-event-20260608')),
      findsOneWidget,
    );
  });

  testWidgets('applies custom normal and selected text colors', (tester) async {
    const normalColor = Colors.deepPurple;
    const selectedColor = Colors.amber;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenericCalendar(
            initialMonth: DateTime(2026, 6),
            selectedDate: DateTime(2026, 6, 15),
            foregroundColor: normalColor,
            selectedTextColor: selectedColor,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('June 2026')).style?.color,
      normalColor,
    );
    expect(tester.widget<Text>(find.text('15')).style?.color, selectedColor);
  });

  testWidgets('navigates between months', (tester) async {
    await tester.pumpWidget(calendar());

    await tester.tap(find.byTooltip('Next month'));
    await tester.pump();

    expect(find.text('July 2026'), findsOneWidget);
  });

  testWidgets('date bounds disable selection and month navigation', (
    tester,
  ) async {
    var selections = 0;
    await tester.pumpWidget(
      calendar(
        firstDate: DateTime(2026, 6, 10),
        lastDate: DateTime(2026, 6, 20),
        onSelect: (_) => selections++,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-day-20260609')));
    expect(selections, 0);
    final nextButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
    );
    expect(nextButton.onPressed, isNull);
  });
}
