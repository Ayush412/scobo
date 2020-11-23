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
      //navigate(context, HomeScreen());
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
        ),
      ),
    );
  }
}