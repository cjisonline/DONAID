import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';

class EditCampaign extends StatefulWidget {
  Campaign campaign;

  EditCampaign({Key? key, required this.campaign}) : super(key: key);

  @override
  _EditCampaignState createState() => _EditCampaignState();
}

class _EditCampaignState extends State<EditCampaign> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static final goalRegExp = RegExp(
      r"^(?!0\.00)\d{1,13}(,\d{3})*(\.\d\d)?$"
  );
  var category = [];

  TextEditingController? _campaignTitleController;
  TextEditingController? _campaignDescriptionController;
  TextEditingController? _campaignGoalAmountController;
  TextEditingController? _campaignEndDateController;
  TextEditingController? _campaignCategoryController;

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

  _submitForm(){
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
  }

  _updateCampaign() async{
    _firestore.collection('Campaigns').doc(widget.campaign.id).update({
      "title": _campaignTitleController?.text,
      "description": _campaignDescriptionController?.text,
      "category": _campaignCategoryController?.text,
      "goalAmount": double.parse(_campaignGoalAmountController!.text.toString()),
      "endDate": Timestamp.fromDate(DateTime.parse(_campaignEndDateController!.text.toString())),
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Edit Campaign'),
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
                await _updateCampaign();
                Navigator.pop(context,true);
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
              _buildCampaignTitleField(),
              _buildOrganizationDescriptionField(),
              _buildGoalAmountField(),
              _buildEndDateField(),
              _buildCategoryField(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignTitleField() {
    _campaignTitleController = TextEditingController(text: widget.campaign.title);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _campaignTitleController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Title',
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
              return 'Please enter campaign title.';
            }
            return null;
          },
        ));
  }

  Widget _buildOrganizationDescriptionField() {
    _campaignDescriptionController = TextEditingController(text: widget.campaign.description);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _campaignDescriptionController,
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Campaign Description',
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
    _campaignGoalAmountController = TextEditingController(text: widget.campaign.goalAmount.toString());
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: _campaignGoalAmountController,
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
    var date = DateTime.fromMicrosecondsSinceEpoch(widget.campaign.endDate.microsecondsSinceEpoch);
    _campaignEndDateController = TextEditingController(text: date.toString().substring(0,10));
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _campaignEndDateController,
          readOnly: true,
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter end date.";
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
            _campaignEndDateController?.text = date.toString().substring(0,10);
          },));
  }

  Widget _buildCategoryField(){
    _campaignCategoryController = TextEditingController(text: widget.campaign.category);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField <String>(
          value: _campaignCategoryController?.text,
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
            _campaignCategoryController?.text = val.toString();
          }),
          validator: (value) => value == null
              ? 'Please fill in the category.' : null,
        )
    );
  }
}
