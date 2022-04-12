import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/admin_carousal_card_content.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/DonorWidgets/organization_card.dart';
import 'package:donaid/Donor/DonorWidgets/urgent_case_card.dart';
import 'package:donaid/Donor/beneficiaries_expanded_screen.dart';
import 'package:donaid/Donor/categories_screen.dart';
import 'package:donaid/Donor/organizations_expanded_screen.dart';
import 'package:donaid/Donor/urgent_cases_expanded_screen.dart';
import 'package:donaid/Models/AdminCarouselImage.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/CharityCategory.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Donor/DonorWidgets/beneficiary_card.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/notifications.dart';
import 'notifications_page.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();

  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  int _currentIndex=0;
  List<AdminCarouselImage> adminCarouselImages=[];
  List cardList=[];


  List<Beneficiary> beneficiaries = [];
  List<UrgentCase> urgentCases = [];
  List<Organization> organizations = [];
  List<CharityCategory> charityCategories = [];
  var pointlist = [];


  @override
  void initState() {
    super.initState();
    handleNotifications();
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();
    _getCarouselImagesAndCardList();

    if(_auth.currentUser?.email != null){
      _getFavorite();
    }

    Get.find<ChatService>().getFriendsData(loggedInUser!.uid);
    Get.find<ChatService>().listenFriend(loggedInUser!.uid, 0);
  }

  handleNotifications()async{
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return DonorNotificationPage();
      }));

    });
    registerNotification();
    checkForInitialMessage();
  }

  checkForInitialMessage() async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      addNotification(_auth.currentUser?.uid, initialMessage);
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return DonorNotificationPage();
      }));
    }
  }

  registerNotification() async {
    NotificationSettings notificationSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true
    );

    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized)
      {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          addNotification(_auth.currentUser?.uid, message);

          if(message.notification!=null){
            showSimpleNotification(
              Text(message.notification!.title!),
              subtitle: Text(message.notification!.body!),
              duration: Duration(seconds: 5),
              slideDismissDirection: DismissDirection.up,

            );
          }
        });
      }
    else{
      print("Permission declined by user.");
    }
  }

  _refreshPage() {
    beneficiaries.clear();
    urgentCases.clear();
    organizations.clear();
    charityCategories.clear();
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();

    if(_auth.currentUser?.email != null){
      _getFavorite();
    }

    setState(() {});
}

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getFavorite() async {
    if(loggedInUser?.email != null) {
      await _firestore.collection("Favorite").doc(loggedInUser!.uid)
          .get()
          .then((value) {
        setState(() {
          pointlist = List.from(value['favoriteList']);
        });
      });
    }
  }


  _getOrganizationUsers() async {
    var ret = await _firestore.collection('OrganizationUsers').where('approved', isEqualTo: true).get();
    for (var element in ret.docs) {
      Organization organization = Organization(
        organizationName: element.data()['organizationName'],
        uid: element.data()['uid'],
        organizationDescription: element.data()['organizationDescription'],
        country: element.data()['country'],
        gatewayLink: element.data()['gatewayLink'],
        profilePictureDownloadURL: element.data()['profilePictureDownloadURL']
      );
      organizations.add(organization);
    }
    setState(() {});
  }


  _getCharityCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    for (var element in ret.docs) {
      CharityCategory charityCategory = CharityCategory(
        name: element.data()['name'],
        id: element.data()['id'],
        iconDownloadURL:element.data()['iconDownloadURL']
      );
      charityCategories.add(charityCategory);
    }
    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('active',isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();
    for (var element in ret.docs) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active']
      );
      beneficiaries.add(beneficiary);
    }
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('approved',isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();

    for (var element in ret.docs) {
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active'],
          rejected: element.data()['rejected'],
          approved: element.data()['approved']
      );
      urgentCases.add(urgentCase);
    }
    setState(() {});
  }

  _getCarouselImagesAndCardList() async{
    var ret = await _firestore.collection('AdminCarouselImages').get();

    for(var doc in ret.docs){
      AdminCarouselImage carouselImage = AdminCarouselImage(id: doc.data()['id'], pictureDownloadURL: doc.data()['pictureDownloadURL']);

      adminCarouselImages.add(carouselImage);
    }

    for(var image in adminCarouselImages){
      cardList.add(AdminCarouselCardContent(image));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('dashboard'.tr),
      ),
      drawer: const DonorDrawer(),
      body:_body() ,
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }

  _body() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
      child: Container(
      decoration: BoxDecoration(
      color: Colors.blueGrey.shade50,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: Colors.grey.shade100)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: cardList.map((card){
                return Builder(
                    builder:(BuildContext context){
                      return Container(
                        height: MediaQuery.of(context).size.height*0.30,
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: card,
                        ),
                      );
                    }
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'categories'.tr,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())).then((value) => _refreshPage());
                        },
                        child:  Text(
                          'see_more'.tr,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ]),
              ),
            ),
            SizedBox(
                height: 75.0,
                child: ListView.builder(
                  itemCount: charityCategories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return CharityCategoryCard(
                        charityCategories[index].name, charityCategories[index].iconDownloadURL);
                  },
                )),

                // organization list
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'organization'.tr,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizationsExpandedScreen())).then((value) => _refreshPage());
                            },
                            child:  Text(
                              'see_more'.tr,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ]),
                  ),
                ),
                SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: organizations.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int index) {
                        return OrganizationCard(organizations[index]);
                      },
                    )),

                //beneficiaries list
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'beneficiaries'.tr,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => BeneficiaryExpandedScreen())).then((value) => _refreshPage());
                            },
                            child:  Text(
                              'see_more'.tr,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ]),
                  ),
                ),
                beneficiaries.isNotEmpty
                    ? SizedBox(
                    height: 325.0,
                    child: ListView.builder(
                      itemCount: beneficiaries.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int index) {
                        return BeneficiaryCard(beneficiaries[index]);
                      },
                    ))
                    :  Center(child: Text('no_active_beneficiaries_to_show'.tr, style: TextStyle(fontSize: 18),)),

                // urgent case list
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'urgent_cases'.tr,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UrgentCasesExpandedScreen())).then((value) => _refreshPage());
                            },
                            child:  Text(
                              'see_more'.tr,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ]),
                  ),
                ),
                urgentCases.isNotEmpty
                    ? SizedBox(
                    height: 325.0,
                    child: ListView.builder(
                      itemCount: urgentCases.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int index) {
                        return UrgentCaseCard(urgentCases[index]);
                      },
                    ))
                    :  Center(child: Text('no_active_urgent_sases_show'.tr, style: TextStyle(fontSize: 18),)),
              ],
            ),
          )),
    );
  }
}


