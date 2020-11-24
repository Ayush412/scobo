import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Connection{
  Timer timer;

  checkConnection() async{
    bool con = false;
    DateTime date = DateTime.now();
    print(date);
    await FirebaseFirestore.instance.collection('scobo').doc('app').update({
      'status': date
    });
    await Future.delayed(const Duration(seconds: 8),(){});
    await FirebaseFirestore.instance.collection('scobo').doc('bot').get().then((value){
      print(value['status'].toDate());
      if (value['status'].toDate().isAfter(date))
        con = true;
    });
    if (con)
      print('good');
    else
      print('bad');
  }

}

final connection = Connection();