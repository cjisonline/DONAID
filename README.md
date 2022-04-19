# DONAID
## Description 
The DONAID application's goal is to connect charity organizations to donors across the globe. Through DONAID, charity organizations can advertise their charities. This mobile application allows those in need to receive funds when and where they need them. There are people in the world willing to donate to a cause, and we can solve that.

## Contributers:
CJ Fox, Ashley John, Kamal Mansour, Devin Stawicki, Raisa Zaman

## Table of Contents
1. [Steps to run app on iOS simulator](#paragraph1)
2. [How to enable push notifications and Apple sign in for deployment](#paragraph2)
3. [How to install Android Studio](#paragraph3)
4. [How to install Flutter and Dart](#paragraph4)
5. [Firebase](#paragraph5)
6. [Node App & Stripe API](#paragraph6)
7. [DONAID Mobile Application Packages](#paragraph7)
8. [Login Information](#paragraph8)
9. [Edit & Deploy Admin Panel Updates](#paragraph9)
10. [CONTACT](#contact)


## I. Steps to run app on iOS simulator <a name="paragraph1"></a>

Download XCode first, open it and select from the dropdown the device you want to use, then close Xcode.
Make sure Cocoapods is installed on your Macbook (terminal command: sudo install gem cocoapods), and Rosetta also (Enter this command into the VSCode terminal: `softwareupdate --install-rosetta --agree-to-license`)

Using VSCode instead of Android Studio on Macbook is preferred, but XCode is necessary.

### On M1 chip Macbook only:

1. Clone the repository.
2. In the project, cd ( change directory ) into the iOS file.
3. Run this command : `sudo arch -x86_64 gem install ffi`
4. Enter your password
5. After its done parsing file, run the command: `pod install`
6. Go to terminal and type ` open -a Simulator`
7. A simulator that you chose earlier should open
8. Click on run -> run without debugging
9. Wait about 5-10 mins(might be 2-3 mins) and it should simulate it.

For an intel Macbook, skip steps 3 and 4 only, since those are only required for M1 devices.

To run on real iOS device:
  
 1. You have to use Xcode for this one.
 2. Open your project file and go to iOS file, then open the file runner workspace.
 3. Xcode should automatically open.
 4. Click on runner on the left side, then go to signing, click to add a team then enter your information.
 5. Then add your team (personal).
 6. After that plug in your iPhone and click trust from your iPhone while its unlocked. make sure your iPhone is unlocked throughout this whole process.
 7. After trusting, click `Run` on the top (the play button).
 8. Wait for about 5-10 mins. 
 9. It should prompt you that the app developer is not trusted.
 10. Go to your iPhone Settings-> General -> VPN and Device management and click your app from there and put TRUST.
 11. Click `Run` again (the play button).
 12. Wait another 2-5 mins.
 13. App should run on the iPhone, do NOT disconnect your device or it will kick you out of the app.


## II. How to enable push notifications and Apple sign in for deployment <a name="paragraph2"></a>

The application already has Apple sign in and push notifications implemented.
In case you need to use them, you need a paid Apple developer account (priced at $100/year)
After you get the account, follow the steps below to enable:

1. Go into your iOS folder inside the DONAID project.
2. Find Runner.cxworkspace and open it.
3. Xcode should automatically open, on the left, click files(first folder icon on the left side of the IDE).
4. Double click Runner.
5. In Sign-in and capabilities, sign in with your PAID Apple developer account.
6. After signing in, click (+) or "capabilities", whichever shows.
7. In there search for apple sign in, apple background and push notifications. 
8. Enable all of them and click "try again" below the signing. 

Following these steps will enable the use of these functionalities' implementation on iOS devices.

## III. How to install Android Studio<a name="paragraph3"></a>

Android Studio 2020.3.1 will be used as an IDE for the application for debugging and testing purposes. 
(Install at https://developer.android.com/studio), you will need to configure the emulator via the AVD manager settings in Android Studio. 
The emulator API version is API 30, all other settings are left as default.

## IV. How to install Flutter and Dart <a name="paragraph4"></a>

We used Flutter version 2.5.1 and Dart version 2.15 as a programming language and framework to develop the app. 
To install the correct version of Flutter and Dart, use the following link download Flutter and Dart as one package: 
https://docs.flutter.dev/development/tools/sdk/releases

## V. Firebase <a name="paragraph5"></a>
-	Firebase Authentication – All DONAID users are authenticated using email and password. It also provides Google, Apple, and Facebook sign-in. Firebase Authentication also tracks anonymous authentication which allows the user to login without an email and password. 
-	Firestore Database – All the data in DONAID is stored in the cloud Firestore. The data is organized into different collections. Each collection has documents which store the various data entries. 
-	Realtime Database – All the messaging data of DONAID is stored within the Realtime database. This allows for data to be synced in realtime. 
-	Firebase Storage – All the images are saved in the Firebase storage which includes the carousel, icons, profile pictures, and verification documents. 

  ## VI. Node App & Stripe API <a name="paragraph6"></a>
The DONAID application required the implementation of a small node.js application in order to properly use the Stripe API. This is because the Stripe API provides two API keys - a publishable key and a secret key. For proper security of the application, the secret key must not be stored in the mobile application.

So, the DONAID mobile application has the publishable Stripe API key in its mobile code which can be found in the initalization of the application in `main.dart`. 
  
Then, when the mobile application needs to communicate with the Stripe API, it will make an HTTPS request to the node.js app that we have created which is hosted on Heroku. The node.js app contains the Stripe secret API key and so it will make the necessary call to Stripe API and then return the needed information back to the mobile application.  The node.js app is needed for any and all communication with the Stripe API. More detailed information on the implementation of the node.js app and the use of the Stripe API can be found within the code's comments.
  
  ## VII. DONAID Mobile Application Packages <a name="paragraph7"></a>
All packages that are needed for the DONAID mobile application are outlined in the dependencies section of the pubspec.yaml file. All packages used in the DONAID mobile application were imported and implemented by following documentation on pub.dev.  This section will describe some of the most important packages in the project.
All packages are also commented in the pubspec.yaml file to give brief descriptions of their uses in the app.
 
  * Get (https://pub.dev/packages/get): Used for translations in the application's language localization
  * Firebase Core (https://pub.dev/packages/firebase_core): This package is needed in order to use other Firebase services because other Firebase services depend on Firebase Core
  * Firebase Auth (https://pub.dev/packages/firebase_auth): Used for logging users into the application and retrieving user information from Firebase
  * Cloud Firestore (https://pub.dev/packages/cloud_firestore): This package is needed for the use of Firebase Firestore database
  * Firebase Storage (https://pub.dev/packages/firebase_storage): This package is needed for the use of Firebase Storage - the Firebase file storage that the application uses for storing profile pictures, organization verification documents, and other similar documents.
  * Firebase Messaging (https://pub.dev/packages/firebase_messaging): This package is used for Firebase Cloud Messaging which is the Firebase service that's used for the implementation of push notifications.
  * Shared Preferences (https://pub.dev/packages/shared_preferences): This package is used for storing small amounts of data on a user's mobile device which is used in the DONAID application for storing information such as whether a user has push notifications enabled, a user's language preferences, etc.
  * Flutter Stripe (https://pub.dev/packages/flutter_stripe): Used for the implementation of Stripe into the DONAID mobile application
  * Http (https://pub.dev/packages/http): Used for making https API requests in the implementation of Stripe.

  
  ## VIII. Login Information <a name="paragraph8"></a>
For all services used in the creation of this project, if they required account creation with the service, the DONAID team used a specific DONAID email for all accounts.
  
One of the important uses of the DONAID email was for the creation of a Stripe account to use for development. The other most important use of the DONAID email is that it has ownership in the DONAID Firebase project and the Heroku project which hosts the node.js app outlined in section VI. Due to the sensitivity of the information in the node.js application and the Stripe development account, the login information for these services will be given to the client, Dr. Seyed. If upon continuing the development of the DONAID application, this login information is needed, please contact Dr. Seyed. 
  
  ## IX. Edit & Deploy Admin Panel Updates <a name="paragraph9"></a>
The DONAID administration panel web application was placed in a separate branch to not interfere with the flutter/dart code. This branch is titled "AdminConsole" in this repository. To edit the admin panel, clone the branch to a folder and edit the pages within the ./public folder only. The files outside the ./public folder are specific settings required within Firebase to deploy the web app to the domain it is at: https://donaid-d3244.web.app/
  
The DONAID administration panel web application was developed using HTML, CSS and vanilla JavaScript. There are no packages or frameworks involved that need to be installed, simply applications that allow the developer to edit and deploy new features. These are explained below. The application can be edited with whatever IDE the user prefers, but for the sake of compatibility and limitless extension options, VSCode was used: https://code.visualstudio.com/download with the Live Server Extension for ease of use when testing new features: https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer
  
One thing that is needed to deploy the web app, if updated, is the Firebase CLI, which can be found here: https://firebase.google.com/docs/cli
Once downloaded and installed, within the terminal that the web app is cloned, run the command "firebase deploy" and type "no" for any prompts to delete any current repositories. The web app with its new updates will be deployed to the link above. 
  
## X. Contact <a name="contact"></a>
- I. How to Run app on iOS simulator/device -- contact Kamal if you need more assistance. 
- II. How to add enable apple sign in and push notifications(iOS) -- contact Kamal if you need more assistance.
- For other information, the DONAID team lead, CJ Fox, can be contacted for assistance at ge5315@wayne.edu


