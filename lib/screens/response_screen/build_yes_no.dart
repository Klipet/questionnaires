import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import '../../util/colors.dart';
import '../../util/const_url.dart';
import '../questionnaires.dart';

class YesNoVariant extends StatefulWidget {
  // const YesNoVariant({super.key});

  final String language;
  final int id;
  final int totalQuestionsCount;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;
  final PageController onPressedController;

  const YesNoVariant(
      {super.key,
      required this.language,
      required this.qestion,
      required this.index,
      required this.onPressed,
      required this.id,
      required this.onPressedController,
      required this.totalQuestionsCount});

  @override
  State<YesNoVariant> createState() => _YesNoVariantState();
}

class _YesNoVariantState extends State<YesNoVariant> {
  bool isCheckedFirstButton = false;
  bool isCheckedSecondButton = false;
  late List<dynamic> responseChec;

  @override
  void initState() {
    responseChec = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String coment = returnQestinComment(widget.language);
    String title = returnQestinName(widget.language);
    String buttonText = returnButtonNext(widget.language);
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 32, top: 48, right: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 48,
                    fontFamily: 'RobotoBlack',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(coment,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'RobotoRegular',
                      fontWeight: FontWeight.w400,
                    )),
              ],
            )),
        const SizedBox(height: 100),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  icon: Icon(
                    !isCheckedFirstButton
                        ? Icons.check_circle_outline
                        : Icons.check_circle,
                    color: questionsGroupColor,
                    size: 150,
                  ),
                  onPressed: () {
                    setState(() {
                      //isCheckedFirstButton = !isCheckedFirstButton; // Изменяем состояние isChecked при нажатии на кнопку
                      if (!isCheckedFirstButton) {
                        isCheckedFirstButton = !isCheckedFirstButton;
                        isCheckedSecondButton = false;
                      }
                      responseChec.add(widget.qestion['responseVariants']);
                    });
                  },
                ),
                const SizedBox(width: 12.5),
                IconButton(
                  icon: Icon(
                    !isCheckedSecondButton
                        ? Icons.cancel_outlined
                        : Icons.cancel,
                    color: Colors.red,
                    size: 150,
                  ),
                  onPressed: () {
                    setState(() {
                      //isCheckedSecondButton = !isCheckedSecondButton; // Изменяем состояние isChecked при нажатии на кнопку
                      if (!isCheckedSecondButton) {
                        isCheckedSecondButton = !isCheckedSecondButton;
                        isCheckedFirstButton =
                            false; // сбрасываем состояние первой кнопки при нажатии на вторую
                      }
                      responseChec.add(widget.qestion['responseVariants']);
                    });
                  },
                )
              ]),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 64),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
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
            ))
      ]),
    );
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

  void _onNextPressed() {
    // Проверяем, есть ли хотя бы один выбранный вариант ответа
    if (isCheckedFirstButton != false || isCheckedSecondButton != false) {
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
    String valueToSend = '';

    if (isCheckedFirstButton == true) {
      valueToSend = 'true';
    } else if (isCheckedSecondButton == true) {
      valueToSend = 'false';
    } else {
      // Оба значения равны false, определите, что делать в этом случае.
    }
// Получаем выбранные варианты ответов на основе isCheckedList
    try {
      Map<String, dynamic> requestBody = {
        'oid': 0,
        'questionnaireId': widget.qestion['questionnaireId'],
        'responses': [
          {
            'id': 0,
            'questionId': widget.qestion['id'],
            'responseVariantId': 0,
            // Уточните, какой ID нужно использовать
            'alternativeResponse': valueToSend,
            // Объединяем выбранные варианты в строку
            'comentary': '',
            // Пустая строка, замените на комментарий, если необходимо
            'gradingType': widget.qestion['gradingType'].toInt(),
            // Уточните, какой тип оценки нужно использовать
            'dateResponse': DateTime.now().toIso8601String(),
            // Текущая дата и время
          }
        ],
        'licenseId': license
      };
      // Отправляем POST-запрос на сервер
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));
      Uri url = Uri.parse(postResponse); // Замените на ваш URL
      try {
        final response =
            await http.post(url, body: jsonEncode(requestBody), headers: {
          'Authorization': basicAuth,
          "Accept": "application/json",
          "content-type": "application/json"
        });
        if (response.statusCode == 200) {
          // Обработка успешного ответа от сервера
          print('Response sent successfully.');
        } else {
          // Обработка ошибки
          print('Failed to send response. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Обработка ошибок сети
        print('Error sending response: $e');
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
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const Questionnaires()),
                    (route) => false),
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
