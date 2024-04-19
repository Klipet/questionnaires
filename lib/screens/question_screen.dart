import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/screens/questionnaires.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';
import 'package:http/http.dart' as http;
import '../factory/questions.dart';
import '../provider/locale_provider.dart';
import '../util/const_url.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<Questionaires> questions;
  late List<dynamic> questionsList;
  late int oid;
  late String language;
  late PageController _pageViewController;

  bool isLoading = true;
  late int _currentPageIndex = 0;


  @override
  void initState() {
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
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    oid = args['oid'] as int;
    language = args['language'] as String;
    return Scaffold(
        appBar: AppBar(
          title: Text('text'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(children: [
                PageView.builder(
                  padEnds: false,
                  physics: NeverScrollableScrollPhysics(),
                  // Отключает возможность скроллинга через слайд
                  pageSnapping: false,
                  controller: _pageViewController,
                  itemCount: questions.length,
                  onPageChanged: (int index) {
                    // Обновите текущий индекс страницы при ее изменении
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(returnLanguage(language)[index], style: const TextStyle(
                              fontSize: 50
                            ),),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red, // foreground
                              ),
                              onPressed: () {
                                if(_currentPageIndex == questions.length -1 ){
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const Questionnaires()),
                                          (route) => false);
                                }else{
                                  _pageViewController.nextPage(
                                      duration: const Duration(microseconds: 200),
                                      curve: Curves.easeInOut);
                                }
                              },
                              child: Text(
                                  'ElevatedButton with custom foreground/background $index'),
                            ),

                          ],
                        )  );
                  },
                ),
              ]
        )
    );
  }



  Future<void> fetchQuestionnaires() async {
    var shered = await SecureSharedPref.getInstance();
    var license = await shered.getString("licenseID");
    const String username = 'uSr_nps';
    const String password = "V8-}W31S!l'D";
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await http.get(
        Uri.parse(urlQestions + license! + '&id=$oid'),
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
