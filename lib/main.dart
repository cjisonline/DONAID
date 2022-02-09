import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:donaid/Registration/registration_screen.dart';
import 'package:flutter/material.dart';
import 'Organization/urgent_case_form.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'Registration/donor_registration_screen.dart';
import 'Registration/organization_registration_screen.dart';
import 'Donor/donor_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const Donaid());
}

class Donaid extends StatelessWidget {
  const Donaid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        DonorRegistrationScreen.id: (context) => const DonorRegistrationScreen(),
        OrganizationRegistrationScreen.id: (context) => const OrganizationRegistrationScreen(),
        DonorDashboard.id: (context) => const DonorDashboard(),
        OrganizationDashboard.id: (context) => const OrganizationDashboard(),
        UrgentForm.id: (context) => const UrgentForm(),
      },
    );
  }
}


