/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

Questions questionsFromJson(String str) => Questions.fromJson(json.decode(str));

String questionsToJson(Questions data) => json.encode(data.toJson());

class Questions {
    Questions({
        required this.questionnaire,
        required this.errorName,
        required this.errorMessage,
        required this.errorCode,
    });

    Questionnaire questionnaire;
    String errorName;
    String errorMessage;
    int errorCode;

    factory Questions.fromJson(Map<dynamic, dynamic> json) => Questions(
        questionnaire: Questionnaire.fromJson(json["questionnaire"]),
        errorName: json["errorName"],
        errorMessage: json["errorMessage"],
        errorCode: json["errorCode"],
    );

    Map<dynamic, dynamic> toJson() => {
        "questionnaire": questionnaire.toJson(),
        "errorName": errorName,
        "errorMessage": errorMessage,
        "errorCode": errorCode,
    };
}

class Questionnaire {
    Questionnaire({
        required this.name,
        required this.questions,
        required this.oid,
        required this.createDate,
        required this.status,
    });

    String name;
    List<Question> questions;
    int oid;
    DateTime createDate;
    int status;

    factory Questionnaire.fromJson(Map<dynamic, dynamic> json) => Questionnaire(
        name: json["name"],
        questions: List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
        oid: json["oid"],
        createDate: DateTime.parse(json["createDate"]),
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "name": name,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
        "oid": oid,
        "createDate": createDate.toIso8601String(),
        "status": status,
    };
}

class Question {
    Question({
        required this.comentary,
        required this.createData,
        required this.question,
        required this.index,
        required this.questionnaireId,
        required this.id,
        required this.gradingType,
        this.responseVariants,
    });

    String comentary;
    DateTime createData;
    String question;
    int index;
    int questionnaireId;
    int id;
    int gradingType;
    List<ResponseVariant>? responseVariants;

    factory Question.fromJson(Map<dynamic, dynamic> json) => Question(
        comentary: json["comentary"],
        createData: DateTime.parse(json["createData"]),
        question: json["question"],
        index: json["index"],
        questionnaireId: json["questionnaireId"],
        id: json["id"],
        gradingType: json["gradingType"],
        responseVariants: json["responseVariants"] == null ? [] : List<ResponseVariant>.from(json["responseVariants"]!.map((x) => ResponseVariant.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "comentary": comentary,
        "createData": createData.toIso8601String(),
        "question": question,
        "index": index,
        "questionnaireId": questionnaireId,
        "id": id,
        "gradingType": gradingType,
        "responseVariants": responseVariants == null ? [] : List<dynamic>.from(responseVariants!.map((x) => x.toJson())),
    };
}

class ResponseVariant {
    ResponseVariant({
        required this.questionId,
        required this.response,
        required this.id,
    });

    int questionId;
    String response;
    int id;

    factory ResponseVariant.fromJson(Map<dynamic, dynamic> json) => ResponseVariant(
        questionId: json["questionId"],
        response: json["response"],
        id: json["id"],
    );

    Map<dynamic, dynamic> toJson() => {
        "questionId": questionId,
        "response": response,
        "id": id,
    };
}
