import 'package:flutter/material.dart';


class QuestionScreen extends StatelessWidget {


  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int oid = args['oid'] as int;
    return Scaffold(
      appBar: AppBar(
        title: Text('text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(oid.toString()),
            // Отображение вариантов ответов (если есть)

          ],
        ),
      ),

    );
  }
}