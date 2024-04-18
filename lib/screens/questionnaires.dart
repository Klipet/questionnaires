import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:questionnaires/factory/get_questionnaires.dart';
import 'package:questionnaires/provider/locale_provider.dart';
import 'package:questionnaires/screens/license.dart';
import 'package:questionnaires/util/colors.dart';
import 'package:questionnaires/util/images.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../model/language_model.dart';
import '../util/const_url.dart';

class Questionnaires extends StatefulWidget {
  const Questionnaires({super.key});

  @override
  State<StatefulWidget> createState() => _Questionnaires();
}

class _Questionnaires extends State<Questionnaires> {
  late List<GetQuestionnaires> questionnaires;
  LanguageModel? _choseValue;
  final List<LanguageModel> _languages = List.empty(growable: true);
  late Timer _timer;
  bool hasError = false;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    questionnaires = [];
    _startTimer();
    fetchQuestionnaires();
    _languages.add(LanguageModel(code: 'ro', name: 'Romana'));
    _languages.add(LanguageModel(code: 'ru', name: 'Русскии'));
    _languages.add(LanguageModel(code: 'en', name: 'English'));
  }

  @override
  void dispose() {
    _timer.cancel(); // Не забудьте отменить таймер при уничтожении виджета
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Вызываем ваш метод fetchQuestionnaires каждые 60 секунд
      fetchQuestionnaires();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LocaleProvider>(context);
    final currentLanguageCode = languageProvider.currentLanguageCode;
    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton(
              hint: const Text('Language'),
              items: const [
                DropdownMenuItem(
                  value: 'RO',
                  child: Text('Romanian'),
                ),
                DropdownMenuItem(
                  value: 'RU',
                  child: Text('Russian'),
                ),
                DropdownMenuItem(
                  value: 'EN',
                  child: Text('English'),
                ),
              ],
              onChanged: (String? newLanguageCode) {
                if (newLanguageCode != null) {
                  languageProvider.changeLanguage(newLanguageCode);
                }
              }
              //   items: _languages
              //       .map<DropdownMenuItem<LanguageModel>>((LanguageModel value) {
              //     return DropdownMenuItem<LanguageModel>(
              //       value: value,
              //       child: Text(
              //         value.name!,
              //       ),
              //     );
              //   }).toList(),
              //   hint: Text(
              //     AppLocalizations.of(context)!.hintDropDawn,
              //   ),
              //   onChanged: (LanguageModel? newValue) {
              //     setState(() {
              //       returnLanguage();
              //       _choseValue = newValue;
              //       Provider.of<LocaleProvider>(context, listen: false)
              //           .setLocale(Locale(newValue!.code!));
              //     });
              //   },
              ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.only(top: 10),
              child: hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 90),
                                Image.asset(
                                  emptyImage,
                                  // Путь к вашей картинке
                                  fit: BoxFit.fill,
                                ),
                                const SizedBox(height: 80),
                                Text(
                                  AppLocalizations.of(context)!
                                      .textErrorQuestions,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: 25,
                                      fontFamily: 'RobotoBlack',
                                      fontWeight: FontWeight.w200),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          returnTitle(currentLanguageCode),
                          //AppLocalizations.of(context)!.appTitle,
                          style: const TextStyle(
                            fontSize: 48,
                            fontFamily: 'RobotoBlack',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(top: 48),
                                child: LayoutBuilder(builder:
                                    (BuildContext context,
                                        BoxConstraints constraints) {
                                  double availableHeight = constraints.maxHeight;
                                  double elementHeight = 70.0 + 16.0;
                                  int numberOfElements = (availableHeight / elementHeight).floor();
                                  return ListView.builder(
                                    itemCount: getFilteredQuestionnaires(currentLanguageCode).length > numberOfElements
                                        ? numberOfElements
                                        : currentLanguageCode.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32, right: 32, bottom: 16),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/question',
                                              arguments: {
                                                'oid':
                                                    questionnaires[index].oid,
                                              },
                                            );
                                          },
                                          child: Container(
                                              transformAlignment:
                                                  Alignment.centerLeft,
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  color: const Color.fromRGBO(
                                                      55, 170, 15, 1),
                                                  border: Border.all(
                                                      color: Colors.white)),
                                              height: 70,
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                returnLanguage(currentLanguageCode)[index],
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontFamily: 'RobotoRegular',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )),
                                        ),
                                      );
                                    },
                                  );
                                }))),
                      ],
                    )),
    );
  }

  Future<void> fetchQuestionnaires() async {
    var shered = await SecureSharedPref.getInstance();
    var license = await shered.getString("licenseID");
    const String username = 'uSr_nps';
    const String password = "V8-}W31S!l'D";
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await http.get(Uri.parse(urlQestionaries + license!),
        headers: <String, String>{'authorization': basicAuth});
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseDate = json.decode(response.body);
      setState(() {});
      if (responseDate['questionnaires'] != null) {
        questionnaires = parseQuestionnaires(responseDate);
        hasError = false;
        int errorCode = responseDate['errorCode'] as int;
        if (questionnaires.isEmpty) {
          hasError = true;
        } else if (errorCode == 165) {
          hasError = true;
        } else if (errorCode == 124) {
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const License()),
                  (route) => false);
        } else if (responseDate == null) {
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const License()),
              (route) => false);
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const License()),
                (route) => false);
      }
      setState(() {
        isLoading = false;
      });
    } else {

    }
  }
  List<GetQuestionnaires> getFilteredQuestionnaires(String localeCode) {
    // Фильтруйте `questionnaires` так, чтобы включить только те опросники, у которых есть название на выбранном языке
    return questionnaires.where((questionnaire) {
      // Разбираем JSON и проверяем наличие названия на выбранном языке
      Map<String, dynamic> nameMap = jsonDecode(questionnaire.name);
      // Возвращаем true, если есть название на выбранном языке и оно не равно null
      return nameMap.containsKey(localeCode) && nameMap[localeCode] != null;
    }).toList();
  }

  List<String> returnLanguage(String localeCod) {
    List<String> languageNames = [];
    for (GetQuestionnaires questions in questionnaires) {
      String nameJson = questions.name;
      Map<String, dynamic> nameMap = jsonDecode(nameJson);
      if (nameMap.containsKey(localeCod)) {
        String languageName = nameMap[localeCod];
        if(languageName.isEmpty){
          languageNames.removeLast();
        }else{
          languageNames.add(languageName);
        }
      }
    }
    return languageNames;
  }

  String returnTitle(String localeCod) {
    String enName = 'Questionnaires';
    String roName = 'Chestionare';
    String ruName = 'Опросник';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
}

List<GetQuestionnaires> parseQuestionnaires(Map<String, dynamic> responseData) {
  final List<dynamic> questionnairesJson = responseData['questionnaires'];
  return questionnairesJson
      .map((json) => GetQuestionnaires.fromJson(json))
      .toList();
}
