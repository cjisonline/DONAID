import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:donaid/localServices.dart';
import 'package:donaid/Models/user.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Auth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly'
  ]);
  static final FacebookAuth _facebookAuth = FacebookAuth.instance;

  static fbLogin(context) async {
    try {
      LoginResult facebookLoginResult =
          await _facebookAuth.login(permissions: ["public_profile", "email"]);
      if (facebookLoginResult.status == LoginStatus.success) {
        String token = facebookLoginResult.accessToken!.token;
        var graphResponse = await Dio().get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),email&access_token=$token');
        final profile = jsonDecode(graphResponse.data);
        AuthCredential authCredential = FacebookAuthProvider.credential(token);
        User? user = (await _auth.signInWithCredential(authCredential)).user;
        if (user == null) {
          EasyLoading.showInfo("something_wrong".tr,
              duration: const Duration(seconds: 3));
        } else {
          currentUser.id = user.uid;
          currentUser.name = profile["name"] ?? "";
          currentUser.email = profile["email"] ?? "";
          try {
            currentUser.image = profile["picture"]["data"]["url"] ?? "";
          } catch (e) {
            print(e);
          }
          await LocalServices.write("user", currentUser.toJSON());
          Navigator.pushNamed(context, DonorDashboard.id);
        }
      } else if (facebookLoginResult.status == LoginStatus.cancelled) {
        EasyLoading.showInfo("login_cancelled_by_user".tr,
            duration: const Duration(seconds: 3));
      } else if (facebookLoginResult.status == LoginStatus.failed) {
        EasyLoading.showInfo(facebookLoginResult.message ?? "",
            duration: const Duration(seconds: 3));
      }
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.message ?? "",
          duration: const Duration(seconds: 3));
    } on PlatformException catch (e) {
      EasyLoading.showInfo(e.message ?? "",
          duration: const Duration(seconds: 3));
    } on Exception catch (e) {
      EasyLoading.showInfo(e.toString(), duration: const Duration(seconds: 3));
    }
  }

  static googleLogin(context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        User? user = (await _auth.signInWithCredential(authCredential)).user;
        if (user == null) {
          EasyLoading.showInfo("something_wrong".tr,
              duration: const Duration(seconds: 3));
        } else {
          currentUser.name = googleSignInAccount.displayName ?? "";
          currentUser.email = googleSignInAccount.email;
          currentUser.image = googleSignInAccount.photoUrl ?? "";
          currentUser.id = user.uid;
          await LocalServices.write("user", currentUser.toJSON());
          Navigator.pushNamed(context, DonorDashboard.id);
        }
      } else {
        EasyLoading.showInfo("something_wrong".tr,
            duration: const Duration(seconds: 3));
      }
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.message.toString(),
          duration: const Duration(seconds: 3));
    } on PlatformException catch (e) {
      EasyLoading.showInfo(e.message.toString(),
          duration: const Duration(seconds: 3));
    } on Exception catch (e) {
      EasyLoading.showInfo(e.toString(), duration: const Duration(seconds: 3));
    }
  }

  static emailSignIn(BuildContext context, String user, password) async {
    try {
      UserCredential fbUser = await _auth.signInWithEmailAndPassword(
          email: user, password: password);
      if (fbUser.user != null) {
        currentUser.id = fbUser.user!.uid;
        await LocalServices.write("user", currentUser.toJSON());
        Navigator.pushNamed(context, DonorDashboard.id);
      } else {
        EasyLoading.showInfo("something_wrong".tr,
            duration: const Duration(seconds: 3));
      }
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.message.toString(),
          duration: const Duration(seconds: 3));
    }
  }

  static emailSignUp(BuildContext context, String user, password) async {
    try {
      UserCredential fbUser = await _auth.createUserWithEmailAndPassword(
          email: user, password: password);
      if (fbUser.user != null) {
        currentUser.id = fbUser.user!.uid;
        // await fbUser.user!.sendEmailVerification();
        await LocalServices.write("user", currentUser.toJSON());
        Navigator.pushNamed(context, DonorDashboard.id);
      } else {
        EasyLoading.showInfo("something_wrong".tr,
            duration: const Duration(seconds: 3));
      }
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.message.toString(),
          duration: const Duration(seconds: 3));
    }
  }

  static getCurrentUser() async {
    var user = LocalServices.read('user');
    if (user == null) {
    } else {
      currentUser = UserModel.toModel(user);
    }
  }

  static Future<bool> appleLogin(context) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
              scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
              nonce: nonce,
              webAuthenticationOptions: WebAuthenticationOptions(
                  clientId: 'com.youme.login',
                  redirectUri: Uri.parse(
                      'https://donaid-d3244.firebaseapp.com/__/auth/handler')));

      OAuthCredential authCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken, rawNonce: rawNonce);
      User? user =
          (await FirebaseAuth.instance.signInWithCredential(authCredential))
              .user;
      if (user == null) {
        EasyLoading.showInfo("something_wrong".tr,
            duration: const Duration(seconds: 3));
        return false;
      } else {
        currentUser.name =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        currentUser.email = '${appleCredential.email}';
        currentUser.image = "";
        currentUser.id = user.uid;
        await LocalServices.write("user", currentUser.toJSON());
        Navigator.pushNamed(context, DonorDashboard.id);
        return true;
      }
    } on FirebaseAuthException catch (error) {
      EasyLoading.showInfo(error.message.toString(),
          duration: const Duration(seconds: 3));
    } on PlatformException catch (e) {
      EasyLoading.showInfo(e.message.toString(),
          duration: const Duration(seconds: 3));
    } on Exception catch (e) {
      EasyLoading.showInfo(e.toString(), duration: const Duration(seconds: 3));
    }
    return false;
  }

  static Future<bool> logOut() async {
    try {
      if (chatListener != null) chatListener.cancel();
      chatListener = null;
      await _auth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print(e);
      }
      try {
        await _facebookAuth.logOut();
      } catch (e) {
        print(e);
      }
      try {
        await LocalServices.clear();
      } catch (e) {
        print(e);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
