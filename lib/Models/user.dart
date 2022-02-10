class UserModel {
  String id = "";
  String name = "";
  String image = "";
  String email = "";
  bool gender = true; //true for male, false for female
  UserModel();
  UserModel.toModel(Map<String, dynamic> jsonMap) {
    email = jsonMap['email'] ?? "";
    id = jsonMap['id'] ?? "";
    gender = jsonMap['gender'] ?? true;
    image = jsonMap['image'] ?? "";
    name = jsonMap['name'] ?? "";
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> jsonMap = {};
    jsonMap['id'] = id;
    jsonMap['email'] = email;
    jsonMap['image'] = image;
    jsonMap['name'] = name;
    jsonMap['gender'] = gender;
    return jsonMap;
  }
}
