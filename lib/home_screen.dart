import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get_storage/get_storage.dart';
import 'authentication.dart';
import 'login_screen.dart';
import 'Registration/registration_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'main.dart';


class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
             child: Material(
               elevation: 5.0,
               color: Colors.blue,
               borderRadius: BorderRadius.circular(30.0),
               child: MaterialButton(
                 child: const Text(
                   'Login',
                   style: TextStyle(
                     color: Colors.white,
                   ),
                 ),
                 onPressed: (){
                   Navigator.pushNamed(context, LoginScreen.id);
                 },
               ),
             ),
           ),

            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
              child: Material(
                elevation: 5.0,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                ),
              ),
            ),

            Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: SignInButton(Buttons.Facebook,
                    onPressed: () async => Auth.fbLogin(context))),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: SignInButton(Buttons.Google,
                  onPressed: () => Auth.googleLogin(context)),
            )
          ],
        ),
      ),
    );
  }
}
