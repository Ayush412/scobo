import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scobo/widgets/circular_indicator.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:scobo/widgets/mapPainter.dart';
import 'package:scobo/widgets/waypointsShelf.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  ui.Image previousMap;

  onRefresh() async{
    bloc.loadingStatusIn.add(true);
    await rosBloc.refresh();
    bloc.loadingStatusIn.add(false);
    rosBloc.addWaypoints();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rosBloc.subscribeRosTopicMap();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Autonomous Navigation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
        actions: [
          circularProgressIndicator(context),
          IconButton(
            icon: Icon(Icons.refresh), 
            onPressed: ()=> onRefresh(), 
            color: Colors.black,
            splashColor: Colors.black,
            splashRadius: 15
          ),
        ],
      ),
      body: ColorfulSafeArea(
        color: Colors.black,//Color(0xff13a8d0),
        child: StreamBuilder(
          stream: rosBloc.mapOut,
          builder: (context, map){
            if(map.hasData){
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[600],
                child: Column(
                  children: [
                    InteractiveViewer(
                      maxScale: 10,
                      child: Container(
                        width: double.infinity,
                        child: Center(
                          child: FutureBuilder(
                            future: rosBloc.getMapAsImage(),
                            initialData: previousMap,
                            builder: (context, image) {
                              if(image.data == null){
                                return SizedBox();
                              }
                              previousMap = image.data;
                              return Map(map: image.data);
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: WaypointShelf()),
                  ],
                ),
              );
            }
            else
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Waiting for map...', style: TextStyle(color: Colors.black, fontSize: 20)),
                  Container(
                    height: 20, width: 20,
                    child: SpinKitDoubleBounce(size: 30, color: Colors.blue)
                  )
                ],
              ),
            );
          },
        ),
      )
    );
  }
}