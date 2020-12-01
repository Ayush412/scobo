import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scobo/navigate.dart';
import 'package:scobo/screens/login.dart';
import 'package:scobo/bloc/login/login_bloc.dart';

customDrawer(BuildContext context){
  return Drawer(
    elevation: 4,
    child: Column(
      children: <Widget>[
        Container(
          height: 90,
          width: MediaQuery.of(context).size.width,
          child: DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey[300]),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('Hello, ${loginBloc.userMap['Name']}', style: GoogleFonts.sourceSansPro(fontSize: 20, fontWeight: FontWeight.bold),)
            )
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => logOut(context),
                child: Container(
                  height: 40,
                  child: Center(
                    child: Text('LOGOUT', style: GoogleFonts.sourceSansPro(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                ),
              ),
            )
          ),
        )
      ]
    )
  );
}

drawerOptions(BuildContext context, String img, String text, dynamic className, double pad){
  return Padding(
    padding: EdgeInsets.only(left: 20, top: pad),
    child: InkWell(
      onTap: () => navigate(context, className),
      child: Row(
        children: <Widget>[
          Image.asset(img, height:30, width:30),
          SizedBox(width: 30),
          Text(text, style: GoogleFonts.sourceSansPro(fontSize: 20, fontWeight: FontWeight.w600),)
        ],
      ),
    ),
  );
}

logOut(BuildContext context) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('email', null);
  navigate(context, Login());
}