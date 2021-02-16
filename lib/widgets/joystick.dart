import 'dart:math';
import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final double baseSize;
  final double stickSize;
  final void Function(Offset) onStickMove;

  const Joystick(
      {Key key,
      @required this.baseSize,
      @required this.stickSize,
      this.onStickMove})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var baseSize2 = baseSize;
    return _JoystickState(
      baseSize2,
      stickSize,
      onStickMove,
    );
  }
}

class _JoystickState extends State<Joystick> {
  final double baseSize;
  final double stickSize;
  var tapCount = 0;
  Offset offset = Offset(0, 0);
  var angle = 0;
  var radius;
  bool inMotion = false;

  void Function(Offset) onStickMove;

  _JoystickState(this.baseSize, this.stickSize, this.onStickMove) {
    radius = baseSize / 2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (start) {
        inMotion = true;
        var local = start.localPosition.translate(-radius, -radius);
        var x = cos(local.direction);
        var y = sin(local.direction);
        var maxDistance = (local.distance / radius);
        maxDistance = maxDistance > 1 ? 1 : maxDistance;
        if (onStickMove != null) onStickMove(Offset(x, y) * maxDistance);
        if (local.distance >= radius) {
          local = Offset(x, y) * radius;
        }
        setState(() {
          offset = local;
        });
      },
      onPanEnd: (_) {
        inMotion = false;
        if (onStickMove != null) onStickMove(Offset(0, 0));
        setState(() {
          offset = Offset(0, 0);
        });
      },
      child: Material(
        //OUTER RADIUS
        shape: CircleBorder(
            side: BorderSide(width: 2, color: Colors.grey.withAlpha((80)))),
        color: Colors.white.withAlpha(0),
        child: Container(
          height: baseSize,
          width: baseSize,
          child: Center(
            child: Stack(
              children: <Widget>[
                //Middle RADIUS
                Center(
                  child: Material(
                    shape: CircleBorder(
                        side: BorderSide(
                            width: 4, color: Colors.grey.withAlpha((20)))),
                    color: Colors.grey.withAlpha(0),
                    child: Container(
                      height: baseSize * 0.7,
                      width: baseSize * 0.7,
                    ),
                  ),
                ),
                //Inner RADIUS
                Center(
                  child: Material(
                    shape: CircleBorder(),
                    color: Colors.grey.withAlpha(30),
                    child: Container(
                      height: stickSize,
                      width: stickSize,
                    ),
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: offset,
                    child: Material(
                      shape: CircleBorder(
                          side: BorderSide(width: 2, color: Colors.black38)),
                      color: Colors.grey,
                      elevation: 4.0,
                      child: Container(
                        height: inMotion ? stickSize / 2 : stickSize,
                        width: inMotion ? stickSize / 2 : stickSize,
                        child: Center(
                          child: Icon(
                            Icons.blur_on,
                            size: inMotion
                                ? stickSize / 2 / 1.4
                                : stickSize / 1.4,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
