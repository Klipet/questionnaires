import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/colors.dart';
import '../questionnaires.dart';

class MulteAnsverVatinat extends StatefulWidget {
  // const MulteAnsverVatinat({super.key});
  final String language;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;

  const MulteAnsverVatinat(
      {super.key,
      required this.language,
      required this.index,
      required this.qestion,
      required this.onPressed});

  @override
  State<MulteAnsverVatinat> createState() => _MulteAnsverVatinatState();
}

class _MulteAnsverVatinatState extends State<MulteAnsverVatinat> {
  late List<bool> isCheckedList;

  @override
  void initState() {
    isCheckedList = List.generate(countColunm(), (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String coment = returnQestinComment(widget.language);
    String title = returnQestinName(widget.language);
    String buttonText = returnButtonNext(widget.language);

    return Center(
        child: Padding(
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
          const SizedBox(height: 20),
          Text('($coment)',
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'RobotoRegular',
                fontWeight: FontWeight.w400,
              )),
          const SizedBox(height: 50),
          Expanded(
              child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 125,
            ),
            itemCount: countColunm(),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isCheckedList[index] = !isCheckedList[
                              index]; // Изменяем состояние isChecked при нажатии на кнопку
                        });
                      },
                      icon: Icon(
                          isCheckedList[index]
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.green,
                          size: 54),
                    ),
                    SizedBox(width: 8.0),
                    // Пространство между иконкой и текстом
                    Text(
                      returnResponse(widget.language)[index],
                      style: const TextStyle(
                        fontSize: 32,
                        fontFamily: 'RobotoRegular',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
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
          title: Text(returnDialogTitle(widget.language)),
          content: Text(returnDialogMessage(widget.language)),
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
              child: Text('OK'),
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
}

class _sendResponseToServer {}
