import 'dart:convert';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/util/colors.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';

class License extends StatefulWidget {
  const License({super.key});

  @override
  State<StatefulWidget> createState() => _License();
}

class _License extends State<License> {
  bool forceError = false;


  PinTheme errorTheme = PinTheme(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(3),
    ),
  );

  final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: textColor),
        borderRadius: BorderRadius.circular(3),
      ));


  void putLicenseID(String license) async {
    var pref = await SecureSharedPref.getInstance();
    pref.putString('licenseID', license);
    String? savedLicense = await pref.getString('licenseID');
    if (savedLicense != null) {
      // Лицензия сохранена
      print('Лицензия сохранена: $savedLicense');
    } else {
      // Лицензия не сохранена
      print('Лицензия не сохранена');
    }

  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 64),
              const Text(
                'Activare licență',
                style: TextStyle(
                  fontFamily: 'RobotoBlack',
                  fontSize: 48,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Introduceți licența din 9 cifre',
                style: TextStyle(
                  fontFamily: 'RobotoRegular',
                  fontSize: 32,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 9,
                errorPinTheme: errorTheme,
                defaultPinTheme: defaultPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: false,
                onCompleted: (code) => getLicenseStatus(context, code),
                forceErrorState: forceError,
              ),
            ],
          )
        ],
      ),
    );
  }
  void getLicenseStatus(BuildContext context, String code) async {
    try {
      const String username = 'uSr_nps';
      const String password = "V8-}W31S!l'D";
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));
      var getResponse = await http.get( Uri.parse(
          urlActivate + code),
          headers: <String, String>{ 'authorization': basicAuth});
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> responseDate = json.decode(getResponse.body);
        int errorCode = responseDate['errorCode'] as int;
        if (errorCode == 0) {
          String licenseID = responseDate['id'] as String;
          String nameLicense = responseDate['name'] as String;
          putLicenseID(licenseID);
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Questionnaires()),
                  (route) => false);
        } else {
          setState(() {
            forceError = true;
            errorTheme = PinTheme(
              width: 56,
              height: 56,
              textStyle: const TextStyle(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: FontWeight.w600),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          });
        }
      } else {
        setState(() {
          forceError = true;
          errorTheme = PinTheme(
            width: 56,
            height: 56,
            textStyle: const TextStyle(
                fontSize: 20,
                color: textColor,
                fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        });
      }
    } catch (e) {
      print('Error in getLicenseStatus: $e');
    }
  }

}
