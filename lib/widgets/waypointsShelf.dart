import 'package:flutter/material.dart';
import 'package:scobo/models/Waypoint.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';

class WaypointShelf extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder(
            stream: rosBloc.waypointsOut,
            builder: (context, list) {
              if(!list.hasData)
                return SizedBox();
              else
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: GridView.builder(
                  itemCount: list.data.waypoints.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width/2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: (){
                          rosBloc.setActiveWaypoint(list.data.waypoints[index]);},
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: list.data.waypoints[index].color[300]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.hotel, color: Colors.white.withOpacity(0.65), size: 40),
                              Text(list.data.waypoints[index].name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ]
                          )
                        ),
                      )
                    );
                  },
                ),
              );
            },
      ),
    );
  }
}