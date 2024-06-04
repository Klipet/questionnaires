import 'package:flutter/widgets.dart';
import 'package:questionnaires/factory/response_post.dart';

class ResponsePostProvider extends ChangeNotifier {
  List<ResponsePost> _responses = [];

  void addResponse(ResponsePost response) {
    _responses.add(response);
    notifyListeners();
  }

  List<ResponsePost> get responses => _responses;

  void clearResponses() {
    _responses.clear();
  }
  // Очищаем ответы для конкретного вопроса
  void clearResponsesForQuestion(int questionId) {
    _responses.removeWhere((response) => response.questionId == questionId);
    notifyListeners();
  }
}