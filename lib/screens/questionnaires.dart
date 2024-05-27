import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:questionnaires/factory/get_questionnaires.dart';
import 'package:questionnaires/provider/locale_provider.dart';
import 'package:questionnaires/screens/license.dart';
import 'package:questionnaires/util/colors.dart';
import 'package:questionnaires/util/images.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import '../util/const_url.dart';
import 'nullQestionariesList.dart';
import 'question_screen.dart';

class Questionnaires extends StatefulWidget {
  const Questionnaires({super.key});

  @override
  State<StatefulWidget> createState() => _Questionnaires();
}

class _Questionnaires extends State<Questionnaires> {
  late List<GetQuestionnaires> questionnaires;
  late Timer _timer;
  int countChestionar = 0;
  bool hasError = false;
  String? errorMessage;
  bool isLoading = true;
  bool isItemVisible = true; // Состояние видимости элемента списка
  final ScrollController _scrollController = ScrollController();
  late String deviceNameNow;
  final double _itemHeight = 100.0; // Высота элемента списка

  @override
  void initState() {
    super.initState();
    questionnaires = [];
    _scrollController.addListener(_scrollListener);
    _startTimer();
    deviceNameNow = '';
    _initializeData();
    fetchQuestionnaires();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _timer.cancel(); // Не забудьте отменить таймер при уничтожении виджета
    super.dispose();
  }

  Future<void> _initializeData() async {
    String name = await getDeviceName();
    setState(() {
      deviceNameNow = name;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Вызываем ваш метод fetchQuestionnaires каждые 60 секунд
      fetchQuestionnaires();
    });
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

  Future<String> getDeviceName() async {
    var shered = await SecureSharedPref.getInstance();
    String deviceName = await shered.getString("deviceID") ?? '';
    return deviceName;
  }
  DropdownMenuItem<String> _buildDropdownMenuItem(String value, String text, String imagePath) {
    return DropdownMenuItem(
      alignment: Alignment.center,
      value: value,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(imagePath, fit: BoxFit.fill),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontFamily: 'RobotoRegular',
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const Divider(color: birderDropDown),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LocaleProvider>(context);
    final currentLanguageCode = languageProvider.currentLanguageCode;
    sortQuestionnairesByIndex(questionnaires, currentLanguageCode);
  //  List<String> filteredQuestionnaires = getFilteredQuestionnairesWithFallback(currentLanguageCode);
  //  int questionnairesCount = filteredQuestionnaires.length;
    return Scaffold(
        appBar: AppBar(actions: [
          DropdownButton(
            underline: Container(),
            padding: const EdgeInsets.only(right: 56),
            elevation: 0,
            icon: Image.asset('assets/images/drop_down.png', fit: BoxFit.fill),
            hint: Padding(
              padding: const EdgeInsets.only(right: 23),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(_currentFluf(currentLanguageCode), fit: BoxFit.fill),
                  const SizedBox(width: 23),
                  Text(
                    returnDropdownButton(currentLanguageCode),
                    style: const TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontFamily: 'RobotoRegular',
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            items: [
              _buildDropdownMenuItem('RO', 'Română', 'assets/images/ro.png'),
              _buildDropdownMenuItem('RU', 'Русский', 'assets/images/ru.png'),
              _buildDropdownMenuItem('EN', 'English', 'assets/images/en.png'),
              DropdownMenuItem(
                alignment: Alignment.topLeft,
                value: 'RO',
                child: Text(
                  deviceNameNow,
                  style: const TextStyle(
                      color: textDropDown,
                      fontSize: 14,
                      fontFamily: 'RobotoRegular',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
            onChanged: (String? newLanguageCode) {
              if (newLanguageCode != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  languageProvider.changeLanguage(newLanguageCode);
                });
              }
            },
          ),
        ]),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: questionsGroupColor),
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
                                    errorMessageText(currentLanguageCode),
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      child:getFilteredQuestionnaires(currentLanguageCode).isEmpty || returnLanguage(currentLanguageCode).isEmpty
                          ? NullQestionariesList(language: currentLanguageCode,)
                          : LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            return Scrollbar(
                              thickness: 5,
                              radius: Radius.circular(2),
                              interactive: true,
                              trackVisibility: true,
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                final screenHeight = constraints.maxHeight;
                                const itemHeight = 100.0;
                                final filteredQuestionnaires = getFilteredQuestionnaires(currentLanguageCode);
                                final itemCount = (screenHeight / itemHeight).floor().clamp(0, filteredQuestionnaires.length);
                                return Padding(padding: EdgeInsets.only(top: 48),
                                    child:  ListView.builder(
                                      itemExtent: 86,
                                      controller: _scrollController,
                                      shrinkWrap: true, // Добавляем shrinkWrap: true
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: returnLanguage(currentLanguageCode).length,
                                      itemBuilder: (context, index) {
                                        int originalIndex = questionnaires.indexWhere((questions) {
                                          String nameJson = questions.name;
                                          if (nameJson != null) {
                                            Map<String, dynamic> nameMap = jsonDecode(nameJson);
                                            return nameMap[currentLanguageCode] == returnLanguage(currentLanguageCode).length;
                                          }
                                          return false;
                                        });
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 32, right: 32, bottom: 16),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          QuestionScreen(
                                                              oid: questionnaires[index].oid,
                                                              language: currentLanguageCode)));
                                              },
                                            child: Container(
                                                transformAlignment:
                                                Alignment.centerLeft,
                                                alignment: Alignment.centerLeft,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(6.0),
                                                    color: const Color.fromRGBO(55, 170, 15, 1),
                                                    border: Border.all(color: Colors.white)),
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
                                        },));
                              }),
                            );
                          }
                          ),
                    )
                  ],)
        )
    );
  }

//  List<String> getFilteredQuestionnairesWithFallback(String currentLanguageCode) {
//    var filteredQuestionnaires = getFilteredQuestionnaires(currentLanguageCode);
//    if (filteredQuestionnaires.isEmpty) {
//      // Если данных нет для текущего языка, переключаемся на 'RU'
//      currentLanguageCode = 'RU';
//      filteredQuestionnaires = getFilteredQuestionnaires(currentLanguageCode);
//      if (filteredQuestionnaires.isEmpty) {
//        // Если данных нет для 'RU', переключаемся на 'EN'
//        currentLanguageCode = 'EN';
//        filteredQuestionnaires = getFilteredQuestionnaires(currentLanguageCode);
//      }
//    }
//    return filteredQuestionnaires;
//  }


  void _scrollListener() {
    final double topEdge = _scrollController.offset;
    final double bottomEdge =
        _scrollController.offset + MediaQuery.of(context).size.height;

    // Вычисляем индексы первого и последнего элементов, видимых на экране
    final int firstVisibleIndex = (topEdge / _itemHeight).floor();
    final int lastVisibleIndex = (bottomEdge / _itemHeight).ceil();

    // Обновляем состояние, чтобы перерисовать виджет
    setState(() {
      // Теперь вы можете использовать firstVisibleIndex и lastVisibleIndex для скрытия элементов в вашем списке
      // Например, можно хранить список видимых индексов в состоянии и использовать его для отображения элементов
      if (topEdge > 0 || bottomEdge < lastVisibleIndex) {
        isItemVisible = false;
      } else {
        isItemVisible = true;
      }
    });
  }

  Future<void> fetchQuestionnaires() async {
    var shered = await SecureSharedPref.getInstance();
    String license = await shered.getString("licenseID") ?? '';
    print(license);
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await http.get(Uri.parse(urlQestionaries + license),
        headers: <String, String>{'authorization': basicAuth});
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseDate = json.decode(response.body);
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
    }
  }
  void sortQuestionnairesByIndex(List<GetQuestionnaires> questionnaires, String localeCode) {
    questionnaires.sort((a, b) {
      String nameJsonA = a.name;
      String nameJsonB = b.name;
      if (nameJsonA != null && nameJsonB != null) {
        Map<String, dynamic> nameMapA = jsonDecode(nameJsonA);
        Map<String, dynamic> nameMapB = jsonDecode(nameJsonB);
        String nameA = nameMapA[localeCode] ?? '';
        String nameB = nameMapB[localeCode] ?? '';
        return nameA.compareTo(nameB);
      }
      return 0;
    });
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
      Map<String, dynamic>? nameMap = jsonDecode(nameJson); // Обратите внимание на "?"
      if (nameMap != null && (nameMap.containsKey(localeCod) || nameMap[localeCod] != null)) {
        String? languageName = nameMap[localeCod]; // Обратите внимание на "?"
        if (languageName != null) { // Проверяем, что languageName не равен null
          languageNames.add(languageName);
        }
      }
    }
    return languageNames;
  }



  String returnTitle(String localeCod) {
    String enName = 'Questionnaires';
    String roName = 'Chestionare';
    String ruName = 'Опросники';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
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

  String errorMessageText(String localeCod) {
    String enName =
        'The questionnaire is not ready yet, but we are actively working on it. It will be available for filling out soon. Thank you for your understanding!';
    String roName =
        'Questionarul nu este încă pregătit, dar lucrăm activ la el. În curând va fi disponibil pentru completare. Mulțumim pentru înțelegere!';
    String ruName =
        'Опросник еще не готов, но мы активно работаем над ним. Скоро будет доступен для заполнения. Спасибо за понимание!';
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
