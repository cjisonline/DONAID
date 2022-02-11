import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class LocalServices {
  static final GetStorage _myBox = GetStorage();

  static read(key) {
    var temp = _myBox.read(key);
    return temp;
  }

  static write(key, value) async {
    await _myBox.write(key, value);
  }

  static clear() async {
    //when logout
    await _myBox.erase();
  }
}
