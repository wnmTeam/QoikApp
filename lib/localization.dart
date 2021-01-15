import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Languages{
  static String translate(BuildContext context,String key){
    return AppLocalization.of(context).translate(key);
  }
}


class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  static const LocalizationsDelegate<AppLocalization> delegate = _AppLocalizationDelegate();

  Map<String, String> _localizedString;

  Future load() async {
    String jsonSting =
        await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonSting);

    _localizedString = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String translate(String key) {
    return _localizedString[key];
  }

}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization>{

  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar','en'].contains(locale.languageCode);

  }

  @override
  Future<AppLocalization> load(Locale locale) async {

    AppLocalization localization = new AppLocalization(locale);
    await localization.load();
    return localization;

  }

  @override
    bool shouldReload(_AppLocalizationDelegate old)=>false;



}
