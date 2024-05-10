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
import 'package:transformable_list_view/transformable_list_view.dart';
import '../util/const_url.dart';
import 'question_screen.dart';

class Questionnaires extends StatefulWidget {
  const Questionnaires({super.key});

  @override
  State<StatefulWidget> createState() => _Questionnaires();
}

class _Questionnaires extends State<Questionnaires> {
  late List<GetQuestionnaires> questionnaires;
  late Timer _timer;
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LocaleProvider>(context);
    final currentLanguageCode = languageProvider.currentLanguageCode;
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
                  Image.asset(_currentFluf(currentLanguageCode),
                      fit: BoxFit.fill),
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
              DropdownMenuItem(
                  alignment: Alignment.center,
                  value: 'RO',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/ro.png', fit: BoxFit.fill),
                          const SizedBox(width: 16),
                          const Text('Română',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const Divider(
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
                          Image.asset('assets/images/ru.png', fit: BoxFit.fill),
                          const SizedBox(width: 16),
                          const Text('Русский',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                      const Divider(
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
                          Image.asset('assets/images/en.png', fit: BoxFit.fill),
                          const SizedBox(width: 16),
                          const Text('English',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'RobotoRegular',
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const Divider(
                        color: birderDropDown,
                      )
                    ],
                  )),
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
                languageProvider.changeLanguage(newLanguageCode);
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
                                  child: TransformableListView.builder(
                                    getTransformMatrix: getTransformMatrix,
                                    itemBuilder: (context, index) {
                                      return Scrollbar(
                                          thickness: 5,
                                          child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        QuestionScreen(
                                                            oid: questionnaires[
                                                                    index]
                                                                .oid,
                                                            language:
                                                                currentLanguageCode)));
                                          },
                                          child: Container(
                                              height: 80,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: index.isEven
                                                    ? questionsGroupColor
                                                    : questionsGroupColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 16),
                                                child: Text(
                                                  returnLanguage(
                                                      currentLanguageCode)[index],
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 32,
                                                    fontFamily: 'RobotoRegular',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ), )
                                      ));
                                    },
                                    itemCount: getFilteredQuestionnaires(
                                            currentLanguageCode)
                                        .length,
                                  )
                              )
                            )

                                  //  LayoutBuilder(builder:
                                  //      (BuildContext context,
                                  //          BoxConstraints constraints) {
                                  //    double availableHeight = constraints.maxHeight;
                                  //    double elementHeight = 8 * (70.0 + 16.0);
                                  //    int numberOfElements = (availableHeight /
                                  //            getFilteredQuestionnaires(
                                  //                    currentLanguageCode)
                                  //                .length)
                                  //        .floor();
                                  //    return
                                  //  Scrollbar(
                                  //    thickness: 5,
                                  //      radius: Radius.circular(2),
                                  //      interactive: true,
                                  //      trackVisibility: true,
                                  //      thumbVisibility: true,
                                  //    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                  //      final screenHeight = constraints.maxHeight;
                                  //      const itemHeight = 100.0;
                                  //      final filteredQuestionnaires = getFilteredQuestionnaires(currentLanguageCode);
                                  //      final itemCount = (screenHeight / itemHeight).floor().clamp(0, filteredQuestionnaires.length);
                                  //      return ListView.builder(
                                  //        itemExtent: 86,
                                  //        controller: _scrollController,
                                  //        shrinkWrap: true, // Добавляем shrinkWrap: true
                                  //        physics: const AlwaysScrollableScrollPhysics(),
                                  //        itemCount: getFilteredQuestionnaires(currentLanguageCode).length,
                                  //        //getFilteredQuestionnaires(currentLanguageCode).length,
                                  //
                                  //        //getFilteredQuestionnaires(currentLanguageCode).length,
                                  //        // numberOfElements
                                  //        // ? numberOfElements
                                  //        // : currentLanguageCode.length,
                                  //        itemBuilder: (context, index) {
                                  //          final realIndex = index % filteredQuestionnaires.length;
                                  //          getFilteredQuestionnaires(
                                  //              currentLanguageCode)
                                  //              .sort((a, b) => a.compareTo(b));
                                  //          return Padding(
                                  //            padding: const EdgeInsets.only(
                                  //                left: 32, right: 32, bottom: 16),
                                  //            child: InkWell(
                                  //              onTap: () {
                                  //                Navigator.of(context).push(
                                  //                    MaterialPageRoute(
                                  //                        builder: (context) =>
                                  //                            QuestionScreen(
                                  //                                oid: questionnaires[
                                  //                                realIndex]
                                  //                                    .oid,
                                  //                                language:
                                  //                                currentLanguageCode)));
                                  //              },
                                  //              child: Container(
                                  //                  transformAlignment:
                                  //                  Alignment.centerLeft,
                                  //                  alignment: Alignment.centerLeft,
                                  //                  decoration: BoxDecoration(
                                  //                      borderRadius:
                                  //                      BorderRadius.circular(6.0),
                                  //                      color: const Color.fromRGBO(
                                  //                          55, 170, 15, 1),
                                  //                      border: Border.all(
                                  //                          color: Colors.white)),
                                  //                  height: 70,
                                  //                  padding: const EdgeInsets.all(10),
                                  //                  child: Text(
                                  //                    returnLanguage(
                                  //                        currentLanguageCode)[index],
                                  //                    textAlign: TextAlign.left,
                                  //                    style: const TextStyle(
                                  //                      color: Colors.white,
                                  //                      fontSize: 32,
                                  //                      fontFamily: 'RobotoRegular',
                                  //                      fontWeight: FontWeight.w400,
                                  //                    ),
                                  //                  )),
                                  //            ),
                                  //          );
                                  //        },);
                                  //    }),
                                  //    )
                                  //);
                                  // }
                          ]),
              ));
  }

  Matrix4 getTransformMatrix(TransformableListItem item) {
    /// final scale of child when the animation is completed
    const endScaleBound = 0.3;

    /// 0 when animation completed and [scale] == [endScaleBound]
    /// 1 when animation starts and [scale] == 1
    final animationProgress = item.visibleExtent / item.size.height;

    /// result matrix
    final paintTransform = Matrix4.identity();

    /// animate only if item is on edge
    if (item.position != TransformableListItemPosition.middle) {
      final scale = endScaleBound + ((1 - endScaleBound) * animationProgress);

      paintTransform
        ..translate(item.size.width / 2)
        ..scale(scale)
        ..translate(-item.size.width / 2);
    }

    return paintTransform;
  }

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

  List<String> getFilteredQuestionnaires(String localeCode) {
    List<String> qestion = [];
    for (GetQuestionnaires questions in questionnaires) {
      String nameJson = questions.name;
      if (nameJson != null) {
        Map<String, dynamic> nameMap = jsonDecode(nameJson);
        if (nameMap.containsKey(localeCode) && nameMap[localeCode] != null) {
          qestion.add(nameMap[localeCode]);
        }
      }
    }
    return qestion;

    //  // Фильтруйте `questionnaires` так, чтобы включить только те опросники, у которых есть название на выбранном языке
    //  return questionnaires.where((questionnaire) {
    //    // Разбираем JSON и проверяем наличие названия на выбранном языке
    //    Map<String, dynamic> nameMap = jsonDecode(questionnaire.name);
    //    if (nameMap.containsKey(localeCode)){
    //      var name = nameMap[localeCode];
    //      qestion.add(nameMap[localeCode]);
    //    }
    //    // Возвращаем true, если есть название на выбранном языке и оно не равно null
    //    return nameMap.containsKey(localeCode) && nameMap[localeCode] != null;
    //  }).toList();
  }

  List<String> returnLanguage(String localeCod) {
    List<String> languageNames = [];
    for (GetQuestionnaires questions in questionnaires) {
      String nameJson = questions.name;

      // Проверяем, есть ли поле "name" в JSON-мапе
      if (nameJson != null && nameJson.isNotEmpty) {
        Map<String, dynamic> nameMap = jsonDecode(nameJson);

        // Проверяем, существует ли ключ localeCod в nameMap
        if (nameMap.containsKey(localeCod)) {
          String languageName = nameMap[localeCod];
          if (languageName.isEmpty) {
            languageNames.removeLast();
          } else {
            languageNames.add(languageName);
          }
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
