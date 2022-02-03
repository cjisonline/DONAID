import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           Padding(
             padding: EdgeInsets.symmetric(vertical: 16.0),
             child: Material(
               elevation: 5.0,
               color: Colors.blue,
               borderRadius: BorderRadius.circular(30.0),
               child: MaterialButton(
                 child: Text(
                   'Login',
                   style: TextStyle(
                     color: Colors.white,
                   ),
                 ),
                 onPressed: (){
                   Navigator.pushNamed(context, LoginScreen.id);
                 },
               ),
             ),
           ),

            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
