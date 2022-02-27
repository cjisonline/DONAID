import 'package:donaid/Models/user.dart';
import 'package:donaid/Models/message.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get_storage/get_storage.dart';

class MyGlobals {
  static GetStorage myBox = GetStorage();
  static UserModel currentUser = UserModel();
  static RxList<MessageModel> allMessages = <MessageModel>[].obs;
}

UserModel currentUser = UserModel();
