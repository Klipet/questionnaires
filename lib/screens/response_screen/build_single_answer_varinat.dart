import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/save_response/yes_no_variant.dart';
import 'package:questionnaires/util/const_url.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import '../../factory/response_post.dart';
import '../../provider/post_privider.dart';
import '../../save_response/multe_ansver_vatinat.dart';
import '../../util/colors.dart';
import '../questionnaires.dart';

class SingleAnswerVariant extends StatefulWidget {
  //const SingleAnswerVariant({super.key});

  final String language;
  final int id;
  final int totalQuestionsCount;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;
  final PageController onPressedController;

  const SingleAnswerVariant(
      {super.key,
      required this.language,
      required this.qestion,
      required this.index,
      required this.onPressed,
      required this.id,
      required this.onPressedController,
      required this.totalQuestionsCount,});

  @override
  State<SingleAnswerVariant> createState() => _SingleAnswerVariantState();
}

class _SingleAnswerVariantState extends State<SingleAnswerVariant> {
  late bool isCheckedList = false;
  late List<dynamic> responseChec = [];
  int? selectedIndex;

  @override
  void initState() {
    // isCheckedList = List.generate(countColunm(), (index) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedResponses();
    });
    super.initState();
  }
  void _loadSavedResponses() {
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    List<int>? savedResponses = multeAnsverVatinatResponse.getResponse(widget.index);
    if (savedResponses != null && savedResponses.isNotEmpty) {
      setState(() {
        selectedIndex = savedResponses[0];
      });
      print("Qestion response save : ${selectedIndex}");
    }
  }

  void _saveResponses() {
    if (selectedIndex != null) {
      List<int> selectedIndices = [selectedIndex!];
      final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
      multeAnsverVatinatResponse.addResponse(widget.index, selectedIndices);
    }
  }

  @override
  Widget build(BuildContext context) {
    String coment = returnQestinComment(widget.language);
    String title = returnQestinName(widget.language);
    String buttonText = returnButtonNext(widget.language);

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 32, top: 48, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            title,
            minFontSize: 38,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 48,
              fontFamily: 'RobotoBlack',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          AutoSizeText(coment,
              minFontSize: 22,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'RobotoRegular',
                fontWeight: FontWeight.w400,
              )),
          const SizedBox(height: 50),
          Expanded(
        //    child:
        //    Scrollbar(
        //      thickness: 5,
        //      radius: Radius.circular(2),
        //      interactive: true,
        //      trackVisibility: true,
        //      thumbVisibility: true,
              child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 80,
              ),
              itemCount: countColunm(),
              itemBuilder: (context, index) {
                return Container(
                  width: 60,
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        responseChec.clear();
                        responseChec.add(widget.qestion['responseVariants'][index]);
                        print("Response Map : ${responseChec[0]}");
                        _saveResponses();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            selectedIndex == index
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selectedIndex == index
                                ? questionsGroupColor
                                : questionsGroupColor,
                            size: 56,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: AutoSizeText(
                            returnResponse(widget.language)[index],
                            minFontSize: 20,
                            maxLines: 2,
                            maxFontSize: 32,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontFamily: 'RobotoRegular',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 64),
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
          )
        ],
      ),
    )
    );
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
    if (selectedIndex != null) {
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
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    final yesAndNo = Provider.of<YesNoVariantResponse>(context, listen: false);
    if (responseChec.isEmpty) {
      List<int>? savedResponses = multeAnsverVatinatResponse.getResponse(widget.index);
      if (savedResponses != null && savedResponses.isNotEmpty) {
        setState(() {
          selectedIndex = savedResponses[0];
          print("Qestion response save : ${savedResponses[0]}");
          responseChec.add(savedResponses[0]);
        });
      }
      print("Qestion add response : $responseChec");
    }
    var id = responseChec[0];
    print("Qestion Map : ${responseChec}");
// Получаем выбранные варианты ответов на основе isCheckedList
    try {
      responsePostProvider.addResponse(ResponsePost(
        id: 0,
        questionId: widget.qestion['id'],
        responseVariantId: id,
        alternativeResponse: '',
        commentary: '',
        gradingType: widget.qestion['gradingType'].toInt(),
        dateResponse: DateTime.now().toIso8601String(),
      ));
      print(responsePostProvider.responses.length);
      //  var id = responseChec[0]['id'];
      //  var responseVariantId = responseChec[0]['questionId'];
      //  Map<String, dynamic> requestBody = {
      //    'oid': 0,
      //    'questionnaireId': widget.qestion['questionnaireId'],
      //    'responses': [
      //      {
      //        'id': 0,
      //        'questionId': responseVariantId.toInt(),
      //        'responseVariantId': id.toInt(),
      //        // Уточните, какой ID нужно использовать
      //        'alternativeResponse': '',
      //        // Объединяем выбранные варианты в строку
      //        'comentary': '',
      //        // Пустая строка, замените на комментарий, если необходимо
      //        'gradingType': widget.qestion['gradingType'].toInt(),
      //        // Уточните, какой тип оценки нужно использовать
      //        'dateResponse': DateTime.now().toIso8601String(),
      //        // Текущая дата и время
      //      }
      //    ],
      //    'licenseId': license
      //  };
      //  // Отправляем POST-запрос на сервер
      //  final String basicAuth =
      //      'Basic ' + base64Encode(utf8.encode('$username:$password'));
      //  Uri url = Uri.parse(postResponse); // Замените на ваш URL
      //  try {
      //    final response =
      //        await http.post(url, body: jsonEncode(requestBody), headers: {
      //      'Authorization': basicAuth,
      //      "Accept": "application/json",
      //      "content-type": "application/json"
      //    });
      //    if (response.statusCode == 200) {
      //      // Обработка успешного ответа от сервера
      //      print('Response sent successfully.');
      //    } else {
      //      // Обработка ошибки
      //      print('Failed to send response. Status code: ${response.statusCode}');
      //    }
      //  } catch (e) {
      //    // Обработка ошибок сети
      //    print('Error sending response: $e');
      //  }

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
          builder: (context) =>
              AlertDialog(
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
                      List<ResponsePost> allResponses = responsePostProvider
                          .responses;
                      print("PostRespons: ${allResponses.toString()}");
                      Map<String, dynamic> staticData = {
                        "oid": 0,
                        "questionnaireId": 0,
                        "responses": allResponses,
                        "licenseId": license,

                      };
                      final String basicAuth =
                          'Basic ${base64Encode(
                          utf8.encode('$username:$password'))}';
                      Uri url = Uri.parse(postResponse); // Замените на ваш URL
                      try {
                        final response =
                        await http.post(
                            url, body: jsonEncode(staticData), headers: {
                          'Authorization': basicAuth,
                          "Accept": "application/json",
                          "content-type": "application/json"
                        });
                        if (response.statusCode == 200) {
                          // Обработка успешного ответа от сервера
                          print('Response sent successfully.');
                          responsePostProvider.clearResponses();
                          multeAnsverVatinatResponse.clearResponseVariant();
                          yesAndNo.clearResponseVariant();
                        } else {
                          // Обработка ошибки
                          print(
                              'Failed to send response. Status code: ${response
                                  .statusCode}');
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
