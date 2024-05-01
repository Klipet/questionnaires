import 'dart:async';
import 'package:flutter/material.dart';
import 'package:questionnaires/screens/questionnaires.dart';

import '../util/colors.dart';
import '../util/images.dart';

class ErrorScreen extends StatefulWidget {
  //const ErrorScreen({super.key});
  final String language;

  const ErrorScreen({super.key, required this.language});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  int _secondsRemaining = 10;
  late Timer _timer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_secondsRemaining < 1) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Questionnaires()),
              (route) => false);
        } else {
          _secondsRemaining--;
        }
      });
      // Вызываем ваш метод fetchQuestionnaires каждые 60 секунд
    });
  }

  @override
  void dispose() {
    // Отмена таймера при удалении виджета
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: null,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                _secondsRemaining.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'RobotoRegular',
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 90),
                Image.asset(
                  emptyImage,
                  // Путь к вашей картинке
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 80),
                Text(
                  errorMessage(widget.language),
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
        ]));
  }

  String errorMessage(String localeCod) {
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
