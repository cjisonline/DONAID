import 'package:donaid/Services/chatServices.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Accounts {
  Future<bool> signInWithEmail(
      BuildContext context, String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      MyGlobals.currentUser.id = user.user!.uid;
      MyGlobals.currentUser.email = user.user!.email!;
      return true;
    } on FirebaseAuthException catch (error) {
      await EasyLoading.showInfo(error.code, duration: Duration(seconds: 4));
      return false;
    }
  }

  Future<bool> forgetEmail(BuildContext context, String email) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.code, duration: Duration(seconds: 4));
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      MyGlobals.currentUser.id = user.user!.uid;
      MyGlobals.currentUser.email = user.user!.email!;
      return true;
    } on FirebaseAuthException catch (error) {
      await EasyLoading.showInfo(error.code, duration: Duration(seconds: 4));
      return false;
    }
  }

  static bool checkUser() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user != null) {
      MyGlobals.currentUser.id = user.uid;
      return true;
    }
    return false;
  }

  static logoutUser(context) async {
    if (chatListener != null) chatListener.cancel();      chatListener=null;

    FirebaseAuth _auth = FirebaseAuth.instance;
    // MyGlobals.currentUser = '';
    await MyGlobals.myBox.erase();
    await _auth.signOut();
  }
}
