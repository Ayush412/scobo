import 'package:flutter/material.dart';
import 'package:scobo/bloc/connection.dart';
import 'package:scobo/bloc/login/login_bloc.dart';
import 'package:scobo/widgets/index_row.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:scobo/widgets/dash_row.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
class Dahsboard extends StatefulWidget {
  @override
  _DahsboardState createState() => _DahsboardState();
}

class _DahsboardState extends State<Dahsboard> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
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
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Text("STATS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("avatar_doc.jpg"),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(loginBloc.userMap['Name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right:20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      dashRow(context, "BEDS AIDED", Icons.hotel, connection.bedOut),
                      SizedBox(width:20),
                      dashRow(context, "DAYS ACTIVE", Icons.calendar_today, connection.dayOut),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue[200]),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
                                  ),
                                  StreamBuilder(
                                    stream: connection.connectionOut,
                                    builder: (_, AsyncSnapshot<String> img){
                                      return Image.asset(img.data, height:100);
                                    }
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          children: [
                                            indexRow('bot_good.png', 'Connected and ready for instructions'),
                                            indexRow('bot_moving.png', 'Bot is moving'),
                                            indexRow('bot_connect.png', 'Checking connectivity'),
                                            indexRow('bot_error.png', 'No signal from bot')
                                          ],
                                        ),
                                    ),
                                  ),
                                ]
                              )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue[200]),
                              child: Column(
                                children:[
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text('BATTERY',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: StreamBuilder(
                                      stream: connection.batteryOut,
                                      builder: (_, AsyncSnapshot<int> battery){
                                        print(battery.data);
                                        return Column(
                                          children: [
                                            BatteryIndicator(
                                              style: BatteryIndicatorStyle.skeumorphism,
                                              showPercentSlide: true,
                                              battery: battery.data == null ? 0 : battery.data,
                                              showPercentNum: false,
                                              size: 40,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text("${battery.data}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
                                            )
                                          ],
                                        );
                                      }
                                    )
                                  )
                                ]
                              )
                            ),
                          )
                        ],
                      ),
                  ),
                ),
              ]
            ),
          )
        ]
      )
    );
  }
}
    
