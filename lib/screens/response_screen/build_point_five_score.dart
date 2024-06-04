import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/provider/post_privider.dart';
import 'package:questionnaires/factory/questions.dart';
import 'package:questionnaires/save_response/single_variant_response.dart';
import 'package:questionnaires/save_response/yes_no_variant.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../factory/response_post.dart';
import '../../save_response/multe_ansver_vatinat.dart';
import '../../util/colors.dart';
import '../../util/const_url.dart';
import '../questionnaires.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PointFiveScore extends StatefulWidget {
  // const PointFiveScore({super.key});
  final String language;
  final int id;
  final int totalQuestionsCount;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;
  final PageController onPressedController;

  const PointFiveScore(
      {super.key,
      required this.language,
      required this.qestion,
      required this.index,
      required this.onPressed,
      required this.id,
      required this.onPressedController,
      required this.totalQuestionsCount});

  @override
  State<PointFiveScore> createState() => _PointFiveScoreState();
}

class _PointFiveScoreState extends State<PointFiveScore> {
  bool isCheckedFirstButton = false;
  int selectedIndex = -1;
  bool selected = false;
  late List<bool> isCheckedList;
  late List<dynamic> responseChec;



  @override
  void initState() {
    isCheckedList = List.generate(5, (index) => false);
    responseChec = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedResponses();
    });
    super.initState();
  }
  final List<String> images = [
   'assets/images/smile_hangry.png',
   'assets/images/smile_bad.png',
   'assets/images/smile_of.png',
   'assets/images/smile_simpl.png',
   'assets/images/smile_love.png',
 ];
 final List<String> selectedImages = [
   'assets/images/selected_smile_hangry.png',
   'assets/images/selected_smile_bad.png',
   'assets/images/selected_smile_of.png',
   'assets/images/selected_smile_simpl.png',
   'assets/images/selected_smile_love.png',
 ];

  void _loadSavedResponses() {
    final variant = Provider.of<YesNoVariantResponse>(context, listen: false);
    List<String>? savedResponses = variant.getResponse(widget.index);
    if (savedResponses != null && savedResponses.isNotEmpty) {
      setState(() {
        selectedIndex = int.parse(savedResponses[0]);
        isCheckedList[selectedIndex] = true;
      });
    }
  }

  void _saveSelectedResponse(int index) {
    final multeAnsverVatinatResponse =
    Provider.of<YesNoVariantResponse>(context, listen: false);
    multeAnsverVatinatResponse.addResponse(widget.index, [index.toString()]);
  }

  @override
  Widget build(BuildContext context) {
    final responsePostProvider = Provider.of<ResponsePostProvider>(context);
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
                AutoSizeText(coment,
                    minFontSize: 22,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'RobotoRegular',
                      fontWeight: FontWeight.w400,
                    )),
              ],
            )),
        //const SizedBox(height: 110),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  int value = index + 1; // Определяем значение для каждой цифры (можете использовать что угодно)
                  return Padding(
                    padding: const EdgeInsets.only(right: 57),
                      child: _buttonImages(index)
                     // isCheckedList[index] ? Image.asset(selectedImages[index], fit: BoxFit.contain)
                     //     : Image.asset(images[index], fit: BoxFit.contain),

                  );
                }),
              ),
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

  Widget _buttonImages(int i) {
     bool isPressed = i == selectedIndex; // Получаем состояние нажатия кнопки
   return  GestureDetector(
     onTapUp: (_) {
       // Действие при нажатии на кнопку
       setState(() {
         selectedIndex = i;
         for (int i = 0; i < isCheckedList.length; i++) {
           isCheckedList[i] = i == selectedIndex;
         }
         selectedIndex = i;
       });
       _saveSelectedResponse(i);
       },
     child: Container(
       width: 157, // Ширина изображения
       height: 157, // Высота изображения
       child: Image.asset(
         i != selectedIndex? images[i]:  selectedImages[i],
         fit: BoxFit.fill,
       ),
  ),
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
    if (selectedIndex != -1) {
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

  void _sendResponseToServer() async {
    var shered = await SecureSharedPref.getInstance();
    var license = await shered.getString("licenseID");
    final responsePostProvider = Provider.of<ResponsePostProvider>(context, listen: false);
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    final singleVatinatResponse = Provider.of<SingleVariantResponse>(context, listen: false);
    final yesAndNo = Provider.of<YesNoVariantResponse>(context, listen: false);
    print(selectedIndex! +1 );
    String response = (selectedIndex! + 1).toString();
    try {
      responsePostProvider.addResponse(
          ResponsePost(
        id: 0,
        questionId: widget.qestion['id'],
        responseVariantId: 0,
        alternativeResponse: response,
        commentary: '',
        gradingType: widget.qestion['gradingType'].toInt(),
        dateResponse: DateTime.now().toIso8601String(),
      )
      );
      print(responsePostProvider.responses.toString());

    } catch (e) {
      print('Error sending response: $e');
    } finally {
      var i = widget.totalQuestionsCount;
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
                      multeAnsverVatinatResponse.clearResponseVariant();
                      yesAndNo.clearResponseVariant();
                      singleVatinatResponse.clearResponseVariant();
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
}
