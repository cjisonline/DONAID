import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';

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
      await _updateAdoption();
      Navigator.pop(context,true);
    }
    _formKey.currentState!.save();
  }

  _updateAdoption() async{
    _firestore.collection('Adoptions').doc(widget.adoption.id).update({
      "name": _adoptionNameController?.text,
      "biography": _adoptionBiographyController?.text,
      "category": _adoptionCategoryController?.text,
      "goalAmount": double.parse(_adoptionGoalAmountController!.text.toString()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Edit Adoption'),
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

  Widget _buildAdoptionNameField() {
    _adoptionNameController = TextEditingController(text: widget.adoption.name);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _adoptionNameController,
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
              return 'Please enter adoption name.';
            }
            return null;
          },
        ));
  }

  Widget _buildAdoptionBiographyField() {
    _adoptionBiographyController = TextEditingController(text: widget.adoption.biography);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _adoptionBiographyController,
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
    _adoptionGoalAmountController = TextEditingController(text: widget.adoption.goalAmount.toStringAsFixed(2));
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: _adoptionGoalAmountController,
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
            onChanged: (val) {
              _adoptionCategoryController?.text = val.toString();
            },
          validator: (value) => value == null
              ? 'Please fill in the category.' : null,
        )
    );
  }
}