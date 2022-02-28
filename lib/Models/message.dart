import 'package:firebase_database/firebase_database.dart';

class MessageModel {
  String senderId = "";
  String id = "";
  String receiverId = "";
  String body = "";
  String recname = "";
  DateTime creationDate = DateTime(1000);
  String type = "text";

  MessageModel();

  MessageModel.toModel(key, jsonMap) {
    body = jsonMap['body'] ?? "";
    id = key ?? "";
    senderId = jsonMap['senderId'] ?? "";
    creationDate = DateTime.fromMicrosecondsSinceEpoch(jsonMap['creationDate']);
    type = jsonMap['type'] ?? "";
  }

  Map<String, dynamic> toSendMessageJSON() {
    Map<String, dynamic> jsonMap = Map<String, dynamic>();
    jsonMap['body'] = this.body;
    jsonMap['type'] = this.type;
    jsonMap['senderId'] = this.senderId;
    this.creationDate = DateTime.now();
    jsonMap["creationDate"] = ServerValue.timestamp;
    return jsonMap;
  }
}
