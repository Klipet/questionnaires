import 'package:flutter/material.dart';



class YesNoVariant extends StatefulWidget {
 // const YesNoVariant({super.key});

  final String language;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;

  const YesNoVariant({super.key, required this.language, required this.qestion, required this.index, required this.onPressed});

  @override
  State<YesNoVariant> createState() => _YesNoVariantState();
}

class _YesNoVariantState extends State<YesNoVariant> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
