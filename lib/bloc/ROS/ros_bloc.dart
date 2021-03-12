import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scobo/models/NavMsgsOccupancyGridExtension.dart';
import 'package:ros_nodes/messages/geometry_msgs/PoseStamped.dart';
import 'package:ros_nodes/messages/geometry_msgs/Twist.dart';
import 'package:ros_nodes/messages/nav_msgs/OccupancyGrid.dart';
import 'package:ros_nodes/messages/nav_msgs/Odometry.dart';
import 'package:ros_nodes/messages/sensor_msgs/CompressedImage.dart';
import 'package:ros_nodes/ros_nodes.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:scobo/models/Waypoint.dart';
import 'package:wifi/wifi.dart';

class RosBloc implements BaseBloc{

  //CONTROLLERS
  BehaviorSubject<Uint8List> imageController = BehaviorSubject();
  BehaviorSubject<List> velocityController = BehaviorSubject();
  BehaviorSubject<Int8List> mapController = BehaviorSubject();
  BehaviorSubject<List<dynamic>> mapBlipsController = BehaviorSubject();
  BehaviorSubject<WaypointList> waypointsController = BehaviorSubject();

  //SINKS
  Sink<Uint8List> get imageIn => imageController.sink;
  Sink<List> get velocityIn => velocityController.sink;
  Sink<Int8List> get mapIn => mapController.sink;
  Sink<List<dynamic>> get mapBlipsIn => mapBlipsController.sink;
  Sink<WaypointList> get waypointsIn => waypointsController.sink;

  //STREAMS
  Stream<Uint8List> get imageOut => imageController.stream;
  Stream<List> get velocityOut => velocityController.stream;
  Stream<Int8List> get mapOut => mapController.stream;
  Stream<List<dynamic>> get mapBlipsOut => mapBlipsController.stream;
  Stream<WaypointList> get waypointsOut => waypointsController.stream;

  final cameraImage = SensorMsgsCompressedImage();
  final velocityPublished = GeometryMsgsTwist();
  final mapImage = NavMsgsOccupancyGrid();
  var odometry = NavMsgsOdometry();
  final poseStamped = PoseStamped();

  //ROS TOPICS
  RosConfig rosConfig;
  RosClient rosClient;
  RosTopic<SensorMsgsCompressedImage> rosTopicCamera;
  RosTopic<GeometryMsgsTwist> rosTopicVelocity;
  RosTopic<NavMsgsOccupancyGrid> rosTopicMap;
  RosTopic<NavMsgsOdometry> rosTopicOdometry;
  RosTopic<PoseStamped> rosTopicNavigation;

  Waypoint activeWaypoint;
  WaypointList waypointList = WaypointList([
            Waypoint(name: 'Bed 1', color: Colors.green, x: 1.4, y: -1.3),
            Waypoint(name: 'Bed 2', color: Colors.red, x: 0.8, y: -1.0)
          ]);

  initialiseRos() async{
    String ip = await Wifi.ip;
    rosConfig = RosConfig(
      'ros_enabled_device',
      'http://192.168.100.13:11311', //master ip (change as per laptop, leave port 11311 as it is)
      ip,  //mobile ip (client)
      24125 //port
    );
    rosClient = RosClient(rosConfig);
  }

  initialiseRosTopics() async{
    rosTopicCamera = RosTopic('camera/rgb/image_raw/compressed', cameraImage);
    rosTopicVelocity = RosTopic('cmd_vel', velocityPublished);
    rosTopicMap = RosTopic('map', mapImage);
    rosTopicOdometry = RosTopic('odom', odometry);
    rosTopicNavigation = RosTopic('move_base_simple/goal', poseStamped);
  }

  subscribeRosTopics() async{
    await initialiseRos();
    await initialiseRosTopics();
    await subscribeRosTopicCamera();
    await subscribeRosTopicVelocity();
    await subscribeRosTopicOdometry();
    await subscribeRosTopicMap();
    await publishRosTopicNavigation();
    addWaypoints();
  }

  addWaypoints(){
    waypointsIn.add(waypointList);
  }

  subscribeRosTopicCamera() async{
    var subCameraImage = await rosClient.subscribe(rosTopicCamera);
    subCameraImage.onValueUpdate.listen((event) {
      imageIn.add(event.data);
    });
  }

  subscribeRosTopicOdometry() async{
    final subOdometery = await rosClient.subscribe(rosTopicOdometry);
    subOdometery.onValueUpdate.listen((event) {
      odometry = event;
      mapBlipsIn.add(
        [
          odometry, 
          waypointList
        ]
      );
    });
  }

  subscribeRosTopicVelocity() async{
    await rosClient.unregister(rosTopicVelocity);
    var pubVelocity = await rosClient.register(rosTopicVelocity,
      publishInterval: Duration(milliseconds: 100));
    velocityOut.listen((data) { 
      rosTopicVelocity.msg.linear.x = data[0];
      rosTopicVelocity.msg.angular.z = data[1];
    });
  }

  subscribeRosTopicMap() async{
    var subMapImage = await rosClient.subscribe(rosTopicMap);
    subMapImage.onValueUpdate.listen((event) {
      mapIn.add(event.data);
    });
  }

  publishRosTopicNavigation() async{
    await rosClient.unregister(rosTopicNavigation);
    var pubNav = await rosClient.register(rosTopicNavigation,
    publishInterval: Duration(milliseconds: 500));
  }

  Future<ui.Image> getMapAsImage(){
    final completer = Completer<ui.Image>();  
    ui.decodeImageFromPixels(
      mapImage.toRGBA(fill: Colors.grey[300], border: Colors.black),
      mapImage.info.width,
      mapImage.info.width,
      ui.PixelFormat.rgba8888,
      completer.complete);
    return completer.future;
  }

  setActiveWaypoint(Waypoint newWaypoint){
    if(activeWaypoint != newWaypoint){
      print('x:${newWaypoint.x}\ty:${newWaypoint.y}');
      activeWaypoint = newWaypoint;
      rosTopicNavigation.msg
        ..pose.orientation.w = 0
        ..header.frame_id = 'map'
        ..pose.position.x = newWaypoint.x
        ..pose.position.y = newWaypoint.y;
    }
  }

  @override
  void dispose() {
    imageController.close();
    velocityController.close();
    mapController.close();
    mapBlipsController.close();
    waypointsController.close();
  }

}

final rosBloc = RosBloc();