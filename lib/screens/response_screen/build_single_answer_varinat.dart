import 'package:flutter/material.dart';

class SingleAnswerVariant extends StatefulWidget {
  //const SingleAnswerVariant({super.key});

  final String language;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;

  const SingleAnswerVariant({super.key, required this.language, required this.qestion, required this.index, required this.onPressed});

  @override
  State<SingleAnswerVariant> createState() => _SingleAnswerVariantState();
}

class _SingleAnswerVariantState extends State<SingleAnswerVariant> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
