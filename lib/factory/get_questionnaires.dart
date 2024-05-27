class GetQuestionnaires {
  final int oid;
  final String name;
  final String createDate;
  final String updateDate;
  final int status;
  final String errorMessage;
  final String errorName;
  final int errorCode;

  const GetQuestionnaires({
    required this.oid,
    required this.name,
    required this.createDate,
    required this.updateDate,
    required this.status,
    required this.errorMessage,
    required this.errorName,
    required this.errorCode
  });

  factory GetQuestionnaires.fromJson(Map<String, dynamic> json) {
    return GetQuestionnaires(
      oid: json['oid']?? 0,
      name: json['name']?? '',
      createDate: json['createDate']?? '',
      updateDate: _toDate(json['updateDate']) ?? 'Null',
      status: json['status'] ?? 0,
      errorMessage: json['errorMessage'] ?? '',
      errorName: json['errorName'] ?? '',
      errorCode: json['errorCode']?? 0,
    );
  }

  static String _toDate(dynamic date) {
    if (date == null) {
      return ''; // or any other default value as per your requirement
    } else if (date is String) {
      return ''; // if date is already a string, return it
    } else {
      // Handle other cases if needed
      return '';
    }
  }
}
