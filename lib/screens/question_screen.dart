import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/save_response/single_variant_response.dart';
import 'package:questionnaires/screens/error_screen.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:questionnaires/screens/response_screen/build_point_then_score.dart';
import 'package:questionnaires/screens/response_screen/build_yes_no.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:http/http.dart' as http;
import '../factory/get_questionnaires.dart';
import '../factory/questions.dart';
import '../provider/post_privider.dart';
import '../save_response/multe_ansver_vatinat.dart';
import '../save_response/yes_no_variant.dart';
import '../util/colors.dart';
import '../util/const_url.dart';
import 'license.dart';
import 'response_screen/build_multiple_ansver_vriant.dart';
import 'response_screen/build_point_five_score.dart';
import 'response_screen/build_single_answer_varinat.dart';

class QuestionScreen extends StatefulWidget {
  // const QuestionScreen({super.key});
  final int oid;
  final String language;

  //
  const QuestionScreen({super.key, required this.oid, required this.language});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<Questionaires> questions;
  late List<GetQuestionnaires> questionsListTotal;
  late List<dynamic> questionsList;
  late PageController _pageViewController;
  bool isLoading = true;
  late bool hasError;
  Map<String, dynamic> qestionMap = {};
  late int _currentPageIndex = 0;


  @override
  void initState() {
    questions = [];
    _pageViewController = PageController();
    _currentPageIndex;
    fetchQuestionnaires();
    super.initState();
  }

  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.oid;
    widget.language;
    String count = questions.length.toString();
    final responsePostProvider = Provider.of<ResponsePostProvider>(context, listen: false);
    final multeAnsverVatinatResponse = Provider.of<MulteAnsverVatinatResponse>(context, listen: false);
    final singleVatinatResponse = Provider.of<SingleVariantResponse>(context, listen: false);
    final yesAndNo = Provider.of<YesNoVariantResponse>(context, listen: false);
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: questionsGroupColor),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 0),
                child: hasError
                    ? ErrorScreen(language: widget.language)
                    : PageView.builder(
                        itemCount: questions.length,
                        padEnds: false,
                        physics: const NeverScrollableScrollPhysics(),
                        // Отключает возможность скроллинга через слайд
                        pageSnapping: false,
                        controller: _pageViewController,
                        onPageChanged: (int index) {
                          // Обновите текущий индекс страницы при ее изменении
                          setState(() {
                            _currentPageIndex = index;
                            if (index == 0){
                              responsePostProvider.clearResponses();
                              print('$index Удален опросник');
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          return Scaffold(
                              appBar: AppBar(
                                centerTitle: true,
                                leading: index.toInt() == 0
                                    ? null
                                    : IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  iconSize: 24,
                                  color: Colors.white,
                                  onPressed: () {
                                    if(index > 0){
                                      responsePostProvider.clearResponsesForQuestion(questionsList[index]['id']);
                                      print('${questionsList[index]['id']} index удален');

                                    }
                                    goToPreviousPage(); // Вызываем метод для перехода на предыдущую страницу
                                  },
                                ),
                                automaticallyImplyLeading: false,
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.home_outlined),
                                    color: Colors.white,
                                    iconSize: 25,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => AlertDialog(alignment: Alignment.center,
                                                  title: Text(returnDialogTitleFinish(widget.language), textAlign: TextAlign.center, style: const TextStyle(
                                                      fontSize: 24,
                                                      fontFamily: 'RobotoBlack',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    returnDialogMessageFinish(widget.language),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontFamily:
                                                          'RobotoRegular',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                            actionsAlignment: MainAxisAlignment.center,
                                                  actions: [
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.only(left: 15)),
                                                        alignment:
                                                            Alignment.center,
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        fixedSize:
                                                            MaterialStateProperty.all(const Size(200, 57)),
                                                        backgroundColor:
                                                            MaterialStateProperty.resolveWith<Color>((Set<MaterialState>states) {
                                                            if (states.contains(MaterialState.pressed)) {return Colors.green;}
                                                            return questionsGroupColor;
                                                          },
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        multeAnsverVatinatResponse.clearResponseVariant();
                                                        yesAndNo.clearResponseVariant();
                                                        responsePostProvider.clearResponses();
                                                        singleVatinatResponse.clearResponseVariant();
                                                        Navigator.of(context).pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                                builder: (context) => const Questionnaires()),
                                                                (route) => false);
                                                      },
                                                      child: Text(
                                                        returnDialogOK(widget.language),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 24,
                                                          fontFamily:
                                                              'RobotoRegular',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        alignment: Alignment.center,
                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                                                        ),
                                                        fixedSize:
                                                        MaterialStateProperty.all(const Size(200, 57)),
                                                        backgroundColor:
                                                        MaterialStateProperty.resolveWith<Color>((Set<MaterialState>states) {
                                                            if (states.contains(MaterialState.pressed)) {return Colors.red;}
                                                            return Colors.red;
                                                          },
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text(
                                                        returnDialogCancel(widget.language),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 24,
                                                          fontFamily:
                                                          'RobotoRegular',
                                                          fontWeight:
                                                          FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ]));
                                    },
                                  ),
                                ],
                                title: Text(
                                  (index + 1).toString() +
                                      " / " +
                                      count.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: questionsGroupColor,
                              ),
                              body: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Stack(
                                      children: [
                                        Center(
                                          child: buildQuestions(
                                              questionsList,
                                              questions,
                                              widget.language,
                                              _currentPageIndex,
                                              nextQuestion),
                                        )
                                      ],
                                    ));
                        },
                      )));
  }

  void nextQuestion() {
    setState(() {
      if (_currentPageIndex < questions.length - 1) {
        _currentPageIndex++;
        // Обновляем содержимое виджета с новым индексом
        _pageViewController.nextPage(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      } else {
        // Если достигнут конец списка вопросов, можно выполнить какие-то действия, например, показать диалоговое окно
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('End of questions'),
            content: Text('You have reached the end of the questions.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const Questionnaires()),
                    (route) => false),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  void goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageViewController.previousPage(
          duration: const Duration(microseconds: 200), curve: Curves.easeInOut);
    }
  }

  Widget qestionsResponse() {
    for (var qesten in questionsList) {
      if (qesten.containsKey('question')) {
        String? nameJson = qesten['question'];
        Map<String, dynamic> nameMap = jsonDecode(nameJson!);
      }
    }
    return Center();
  }

  Future<void> fetchQuestionnaires() async {
    var shered = await SecureSharedPref.getInstance();
    var license = await shered.getString("licenseID");
    const String username = 'uSr_nps';
    const String password = "V8-}W31S!l'D";
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await http.get(
        Uri.parse(urlQestions + license! + '&id=' + widget.oid.toString()),
        headers: <String, String>{'authorization': basicAuth});
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseDate = json.decode(response.body);
      int errorcode = responseDate['errorCode'] as int;
      setState(() {});
      if (responseDate['questionnaire'] != null) {
        questionsList = responseDate['questionnaire']['questions'];
        questions = parseQuestionaires(responseDate);
        List<dynamic> allQuestions = responseDate['questionnaire']['questions'];
        questionsListTotal = allQuestions.map((json) => GetQuestionnaires.fromJson(json)).toList();
        if(allQuestions.isEmpty){
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ErrorScreen(language: widget.language)),
                  (route) => false);
        }else{
          Map<String, dynamic> qestionFirst = allQuestions[0];
          Map<String, dynamic> questionMap = jsonDecode(qestionFirst['question']);
          String titleQestion = questionMap[widget.language];
          if (titleQestion == '') {
            setState(() {
              hasError = true;
            });
          } else {
            setState(() {
              hasError = false;
            });
          }
          setState(() {
            isLoading = false;
          });
        }
          } else if (errorcode == 124) {
             Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const License()),
                (route) => false);
      }
    }

  }

  List<String> returnLanguage(String localeCod) {
    List<String> languageNames = [];
    for (var questionsTitle in questionsList) {
      // Проверяем, что 'questionsTitle' содержит ключ 'question'
      if (questionsTitle.containsKey('question')) {
        String? nameJson = questionsTitle['question'];
        try {
          Map<String, dynamic> nameMap = jsonDecode(nameJson!);
          if (nameMap.containsKey(localeCod)) {
            String languageName = nameMap[localeCod];
            if (languageName.isNotEmpty) {
              languageNames.add(languageName);
            }
          }
        } catch (e) {
          print('Ошибка при декодировании JSON: $e');
          continue;
        }
      }
    }
    return languageNames;
  }

  Widget buildQuestions(
      List<dynamic> questionsList,
      List<Questionaires> questions,
      String language,
      int index,
      VoidCallback _next) {
    var totalQestion = questions.length;
    if (index >= 0 && index < questionsList.length) {
      final question = questionsList[index];
      int gradingType = question['gradingType'];
      switch (gradingType) {
        case 1:
          // Вопрос с Да.нет
          return YesNoVariant(
              totalQuestionsCount: totalQestion,
              qestion: question,
              language: language,
              index: index,
              onPressed: _next,
              id: widget.oid,
              onPressedController: _pageViewController);
          break;
        case 2:
          // Вопрос с от 1 до 10
          return PointThenScore(
              totalQuestionsCount: totalQestion,
              qestion: question,
              language: language,
              index: index,
              onPressed: _next,
              id: widget.oid,
              onPressedController: _pageViewController);
        case 3:
          // Вопрос с одним ответом
          return SingleAnswerVariant(
              totalQuestionsCount: totalQestion,
              qestion: question,
              language: language,
              index: index,
              onPressed: _next,
              id: widget.oid,
              onPressedController: _pageViewController);
          break;
        case 4:
          // Вопрос с множеством ответов
          return MulteAnsverVatinat(
              totalQuestionsCount: totalQestion,
              qestion: question,
              language: language,
              index: index,
              onPressed: _next,
              id: widget.oid,
              onPressedController: _pageViewController);
          break;
        default:
          //Вопрос с от 1 до 5
          return PointFiveScore(
              totalQuestionsCount: totalQestion,
              qestion: question,
              language: language,
              index: index,
              onPressed: _next,
              id: widget.oid,
              onPressedController: _pageViewController);
      }
    }
    return const Center();
  }

  String returnDialogMessageFinish(String language) {
    String enName = 'Exiting the survey will lead to deletion of all your responses. Continue?';
    String roName = 'Ieșirea din sondaj va duce la ștergerea tuturor răspunsurilor tale. Continuați?';
    String ruName = 'Выход из опроса приведет к удалению всех ваших ответов. Продолжить?';
    if (language == 'RO') {
      return roName;
    } else if (language == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

  String returnDialogTitleFinish(String language) {
    String enName = 'Attention!';
    String roName = 'Atenție!';
    String ruName = 'Внимание!';
    if (language == 'RO') {
      return roName;
    } else if (language == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnDialogOK(String language) {
    String enName = 'Ok';
    String roName = 'Bine';
    String ruName = 'Хорошо';
    if (language == 'RO') {
      return roName;
    } else if (language == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
  String returnDialogCancel(String language) {
    String enName = 'Cancel';
    String roName = 'Anulare';
    String ruName = 'Отмена';
    if (language == 'RO') {
      return roName;
    } else if (language == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }

//}
}

List<Questions> parseQuestTitle(Map<String, dynamic> responseData) {
  // Извлекаем список вопросов из карты
  final List<dynamic> questionsJson =
      responseData['questionnaire']['questions'];
  // Преобразуем каждый вопрос в объект Question
  return questionsJson.map((json) => Questions.fromJson(json)).toList();
}


List<Questionaires> parseQuestionaires(Map<String, dynamic> responseData) {
  // Извлекаем список вопросов из карты
  final List<dynamic> questionsJson =
      responseData['questionnaire']['questions'];
  // Преобразуем каждый вопрос в объект Question
  return questionsJson.map((json) => Questionaires.fromJson(json)).toList();
}
