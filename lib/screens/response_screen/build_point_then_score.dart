import 'package:flutter/material.dart';

class PointThenScore extends StatefulWidget {
  //const PointThenScore({super.key});

  final String language;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;

  const PointThenScore({super.key, required this.language, required this.qestion, required this.index, required this.onPressed});

  @override
  State<PointThenScore> createState() => _PointThenScoreState();
}

class _PointThenScoreState extends State<PointThenScore> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
