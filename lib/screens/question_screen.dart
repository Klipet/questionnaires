import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:http/http.dart' as http;
import '../factory/questions.dart';
import '../util/colors.dart';
import '../util/const_url.dart';

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
  late List<dynamic> questionsList;
  late PageController _pageViewController;
  bool isLoading = true;
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
    //  final Map<String, dynamic> args =
    //      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //  oid = args['oid'] as int;
    //  language = args['language'] as String;
    String count = questions.length.toString();
    return Container(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : PageView.builder(
                itemCount: questions.length,
                padEnds: false,
                physics: NeverScrollableScrollPhysics(),
                // Отключает возможность скроллинга через слайд
                pageSnapping: false,
                controller: _pageViewController,
                onPageChanged: (int index) {
                  // Обновите текущий индекс страницы при ее изменении
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        leading: index.toInt() == 0 ? null : IconButton(
                          onPressed: () {
                            goToPreviousPage(); // Вызываем метод для перехода на предыдущую страницу
                          },
                          icon: const Icon(Icons.arrow_back), iconSize: 24, color: Colors.white,
                        ),
                        automaticallyImplyLeading: false,
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.home_outlined), color: Colors.white, iconSize: 25,),
                        ],
                        title: Text(
                          (index + 1).toString() + " / " + count.toString(),
                          textAlign: TextAlign.center, style: const TextStyle(
                          color: Colors.white
                        ),
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
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      returnLanguage(widget.language)[index],
                                      style: const TextStyle(fontSize: 50),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Colors.red, // foreground
                                      ),
                                      onPressed: () {
                                        if (_currentPageIndex ==
                                            questions.length - 1) {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Questionnaires()),
                                                  (route) => false);
                                        } else {
                                          _pageViewController.nextPage(
                                              duration: const Duration(
                                                  microseconds: 200),
                                              curve: Curves.easeInOut);
                                        }
                                      },
                                      child: Text(
                                          'ElevatedButton with custom foreground/background $index'),
                                    ),
                                  ],
                                ))
                              ],
                            ));
                },
              ));
  }
  List<Widget> buildQuestions(List<dynamic> questions) {
    List<Widget> questionWidgets = [];

    for (var question in questions) {
      int gradingType = question['gradingType'];
      switch (gradingType) {
        case 1:
        // Вопрос с Да.нет
          questionWidgets.add(buildYesNo(question));
          break;
        case 2:
        // Вопрос с от 1 до 10
          questionWidgets.add(buildPointThenScore(question));
          break;
        case 3:
        // Вопрос с одним ответом
          questionWidgets.add(buildSingleAnswerVarinat(question));
          break;
        case 4:
        // Вопрос с множеством ответов
          questionWidgets.add(buildMultipleAnsverVriant(question));
          break;
        default:
        // Вопрос с от 1 до 5
          questionWidgets.add(buildPointFiveScore(question));
      }
    }

    return questionWidgets;
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
      setState(() {});
      if (responseDate['questionnaire'] != null) {
        questionsList = responseDate['questionnaire']['questions'];
        questions = parseQuestionaires(responseDate);
        setState(() {
          isLoading = false;
        });
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

  Widget buildYesNo(question) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          returnLanguage(widget.language)[index],
          style: const TextStyle(fontSize: 50),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
            Colors.red, // foreground
          ),
          onPressed: () {
            if (_currentPageIndex ==
                questions.length - 1) {
              Navigator.of(context)
                  .pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                      const Questionnaires()),
                      (route) => false);
            } else {
              _pageViewController.nextPage(
                  duration: const Duration(
                      microseconds: 200),
                  curve: Curves.easeInOut);
            }
          },
          child: Text(
              'ElevatedButton with custom foreground/background $index'),
        ),
      ],
    ));
  }

  Widget buildPointThenScore(question) {
    return Container();
  }

  Widget buildSingleAnswerVarinat(question) {
    return Container();
  }

  Widget buildMultipleAnsverVriant(question) {
    return Container();
  }

  Widget buildPointFiveScore(question) {
    return Container();
  }

  Widget buildDefaultQuestion(question) {
    return Container();
  }
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
