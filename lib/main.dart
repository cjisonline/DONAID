import 'package:donaid/Donor/beneficiaries_expanded_screen.dart';
import 'package:donaid/Donor/categories_screen.dart';
import 'package:donaid/Donor/donor_favorite_screen.dart';
import 'package:donaid/Donor/donor_search_screen.dart';
import 'package:donaid/Donor/notifications_page.dart';
import 'package:donaid/Donor/organizations_expanded_screen.dart';
import 'package:donaid/Donor/urgent_cases_expanded_screen.dart';
import 'package:donaid/Organization/add_beneficiary_screen.dart';
import 'package:donaid/Organization/add_urgentcase_screen.dart';
import 'package:donaid/Donor/donor_edit_profile.dart';
import 'package:donaid/Donor/donor_profile.dart';
import 'package:donaid/Organization/gateway_visits.dart';
import 'package:donaid/Organization/notifications_page.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:donaid/Organization/organization_edit_profile.dart';
import 'package:donaid/Organization/organization_profile.dart';
import 'package:donaid/Registration/registration_screen.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:donaid/Translations/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'Donor/donation_history.dart';
import 'Donor/settings.dart';
import 'Organization/add_campaigns_screen.dart';
import 'Organization/add_selection_screen.dart';
import 'Organization/search_page.dart';
import 'Organization/organization_activebeneficiaries_expanded_screen.dart';
import 'Organization/organization_activecampaigns_expanded_screen.dart';
import 'Organization/organization_activeurgentcases_expanded_screen.dart';
import 'Organization/settings.dart';
import 'Services/notifications.dart';
import 'authentication.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'Registration/donor_registration_screen.dart';
import 'Registration/organization_registration_screen.dart';
import 'Donor/donor_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  await Firebase.initializeApp();
  final _auth = FirebaseAuth.instance;
  if (_auth.currentUser != null) {
    addNotification(_auth.currentUser?.uid, message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51KTuiGEvfimLlZrsjvlq3mE1JEa8nGiejkGVgw9MvqJd9viDPIXCbUGbWp1QaXf50sQIQs3MNWlVjp99VAruB0qW00xrE9kMs7';

  Stripe.merchantIdentifier = 'Donaid';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  await Auth.getCurrentUser();
  Get.put(ChatService());
  runApp(const Donaid());
}

class Donaid extends StatelessWidget {
  const Donaid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
          builder: EasyLoading.init(),
          theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity),
          initialRoute: HomeScreen.id,
          routes: {
            HomeScreen.id: (context) => const HomeScreen(),
            LoginScreen.id: (context) => const LoginScreen(),
            RegistrationScreen.id: (context) => const RegistrationScreen(),
            DonorRegistrationScreen.id: (context) =>
                const DonorRegistrationScreen(),
            OrganizationRegistrationScreen.id: (context) =>
                const OrganizationRegistrationScreen(),
            DonorDashboard.id: (context) => const DonorDashboard(),
            OrganizationDashboard.id: (context) =>
                const OrganizationDashboard(),
            CategoriesScreen.id: (context) => const CategoriesScreen(),
            BeneficiaryExpandedScreen.id: (context) =>
                const BeneficiaryExpandedScreen(),
            UrgentCasesExpandedScreen.id: (context) =>
                const UrgentCasesExpandedScreen(),
            OrganizationsExpandedScreen.id: (context) =>
                const OrganizationsExpandedScreen(),
            OrgAddSelection.id: (context) => const OrgAddSelection(),
            AddCampaignForm.id: (context) => AddCampaignForm(),
            AddBeneficiaryForm.id: (context) => AddBeneficiaryForm(),
            AddUrgentCaseForm.id: (context) => AddUrgentCaseForm(),
            DonorProfile.id: (context) => const DonorProfile(),
            DonorEditProfile.id: (context) => const DonorEditProfile(),
            OrganizationProfile.id: (context) => const OrganizationProfile(),
            OrganizationEditProfile.id: (context) =>
                const OrganizationEditProfile(),
            DonorSearchScreen.id: (context) => const DonorSearchScreen(),
            OrganizationBeneficiariesExpandedScreen.id: (context) =>
                const OrganizationBeneficiariesExpandedScreen(),
            OrganizationUrgentCasesExpandedScreen.id: (context) =>
                const OrganizationUrgentCasesExpandedScreen(),
            OrganizationCampaignsExpandedScreen.id: (context) =>
                const OrganizationCampaignsExpandedScreen(),
            OrgSearchPage.id: (context) => const OrgSearchPage(),
            DonationHistory.id: (context) => const DonationHistory(),
            DonorFavoritePage.id: (context) => const DonorFavoritePage(),
            DonorNotificationPage.id: (context) =>
                const DonorNotificationPage(),
            OrganizationNotificationPage.id: (context) =>
                const OrganizationNotificationPage(),
            DonorSettingsPage.id: (context) => const DonorSettingsPage(),
            OrganizationSettingsPage.id: (context) =>
                const OrganizationSettingsPage(),
            GatewayVisits.id: (context) => const GatewayVisits(),
          },
          /* Translations are kept as a simple key-value dictionary map.
            To add custom translations, create a class and extend Translations.
            Translations inject the Messages() values in the applications which access with the
            parameter '.tr' */
          translations: Messages(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US')),
    );
  }
}
