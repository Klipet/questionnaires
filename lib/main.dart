import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/l10n/supported_localization.dart';
import 'package:questionnaires/provider/locale_provider.dart';
import 'package:questionnaires/save_response/multe_ansver_vatinat.dart';
import 'package:questionnaires/save_response/yes_no_variant.dart';
import 'package:questionnaires/screens/license.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/screens/splash_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'provider/post_privider.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ChangeNotifierProvider(
    create: (context) => LocaleProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    requestWifiPermission();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ResponsePostProvider()),
        ChangeNotifierProvider(create: (context) => MulteAnsverVatinatResponse()),
        ChangeNotifierProvider(create: (context) => YesNoVariantResponse()),
      ],
      child:// Consumer<LocaleProvider>(
      //  builder: (context, localeProvider, child) {
         // return
      MaterialApp(
            routes: {
              '/questionaries': (context) => const Questionnaires(),
              '/license': (context) => const License(),
              // '/question': (context) => const QuestionScreen(),
            },
            locale:Locale(Provider.of<LocaleProvider>(context).currentLanguageCode), // Используем поле _currentLanguageCode
      localizationsDelegates: const [
              // Убедитесь, что у вас есть эти делегаты для локализации
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.support,
            showSemanticsDebugger: false,
            debugShowCheckedModeBanner: false,
            home: const Splash(), //Image.asset('assets/images/startScreen.png', fit: BoxFit.fill,),
      ));
        }
      //),

  }
  void requestWifiPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
  }



