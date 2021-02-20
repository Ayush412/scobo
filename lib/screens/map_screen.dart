import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scobo/widgets/circular_indicator.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:scobo/widgets/mapPainter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  ui.Image previousMap;

  onRefresh() async{
    bloc.loadingStatusIn.add(true);
    await Future.delayed(Duration(seconds: 3));
    await rosBloc.subscirbeRosTopicMap();
    bloc.loadingStatusIn.add(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rosBloc.subscirbeRosTopicMap();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ColorfulSafeArea(
        color: Colors.black,//Color(0xff13a8d0),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("bkg.jpg"), fit: BoxFit.fill)
                ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      circularProgressIndicator(context),
                      IconButton(
                        icon: Icon(Icons.refresh), 
                        onPressed: ()=> onRefresh(), 
                        color: Colors.white,
                        splashColor: Colors.grey[400],
                        splashRadius: 15
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: StreamBuilder(
                      stream: rosBloc.mapOut,
                      builder: (context, map){
                        if(map.hasData){
                          return InteractiveViewer(
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
                          );
                        }
                        else
                        return Text('no map');
                      },
                    ),
                  )
                ],
              ),
            )
          ]
        )
      )
    );
  }
}