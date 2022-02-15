import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  static const id = 'categories_screen';
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      drawer: const DonorDrawer(),
    );
  }
}
