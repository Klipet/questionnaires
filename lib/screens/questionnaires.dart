import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:questionnaires/factory/get_questionnaires.dart';
import 'package:questionnaires/provider/locale_provider.dart';
import 'package:questionnaires/util/colors.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../model/language_model.dart';

class Questionnaires extends StatefulWidget {
  const Questionnaires({super.key});

  @override
  State<StatefulWidget> createState() => _Questionnaires();
}

class _Questionnaires extends State<Questionnaires> {
  late List<GetQuestionnaires> questionnaires;
  LanguageModel? _choseValue;
  List<LanguageModel> _languages = List.empty(growable: true);
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
    return Scaffold(
        appBar: AppBar(
          actions: [
            DropdownButton<LanguageModel>(
              items: _languages
                  .map<DropdownMenuItem<LanguageModel>>((LanguageModel value) {
                return DropdownMenuItem<LanguageModel>(
                  value: value,
                  child: Text(
                    value.name!,
                  ),
                );
              }).toList(),
              hint: Text(
                AppLocalizations.of(context)!.hintDropDawn,
              ),
              onChanged: (LanguageModel? newValue) {
                setState(() {
                  _choseValue = newValue;
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(Locale(newValue!.code!));
                });
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [hasError ?  Center(
                      child: Column(children: [
                        const SizedBox(height: 90),
                        Image.asset(
                          'assets/images/error_empty.png',
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
                        : Text(
                            AppLocalizations.of(context)!.appTitle,
                            style: const TextStyle(
                              fontSize: 48,
                              fontFamily: 'RobotoBlack',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: ListView.builder(
                        itemCount: questionnaires.length,
                        itemBuilder: (context, index) {
                          final questionnaire = questionnaires[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 32, right: 32, bottom: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/question',
                                  arguments: {'oid': questionnaires[index].oid},
                                );
                              },
                              child: Container(
                                transformAlignment: Alignment.centerLeft,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: const Color.fromRGBO(55, 170, 15, 1),
                                    border: Border.all(color: Colors.white)),
                                height: 70,
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  questionnaire.name,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontFamily: 'RobotoRegular',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ));
  }

  void handleError() {
    // Обработка ошибки
    setState(() {
      hasError = true;
      errorMessage = AppLocalizations.of(context)!.textErrorQuestions;
    });
  }

  Future<void> fetchQuestionnaires() async {
    try {
      var shered = await SecureSharedPref.getInstance();
      var license = await shered.getString("licenseID");
      const String username = 'uSr_nps';
      const String password = "V8-}W31S!l'D";
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));
      final response = await http.get(
          Uri.parse(
              'https://dev.edi.md/ISNPSAPI/Mobile/GetQuestionnaires?LicenseID=$license'),
          headers: <String, String>{'authorization': basicAuth});
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseDate = json.decode(response.body);
        setState(() {});
        questionnaires = parseQuestionnaires(responseDate);
        int errorCode = responseDate['errorCode'] as int;
        if(questionnaires.isEmpty){
          handleError();
        }else if(errorCode == 165){
          handleError();
        }
      } else {
        throw Exception('Failed to load questionnaires');
      }
    } catch (error) {
      print('Error fetching data: $error');
      handleError();
    }
    setState(() {
      isLoading = false;
    });
  }
}

List<GetQuestionnaires> parseQuestionnaires(Map<String, dynamic> responseData) {
  final List<dynamic> questionnairesJson = responseData['questionnaires'];
  return questionnairesJson
      .map((json) => GetQuestionnaires.fromJson(json))
      .toList();
}
