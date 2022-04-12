# donaid

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



----- STEPS TO RUN APP ON IOS SIMULATOR / REAL OS DEVICE ------

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


