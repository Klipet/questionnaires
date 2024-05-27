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
    notifyListeners();
  }
  void clearFirstResponse(){
    _responses.removeLast();
  }
}