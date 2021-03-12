import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:scobo/models/Waypoint.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';
import 'package:ros_nodes/messages/nav_msgs/Odometry.dart';
import 'package:vector_math/vector_math.dart' show radians, Quaternion;

class MapPainter extends CustomPainter{
  
  final double waveRadius;
  final Color waveAccentColor;
  final Color waveColor;
  final NavMsgsOdometry robotOdom;
  final ui.Image map;
  final WaypointList waypoints;
  final Waypoint activeWaypoint;

  Paint wavePaint, wavePaint2, solidPaint, waypointPaint;
  double robotFootprint = 4.0;
  double maxRadius = 15;
  double gaps = 5;

  double waypointMinSize = 3;
  double waypointRadiusMax = 5;
  int waypointSides = 4;

  MapPainter({
    @required this.map,
    @required this.waveRadius,
    @required this.waveAccentColor,
    @required this.waveColor,
    @required this.robotOdom,
    @required this.waypoints,
    @required this.activeWaypoint,
  }) {
    wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.5
      ..isAntiAlias = true;
    wavePaint2 = Paint()
      ..color = waveAccentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = true;
    solidPaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.5
      ..isAntiAlias = true;
    waypointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.5
      ..isAntiAlias = true;
  }
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
      canvas.save();
    {
      canvas.translate(map.width/2, map.height/2.5);
      canvas.rotate(radians(180));
      canvas.translate(-map.width / 2, -map.height / 2);
      canvas.scale(1, -1);
      canvas.translate(0, -map.height.toDouble());
      
      canvas.save();
      {
        canvas.translate(-6, -6);
        canvas.drawImage(map, Offset.zero, Paint());
      }
      
      canvas.restore();

      canvas.save();
      {
        double centerX = map.width / 2;
        double centerY = map.height / 2;
        canvas.translate(centerX, centerY);

        final resolution = 0.05;

        //draw waypoints
        var miliseconds = DateTime.now().millisecondsSinceEpoch;
        var animationSizePercent = (miliseconds % 1700) / 1700;
        for (var item in waypoints.waypoints) {
          canvas.save();
          {
            canvas.translate(item.x / resolution, item.y / resolution);
            canvas.drawPath(
                drawNSide(
                  6,
                  waypointMinSize +
                      (animationSizePercent *
                          (waypointRadiusMax - waypointMinSize)),
                ),
                waypointPaint
                  ..color = item.color.withOpacity(animationSizePercent));
            canvas.restore();
          }
        }
        double robotPositionX = (robotOdom.pose.pose.position.x) / resolution;
        double robotPositionY = (robotOdom.pose.pose.position.y) / resolution;

        //draw robot
        var robotCenter = Offset(0, 0);
        var currentRadius = waveRadius;
        bool drawOnce = true;
        while (currentRadius < maxRadius) {
          //Drawing waypoints
          for (var item in waypoints.waypoints) {
            bool active = item == activeWaypoint;
            canvas.save();
            canvas.translate(item.x / resolution, item.y / resolution);
            //---Pulsating inner
            if (active) {
              canvas.drawPath(
                  drawNSide(waypointSides, currentRadius * 0.8),
                  waypointPaint
                    ..style = PaintingStyle.fill
                    ..strokeWidth = 1
                    ..color =
                        item.color.withOpacity(1 - currentRadius / maxRadius));
            }
            //---Pulsating outer
            canvas.drawPath(
                drawNSide(waypointSides, currentRadius * 0.8),
                waypointPaint
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = active ? 1 : 0.2
                  ..color =
                      item.color.withOpacity(1 - currentRadius / maxRadius));
            //---Solid shape
            canvas.drawPath(
                drawNSide(waypointSides, 3),
                waypointPaint
                  ..style = PaintingStyle.fill
                  ..color = item.color.withOpacity(1));
            canvas.restore();
          }
          //Drawing robot
          canvas.save();
          canvas.translate(robotPositionX, robotPositionY);

          //---Drawing Cone shape
          if (drawOnce) {
            canvas.save();
            var robotRotation = Quaternion(
                robotOdom.pose.pose.orientation.x,
                robotOdom.pose.pose.orientation.y,
                robotOdom.pose.pose.orientation.z,
                robotOdom.pose.pose.orientation.w);
            canvas.rotate(robotOdom.pose.pose.orientation.x < 0
                ? robotRotation.radians
                : -robotRotation.radians);

            var rect = Rect.fromCircle(
              center: Offset(0, 0),
              radius: 15.0,
            );

            var gradient = RadialGradient(
              colors: [
                waveColor.withOpacity(0),
                waveColor.withOpacity(0),
                waveAccentColor.withOpacity(0.7),
                waveAccentColor.withOpacity(0.0),
              ],
              stops: [0.0, 0.25, 0.251, 1.0],
            );

            //---/---/create the Shader from the gradient and the bounding square
            var paint = Paint()..shader = gradient.createShader(rect);

            canvas.drawPath(drawCone(15, 55), paint..isAntiAlias = true);
            canvas.restore();
            //---/---/preventing blinking
            drawOnce = false;
          }
          canvas.drawCircle(
              robotCenter,
              currentRadius,
              wavePaint
                ..color =
                    wavePaint.color.withOpacity(1 - currentRadius / maxRadius));
          canvas.drawCircle(
              robotCenter,
              currentRadius,
              wavePaint2
                ..color = wavePaint2.color
                    .withOpacity(1 - currentRadius / maxRadius));
          canvas.drawCircle(robotCenter, 3, solidPaint);
          canvas.restore();

          currentRadius += 7;
        }
      }
      canvas.restore();
    }
    canvas.restore();
  }

  Path drawNSide(int sides, double radius) {
    assert(sides >= 3);
    final shape = Path();
    var angle = (math.pi * 2) / sides;
    // Offset firstPoint = Offset(radius * math.cos(0.0), radius * math.sin(0.0));
    Offset firstPoint = Offset(radius * 1, 0);
    shape.moveTo(firstPoint.dx, firstPoint.dy);
    for (int i = 1; i <= sides; i++) {
      double shapeX = radius * math.cos(angle * i);
      double shapeY = radius * math.sin(angle * i);
      shape.lineTo(shapeX, shapeY);
    }
    shape.close();
    return shape;
  }

  Path drawCone(double radius, double angle) {
    angle /= 2;
    final shape = Path();
    Offset firstPoint = Offset(0, 0);
    Offset secondPoint = Offset(
        radius * math.cos(radians(-angle)), radius * math.sin(radians(-angle)));
    Offset thirdPoint = Offset(
        radius * math.cos(radians(angle)), radius * math.sin(radians(angle)));
    var rect = Rect.fromCircle(
      center: Offset(0, 0),
      radius: radius,
    );

    shape.moveTo(firstPoint.dx, firstPoint.dy);
    shape.lineTo(secondPoint.dx, secondPoint.dy);
    shape.arcToPoint(thirdPoint, radius: Radius.circular(radius));

    shape.close();
    return shape;
  }
  
  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    return oldDelegate.waveRadius != waveRadius ||
        oldDelegate.map.hashCode != map.hashCode;
  }

}

class Map extends StatefulWidget {
  
  const Map({Key key, @required this.map, this.showGrid})
      : assert(map != null),
        super(key: key);
  final ui.Image map;
  final showGrid;

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with SingleTickerProviderStateMixin {

  double waveRadius = 0.0;
  double waveGap = 7.0;
  Animation<double> _animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 1500), 
      vsync: this
    );
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    _animation = Tween(begin: 0.0, end: waveGap).animate(controller)
      ..addListener(() {
        setState(() {
          waveRadius = _animation.value;
        });
      });
    return FittedBox(
      child: SizedBox(
        width: widget.map.width.toDouble(),
        height: widget.map.height.toDouble(),
        child: StreamBuilder(
          stream: rosBloc.mapBlipsOut,
          builder: (context, list) {
            if(list==null || !list.hasData)
              return Container(
                child: Text('Waiting'),
              );
            else
              return CustomPaint(
                painter: MapPainter(
                    map: widget.map,
                    waveRadius: waveRadius,
                    waveAccentColor: Theme.of(context).accentColor,
                    waveColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.amberAccent
                        : Colors.cyanAccent,
                    robotOdom: list.data[0],
                    waypoints: list.data[1],
                    activeWaypoint: rosBloc.activeWaypoint,
                )
              );
          }
        ),
      ),
    );
  }
}