import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditAdoption extends StatefulWidget {
  Adoption adoption;

  EditAdoption({Key? key, required this.adoption}) : super(key: key);

  @override
  _EditAdoptionState createState() => _EditAdoptionState();
}

class _EditAdoptionState extends State<EditAdoption> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static final goalRegExp = RegExp(
      r"^(?!0\.00)\d{1,13}(,\d{3})*(\.\d\d)?$"
  );
  var category = [];

  TextEditingController? _adoptionNameController;
  TextEditingController? _adoptionBiographyController;
  TextEditingController? _adoptionGoalAmountController;
  TextEditingController? _adoptionCategoryController;

  @override
  void initState(){
    super.initState();
    _getCategories();
  }


  // get categories from Firebase
  _getCategories() async {
    var ret = await _firestore
        .collection('CharityCategories')
        .get();
    ret.docs.forEach((element) {
      category.add(element.data()['name']);
    });

    setState(() {});
  }

  // Submit and validate from
  _submitForm() async{
    // Information inputted in the form is invalid
    // Show errors
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Information inputted in the form is valid
    // Update adoption's information and navigate to adoption details page
    else{
      await _updateAdoption();
      Navigator.pop(context,true);
    }
    _formKey.currentState!.save();
  }

  // Update current adoption's information in Firebase
  _updateAdoption() async{
    _firestore.collection('Adoptions').doc(widget.adoption.id).update({
      "name": _adoptionNameController?.text,
      "biography": _adoptionBiographyController?.text,
      "category": _adoptionCategoryController?.text,
      "goalAmount": double.parse(_adoptionGoalAmountController!.text.toString()),
    });
  }

  // Display edit adoption page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title:  Text('edit_adoption'.tr),
          leadingWidth: 80,
          // Display cancel button in top app bar
          // On pressed, navigate to the profile page
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancel'.tr,
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
          actions: [
            // Display save button in top app bar
            // On pressed, submit edit adoption form
            TextButton(
              onPressed: () async {
                _submitForm();
              },
              child: Text('save'.tr,
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
              _buildAdoptionNameField(),
              _buildAdoptionBiographyField(),
              _buildGoalAmountField(),
              _buildCategoryField(),

            ],
          ),
        ),
      ),
    );
  }
  // Create name text field and prepopulate adoption's name
  Widget _buildAdoptionNameField() {
    _adoptionNameController = TextEditingController(text: widget.adoption.name);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          readOnly: widget.adoption.amountRaised > 0,
          controller: _adoptionNameController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text:  TextSpan(
                    text: 'name'.tr,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 20.0),
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          validator: (value) {
            // Show error message if text field is left blank
            if (value == null || value.isEmpty) {
              return 'please_enter_adoption_name'.tr;
            }
            return null;
          },
        ));
  }

  // Create biography text field and prepopulate adoption's biography
  Widget _buildAdoptionBiographyField() {
    _adoptionBiographyController = TextEditingController(text: widget.adoption.biography);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: widget.adoption.amountRaised > 0,
        controller: _adoptionBiographyController,
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text: TextSpan(
                  text: 'biography'.tr,
                  style: const TextStyle(
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

  // Create goal amount text field and prepopulate adoption's goal amount
  Widget _buildGoalAmountField(){
    _adoptionGoalAmountController = TextEditingController(text: widget.adoption.goalAmount.toStringAsFixed(2));
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
          readOnly: widget.adoption.amountRaised > 0,
          keyboardType: TextInputType.number,
        controller: _adoptionGoalAmountController,
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

  // Create category drop down menu and prepopulate menu selection with adoption's category
  Widget _buildCategoryField(){
    _adoptionCategoryController = TextEditingController(text: widget.adoption.category);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField <String>(

          value: _adoptionCategoryController?.text,
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
          icon: widget.adoption.amountRaised > 0
              ? Visibility(child: Icon(Icons.keyboard_arrow_down,),visible: false,)
              : Icon(Icons.keyboard_arrow_down),
          items: widget.adoption.amountRaised > 0
              ? [DropdownMenuItem<String>(child: Text(_adoptionCategoryController!.text), value: _adoptionCategoryController!.text,)]
              : category.map((items) {
            return DropdownMenuItem<String>(
              child: Text(items),
              value: items,
            );
          }).toList(),
            onChanged: (val) {
              _adoptionCategoryController?.text = val.toString();
            },
          validator: (value) => value == null
              ? 'please_fill_in_the_category'.tr : null,
        )
    );
  }
}
