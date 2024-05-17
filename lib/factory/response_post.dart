import 'package:hive/hive.dart';


class ResponsePost {
  int id;
  int questionId;
  int responseVariantId;
  String alternativeResponse;
  String commentary;
  int gradingType;
  String dateResponse;

  ResponsePost({
    required this.id,
    required this.questionId,
    required this.responseVariantId,
    required this.alternativeResponse,
    required this.commentary,
    required this.gradingType,
    required this.dateResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'responseVariantId': responseVariantId,
      'alternativeResponse': alternativeResponse,
      'commentary': commentary,
      'gradingType': gradingType,
      'dateResponse': dateResponse,
    };
  }
}

