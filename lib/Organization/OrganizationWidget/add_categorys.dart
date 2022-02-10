import 'package:flutter/material.dart';
import '../organization_dashboard.dart';
import 'category_layout.dart';
///Author: Raisa Zaman
class Category extends StatelessWidget {
  List<Beneficiary> beneficiaries0 =[];
  Category(beneficiaries){
    beneficiaries0 = beneficiaries;
    print(beneficiaries0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: beneficiaries0.length,
      shrinkWrap: true,
      itemBuilder: (context, int index) {
        return CategorySection(beneficiaries0[index].name);
      },
    );
  }
}