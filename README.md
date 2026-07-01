# generic_calendar

A small, modern Flutter month calendar with date selection and event indicators.
It uses only Flutter's Material library and works on web, Android, iOS, Windows,
macOS, and Linux.

## Features

- Date selection through `onSelect`
- Optional selection callback for display-only calendars
- Event dots from an iterable of dates or a predicate
- Previous/next month navigation
- Optional first and last selectable dates
- Locale-aware month and weekday labels
- Locale-aware first day of the week, with Monday/Sunday overrides
- Custom colors and explicit label overrides
- Accessible semantics and responsive sizing
- Light and dark theme support

## Usage

```dart
import 'package:generic_calendar/generic_calendar.dart';

GenericCalendar(
  selectedDate: selectedDate,
  eventDates: [
    DateTime(2026, 7, 4),
    DateTime(2026, 7, 18),
  ],
  textColor: Colors.blueGrey,
  selectedTextColor: Colors.white,
  onSelect: (date) {
    setState(() => selectedDate = date);
    // Perform any additional action here.
  },
)
```

`onSelect` is optional. A display-only calendar can be created without a
callback:

```dart
GenericCalendar(
  eventDates: eventDates,
)
```

Time values in `selectedDate`, `eventDates`, and callback results are treated as
calendar dates. For data backed by a service, an event can also be resolved
dynamically:

```dart
GenericCalendar(
  onSelect: handleSelectedDate,
  hasEvent: (date) => eventDateKeys.contains(
    '${date.year}-${date.month}-${date.day}',
  ),
)
```

Use `firstDate` and `lastDate` to constrain selection. Use `monthNames` and
`weekdayNames` to override the locale-provided labels.

Use `textColor` for the month title, weekday labels, and date numbers. Use
`selectedTextColor` for text and the event dot inside the selected date.

## Localization

The calendar reads month names, weekday names, tooltips, date semantics, and
the first day of the week from your app's `MaterialLocalizations`:

```dart
MaterialApp(
  locale: const Locale('pt', 'BR'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [
    Locale('en'),
    Locale('pt', 'BR'),
  ],
  home: const MyHomePage(),
)
```

Import `package:flutter_localizations/flutter_localizations.dart` for
`GlobalMaterialLocalizations`. Set `startWeekOnMonday` only when you want to
override the locale convention.
