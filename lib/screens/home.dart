import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scobo/bloc/connection.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("DASHBOARD", 
            style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)
          ),
          elevation: 2,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          
        )
      ),
    );
  }
}