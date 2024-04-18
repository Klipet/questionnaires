

import 'package:flutter/material.dart';
import 'package:questionnaires/l10n/supported_localization.dart';

class LocaleProvider with ChangeNotifier{
 //  Locale _locale = Locale('ro');
 //  Locale get locale => _locale;
 //  void setLocale(Locale loc){
 //    if(!L10n.support.contains(loc)) return;
 //    _locale = loc;
 //    notifyListeners();
 //  }
 //  void clearLocale(){
 //    _locale = '' as Locale;
 //    notifyListeners();
 //  }
  String _currentLanguageCode = 'RO';

  String get currentLanguageCode => _currentLanguageCode;

  void changeLanguage(String newLanguageCode) {
    _currentLanguageCode = newLanguageCode;
    notifyListeners(); // Уведомляем подписчиков о смене языка
  }

}