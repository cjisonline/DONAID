import 'package:donaid/pages/registration_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(Donaid());
}

class Donaid extends StatelessWidget {
  const Donaid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
      },
    );
  }
}


