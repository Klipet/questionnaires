import 'dart:convert';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/util/colors.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';

import '../provider/locale_provider.dart';

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


  void putLicenseID(String license, String deviceName) async {
    var pref = await SecureSharedPref.getInstance();
    pref.putString('licenseID', license);
    pref.putString('deviceID', deviceName);
    String? savedLicense = await pref.getString('licenseID');
    if (savedLicense != null) {
      // Лицензия сохранена
      print('Лицензия сохранена: $savedLicense');
    } else {
      // Лицензия не сохранена
      print('Лицензия не сохранена');
    }

  }
  String _currentFluf(String currentLanguage) {
    String ru = 'assets/images/ru.png';
    String ro = 'assets/images/ro.png';
    String en = 'assets/images/en.png';
    if (currentLanguage == 'RO') {
      return ro;
    } else if (currentLanguage == 'RU') {
      return ru;
    } else {
      return en;
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
    final languageProvider = Provider.of<LocaleProvider>(context);
    final currentLanguageCode = languageProvider.currentLanguageCode;
    return Scaffold(
      appBar: AppBar(
          actions: [
            Padding(padding: const EdgeInsets.only(right: 56),
              child: DropdownButton(
                underline: Container(),

                elevation: 0,
                //padding: EdgeInsets.only(right: 20),
                icon: Image.asset('assets/images/drop_down.png',fit: BoxFit.fill),
                hint: Padding(
                  padding: const EdgeInsets.only(right: 23),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(_currentFluf(currentLanguageCode),
                          fit: BoxFit.fill),
                      const SizedBox(width: 23),
                      Text(returnDropdownButton(currentLanguageCode), style: const TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontFamily: 'RobotoRegular',
                          fontWeight: FontWeight.w400
                      ),),
                    ],
                  ),
                ),
                items: [
                  DropdownMenuItem(
                      alignment: Alignment.center,
                      value: 'RO',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset('assets/images/ro.png',
                                  fit: BoxFit.fill),
                              const SizedBox(width: 16),
                              const Text('Română', style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400)),
                            ],
                          ),
                          Divider(
                            color: birderDropDown,
                          )
                        ],
                      )),
                  DropdownMenuItem(
                      alignment: Alignment.center,
                      value: 'RU',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset('assets/images/ru.png',
                                  fit: BoxFit.fill),
                              const SizedBox(width: 16),
                              const Text('Русский',  style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400))
                            ],
                          ),
                          Divider(
                            color: birderDropDown,
                          )
                        ],
                      )),
                  DropdownMenuItem(
                      alignment: Alignment.center,
                      value: 'EN',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset('assets/images/en.png',
                                  fit: BoxFit.fill),
                              const SizedBox(width: 16),
                              const Text('English',  style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400)),
                            ],
                          ),
                          Divider(
                            color: birderDropDown,
                          )
                        ],
                      )),
                ],
                onChanged: (String? newLanguageCode) {
                  if (newLanguageCode != null) {
                    languageProvider.changeLanguage(newLanguageCode);
                  }
                },
              ),

            ),]),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //const SizedBox(height: 64),
               Text(
                returnTitle(currentLanguageCode),
                style: const TextStyle(
                  fontFamily: 'RobotoBlack',
                  fontSize: 48,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
               Text(
                returnMessage(currentLanguageCode),
                style: const TextStyle(
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
              const SizedBox(height: 64),
              forceError ? Text(
                  returnErrorMesage(currentLanguageCode),
                   style: const TextStyle(
                    fontFamily: 'RobotoRegular',
                    fontSize: 48,
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
              )
              ) : Container(),
            ],
          )
        ],
      ),
    );
  }
  void getLicenseStatus(BuildContext context, String code) async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      var getResponse = await http.get( Uri.parse(
          urlActivate + code),
          headers: <String, String>{ 'authorization': basicAuth});
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> responseDate = json.decode(getResponse.body);
        int errorCode = responseDate['errorCode'] as int;
        if (errorCode == 0) {
          String licenseID = responseDate['id'] as String;
          String nameLicense = responseDate['name'] as String;
          print(licenseID);
          putLicenseID(licenseID, nameLicense);
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
  String returnDropdownButton(String localeCod) {
    String enName = 'English';
    String roName = 'Română';
    String ruName = 'Русский';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnTitle(String localeCod) {
    String enName = 'License Activation';
    String roName = 'Activare licență';
    String ruName = 'Активация лицензии';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnMessage(String localeCod) {
    String enName = 'Enter the 9-digit license';
    String roName = 'Introduceți licența din 9 cifre';
    String ruName = 'Введите лицензию из 9 цифр';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnErrorMesage(String localeCod) {
    String enName = 'Activation code error';
    String roName = 'Eroare cod activare';
    String ruName = 'Ошибка кода активации';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

}
