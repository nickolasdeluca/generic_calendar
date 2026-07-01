import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:simple_calendar/simple_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

PreviewLocalizationsData ptBrLocalization() {
  return PreviewLocalizationsData(
    locale: const Locale('pt', 'BR'),
    supportedLocales: [const Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

@Preview(name: 'Simple Calendar', localizations: ptBrLocalization)
Widget ptBrLocalized() => SimpleCalendar();

PreviewLocalizationsData enUsLocalization() {
  return PreviewLocalizationsData(
    locale: const Locale('en', 'US'),
    supportedLocales: [const Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

@Preview(name: 'Simple Calendar', localizations: enUsLocalization)
Widget enUsLocalized() => SimpleCalendar();
