
import 'package:flutter/cupertino.dart';

class MulteAnsverVatinatResponse extends ChangeNotifier {
  Map<int, List<int>> responses = {};

  void addResponse(int pageIndex, List<int> response) {
    responses[pageIndex] = response;
    notifyListeners();
  }

  List<int>? getResponse(int pageIndex) {
    return responses[pageIndex];
  }

  void clearResponse(int pageIndex) {
    responses.remove(pageIndex);
    notifyListeners();
  }
  void clearResponseVariant() {
    responses.clear();
    notifyListeners();
  }
}