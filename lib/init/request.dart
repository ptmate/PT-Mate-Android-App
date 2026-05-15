import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/components/card-avatar.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/init/select.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/success.dart';
import 'package:ptmate_client/_data/sender.dart';


class RequestPage extends StatefulWidget {
  final String id;
  final String client;
  static _RequestPageState appState = _RequestPageState();
  const RequestPage(this.id, this.client);
  @override
  _RequestPageState createState() {
    return RequestPage.appState = new _RequestPageState();
  }
}


class _RequestPageState extends State<RequestPage> {


  var id = "";
  var client = "";
  var spaces = GlobalData.allspaces;
  var label = "-";
  var sublabel = "-\n-";
  var image = "";
  var item;


  @override
  void initState() {
    super.initState();
    Connector.getTrainers();
    setState(() {
      id = widget.id;
      client = widget.client;
    });
    var tmpl = "";
    var tmps = "";
    var tmpi = "";
    var titem;
    for(var space in spaces) {
      if(space.id == id) {
        tmpl = space.name;
        if(space.business != "" && space.business != null) {
          tmpl= space.business;
        }
        tmps = space.name+"\n"+space.email;
        tmpi = space.image;
        titem = space;
      }
    }
    setState(() {
      label = tmpl;
      sublabel = tmps;
      image = tmpi;
      item = titem;
    });
  }


  updateData() {
    if(this.mounted) {
      setState(() {
        spaces = GlobalData.allspaces;
      });
      var tmpl = "";
      var tmps = "";
      var tmpi = "";
      var titem;
      for(var space in spaces) {
        if(space.id == id) {
          tmpl = space.name;
          if(space.business != "" && space.business != null) {
            tmpl = space.business;
          }
          tmps = space.name+"\n"+space.email;
          tmpi = space.image;
          titem = space;
        }
      }
      setState(() {
        label = tmpl;
        sublabel = tmps;
        image = tmpi;
        item = titem;
      });
    }
  }


  tapRespond() {
    AlertDialog alert = AlertDialog(
      title: Text("Respond to request"),
      content: Text("Do you want to connect with "+label+"?"),
      actions: [
        TextButton(
          child: Text("Connect now"),
          onPressed: () {
            tapConnect();
          },
        ),
        TextButton(
          child: Text("Decline this request"),
          onPressed: () {
            tapDecline();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  tapConnect() {
    Navigator.of(context).pop();
    GlobalData.spaces.add(item);
    GlobalData.space = item;
    GlobalUI.isSignup = true;
    if(item.id != "" && item != null) {
      FirebaseSender.connectSpace(item, item.id, client, GlobalUser.ecName, GlobalUser.ecPhone, GlobalUser.ecType);
      FirebaseSender.deleteLog(id);
      var type = "";
      if(GlobalData.space.showForms && GlobalData.space.pre != "") {
        Connector.getForms();
        type = "form";
      }
      Navigator.push(context, PageRoutes.sharedAxis(()=>SuccessPage(type), SharedAxisTransitionType.horizontal));
    }
  }


  tapDecline() {
    FirebaseSender.deleteLog(id);
    Navigator.of(context).pop();
    tapSkip();
  }


  tapSkip() {
    if(GlobalData.spaces.length == 0) {
      Navigator.push(context, PageRoutes.sharedAxis(()=>TrainerPage(false), SharedAxisTransitionType.horizontal));
    } else if(GlobalData.spaces.length == 1) {
      GlobalData.space = GlobalData.spaces[0];
      Navigator.push(context, PageRoutes.sharedAxis(()=>ConnectPage(), SharedAxisTransitionType.horizontal));
    } else {
      Navigator.push(context, PageRoutes.sharedAxis(()=>SelectPage(), SharedAxisTransitionType.horizontal));
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: MediaQuery(child: Container(
          color: AppColors.bgColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Column (
              children: [
                Text(
                  "New request\nto connect",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 40,
                  ),
                ),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 70),
                  width: double.maxFinite,
                  child: Text(
                    "Tap the trainer/gym to respond",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                InkWell (
                  onTap: () {
                    tapRespond();
                  },
                  child: CardAvatar(label, sublabel, image, 60, 24, ""),
                ),
                
                //renderContent(),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: BtnTertiary(label: "I'LL RESPOND LATER", clickFn: tapSkip)
                )
                
                
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }
}