import 'package:flutter/material.dart';

class PointFiveScore extends StatefulWidget {
 // const PointFiveScore({super.key});
  final String language;
  final Map<String, dynamic> qestion;
  final int index;
  final VoidCallback onPressed;

  const PointFiveScore({super.key, required this.language, required this.qestion, required this.index, required this.onPressed});

  @override
  State<PointFiveScore> createState() => _PointFiveScoreState();
}

class _PointFiveScoreState extends State<PointFiveScore> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
