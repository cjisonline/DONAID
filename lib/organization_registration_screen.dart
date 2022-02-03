import 'package:flutter/material.dart';

class OrganizationRegistrationScreen extends StatefulWidget {
  static const id = 'organization_registration_screen';
  const OrganizationRegistrationScreen({Key? key}) : super(key: key);

  @override
  _OrganizationRegistrationScreenState createState() => _OrganizationRegistrationScreenState();
}

class _OrganizationRegistrationScreenState extends State<OrganizationRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
    );;
  }
}
