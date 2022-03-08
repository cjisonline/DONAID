import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';

class EditBeneficiary extends StatefulWidget {
  Beneficiary beneficiary;

  EditBeneficiary({Key? key, required this.beneficiary}) : super(key: key);

  @override
  _EditBeneficiaryState createState() => _EditBeneficiaryState();
}

class _EditBeneficiaryState extends State<EditBeneficiary> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int beneficiaryTimeLimit=0;

  static final goalRegExp = RegExp(
      r"^(?!0\.00)\d{1,13}(,\d{3})*(\.\d\d)?$"
  );
  var category = [];

  TextEditingController? _beneficiaryNameController;
  TextEditingController? _beneficiaryBiographyController;
  TextEditingController? _beneficiaryGoalAmountController;
  TextEditingController? _beneficiaryEndDateController;
  TextEditingController? _beneficiaryCategoryController;

  @override
  void initState(){
    super.initState();
    _getCategories();
    _getTimeLimit();
  }

  _getTimeLimit() async {
    var ret = await _firestore.collection('AdminRestrictions').where('id',isEqualTo: 'CharityDurationLimits').get();

    var doc = ret.docs[0];
    beneficiaryTimeLimit = doc['beneficiaries'];
  }

  _getCategories() async {
    var ret = await _firestore
        .collection('CharityCategories')
        .get();
    ret.docs.forEach((element) {
      category.add(element.data()['name']);
    });

    setState(() {});
  }

  _submitForm() async{
    if (!_formKey.currentState!.validate()) {
      return;
    }
    else{
      await _updateBeneficiary();
      Navigator.pop(context,true);
    }
    _formKey.currentState!.save();
  }

  _updateBeneficiary() async{
    _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
      "name": _beneficiaryNameController?.text,
      "biography": _beneficiaryBiographyController?.text,
      "category": _beneficiaryCategoryController?.text,
      "goalAmount": double.parse(_beneficiaryGoalAmountController!.text.toString()),
      "endDate": Timestamp.fromDate(DateTime.parse(_beneficiaryEndDateController!.text.toString())),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Edit Beneficiary'),
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel',
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _submitForm();
              },
              child: const Text('Save',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      body: _body(),
      bottomNavigationBar: OrganizationBottomNavigation(),
    );
  }


  _body(){
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildCampaignNameField(),
              _buildBeneficiaryBiographyField(),
              _buildGoalAmountField(),
              _buildEndDateField(),
              _buildCategoryField(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignNameField() {
    _beneficiaryNameController = TextEditingController(text: widget.beneficiary.name);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _beneficiaryNameController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Name',
                    style: TextStyle(
                        color: Colors.black, fontSize: 20.0),
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter beneficiary name.';
            }
            return null;
          },
        ));
  }

  Widget _buildBeneficiaryBiographyField() {
    _beneficiaryBiographyController = TextEditingController(text: widget.beneficiary.biography);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _beneficiaryBiographyController,
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Biography',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20.0),
                ),
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            )),
      ),
    );
  }

  Widget _buildGoalAmountField(){
    _beneficiaryGoalAmountController = TextEditingController(text: widget.beneficiary.goalAmount.toStringAsFixed(2));
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: _beneficiaryGoalAmountController,
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter a goal amount.";
          }else if (!goalRegExp.hasMatch(value)){
            return "Please enter a valid goal amount.";
          }
          else {
            return null;
          }
        },
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                  text: TextSpan(
                      text: 'Goal Amount',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 20.0),
                      children: const [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ])),
            ),
            border: const OutlineInputBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(32.0)),
            )),
      ),
    );
  }

  Widget _buildEndDateField(){
    var date = DateTime.fromMicrosecondsSinceEpoch(widget.beneficiary.endDate.microsecondsSinceEpoch);
    _beneficiaryEndDateController = TextEditingController(text: date.toString().substring(0,10));
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _beneficiaryEndDateController,
          readOnly: true,
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter end date.";
            }
            else if(DateTime.parse(value).difference(DateTime.now()).inDays > beneficiaryTimeLimit){
              return 'Beneficiaries cannot have a duration longer than 1 year.';
            }
            else {
              return null;
            }
          },
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'Enter End Date',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 20.0),
                        children: const [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              )),
                        ])),
              ),
              border: const OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(32.0)),
              )
          ),
          onTap: () async {
            var date =  await showDatePicker(
                context: context,
                initialDate:DateTime.now(),
                firstDate:DateTime.now(),
                lastDate: DateTime(2100));
            _beneficiaryEndDateController?.text = date.toString().substring(0,10);
          },));
  }

  Widget _buildCategoryField(){
    _beneficiaryCategoryController = TextEditingController(text: widget.beneficiary.category);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField <String>(
          value: _beneficiaryCategoryController?.text,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'Category',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 20.0),
                        children: const [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              )),
                        ])),
              ),
              border: const OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(32.0)),
              )),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: category == null? []: category.map((items) {
            return DropdownMenuItem<String>(
              child: Text(items),
              value: items,
            );
          }).toList(),
          onChanged: (val) => setState(() {
            _beneficiaryCategoryController?.text = val.toString();
          }),
          validator: (value) => value == null
              ? 'Please fill in the category.' : null,
        )
    );
  }
}
