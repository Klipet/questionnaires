
import 'package:flutter/cupertino.dart';

class SingleVariantResponse extends ChangeNotifier {
  List<int> responses = [];

  void addResponse(List<int> response) {
    responses = response;
    notifyListeners();
  }

  List<int?>? getResponse() {
    return responses;
  }

  void clearResponse() {
    responses.remove(0);
    notifyListeners();
  }
  void clearResponseVariant() {
    responses.clear();
    notifyListeners();
  }
}