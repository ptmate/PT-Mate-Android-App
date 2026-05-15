import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/form.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/models.dart';



class SuccessPage extends StatefulWidget {
  //_SuccessPageState createState() => _SuccessPageState();
  final String type;
  const SuccessPage(this.type);
  @override
  _SuccessPageState createState() => _SuccessPageState();
}


class _SuccessPageState extends State<SuccessPage> with TickerProviderStateMixin {


  String type = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      type = widget.type;
    });
    registerNotification();
  }


  tapContinue() {
    if(type == "form") {
      for(var form in GlobalData.space.forms) {
        if(form.pre) {
          Navigator.push(context, PageRoutes.sharedAxis(()=>PreFormPage(form.id, form), SharedAxisTransitionType.horizontal));
        }
      }
      
    } else {
      if(GlobalData.space.welcome != "") {
        Connector.sendWelcome();
      }
      Navigator.push(context, PageRoutes.sharedAxis(()=>ConnectPage(), SharedAxisTransitionType.horizontal));
    }
    
  }


  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }


  void registerNotification() async {
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    PushNotification _notificationInfo;
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _messaging.getToken().then((token) {
      GlobalUser.token = token ?? "";
      FirebaseSender.updateToken(GlobalUser.uid, token);
    }).catchError((e) {
      print(e);
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: MediaQuery(child: Container(
          padding: EdgeInsets.only(bottom: 20),
          color: AppColors.bgColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column (
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 90, 0, 50),
                width: 110,
                height: 110,
                child: SvgPicture.asset("assets/images/list/terms-on.svg", width: 110, height: 110),
              ),
              Text(
                getText(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 40,
                ),
              ),
              Container (
                padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                width: double.maxFinite,
                child: Text(
                  getSubtext(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),

              // Button
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: BtnPrimary(label: "Continue", clickFn: tapContinue)
                )
              )
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }


  getText() {
    var label = "Great! You're\nnow connected";
    if(type == "form") {
      label = "Great! You're\nconnected";
    } else if(type == "formdone") {
      label = "Great!\nYou're all set";
    }
    return label;
  }


  getSubtext() {
    var label = "Tap continue to get started";
    if(type == "form") {
      label = "Now let's get you set up for training";
    }
    return label;
  }
}