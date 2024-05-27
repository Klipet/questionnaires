import 'package:flutter/material.dart';


class LanguageDropdownButton extends StatelessWidget {
  final List<Locale> supportedLocales;
  final void Function(Locale) onLanguageChanged;

  const LanguageDropdownButton({super.key,
    required this.supportedLocales,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
 //     value: AppLocalizations.of(context)!!!,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          onLanguageChanged(newLocale);
        }
      },
      items: supportedLocales.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(locale.languageCode.toUpperCase()),
        );
      }).toList(),
    );
  }
}
