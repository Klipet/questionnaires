import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:questionnaires/screens/license.dart';
import '../factory/get_questionnaires.dart';
import '../provider/locale_provider.dart';
import 'error_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _Splash();
}

class _Splash extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<GetQuestionnaires> questionnaires;

  @override
  void initState() {
    super.initState();
    questionnaires = [];
    // Убираем системные оверлеи для полного экрана
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // Инициализация анимационного контроллера
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      reverseDuration: const Duration(seconds: 10),
      vsync: this,
    );
    // Удаляем сплэш-экран плагина
    initialization();
  }

  void initialization() async {
    build(context);
    FlutterNativeSplash.remove();
  }

  Future<void> getLicenseStatus(BuildContext context) async {
    try {
      final languageProvider = Provider.of<LocaleProvider>(context, listen: false);
      var shered = await SecureSharedPref.getInstance();
      String license = await shered.getString("licenseID") ?? 'Non';
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      var getResponse = await http.get(
        Uri.parse(urlQestionaries + license),
        headers: <String, String>{'authorization': basicAuth},
      );
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> responseDate = json.decode(getResponse.body);
        int errorCode = responseDate['errorCode'] as int;

        // Обработка ответа сервера и переход на соответствующие экраны
        if (errorCode == 0 || errorCode == 165) {
          if(responseDate['questionnaires'] != null){
            questionnaires = parseQuestionnaires(responseDate);
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Questionnaires()), (route) => false,);
        }
        } else if (errorCode == 400 || errorCode == 124) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const License()),
                (route) => false,
          );
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const License()),
              (route) => false,
        );
      }
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const License()),
            (route) => false,
      );
      print('Error Splash: $e');
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/start_animation.json',
          reverse: true,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() => getLicenseStatus(context));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}