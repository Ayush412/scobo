import 'package:flutter/material.dart';
import 'package:scobo/models/Waypoint.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';

class WaypointShelf extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Material(
        elevation: 0,
        child: StreamBuilder(
          stream: rosBloc.waypointsOut,
          builder: (context, list) {
            if(!list.hasData)
              return SizedBox();
            else
            return Container(
              color: Colors.transparent,
                child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.data.waypoints.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: (){
                        rosBloc.setActiveWaypoint(list.data.waypoints[index]);},
                      child: Text(list.data.waypoints[index].name),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}