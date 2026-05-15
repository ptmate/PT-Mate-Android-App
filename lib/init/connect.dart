import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/graphql.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/nav.dart';

class ConnectPage extends StatefulWidget {
  static _ConnectPageState appState = _ConnectPageState();
  @override
  _ConnectPageState createState() {
    return ConnectPage.appState = new _ConnectPageState();
  }
}

class _ConnectPageState extends State<ConnectPage>
    with TickerProviderStateMixin {
  var _ctrlIn1;
  var _ctrlIn2;
  var _aniIn1;
  var _aniIn2;
  double _opacity = 0;
  double _width = 0;
  bool _active = true;
  int _loaded = 0;

  @override
  void initState() {
    super.initState();
    _ctrlIn1 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _aniIn1 = Tween(begin: 0.2, end: 1.05).animate(CurvedAnimation(
      parent: _ctrlIn1,
      curve: Curves.easeOut,
    ));
    _ctrlIn2 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _aniIn2 = Tween(begin: 0.5, end: 0.9).animate(CurvedAnimation(
      parent: _ctrlIn1,
      curve: Curves.easeOut,
    ));
    _ctrlIn1.addListener(() {
      setState(() {
        _opacity = _ctrlIn1.value;
      });
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _ctrlIn1.forward(from: 0.0);
      _ctrlIn2.forward(from: 0.0);
    });

    _loadData();

    Permission.notification.request();
  }

  @override
  void dispose() {
    _ctrlIn1.dispose();
    _ctrlIn2.dispose();
    super.dispose();
  }

  _setColor() {
    AppColors.PrimaryColor = AppColors.themeDefault;
    GlobalUI.gradients = GlobalUI.gradients0;
    if (GlobalData.space.theme == 'darkblue') {
      AppColors.PrimaryColor = AppColors.themeBlue;
      GlobalUI.gradients = GlobalUI.gradients1;
    }
    if (GlobalData.space.theme == 'darkblue') {
      AppColors.PrimaryColor = AppColors.themeDarkblue;
      GlobalUI.gradients = GlobalUI.gradients2;
    }
    if (GlobalData.space.theme == 'vividblue') {
      AppColors.PrimaryColor = AppColors.themeVividblue;
      GlobalUI.gradients = GlobalUI.gradients3;
    }
    if (GlobalData.space.theme == 'green') {
      AppColors.PrimaryColor = AppColors.themeGreen;
      GlobalUI.gradients = GlobalUI.gradients4;
    }
    if (GlobalData.space.theme == 'darkgreen') {
      AppColors.PrimaryColor = AppColors.themeDarkgreen;
      GlobalUI.gradients = GlobalUI.gradients5;
    }
    if (GlobalData.space.theme == 'vividgreen') {
      AppColors.PrimaryColor = AppColors.themeVividgreen;
      GlobalUI.gradients = GlobalUI.gradients6;
    }
    if (GlobalData.space.theme == 'yellow') {
      AppColors.PrimaryColor = AppColors.themeYellow;
      GlobalUI.gradients = GlobalUI.gradients7;
    }
    if (GlobalData.space.theme == 'orange') {
      AppColors.PrimaryColor = AppColors.themeOrange;
      GlobalUI.gradients = GlobalUI.gradients8;
    }
    if (GlobalData.space.theme == 'red') {
      AppColors.PrimaryColor = AppColors.themeRed;
      GlobalUI.gradients = GlobalUI.gradients9;
    }
    if (GlobalData.space.theme == 'pink') {
      AppColors.PrimaryColor = AppColors.themePink;
      GlobalUI.gradients = GlobalUI.gradients10;
    }
    if (GlobalData.space.theme == 'purple') {
      AppColors.PrimaryColor = AppColors.themePurple;
      GlobalUI.gradients = GlobalUI.gradients11;
    }
    if (GlobalData.space.theme == 'brown') {
      AppColors.PrimaryColor = AppColors.themeBrown;
      GlobalUI.gradients = GlobalUI.gradients12;
    }
    if (GlobalData.space.theme == 'lightblue') {
      AppColors.PrimaryColor = AppColors.themeLightblue;
      GlobalUI.gradients = GlobalUI.gradients13;
    }
    if (GlobalData.space.theme == 'red2') {
      AppColors.PrimaryColor = AppColors.themeRed2;
      GlobalUI.gradients = GlobalUI.gradients14;
    }
    if (GlobalData.space.theme == 'pink2') {
      AppColors.PrimaryColor = AppColors.themePink2;
      GlobalUI.gradients = GlobalUI.gradients15;
    }
    if (GlobalData.space.theme == 'purple2') {
      AppColors.PrimaryColor = AppColors.themePurple2;
      GlobalUI.gradients = GlobalUI.gradients16;
    }
    if (GlobalData.space.theme == 'emeraldgreen') {
      AppColors.PrimaryColor = AppColors.themeEmeraldgreen;
      GlobalUI.gradients = GlobalUI.gradients17;
    }

    //VariableAppIcon.androidAppIconIds = androidIconIds;
    /*VariableAppIcon.androidAppIconIds = ["appicon.DEFAULT", "appicon.BEACH", "appicon.MOVEWELL"];
    VariableAppIcon.changeAppIcon(
androidIconId: "appicon.MOVEWELL",iosIcon: "AppIcon");*/
  }

  _loadData() {
    _setColor();

    Connector.getVersionUpdate();
    if (GlobalData.space.parent == '') {
      Connector.getSpaceBilling(GlobalData.space.id, GlobalData.space.client);
    } else {
      Connector.getSpaceBilling(GlobalData.space.id, GlobalData.space.parent);
    }
    Connector.getSpaceAssessments(GlobalData.space.id, GlobalData.space.client);
    Connector.getSessions();
    Connector.getSessionsSpace();
    Connector.getRecurring();
    Connector.getEvents();
    Connector.getPrograms();
    Connector.getProducts();
    Connector.getPayments();
    Connector.getInvoices();
    Connector.getBest();
    Connector.getClients();
    Connector.getChat();
    Connector.getChatsGroup();
    Connector.getPlans();
    Connector.getLog();
    Connector.getLog2();
    Connector.getGroups();
    Connector.getMovements();
    Connector.getCommunity();
    Connector.getSpaceStaff();
    Connector.getHabits();
    Connector.getDocuments();
    Connector.getNotes();
    Connector.getLocations();
    Connector.getSchedule();

    if (GlobalData.space.country == "au") {
      GlobalUI.currency = "aud";
      GlobalUI.curSym = "A\$";
    } else if (GlobalData.space.country == "nz") {
      GlobalUI.currency = "nzd";
      GlobalUI.curSym = "NZ\$";
    } else {
      GlobalUI.currency = "usd";
      GlobalUI.curSym = "\$";
    }

    if (GlobalData.space.nutritionId != "") {
      GQLConnector.getNutrition(id: int.parse(GlobalData.space.nutritionId));
      GQLConnector.getRecipes();
    }

    FirebaseSender.updateAppVersion();

    Future.delayed(const Duration(milliseconds: 8000), () {
      if (_loaded != 10) {
        _gotoNext();
      }
    });
  }

  updateData() {
    if (this.mounted && _active) {
      int nxt = _loaded + 1;
      setState(() {
        _loaded = nxt;
        _width = (nxt * 10).toDouble();
      });
      if (_loaded == 10) {
        //_gotoNext();
      }
    }
  }

  _gotoNext() {
    if (GlobalUser.token != "" &&
        GlobalUser.token != GlobalUI.token &&
        GlobalData.space.id != "" &&
        GlobalData.space.id != "none") {
      FirebaseSender.updateUserToken();
    }
    /*if(GlobalData.allStaff.length > 0) {
      Connector.getChats();
    }*/
    if (GlobalData.space.forms.length == 0) {
      Connector.getForms();
    }
    setState(() {
      _active = false;
    });
    // Go to next page
    Future.delayed(const Duration(milliseconds: 750), () {
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => Nav(), SharedAxisTransitionType.horizontal));
    });
    /*Navigator.push(
        context,
        PageRoutes.sharedAxis(
            () => Nav(), SharedAxisTransitionType.horizontal));*/
  }

  String getName() {
    var label = GlobalData.space.name;
    label = GlobalData.space.business;
    return label;
  }

  String getInitials() {
    String inits = "";
    String label = GlobalData.space.name;
    if (GlobalData.space.business != "") {
      label = GlobalData.space.business;
    }
    var arr = label.split(" ");
    for (var item in arr) {
      if (item != "") {
        inits += item[0];
      }
    }
    if (inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: MediaQuery(
              child: Container(
                color: AppColors.bgColor,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Loading\ndata from",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            getName(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                        alignment: AlignmentGeometry.center,
                        child: AnimatedOpacity(
                            opacity: _opacity,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: Transform.scale(
                              scale: _aniIn1.value,
                              child: Image.asset(
                                  "assets/images/common/gradient-blur-" +
                                      GlobalData.space.theme +
                                      ".png",
                                  width: 280,
                                  height: 280),
                            ))),
                    Align(
                        alignment: AlignmentGeometry.center,
                        child: AnimatedOpacity(
                            opacity: _opacity,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: Transform.scale(
                              scale: _aniIn2.value,
                              child: Avatar(getInitials(), 120,
                                  GlobalData.space.image, 40, ""),
                            ))),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Container(
                          width: 100,
                          height: 3,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.fieldColor,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: _width,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.PrimaryColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
            ),
          ),
        ));
  }
}
