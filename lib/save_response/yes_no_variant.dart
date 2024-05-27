
import 'package:flutter/cupertino.dart';

class YesNoVariantResponse extends ChangeNotifier {
  Map<int, List<String>> responses = {};

  void addResponse(int pageIndex, List<String> response) {
    responses[pageIndex] = response;
    notifyListeners();
  }

  List<String>? getResponse(int pageIndex) {
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