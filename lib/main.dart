import 'dart:async';
import 'package:scobo/bloc/login/login_bloc.dart';
import 'package:scobo/navigate.dart';
import 'package:scobo/screens/home.dart';
import 'package:scobo/screens/intro.dart';
import 'package:scobo/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String email;
  bool open;
  Timer timer;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    timer = new Timer(const Duration(seconds: 2), () {
      afterSplash();
    });
  }

  Future afterSplash() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    open = prefs.getBool('open');
    if(email==null){
      print('no email');
      if(open==null || open==false)
        navigate(context, Intro());
      else{
        navigate(context, Login());
      }
    }
    else{
      print(email);
      await loginBloc.getUserData(email);
      navigate(context, HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("scobo_logo.png", height: 100),
                Padding(
                  padding: const EdgeInsets.only(top:30),
                  child: Text("SCOBO", style: TextStyle(fontSize: 25, color: Colors.blue[600], fontWeight: FontWeight.bold))
                )
              ],
            ),
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

}
