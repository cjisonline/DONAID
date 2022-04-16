# donaid

APPENDIX

I. How to Run app on iOS simulator/device -- contact Kamal if you need more assistance.
II. How to add enable apple sign in and push notifications(iOS) -- contact Kamal if you need more assistance.




------I. STEPS TO RUN APP ON IOS SIMULATOR / REAL OS DEVICE ------

Download XCode first, open it and select from the dropdown the device you want to use, then close xcode.
also make sure cocoapods is installed on your macbook( terminal command: sudo install gem cocoapods ), and rosetta also( TYPE THIS COMMAND IN VSCODE TERMINAL IN YOUR PROJECT: softwareupdate --install-rosetta --agree-to-license

I would prefer using VSCODE instead of android studio on macbook, but XCODE IS NECESSARY.

ON M1 CHIP MACBOOK ONLY:

1. Clone the repository.
2. In the project, cd ( change directory ) into the ios file.
3. run this command : sudo arch -x86_64 gem install ffi
4. Enter your password
5. after its done parsing file, run the command: pod install
6. go to terminal and type " open -a Simulator"
7. a simulator that you chose earlier should open
8. click on run -> run WITHOUT debugging
9. wait about 5-10 mins(might be 2-3 mins) and it should simulate it.

I have not tested it on an intel macbook, but I assume you can skip steps 3 and 4 only, since those are only required for M1 devices.

TO RUN ON REAL IOS DEVICE( YOUR PERSONAL IPHONE):
  
 1. You have to use xcode for this one.
 2. Open your project file and go to ios file, then open the file runner workspace.
 3. xcode should automatically open.
 4. click on runner on the left side, then go to signing, click to add a team then enter your information.
 5. then add your team ( personal )
 6. after that plug in your iphone and click trust from your iphone while its unlocked. make sure your iphone is unlocked throughout this whole process.
 7. after trusting, click Run on the top ( the play button )
 8. Wait about 5-10 mins
 9. It should prompt you that the app developer is not trusted.
 10. go to your iphone Settings->General->VPN and Device management and click your app from there and put TRUST
 11. click Run again ( the play button )
 12. wait another 2-5 mins
 13. App should run on the iPhone, do NOT disconnect your device or it will kick you out of the app.




------II. HOW TO ENABLE PUSH NOTIFICATIONS FOR iOS AND ENBALE APPLE SIGN IN----

The application already has Apple sign in and Push notifications implemented.
In case you need to use them, you need a paid apple developer account(priced at 100$/year)
After you get the account, follow the steps below to enable:

1. Go into your iOS folder inside the donaid project.
2. Find Runner.cxworkspace and open it
3. Xcode should automatically open, on the left, click files(first folder icon on the left side of the IDE)
4. Double click Runner
5. in Sign-in and capabilities, sign in with your PAID apple developer account
6. after signing in, click (+) or "capabilities", whichever shows.
7. in there search for apple sign in, apple background and push notifications
8. enable all of them and click "try again" below the signing 

Everything should work fine after this, and the app could use both those features and would have the capability to be released on the apple store.

------III. HOW TO INSTALL ANDROID STUDIO----

Android Studio 2020.3.1 will be used as an IDE for the application for debugging and testing purposes. 
(Install at https://developer.android.com/studio), you will need to configure the emulator via the AVD manager settings in Android Studio. 
The emulator API version is API 30, all other settings are left as default.


------IIII. HOW TO INSTALL FLUTTER And DART----

We used flutter version 2.5.1 and Dart version 2.15 as a programming language and framework to develop the app. 
To install the correct version of Flutter and Dart, use the following link download Flutter and Dart as one package: 
https://docs.flutter.dev/development/tools/sdk/releases



