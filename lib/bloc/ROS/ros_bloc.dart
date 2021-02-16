import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ros_nodes/messages/geometry_msgs/PoseStamped.dart';
import 'package:ros_nodes/messages/geometry_msgs/Twist.dart';
import 'package:ros_nodes/messages/nav_msgs/OccupancyGrid.dart';
import 'package:ros_nodes/messages/nav_msgs/Odometry.dart';
import 'package:ros_nodes/messages/sensor_msgs/CompressedImage.dart';
import 'package:ros_nodes/ros_nodes.dart';
import 'package:scobo/bloc/bloc.dart';
import 'package:wifi/wifi.dart';

class RosBloc implements BaseBloc{

  //CONTROLLERS
  BehaviorSubject<Uint8List> imageController = BehaviorSubject();
  BehaviorSubject<List> velocityController = BehaviorSubject();

  //SINKS
  Sink<Uint8List> get imageIn => imageController.sink;
  Sink<List> get velocityIn => velocityController.sink;

  //STREAMS
  Stream<Uint8List> get imageOut => imageController.stream;
  Stream<List> get velocityOut => velocityController.stream;

  final cameraImage = SensorMsgsCompressedImage();
  final velocityPublished = GeometryMsgsTwist();

  //ROS TOPICS
  RosConfig rosConfig;
  RosClient rosClient;
  RosTopic<SensorMsgsCompressedImage> rosTopicCamera;
  RosTopic<GeometryMsgsTwist> rosTopicVelocity;

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
  }

  subscribeRosTopics() async{
    await initialiseRos();
    await initialiseRosTopics();
    await subscribeRosTopicCamera();
    await subscribeRosTopicVelocity();
  }

  subscribeRosTopicCamera() async{
    var subCameraImage = await rosClient.subscribe(rosTopicCamera);
    subCameraImage.onValueUpdate.listen((event) {
      imageIn.add(event.data);
    });
  }

  subscribeRosTopicVelocity() async{
    await rosClient.unregister(rosTopicVelocity);
    var pubVelocity = await rosClient.register(rosTopicVelocity,
      publishInterval: Duration(milliseconds: 100));
    velocityOut.listen((data) { 
      print(data);
      rosTopicVelocity.msg.linear.x = data[0];
      rosTopicVelocity.msg.angular.z = data[1];
    });
  }

  @override
  void dispose() {
    imageController.close();
    velocityController.close();
  }

}

final rosBloc = RosBloc();