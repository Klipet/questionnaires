import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/provider/post_privider.dart';
import 'package:questionnaires/save_response/multe_ansver_vatinat.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import '../../factory/response_post.dart';
import '../../util/colors.dart';
import '../questionnaires.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MulteAnsverVatinat extends StatefulWidget {
  // const MulteAnsverVatinat({super.key});
  final String language;
  final int id;
  final int totalQuestionsCount;
  final Map<String, dynamic> qestion;
  final int index;

  final VoidCallback onPressed;
  final PageController onPressedController;

  const MulteAnsverVatinat(
      {super.key,
      required this.language,
      required this.id,
      required this.index,
      required this.qestion,
      required this.onPressed,
      required this.onPressedController, required this.totalQuestionsCount,});

  @override
  State<MulteAnsverVatinat> createState() => _MulteAnsverVatinatState();
}

class _MulteAnsverVatinatState extends State<MulteAnsverVatinat> {
  late List<bool> isCheckedList;
  late List<dynamic> responseChec;
  final ScrollController _scrollController = ScrollController();
  bool isItemVisible = true;

  @override
  void initState() {
    isCheckedList = List.generate(countColunm(), (index) => false);
    responseChec = [];
    _scrollController.addListener(_scrollListener);
    _loadSavedResponses();
    super.initState();
  }
  void _loadSavedResponses() {
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    List<int>? savedResponses = multeAnsverVatinatResponse.getResponse(widget.index);
    if (savedResponses != null) {
      setState(() {
        for (int i = 0; i < savedResponses.length; i++) {
          isCheckedList[savedResponses[i]] = true;
        //  responseChec.add(widget.qestion['responseVariants'][savedResponses[i]]);
        }
      });
    }
  }

  void _saveResponses() {
    List<int> selectedIndices = [];
    for (int i = 0; i < isCheckedList.length; i++) {
      if (isCheckedList[i]) {
        selectedIndices.add(i);
      }
    }
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    multeAnsverVatinatResponse.addResponse(widget.index, selectedIndices);
  }

  void _scrollListener() {
    final double topEdge = _scrollController.offset;
    final double bottomEdge =
        _scrollController.offset + MediaQuery.of(context).size.height;

    const double itemHeight = 100.0;
    // Вычисляем индексы первого и последнего элементов, видимых на экране
    final int firstVisibleIndex = (topEdge / itemHeight).floor();
    final int lastVisibleIndex = (bottomEdge / itemHeight).ceil();

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

  @override
  Widget build(BuildContext context) {
    String coment = returnQestinComment(widget.language);
    String title = returnQestinName(widget.language);
    String buttonText = returnButtonNext(widget.language);
    final multeAnsverVatinatResponseRemove = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 32, top: 48, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            title,
            wrapWords: true,
            minFontSize: 30,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 48,
              fontFamily: 'RobotoBlack',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          AutoSizeText('($coment)',
              minFontSize: 22,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'RobotoRegular',
                fontWeight: FontWeight.w400,
              )),
          const SizedBox(height: 50),
          Expanded(
          //  child: Scrollbar(
          //    thickness: 5,
          //    radius: Radius.circular(2),
          //    interactive: true,
          //    trackVisibility: true,
          //    thumbVisibility: true,
            child:
            GridView.builder(
            //  controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 125,
              ),
              itemCount: countColunm(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isCheckedList[index] = !isCheckedList[index];
                     // bool response = !_multeAnsverVatinatResponse.getResponse(index) ?? false;
                     // responseChec.add(widget.qestion['responseVariants'][index]);
                      if (isCheckedList[index]) {
                        responseChec.add(widget.qestion['responseVariants'][index]);
                      } else {
                        responseChec.remove(widget.qestion['responseVariants'][index]);
                        multeAnsverVatinatResponseRemove.clearResponseVariant();
                      }
                      _saveResponses();

                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isCheckedList[index] = !isCheckedList[index];
                              if (isCheckedList[index]) {
                                responseChec.add(widget.qestion['responseVariants'][index]);
                              } else {
                                responseChec.remove(widget.qestion['responseVariants'][index]);
                                multeAnsverVatinatResponseRemove.clearResponseVariant();
                              }
                              _saveResponses();

                            });
                          },
                          icon: Icon(
                            isCheckedList[index]
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.green,
                            size: 54,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Flexible(
                          child: AutoSizeText(
                            returnResponse(widget.language)[index],
                            minFontSize: 20,
                            maxLines: 2,
                            maxFontSize: 32,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'RobotoRegular',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            //),
            )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 64),
                child: ElevatedButton(
                  onPressed: () {
                    _onNextPressed();
                    //widget.onPressed();
                  },
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            4), // Устанавливаем радиус скругления в 10 пикселей
                      ),
                    ),
                    fixedSize: MaterialStateProperty.all(const Size(275, 56)),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        // Здесь можно указать разные цвета для различных состояний кнопки
                        if (states.contains(MaterialState.pressed)) {
                          // Цвет, когда кнопка нажата
                          return Colors.green;
                        }
                        // Возвращаем основной цвет для остальных состояний
                        return questionsGroupColor;
                      },
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'RobotoRegular',
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )
            ],
          ),
          ],
      ),
    ));
  }

  int countColunm() {
    List<dynamic> responseVariants = widget.qestion['responseVariants'];
    return responseVariants.length;
  }

  String returnQestinName(String localeCod) {
    String languageName = '';
    Map<String, dynamic> nameMap = jsonDecode(widget.qestion['question']);
    if (nameMap.containsKey(localeCod)) {
      String languageName = nameMap[localeCod];
      if (languageName.isNotEmpty) {
        return languageName;
      }
    }
    return languageName;
  }

  List<String> returnResponse(String localeCod) {
    List<String> languageNames = [];
    List<dynamic> responseVariants = widget.qestion['responseVariants'];

    if (responseVariants != null && responseVariants.isNotEmpty) {
      for (var variant in responseVariants) {
        Map<String, dynamic> responseMap = jsonDecode(variant['response']);

        if (responseMap.containsKey(localeCod)) {
          String languageName = responseMap[localeCod];
          languageNames.add(languageName);
        }
      }
    }
    return languageNames; // Вернуть список всех вариантов ответа
  }

  String returnQestinComment(String localeCod) {
    String languageName = '';
    Map<String, dynamic> nameMap = jsonDecode(widget.qestion['comentary']);
    if (nameMap.containsKey(localeCod)) {
      String languageName = nameMap[localeCod];
      if (languageName.isNotEmpty) {
        return languageName;
      }
    }
    return languageName;
  }

  String returnButtonNext(String localeCod) {
    String enName = 'Next';
    String roName = 'Înainte';
    String ruName = 'Далее';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

  void _onNextPressed() {
    // Проверяем, есть ли хотя бы один выбранный вариант ответа
    if (isCheckedList.contains(true)) {
      // Если есть, выполняем отправку POST-запроса на сервер
      _sendResponseToServer();
    } else {
      // Если ни один вариант не выбран, выводим сообщение об ошибке
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          alignment: Alignment.center,
          title: Text(
            returnDialogTitle(widget.language),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'RobotoBlack',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(returnDialogMessage(widget.language),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'RobotoRegular',
                fontWeight: FontWeight.w400,
              )),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Устанавливаем радиус скругления в 10 пикселей
                  ),
                ),
                fixedSize: MaterialStateProperty.all(const Size(624, 57)),
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    // Здесь можно указать разные цвета для различных состояний кнопки
                    if (states.contains(MaterialState.pressed)) {
                      // Цвет, когда кнопка нажата
                      return Colors.green;
                    }
                    // Возвращаем основной цвет для остальных состояний
                    return questionsGroupColor;
                  },
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'RobotoRegular',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String returnDialogMessage(String localeCod) {
    String enName = 'Please answer the question';
    String roName = 'Vă rugăm să răspundeți la întrebare';
    String ruName = 'Пожалуйста, ответьте на вопрос';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

  String returnDialogTitle(String localeCod) {
    String enName = 'Atention';
    String roName = 'Alertă';
    String ruName = 'Внимание';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

  void _sendResponseToServer() async {
    var shered = await SecureSharedPref.getInstance();
    var license = await shered.getString("licenseID");
    final responsePostProvider = Provider.of<ResponsePostProvider>(context, listen: false);
    print("Qestion Map : ${widget.qestion}");
    try {
      for (int i = 0; i < responseChec.length; i++) {
        var id = responseChec[i]['id'];
        var responseVariantId = responseChec[i]['questionId'];
        responsePostProvider.addResponse(
        ResponsePost(
          id: 0,
          questionId: responseVariantId.toInt(),
          responseVariantId: id.toInt(),
          alternativeResponse: '',
          commentary: '',
          gradingType: widget.qestion['gradingType'].toInt(),
          dateResponse: DateTime.now().toIso8601String(),
        ));
        print(responsePostProvider.responses.length);
      }

    } catch (e) {
      print('Error sending response: $e');
    } finally {
      if (widget.index + 1 != widget.totalQuestionsCount) {
        // Если это последний вопрос, переходим на другую страницу
        widget.onPressedController.nextPage(
          duration: const Duration(microseconds: 200),
          curve: Curves.easeInOut,
        );
      } else {
        // Если ни один вариант не выбран, выводим сообщение об ошибке
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            alignment: Alignment.center,
            title: Text(
              returnDialogTitleFinish(widget.language),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'RobotoBlack',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              returnDialogMessageFinish(widget.language),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'RobotoRegular',
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  alignment: Alignment.center,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all(const Size(624, 57)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green;
                      }
                      return questionsGroupColor;
                    },
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const Questionnaires()),
                          (route) => false);
                  List<ResponsePost> allResponses = responsePostProvider.responses;
                  print("PostRespons: ${allResponses.toString()}");
                  Map<String, dynamic> staticData = {
                    "oid": 0,
                    "questionnaireId": 0,
                    "responses": allResponses,
                    "licenseId": license,
                  };
                  final String basicAuth =
                      'Basic ${base64Encode(utf8.encode('$username:$password'))}';
                  Uri url = Uri.parse(postResponse); // Замените на ваш URL
                  try {
                    final response =
                        await http.post(url, body: jsonEncode(staticData), headers: {
                      'Authorization': basicAuth,
                      "Accept": "application/json",
                      "content-type": "application/json"
                    });
                    if (response.statusCode == 200) {
                      // Обработка успешного ответа от сервера
                      print('Response sent successfully.');
                      responsePostProvider.clearResponses();
                    } else {
                      // Обработка ошибки
                      print('Failed to send response. Status code: ${response.statusCode}');
                    }
                  } catch (e) {
                    // Обработка ошибок сети
                    print('Error sending response: $e');
                  }
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'RobotoRegular',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
  String returnDialogTitleFinish(String localeCod) {
    String enName = 'Thank you';
    String roName = 'Mulțumesc';
    String ruName = 'Спасибо';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnDialogMessageFinish(String localeCod) {
    String enName = 'Survey completed';
    String roName = 'Chestionarul este încheiat';
    String ruName = 'Опрос завершен';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
}
