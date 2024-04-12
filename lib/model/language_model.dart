class LanguageModel{
  String? code;
  String? name;
  LanguageModel({this.name, this.code});
  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}