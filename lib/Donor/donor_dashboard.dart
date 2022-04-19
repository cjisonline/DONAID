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
import 'package:donaid/Models/Adoption.dart';
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
  DateTime today = DateTime.now();

  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  int _currentIndex=0;
  List<AdminCarouselImage> adminCarouselImages=[];
  List cardList=[];


  List<Beneficiary> beneficiaries = [];
  List<Adoption> adoptions=[];
  List<dynamic> beneficiariesAndAdoptions=[];
  List<UrgentCase> urgentCases = [];
  List<Organization> organizations = [];
  List<CharityCategory> charityCategories = [];
  var pointlist = [];

  // initializes functions
  @override
  void initState() {
    super.initState();
    handleNotifications();
    _getCurrentUser();
    _getBeneficiariesAndAdoptions();
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
    /*
    * This method is used to set up everything needed for the app to handle notifications
    * */

    //onMessageOpenedApp is called when the app is opened by the user clicking a notification
    //that was sent to their device. When this happens, we direct the user to their notifications page
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return DonorNotificationPage();
      }));

    });
    registerNotification(); //call registerNotification method
    checkForInitialMessage(); //call checkForIntitialMessage method
  }

  checkForInitialMessage() async{
    //getInitialMessage is called when the app is opened from the terminated state by a push
    //notification that was sent to the device
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      addNotification(_auth.currentUser?.uid, initialMessage); //add that notification to the users notification document in the database

      //redirect to notifications page
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return DonorNotificationPage();
      }));
    }
  }

  registerNotification() async {
    //Requests the notifications permission
    NotificationSettings notificationSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true
    );

    //If the user authorizes notifications then the application listens for notifications
    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized)
      {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          //Whenever a notification is receieved, add it to the user's notifications document in the database
          addNotification(_auth.currentUser?.uid, message);

          /*
          * When we receive a notification while the application is open, we show an in-app overlay using showSimpleNotification to show the notification.
          * Firebase Cloud Messaging will automatically create the push notification to the device when the application is closed.
          * */
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
    adoptions.clear();
    beneficiariesAndAdoptions.clear();
    beneficiaries.clear();
    urgentCases.clear();
    organizations.clear();
    charityCategories.clear();
    _getCurrentUser();
    _getBeneficiariesAndAdoptions();
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

  // Get approved organization users from Firebase
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

  // Get charity categories from Firebase
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

  // From Firebase, get active beneficiaries where the end date is after the current date
  // Order the beneficiaries by end date in ascending order
  _getBeneficiariesAndAdoptions() async {

    //Get Beneficiaries from Firestore
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

    //Only display the adoptions if the user is not a guest user
    if(_auth.currentUser?.email != null) {
      //Get Adoptions from Firestore
      var ret2 = await _firestore.collection('Adoptions')
          .where('active', isEqualTo: true)
          .get();

      for (var element in ret2.docs) {
        Adoption adoption = Adoption(
            name: element.data()['name'],
            biography: element.data()['biography'],
            goalAmount: element.data()['goalAmount'].toDouble(),
            amountRaised: element.data()['amountRaised'].toDouble(),
            category: element.data()['category'],
            dateCreated: element.data()['dateCreated'],
            id: element.data()['id'],
            organizationID: element.data()['organizationID'],
            active: element.data()['active']
        );
        adoptions.add(adoption);
      }

      beneficiariesAndAdoptions.addAll(adoptions);
      beneficiariesAndAdoptions.addAll(beneficiaries);
      
      /*The sorting algorithm below is used to sort the list that contains all beneficiaries and adoptions.
      * We sort this list using the algorithm ( [GoalAmount]-[AmountRaised]/[TodayDateTime - DateCreated] ) 
      * This algorithm essentially calculates the average amount of money that each beneficiary/adoption has raised per day since it was
      * created. We then sort the list in descending order based on this algorithm, so that charities that are not raising as much money as fast
      * will be pushed to the top of the list and get more exposure. This sorting algorithm is only used for beneficiaries and adoptions because
      * adoptions don't have an end date so we couldn't sort beneficiariesAndAdoptions by endDate like we do with other lists.
      *  */
      beneficiariesAndAdoptions.sort((b, a) =>
          ((a.goalAmount-a.amountRaised)/today.difference(a.dateCreated.toDate()).inDays).compareTo((b.goalAmount-b.amountRaised)/today.difference(a.dateCreated.toDate()).inDays));
    }
    else{
      beneficiariesAndAdoptions.addAll(beneficiaries);
    }

    setState(() {});

  }

  // From Firebase, get the approved and active urgent cases where the end date is after the current date
  //  Order the urgent cases by end date in ascending order
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
    //Gets the admin carousel images from the database to display on the dashboard
    var ret = await _firestore.collection('AdminCarouselImages').get();

    for(var doc in ret.docs){
      AdminCarouselImage carouselImage = AdminCarouselImage(id: doc.data()['id'], pictureDownloadURL: doc.data()['pictureDownloadURL']);

      adminCarouselImages.add(carouselImage);
    }

    for(var image in adminCarouselImages){
      cardList.add(AdminCarouselCardContent(image));
    }
  }

  // Create donor dashboard
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

  // Create body for donor dashboard
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


            // Categories section of dashboard
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Display category title
                      Text(
                        'categories'.tr,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[650]),
                        textAlign: TextAlign.start,
                      ),
                      // Display see more option
                      // On pressed, navigate to Categories screen
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
            // Display the charity category list
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


            // Organization section of dashboard
            Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display title
                          Text(
                            'organization'.tr,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[650]),
                            textAlign: TextAlign.start,
                          ),
                          // Display see more option
                          // On pressed, navigate to Organization Expanded Screen
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
                // Display organization list
                SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: organizations.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int index) {
                        return OrganizationCard(organizations[index]);
                      },
                    )),


                // Beneficiary section of dashboard
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display title
                          Text(
                            'beneficiaries'.tr,
                            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[650]),
                            textAlign: TextAlign.start,
                          ),
                          // Display see more option
                          // On pressed, navigate to Beneficiary Expanded Screen
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
            // Display the beneficiary list
            beneficiariesAndAdoptions.isNotEmpty
                    ? SizedBox(
                    height: 325.0,
                    child: ListView.builder(
                      itemCount: beneficiariesAndAdoptions.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int index) {
                        return BeneficiaryCard(beneficiariesAndAdoptions[index]);
                      },
                    ))
                    :  Center(child: Text('no_active_beneficiaries_to_show'.tr, style: TextStyle(fontSize: 18),)),


                // Urgent case section of dashboard
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display title
                          Text(
                            'urgent_cases'.tr,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[650]),
                            textAlign: TextAlign.start,
                          ),
                          // Display see more option
                          // On pressed, navigate to Urgent Case Expanded Screen
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
            // Display the urgent case list
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


