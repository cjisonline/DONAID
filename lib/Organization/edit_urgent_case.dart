import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/UrgentCase.dart';

class EditUrgentCase extends StatefulWidget {
  UrgentCase urgentCase;

  EditUrgentCase({Key? key, required this.urgentCase}) : super(key: key);

  @override
  _EditUrgentCaseState createState() => _EditUrgentCaseState();
}

class _EditUrgentCaseState extends State<EditUrgentCase> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int urgentCaseTimeLimit=0;

  static final goalRegExp = RegExp(
      r"^(?!0\.00)\d{1,13}(,\d{3})*(\.\d\d)?$"
  );
  var category = [];

  TextEditingController? _urgentCaseTitleController;
  TextEditingController? _urgentCaseDescriptionController;
  TextEditingController? _urgentCaseGoalAmountController;
  TextEditingController? _urgentCaseEndDateController;
  TextEditingController? _urgentCaseCategoryController;

  @override
  void initState(){
    super.initState();
    _getCategories();
    _getTimeLimit();
  }

  _getTimeLimit() async {
    var ret = await _firestore.collection('AdminRestrictions').where('id',isEqualTo: 'CharityDurationLimits').get();

    var doc = ret.docs[0];
    urgentCaseTimeLimit = doc['urgentCases'];
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

  _submitForm()async{
    if (!_formKey.currentState!.validate()) {
      return;
    }
    else{
      await _updateUrgentCase();
      Navigator.pop(context,true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Urgent case resubmitted!')));
    }
    _formKey.currentState!.save();
  }

  _updateUrgentCase()async{
    _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
      "title": _urgentCaseTitleController?.text,
      "description": _urgentCaseDescriptionController?.text,
      "category": _urgentCaseCategoryController?.text,
      "goalAmount": double.parse(_urgentCaseGoalAmountController!.text.toString()),
      "endDate": Timestamp.fromDate(DateTime.parse(_urgentCaseEndDateController!.text.toString())),
      "rejected":false,
      "denialReason":""
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title:  Text('Edit Urgent Case'.tr),
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text('cancel'.tr,
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _submitForm();

              },
              child:  Text('save'.tr,
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
              _buildUrgentCaseTitleField(),
              _buildUrgentCaseDescriptionField(),
              _buildGoalAmountField(),
              _buildEndDateField(),
              _buildCategoryField(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentCaseTitleField() {
    _urgentCaseTitleController = TextEditingController(text: widget.urgentCase.title);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          readOnly: widget.urgentCase.amountRaised > 0,
          controller: _urgentCaseTitleController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text:  TextSpan(
                    text: 'title'.tr,
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
              return 'please_enter_a_title.'.tr;
            }
            return null;
          },
        ));
  }

  Widget _buildUrgentCaseDescriptionField() {
    _urgentCaseDescriptionController = TextEditingController(text: widget.urgentCase.description);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: widget.urgentCase.amountRaised > 0,
        controller: _urgentCaseDescriptionController,
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text:  TextSpan(
                  text: 'please_enter_a_description.'.tr,
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
    _urgentCaseGoalAmountController = TextEditingController(text: widget.urgentCase.goalAmount.toStringAsFixed(2));
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: widget.urgentCase.amountRaised > 0,
        keyboardType: TextInputType.number,
        controller: _urgentCaseGoalAmountController,
        validator: (value) {
          if (value!.isEmpty) {
            return "please_enter_a_goal_amount.".tr;
          }else if (!goalRegExp.hasMatch(value)){
            return "please_enter_a_valid_goal_amount".tr;
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
                      text: 'goal_amount'.tr,
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
    var date = DateTime.fromMicrosecondsSinceEpoch(widget.urgentCase.endDate.microsecondsSinceEpoch);
    _urgentCaseEndDateController = TextEditingController(text: date.toString().substring(0,10));
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _urgentCaseEndDateController,
          readOnly: true,
          validator: (value) {
            if (value!.isEmpty) {
              return "please_enter_end_date.".tr;
            }
            if(DateTime.parse(value).difference(DateTime.now()).inDays > urgentCaseTimeLimit){
              return 'urgent_cases_cannot_have_a_duration_longer'.tr;
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
                        text: 'enter_end_date'.tr,
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
            if(widget.urgentCase.amountRaised < widget.urgentCase.goalAmount){
              var date =  await showDatePicker(
                  context: context,
                  initialDate:DateTime.now(),
                  firstDate:DateTime.now(),
                  lastDate: DateTime(2100));
              _urgentCaseEndDateController?.text = date.toString().substring(0,10);
            }
            else{
              return;
            }
          },));
  }

  Widget _buildCategoryField(){
    _urgentCaseCategoryController = TextEditingController(text: widget.urgentCase.category);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField <String>(
          value: _urgentCaseCategoryController?.text,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                    text: TextSpan(
                        text: 'category'.tr,
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
          onChanged: (val) {
            _urgentCaseCategoryController?.text = val.toString();
          },
          validator: (value) => value == null
              ? 'please_fill_in_the_category'.tr : null,
        )
    );
  }
}
