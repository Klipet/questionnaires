

class Questionaires {
    Questionaires? questionnaire;
    String? errorMessage;
    String? errorName;
    int? errorCode;

    Questionaires(
        {this.questionnaire, this.errorMessage, this.errorName, this.errorCode});

    Questionaires.fromJson(Map<String, dynamic> json) {
        questionnaire = json['questionnaire'] != null
            ? new Questionaires.fromJson(json['questionnaire'])
            : null;
        errorMessage = json['errorMessage'];
        errorName = json['errorName'];
        errorCode = json['errorCode'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.questionnaire != null) {
            data['questionnaire'] = this.questionnaire!.toJson();
        }
        data['errorMessage'] = this.errorMessage;
        data['errorName'] = this.errorName;
        data['errorCode'] = this.errorCode;
        return data;
    }
}

class Questionnaire {
    int? oid;
    String? name;
    List<Questions>? questions;
    String? createDate;
    Null? updateDate;
    int? status;

    Questionnaire(
        {this.oid,
            this.name,
            this.questions,
            this.createDate,
            this.updateDate,
            this.status});

    Questionnaire.fromJson(Map<String, dynamic> json) {
        oid = json['oid'];
        name = json['name'];
        if (json['questions'] != null) {
            questions = <Questions>[];
            json['questions'].forEach((v) {
                questions!.add(new Questions.fromJson(v));
            });
        }
        createDate = json['createDate'];
        updateDate = json['updateDate'];
        status = json['status'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['oid'] = this.oid;
        data['name'] = this.name;
        if (this.questions != null) {
            data['questions'] = this.questions!.map((v) => v.toJson()).toList();
        }
        data['createDate'] = this.createDate;
        data['updateDate'] = this.updateDate;
        data['status'] = this.status;
        return data;
    }
}

class Questions {
    int? id;
    int? questionnaireId;
    String? question;
    int? gradingType;
    String? comentary;
    int? index;
    String? createData;
    List<ResponseVariants>? responseVariants;

    Questions(
        {this.id,
            this.questionnaireId,
            this.question,
            this.gradingType,
            this.comentary,
            this.index,
            this.createData,
            this.responseVariants});

    Questions.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        questionnaireId = json['questionnaireId'];
        question = json['question'];
        gradingType = json['gradingType'];
        comentary = json['comentary'];
        index = json['index'];
        createData = json['createData'];
        if (json['responseVariants'] != null) {
            responseVariants = <ResponseVariants>[];
            json['responseVariants'].forEach((v) {
                responseVariants!.add(new ResponseVariants.fromJson(v));
            });
        }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['questionnaireId'] = this.questionnaireId;
        data['question'] = this.question;
        data['gradingType'] = this.gradingType;
        data['comentary'] = this.comentary;
        data['index'] = this.index;
        data['createData'] = this.createData;
        if (this.responseVariants != null) {
            data['responseVariants'] =
                this.responseVariants!.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class ResponseVariants {
    int? id;
    int? questionId;
    String? response;

    ResponseVariants({this.id, this.questionId, this.response});

    ResponseVariants.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        questionId = json['questionId'];
        response = json['response'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['questionId'] = this.questionId;
        data['response'] = this.response;
        return data;
    }
}