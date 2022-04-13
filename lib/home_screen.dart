import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Donor/donor_dashboard.dart';
import 'authentication.dart';
import 'login_screen.dart';
import 'Registration/registration_screen.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setLanguage();
    checkAuthState();
  }

  checkAuthState() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User signed out.');
      } else {
        var userRef = await _firestore
            .collection('Users')
            .where('uid', isEqualTo: user.uid)
            .get();
        var userDoc = userRef.docs.first;

        var userType = userDoc.data()['userType'];

        if (userType == 1) {
          Navigator.pushNamed(context, DonorDashboard.id);
        } else if (userType == 2) {
          Navigator.pushNamed(context, OrganizationDashboard.id);
        }
      }
    });
  }

  _setLanguage()async{
    final SharedPreferences prefs = await _prefs;
    List<String>? locale = prefs.getStringList('Locale');

    if(locale![0].toString() == 'en' && locale[1].toString() == 'US'){
      await Get.updateLocale(
          const Locale('en', 'US'));
    }
    else if(locale![0].toString() == 'fr' && locale![1].toString() == 'FR'){
      await Get.updateLocale(
          const Locale('fr', 'FR'));
    }
    else if(locale![0].toString() == 'ar' && locale![1].toString() == 'SA'){
      await Get.updateLocale(
          const Locale('ar', 'SA'));
    }
    else if(locale![0].toString() == 'es' && locale![1].toString() == 'ES'){
      await Get.updateLocale(
          const Locale('es', 'ES'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  const SizedBox(height: 15),
                  SizedBox(
                      height: 150,
                      child: Image.asset('assets/DONAID_LOGO.png')),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 5.0),
                      child: Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                          child: MaterialButton(
                              child: Text('login'.tr,
                                  style: TextStyle(
                                      fontSize: 25.0, color: Colors.white)),
                              onPressed: () {
                                Navigator.pushNamed(context, LoginScreen.id);
                              }))),
                  const SizedBox(height: 10.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 5.0),
                      child: Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                          child: MaterialButton(
                              child: Text('register'.tr,
                                  style: const TextStyle(
                                      fontSize: 25.0, color: Colors.white)),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RegistrationScreen.id);
                              }))),
                  Padding (
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 5.0),
                      child: Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                          child: MaterialButton(
                              child: Center(
                                child: Text('guest_login'.tr,
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.white)),
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseAuth.instance
                                      .signInAnonymously();
                                  Navigator.of(context).popUntil(
                                      ModalRoute.withName(HomeScreen.id));
                                  Navigator.pushNamed(
                                      context, DonorDashboard.id);
                                } catch (signUpError) {
                                  // print(signUpError);
                                }
                              }))),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: SignInButton(Buttons.Facebook,
                          onPressed: () async => Auth.fbLogin(context),
                          elevation: 5.0)),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: SignInButton(Buttons.Google,
                          onPressed: () => Auth.googleLogin(context),
                          elevation: 5.0)),
                  if (GetPlatform.isIOS)
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: SignInButton(Buttons.Apple,
                            onPressed: () => Auth.appleLogin(context),
                            elevation: 5.0)),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(15))),
                                        title: Center(child: Text("select_language".tr)),
                                        children: <Widget>[
                                          SimpleDialogOption(
                                              onPressed: () async {
                                                final SharedPreferences prefs = await _prefs;
                                                prefs.setStringList('Locale', ['en','US']);

                                                await Get.updateLocale(
                                                    const Locale('en', 'US'));
                                                Navigator.pop(context);
                                              },
                                              child: const Center(child: Text("English"))),
                                          SimpleDialogOption(
                                              onPressed: () async {
                                                final SharedPreferences prefs = await _prefs;
                                                prefs.setStringList('Locale', ['fr','FR']);

                                                await Get.updateLocale(
                                                    const Locale('fr', 'FR'));
                                                Navigator.pop(context);
                                              },
                                              child: const Center(child: Text("French"))),
                                          SimpleDialogOption(
                                              onPressed: () async {
                                                final SharedPreferences prefs = await _prefs;
                                                prefs.setStringList('Locale', ['ar','SA']);

                                                await Get.updateLocale(
                                                    const Locale('ar', 'SA'));
                                                Navigator.pop(context);
                                              },
                                              child: const Center(child: Text("Arabic"))),
                                          SimpleDialogOption(
                                              onPressed: () async {
                                                final SharedPreferences prefs = await _prefs;
                                                prefs.setStringList('Locale', ['es','ES']);

                                                await Get.updateLocale(
                                                    const Locale('es', 'ES'));
                                                Navigator.pop(context);
                                              },
                                              child: const Center(child: Text("Spanish")))
                                        ]);
                                  });
                            },
                            splashColor: Colors.white60,
                            child: Container(
                              width: 150,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text("language".tr,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ))
                      ]),
                ]))));
  }
}
