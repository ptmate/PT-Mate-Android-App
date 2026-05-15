import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/calendar/index.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/messaging/index.dart';
import 'package:ptmate_client/tools/index.dart';
import 'package:ptmate_client/training/index.dart';
import 'package:ptmate_client/_data/sender.dart';

class Nav extends StatefulWidget {
  static _NavState appState = _NavState();
  @override
  _NavState createState() {
    return Nav.appState = new _NavState();
  }
}

class _NavState extends State<Nav> {
  int _currentIndex = 0;
  String dot = "";
  final List<Widget> _children = [
    HomePage(),
    CalendarPage(),
    TrainingPage(),
    HealthPage(),
    MessagingPage(),
    ToolsPage(),
  ];

  @override
  void initState() {
    super.initState();
    /*if(GlobalData.space.community && !GlobalData.space.restricted) {
      _children[0] = CommunityPage();
    }*/
    var dark = "";
    if (GlobalUI.dark) {
      dark = "-dark";
    }
    var tmp = "";
    for (var item in GlobalData.chat.messages) {
      if (item.date.isAfter(GlobalData.chat.clients[0].date) &&
          item.sender != GlobalUser.uid &&
          item.date.isBefore(DateTime.now())) {
        tmp = "-dot";
      }
    }
    for (var chat in GlobalData.chats) {
      var date = DateTime.now();
      for (var client in chat.clients) {
        if (client.id == GlobalUser.uid) {
          date = client.date;
        }
      }
      for (var item in chat.messages) {
        if (item.date.isAfter(date) &&
            item.sender != GlobalUser.uid &&
            item.date.isBefore(DateTime.now())) {
          tmp = "-dot";
        }
      }
    }
    setState(() {
      dot = dark + tmp;
    });
  }

  updateData() {
    if (this.mounted) {
      var dark = "";
      if (GlobalUI.dark) {
        dark = "-dark";
      }
      var tmp = "";
      for (var item in GlobalData.chat.messages) {
        if (item.date.isAfter(GlobalData.chat.clients[0].date) &&
            item.date.isBefore(DateTime.now())) {
          tmp = "-dot";
        }
      }
      for (var chat in GlobalData.chats) {
        var date = DateTime.now();
        for (var client in chat.clients) {
          if (client.id == GlobalUser.uid) {
            date = client.date;
          }
        }
        for (var item in chat.messages) {
          if (item.date.isAfter(date) &&
              item.sender != GlobalUser.uid &&
              item.date.isBefore(DateTime.now())) {
            tmp = "-dot";
          }
        }
      }
      for (var chat in GlobalData.chatsStaff) {
        var date = DateTime.now();
        for (var client in chat.clients) {
          if (client.id == GlobalUser.uid) {
            date = client.date;
          }
        }
        for (var item in chat.messages) {
          if (item.date.isAfter(date) &&
              item.sender != GlobalUser.uid &&
              item.date.isBefore(DateTime.now())) {
            tmp = "-dot";
          }
        }
      }
      setState(() {
        dot = dark + tmp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: AppColors.bgColor,
        selectedItemColor: AppColors.textColor,
        unselectedItemColor: AppColors.fieldColor,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/nav/nav-home.svg",
              width: 20,
              height: 20,
              color: AppColors.navColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/nav/nav-home.svg",
              width: 20,
              height: 20,
              color: AppColors.textColor,
            ),
            label: 'Home',
          ),
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/nav/nav-calendar.svg",
              width: 20,
              height: 20,
              color: AppColors.navColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/nav/nav-calendar.svg",
              width: 20,
              height: 20,
              color: AppColors.textColor,
            ),
            label: 'Calendar',
          ),
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/nav/nav-training.svg",
              width: 20,
              height: 20,
              color: AppColors.navColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/nav/nav-training.svg",
              width: 20,
              height: 20,
              color: AppColors.textColor,
            ),
            label: 'Training',
          ),
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/nav/nav-health.svg",
              width: 20,
              height: 20,
              color: AppColors.navColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/nav/nav-health.svg",
              width: 20,
              height: 20,
              color: AppColors.textColor,
            ),
            label: 'Health',
          ),
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
                "assets/images/nav/nav-messaging" + dot + "-idle.svg",
                width: 20,
                height: 20),
            activeIcon: SvgPicture.asset(
                "assets/images/nav/nav-messaging" + dot + ".svg",
                width: 20,
                height: 20),
            label: 'Messaging',
          ),
          new BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/nav/nav-more.svg",
              width: 20,
              height: 20,
              color: AppColors.navColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/nav/nav-more.svg",
              width: 20,
              height: 20,
              color: AppColors.textColor,
            ),
            label: 'Tools',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    String screen = "Home";
    if (index == 1) {
      screen = "Calendar";
    } else if (index == 2) {
      screen = "Training";
    } else if (index == 3) {
      screen = "Health";
    } else if (index == 4) {
      screen = "Messaging";
    } else if (index == 5) {
      screen = "Tools";
    }

    FirebaseSender.addBookingLog("screen_change", "", {"screen": screen});
  }

  move() {
    setState(() {
      _currentIndex = 1;
    });
    FirebaseSender.addBookingLog("screen_change", "", {"screen": "Calendar"});
  }

  move2() {
    setState(() {
      _currentIndex = 0;
    });
    FirebaseSender.addBookingLog("screen_change", "", {"screen": "Home"});
  }
}
