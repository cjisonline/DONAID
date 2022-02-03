import 'package:donaid/registration_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'donor_registration_screen.dart';
import 'organization_registration_screen.dart';
import 'donor_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
        DonorRegistrationScreen.id: (context) => DonorRegistrationScreen(),
        OrganizationRegistrationScreen.id: (context) => OrganizationRegistrationScreen(),
        DonorDashboard.id: (context) => DonorDashboard(),
      },
    );
  }
}


