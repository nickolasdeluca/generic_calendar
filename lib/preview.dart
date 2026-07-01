import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:generic_calendar/generic_calendar.dart';
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

@Preview(name: 'Generic Calendar (pt-BR)', localizations: ptBrLocalization)
Widget ptBrLocalized() => GenericCalendar();

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

@Preview(name: 'Generic Calendar (en-US)', localizations: enUsLocalization)
Widget enUsLocalized() => GenericCalendar();
