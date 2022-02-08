import 'package:donaid/OrganizationWidget/form.dart';
import 'package:flutter/material.dart';
///Author: Raisa Zaman
class UrgentForm extends StatelessWidget {
  const UrgentForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DONAID'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white.withAlpha(55),
      body: const MyCustomForm(),
    );
  }
}