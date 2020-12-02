import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:scobo/navigate.dart';
import 'package:scobo/widgets/circular_indicator.dart';
import 'package:scobo/widgets/dialog.dart';
import 'package:scobo/widgets/snack.dart';
import 'package:scobo/widgets/textfield.dart';
import 'package:scobo/bloc/login/login_bloc.dart';
import 'package:scobo/sharedpref.dart';
import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<dynamic, dynamic> myMap = Map<dynamic, dynamic>();
  List<Widget> actions = List<Widget>();
  dynamic leading;

  @override
  void initState() { 
    super.initState();
    sharedPreference.removeData();
    leading = IconButton(
      icon: Icon(Icons.close),
      onPressed: () => showDialogBox(context, 'Warning', 'Exit app?', null)
    );
    actions = [
      IconButton(icon: Icon(Icons.info), color: Colors.white,
      onPressed: () => scaffoldKey.currentState.showSnackBar(ShowSnack('Enter user credentials', Colors.black, Colors.orange)))
    ];
  }

  Future checkLogin() async{
    bool hasUser = true;
    bloc.loadingStatusIn.add(true);
    hasUser = await loginBloc.checkLogin();
    if(!hasUser)
      scaffoldKey.currentState.showSnackBar(ShowSnack('User not found', Colors.black, Colors.orange));
    else{
      sharedPreference.saveData(loginBloc.emailID);
      navigate(context, HomeScreen());
    }
    bloc.loadingStatusIn.add(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showDialogBox(context, 'Confirm exit', 'Do you wish tio exit the app?', null),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children:[
              SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 60.0),
                    child: Image.asset('scobo_logo.png', height: MediaQuery.of(context).size.height/5.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text("SCOBO", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold, fontSize: 25)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/1.3,
                    padding: EdgeInsets.only(left:10.0, right: 10, top: 50),
                      child: textField(loginBloc.emailCheck, loginBloc.emailChanged, 'Email', 'Email', Icon(Icons.person), TextInputType.emailAddress, false)
                  ),
                  Container(
                  width: MediaQuery.of(context).size.width/1.3,
                  padding: EdgeInsets.only(left:10.0, right: 10, top: 30),
                    child: textField(loginBloc.passCheck, loginBloc.passChanged, 'Password', 'Password', Icon(Icons.lock), TextInputType.text, true)
                  ),
                   Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: StreamBuilder(
                      stream: loginBloc.credentialsCheck,
                      builder: (context, snap) => RaisedButton(
                        onPressed: snap.hasData? (){checkLogin();} : () => scaffoldKey.currentState.showSnackBar(ShowSnack('Check all fields', Colors.black, Colors.orange)),
                        textColor: Colors.white,
                        color: Color(0xff0f459d),
                        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width/1.6,
                          height: 55,
                          decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(80.0))
                          ),
                          child: Center(
                            child: const Text('LOGIN', style: TextStyle(fontSize: 20)
                            ),
                          ),
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: circularProgressIndicator(context),
                  )
                  ],
                ),
              )
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text("SCOBO, Symbiosis Institue of Technology", style: TextStyle(color: Colors.blue[600]),),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}