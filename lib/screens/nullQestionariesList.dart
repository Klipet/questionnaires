import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';

import '../util/colors.dart';

// Главный виджет списка пустых опросников
class NullQestionariesList extends StatefulWidget {
  final String language; // Язык интерфейса
  const NullQestionariesList({super.key, required this.language});

  @override
  State<NullQestionariesList> createState() => _NullQestionariesListState();
}

// Состояние виджета NullQestionariesList
class _NullQestionariesListState extends State<NullQestionariesList> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/error_null_qestions.png',
            fit: BoxFit.fill,
          ),
          AutoSizeText(
            errorMessage(widget.language),
            maxLines: 2,
            style: const TextStyle(
                color: textColor,
                fontSize: 30,
                fontFamily: 'RobotoBlack',
                fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            // Добавьте обрезку текста, если он превышает две строки
            minFontSize: 12,
            // Минимальный размер шрифта для уменьшения текста, если он не помещается
            stepGranularity: 1,
          ) // Шаг изменения размера шрифта
        ],
      );
  }

  String errorMessage(String localeCod) {
    String enName =
        'Questionnaires are not ready yet, but we are actively working on them. They will be available for completion soon. Thank you for your understanding!';
    String roName =
        'Chestionarile nu sunt încă pregătite, dar lucrăm activ la ei. În curând vor fi disponibile pentru completare. Mulțumim pentru înțelegere!';
    String ruName =
        'Опросники еще не готовы, но мы активно работаем над ними. Скоро будут доступны для заполнения. Спасибо за понимание!';
    if (localeCod == 'RO') {
      return roName;
    } else if (localeCod == 'RU') {
      return ruName;
    } else {
      return enName;
    }
  }
}
