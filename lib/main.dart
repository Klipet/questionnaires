import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:questionnaires/l10n/supported_localization.dart';
import 'package:questionnaires/provider/locale_provider.dart';
import 'package:questionnaires/screens/license.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/screens/splash_page.dart';
import 'package:page_transition/page_transition.dart' show PageTransitionType;
import 'anmation/amination_image.dart';
import 'screens/question_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ChangeNotifierProvider<LocaleProvider>(
    create: (context) => LocaleProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, appStare, child) {
      return MaterialApp(
        routes: {
          '/questionaries':(context) => const Questionnaires(),
          '/question': (context) => const QuestionScreen(),
        },
        locale: Provider.of<LocaleProvider>(context).locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
          supportedLocales: L10n.support,
          showSemanticsDebugger: false,
          home: AnimatedSplashScreen(
            duration: 3000,
            backgroundColor: Colors.orange,
            splash: Image.asset('assets/images/startScreen.png', fit: BoxFit.fill,),
            nextScreen:  const Splash(),
            splashTransition: SplashTransition.scaleTransition,
        )
      );
    });
  }
}


