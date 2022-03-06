import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                  child: Image.asset('assets/DONAID_LOGO.png')
              ),
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
               child: Material(
                 elevation: 5.0,
                 color: Colors.blue,
                 borderRadius: BorderRadius.circular(30.0),
                 child: MaterialButton(
                   child: const Text(
                     'Login',
                     style: TextStyle(
                       fontSize: 25.0,
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
                        fontSize: 25.0,
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
                  padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
                  child: Material(
                      elevation: 5.0,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                          child: const Text('Guest Login',
                              style: TextStyle(fontSize: 25,color: Colors.white)),
                          onPressed: () async {
                            try {
                              await FirebaseAuth
                                  .instance
                                  .signInAnonymously();
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName(HomeScreen
                                      .id)); //remove all screens on the stack and return to home screen
                              Navigator.pushNamed(
                                  context,
                                  DonorDashboard
                                      .id);
                            } catch (signUpError) {
                              print(signUpError);
                            }
                          }))),




              Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: SignInButton(Buttons.Facebook,
                      onPressed: () async => Auth.fbLogin(context),
                      elevation: 5.0,
                  )),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: SignInButton(Buttons.Google,
                    onPressed: () => Auth.googleLogin(context),
                    elevation: 5.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
