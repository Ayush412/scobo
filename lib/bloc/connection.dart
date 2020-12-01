import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scobo/bloc/bloc.dart';

class Connection implements BaseBloc{

  //CONTROLLERS
  final connectionController = BehaviorSubject<String>();
  final batteryController = BehaviorSubject<int>();

  //STREAMS
  Sink<String> get connectionIn => connectionController.sink;
  Sink<int> get batteryIn => batteryController.sink;

  //SINKS
  Stream<String> get connectionOut => connectionController.stream;
  Stream<int> get batteryOut => batteryController.stream;

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
    FirebaseFirestore.instance.collection('scobo').doc('bot').snapshots().listen((event) {
      batteryIn.add(event['battery']);
    });
  }

  @override
  void dispose() {
    connectionController.close();
    batteryController.close();
  }

}

final connection = Connection();