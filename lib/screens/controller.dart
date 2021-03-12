import 'package:flutter/material.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scobo/widgets/circular_indicator.dart';
import 'package:scobo/widgets/joystick.dart';


class Controller extends StatefulWidget {
  @override
  _ControllerState createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {

  void joystickMove(Offset offset, BuildContext context) {
    double x = -offset.dy * 0.4; //linear
    double z = -offset.dx; //angular
    rosBloc.velocityIn.add([x,z]);
  }

  onRefresh() async{
    bloc.loadingStatusIn.add(true);
    await rosBloc.subscribeRosTopicCamera();
    await rosBloc.subscribeRosTopicVelocity();
    await Future.delayed(Duration(seconds: 3));
    bloc.loadingStatusIn.add(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rosBloc.subscribeRosTopicCamera();
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
                      stream: rosBloc.imageOut,
                      builder: (context, image){
                        if(image.hasData){
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              image.data,
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              gaplessPlayback: true,
                              fit: BoxFit.fill,
                            )
                          );
                        }
                        else{
                          return Container(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Waiting for video...', style: TextStyle(color: Colors.white, fontSize: 20)),
                                  Container(
                                    height: 20, width: 20,
                                    child: SpinKitDoubleBounce(size: 30, color: Colors.blue)
                                  )
                                ]
                              )
                            )
                          );
                        }
                      }
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Container(
                      child: Joystick(
                        baseSize: MediaQuery.of(context).size.height / 3.9,
                        stickSize: MediaQuery.of(context).size.height / 3.9 * 0.4,
                        onStickMove: (offset) {
                          joystickMove(offset, context);
                        },
                      ),
                    ),
                  )
                ]
              )
            )
          ]
        )
      ),
    );
  }
}

 