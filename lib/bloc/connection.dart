import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scobo/bloc/bloc.dart';

class Connection implements BaseBloc{

  //CONTROLLERS
  final connectionController = BehaviorSubject<String>();
  final batteryController = BehaviorSubject<int>();
  final bedController = BehaviorSubject<int>();
  final dayController = BehaviorSubject<int>();

  //STREAMS
  Sink<String> get connectionIn => connectionController.sink;
  Sink<int> get batteryIn => batteryController.sink;
  Sink<int> get bedIn => bedController.sink;
  Sink<int> get dayIn => dayController.sink;

  //SINKS
  Stream<String> get connectionOut => connectionController.stream;
  Stream<int> get batteryOut => batteryController.stream;
  Stream<int> get bedOut => bedController.stream;
  Stream<int> get dayOut => dayController.stream;

  Timer timer;

  checkConnection() async{
    bool con = false;
    DateTime date = DateTime.now();
    print(date);
    await FirebaseFirestore.instance.collection('scobo').doc('app').update({
      'status': date
    });
    await Future.delayed(const Duration(seconds: 8),(){});
    await FirebaseFirestore.instance.collection('scobo').doc('status').get().then((value){
      print(value['status'].toDate());
      if (value['status'].toDate().isAfter(date))
        con = true;
    });
    if (con){
      print('good');
      connectionIn.add("bot_good.png");
    }
    else{
      print('bad');
      connectionIn.add("bot_error.png");
    }
  }

  batteryStatus(){
    FirebaseFirestore.instance.collection('scobo').doc('battery').snapshots().listen((event) {
      batteryIn.add(event['battery']);
    });
  }

  bedStatus(){
    FirebaseFirestore.instance.collection('scobo').doc('beds').snapshots().listen((event) {
      bedIn.add(event['beds']);
    });
  }

  dayStatus(){
    FirebaseFirestore.instance.collection('scobo').doc('days').snapshots().listen((event) {
      dayIn.add(event['days']);
    });
  }

  @override
  void dispose() {
    connectionController.close();
    batteryController.close();
    bedController.close();
    dayController.close();
  }

}

final connection = Connection();