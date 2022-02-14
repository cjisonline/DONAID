import 'package:flutter/material.dart';
import 'donor_registration_screen.dart';
import 'organization_registration_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = 'registration_screen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int userType=-1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Register'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child:  Text(
              'Select the type of account:',
              style: TextStyle(
                fontSize: 24.0
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
            child: Material(
              elevation: 5.0,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30.0),
              child: MaterialButton(
                height: 60.0,
                child: const Text(
                  'Donor',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, DonorRegistrationScreen.id);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
            child: Material(
              elevation: 5.0,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30.0),
              child: MaterialButton(
                height: 60.0,
                child: const Text(
                  'Organization',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, OrganizationRegistrationScreen.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
