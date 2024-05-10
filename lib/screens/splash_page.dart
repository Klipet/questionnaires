import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import '../anmation/amination_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'license.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _Splash();
}

class _Splash extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        getLicenseStatus(context);
      }
    });
    initialization();
  }

  void initialization() async {
    build(context);
    FlutterNativeSplash.remove();
  }

  Future<void> getLicenseStatus(BuildContext context) async {
    try {
      var shered = await SecureSharedPref.getInstance();
      String license = await shered.getString("licenseID") ?? 'Non';
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      var getResponse = await http.get(
          Uri.parse(urlQestionaries + license),
          headers: <String, String>{'authorization': basicAuth});
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> responseDate =
        json.decode(getResponse.body);
        int errorCode = responseDate['errorCode'] as int;
        if (errorCode == 0 || errorCode == 165) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Questionnaires()),
                  (route) => false);
        } else if (errorCode == 400) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const License()),
                  (route) => false);
        } else if (errorCode == 124) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const License()),
                  (route) => false);
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const License()),
                (route) => false);
      }
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const License()),
              (route) => false);
      Fluttertoast.showToast(
          msg: 'Error: $e',
          backgroundColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.black, // цвет текста
          fontSize: 15.0);
    }
  }

  final List<String> images = [
    'assets/images/smile_love.png',
    'assets/images/smile_simpl.png',
    'assets/images/smile_of.png',
    'assets/images/smile_bad.png',
    'assets/images/smile_hangry.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 94, right: 94),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.map((image) {
              return FadeTransition(
                opacity: _animation,
                child: DelayedAnimation(
                  delay: Duration(seconds: images.indexOf(image)),
                  child: AnimatedImage(image: image),
                ),
              );
            }).toList(),
          ),
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