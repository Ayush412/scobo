import 'package:flutter/material.dart';
import 'package:scobo/bloc/connection.dart';
import 'package:scobo/screens/controller.dart';
import 'package:scobo/widgets/dialog.dart';
import 'package:scobo/bloc/ROS/ros_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'dashboard.dart';
import 'controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 0;
  PersistentTabController controller = PersistentTabController(initialIndex: 1);

  List<PersistentBottomNavBarItem> navbarItems(){
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: ("Dashboard"),
        activeColor: Colors.blue[400],
        inactiveColor: Colors.grey[600],
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.gamepad),
        title: ("Controller"),
        activeColor: Colors.blue[400],
        inactiveColor: Colors.grey[600],
      ),
    ];
  }

  List<Widget> screens(){
    return [
      Dahsboard(),
      Controller(),
    ];
  }

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connection.connectionIn.add("bot_connect.png");
    connection.bedIn.add(null);
    connection.dayIn.add(null);
    connection.bedStatus();
    connection.dayStatus();
    connection.checkConnection();
    connection.batteryStatus();
    rosBloc.subscribeRosTopics();
    }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        key: scaffoldKey,
        home: PersistentTabView(
          context,
          controller: controller,
          confineInSafeArea: true,
          resizeToAvoidBottomInset: true,
          hideNavigationBarWhenKeyboardShows: true,
          items: navbarItems(),
          screens: screens(),
          backgroundColor: Colors.black,
          handleAndroidBackButtonPress: true,
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          navBarStyle: NavBarStyle.style14,
        ) 
      )
    );
  }
}