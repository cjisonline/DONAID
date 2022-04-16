# DONAID
## Description 
The DONAID application's goal is to connect charity organizations to donors across the globe. Through DONAID, charity organizations can advertise their charities. This mobile application allows those in need to receive funds when and where they need them. There are people in the world willing to donate to a cause, and we can solve that.

## Contributers:
CJ Fox, Ashley John, Kamal Mansour, Devin Stawicki, Raisa Zaman

## Table of Contents
1. [STEPS TO RUN APP ON IOS SIMULATOR / REAL OS DEVICE](#paragraph1)
2. [HOW TO ENABLE PUSH NOTIFICATIONS FOR iOS AND ENBALE APPLE SIGN IN](#paragraph2)
3. [HOW TO INSTALL ANDROID STUDIO](#paragraph3)
4. [FIREBASE](#paragraph4)
5. [CONTACT](#paragraph5)


## I. STEPS TO RUN APP ON IOS SIMULATOR / REAL OS DEVICE <a name="paragraph1"></a>

Download XCode first, open it and select from the dropdown the device you want to use, then close Xcode.
Make sure Cocoapods is installed on your Macbook( terminal command: sudo install gem cocoapods ), and Rosetta also( TYPE THIS COMMAND IN VSCODE TERMINAL IN YOUR PROJECT: `softwareupdate --install-rosetta --agree-to-license`

I would prefer using VSCODE instead of Android Studio on macbook, but XCODE IS NECESSARY.

ON M1 CHIP MACBOOK ONLY:

1. Clone the repository.
2. In the project, cd ( change directory ) into the iOS file.
3. Run this command : `sudo arch -x86_64 gem install ffi`
4. Enter your password
5. After its done parsing file, run the command: `pod install`
6. Go to terminal and type ` open -a Simulator`
7. A simulator that you chose earlier should open
8. Click on run -> run WITHOUT debugging
9. Wait about 5-10 mins(might be 2-3 mins) and it should simulate it.

I have not tested it on an intel macbook, but I assume you can skip steps 3 and 4 only, since those are only required for M1 devices.

TO RUN ON REAL IOS DEVICE( YOUR PERSONAL IPHONE):
  
 1. You have to use Xcode for this one.
 2. Open your project file and go to iOS file, then open the file runner workspace.
 3. Xcode should automatically open.
 4. Click on runner on the left side, then go to signing, click to add a team then enter your information.
 5. Then add your team ( personal ).
 6. After that plug in your iPhone and click trust from your iPhone while its unlocked. make sure your iPhone is unlocked throughout this whole process.
 7. After trusting, click `Run` on the top ( the play button ).
 8. Wait for about 5-10 mins. 
 9. It should prompt you that the app developer is not trusted.
 10. Go to your iPhone Settings-> General -> VPN and Device management and click your app from there and put TRUST.
 11. Click `Run` again ( the play button ).
 12. Wait another 2-5 mins.
 13. App should run on the iPhone, do NOT disconnect your device or it will kick you out of the app.


## II. HOW TO ENABLE PUSH NOTIFICATIONS FOR iOS AND ENBALE APPLE SIGN IN <a name="paragraph2"></a>

The application already has Apple sign in and push notifications implemented.
In case you need to use them, you need a paid Apple developer account (priced at 100$/year)
After you get the account, follow the steps below to enable:

1. Go into your iOS folder inside the DONAID project.
2. Find Runner.cxworkspace and open it.
3. Xcode should automatically open, on the left, click files(first folder icon on the left side of the IDE).
4. Double click Runner.
5. In Sign-in and capabilities, sign in with your PAID Apple developer account.
6. After signing in, click (+) or "capabilities", whichever shows.
7. In there search for apple sign in, apple background and push notifications. 
8. Enable all of them and click "try again" below the signing. 

Everything should work fine after this, and the app could use both those features and would have the capability to be released on the Apple store.

## III. HOW TO INSTALL ANDROID STUDIO

Android Studio 2020.3.1 will be used as an IDE for the application for debugging and testing purposes. 
(Install at https://developer.android.com/studio), you will need to configure the emulator via the AVD manager settings in Android Studio. 
The emulator API version is API 30, all other settings are left as default.


## IV. HOW TO INSTALL FLUTTER And DART <a name="paragraph3"></a>

We used Flutter version 2.5.1 and Dart version 2.15 as a programming language and framework to develop the app. 
To install the correct version of Flutter and Dart, use the following link download Flutter and Dart as one package: 
https://docs.flutter.dev/development/tools/sdk/releases

## V. FIREBASE <a name="paragraph4"></a>
-	Firebase Authentication – All DONAID users are authenticated using email and password. It also provides Google, Apple, and Facebook sign-in. Firebase Authentication also tracks anonymous authentication which allows the user to login without an email and password. 
-	Firestore Database – All the data in DONAID is stored in the cloud Firestore. The data is organized into different collections. Each collection has documents which store the various data entries. 
-	Realtime Database – All the messaging data of DONAID is stored within the Realtime database. This allows for data to be synced in realtime. 
-	Firebase Storage – All the images are saved in the Firebase storage which includes the carousel, icons, profile pictures, and verification documents. 

## VI. CONTACT <a name="paragraph5"></a>
- I. How to Run app on iOS simulator/device -- contact Kamal if you need more assistance. 
- II. How to add enable apple sign in and push notifications(iOS) -- contact Kamal if you need more assistance.


