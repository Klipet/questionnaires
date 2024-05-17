

import 'package:flutter/material.dart';


class LocaleProvider with ChangeNotifier{
  String _currentLanguageCode = 'RO';

  String get currentLanguageCode => _currentLanguageCode;

  void changeLanguage(String newLanguageCode) {
    _currentLanguageCode = newLanguageCode;
    notifyListeners(); // Уведомляем подписчиков о смене языка
  }

}