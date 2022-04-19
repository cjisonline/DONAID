import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCampaign extends StatefulWidget {
  Campaign campaign;

  EditCampaign({Key? key, required this.campaign}) : super(key: key);

  @override
  _EditCampaignState createState() => _EditCampaignState();
}

class _EditCampaignState extends State<EditCampaign> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int campaignTimeLimit=0;

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
    _getTimeLimit();
  }

  _getTimeLimit() async {
    //Get the campaign time limit that is in the AdminRestrictions collection in Firestore.
    //The time limit is given in number of days and can be edited from the admin panel
    var ret = await _firestore.collection('AdminRestrictions').where('id',isEqualTo: 'CharityDurationLimits').get();

    var doc = ret.docs[0];
    campaignTimeLimit = doc['campaigns'];
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
      await _updateCampaign();
      Navigator.pop(context,true);
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
          title:  Text('edit_campaign'.tr),
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
              _buildCampaignTitleField(),
              _buildCampaignDescriptionField(),
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
          readOnly: widget.campaign.amountRaised > 0,//title cannot be edited if some money has been raised
          controller: _campaignTitleController,
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
              return 'please_enter_campaign_title.'.tr;
            }
            return null;
          },
        ));
  }

  Widget _buildCampaignDescriptionField() {
    _campaignDescriptionController = TextEditingController(text: widget.campaign.description);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: widget.campaign.amountRaised > 0,
        controller: _campaignDescriptionController,//description cannot be edited if some money has been raised
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text:  TextSpan(
                  text: 'campaign_description'.tr,
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
    _campaignGoalAmountController = TextEditingController(text: widget.campaign.goalAmount.toStringAsFixed(2));
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: widget.campaign.amountRaised > 0,//goal amount cannot be edited if some money has been raised
        keyboardType: TextInputType.number,
        controller: _campaignGoalAmountController,
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
    var date = DateTime.fromMicrosecondsSinceEpoch(widget.campaign.endDate.microsecondsSinceEpoch);
    _campaignEndDateController = TextEditingController(text: date.toString().substring(0,10));
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _campaignEndDateController,
          readOnly: true,//this makes it so that text cannot be entered in this field, and the user must use the date picker
          validator: (value) {
            /*Validator ensures the field isn't empty and checks the selected end date against the time limit from
            * the AdminRestrictions collection. The number of days between the current date and the selected end date must be
            * less than the time limit. */
            if (value!.isEmpty) {
              return "please_enter_end_date.".tr;
            }
            if(DateTime.parse(value).difference(DateTime.now()).inDays > campaignTimeLimit){
              return 'campaigns_cannot_have_a_duration_longer_than_1_year.'.tr;
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
            if(widget.campaign.amountRaised < widget.campaign.goalAmount){
              //only show the date picker if the goal amount has not been reached
              //If the goal has been reached, do not show date picker so that the campaign
              //cannot be extended
              var date =  await showDatePicker(
                  context: context,
                  initialDate:DateTime.now(),
                  firstDate:DateTime.now(),
                  lastDate: DateTime(2100));
              _campaignEndDateController?.text = date.toString().substring(0,10);
            }
            else{
              return;
            }
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
          icon: widget.campaign.amountRaised > 0
              ? Visibility(child: Icon(Icons.keyboard_arrow_down,),visible: false,)
              : Icon(Icons.keyboard_arrow_down),
          //If some money has been raised, do not show category options, so that category cannot be edited
          items: widget.campaign.amountRaised > 0
              ? [DropdownMenuItem<String>(child: Text(_campaignCategoryController!.text), value: _campaignCategoryController!.text,)]
              : category.map((items) {
            return DropdownMenuItem<String>(
              child: Text(items),
              value: items,
            );
          }).toList(),
          onChanged: (val) {
            _campaignCategoryController?.text = val.toString();
          },
          validator: (value) => value == null
              ? 'please_fill_in_the_category'.tr : null,
        )
    );
  }
}
