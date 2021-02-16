import 'package:flutter/material.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


circularProgressIndicator(BuildContext context){
  return StreamBuilder(
    stream: bloc.loadingStatusOut,
    builder: (context, snapshot){
      if(snapshot.hasData && snapshot.data==true)
        return SpinKitDoubleBounce(size: 30, color: Colors.blue,);
      else if(!snapshot.hasData || snapshot.data==false)
        return SizedBox(height: 30, width: 30);
    },
  );
}