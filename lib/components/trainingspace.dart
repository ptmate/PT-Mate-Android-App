import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/avatar-square.dart';

import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/calendar/index.dart';


class TrainingSpace extends StatefulWidget {

  static _TrainingSpaceState appState = _TrainingSpaceState();
  @override
  _TrainingSpaceState createState(){
    return TrainingSpace.appState = new _TrainingSpaceState();
  }
}


class _TrainingSpaceState extends State<TrainingSpace> {


  String name = GlobalData.space.name;
  String business = GlobalData.space.business;
  String location = GlobalUI.location;
  String image = "";


  @override
  void initState() {
    super.initState();
  }


  void updateData() {
    if(this.mounted) {
      setState(() {
        name = GlobalData.space.name;
        business = GlobalData.space.business;
        location = GlobalUI.location;
      });
    }
  }

  
  String getInitials() {
    String inits = "";
    String label = name;
    if(business != "" && business != null) {
      label = business;
    }
    var arr = label.split(" ");
    for(var item in arr) {
      if(item != "") {
        inits += item[0];
      }
    }
    if(inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

  
  @override
  Widget build(BuildContext context) {
    var text = name;
    if(business != null) {
      text = business;
    }
    if(!GlobalData.space.active) {
      text += " (Inactive)";
    }
    if(GlobalData.locations.length > 0) {
      text = "All locations";
      if(GlobalUI.location == "notset") {
        text = "No location set";
      }
      if(GlobalUI.location != "notset" && GlobalUI.location != "") {
        for(var item in GlobalData.locations) {
          if(item.id == GlobalUI.location) {
            text = item.name;
          }
        }
      }
    }
    if(GlobalData.locations.length > 0) {
      return Container (
        padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
        width: double.maxFinite,
        child: InkWell(
          onTap: () {
            tapLocation(context);
          },
          child: Row (
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: AvatarSquare(getInitials(), 30, GlobalData.space.image, 14),
              ),
              Text(
                text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              //renderLocation(),
            ]
          )
        )
        
      );
    } else {
      return Container (
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        width: double.maxFinite,
        child: Row (
          children: <Widget> [
            Container (
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: AvatarSquare(getInitials(), 30, GlobalData.space.image, 14),
            ),
            Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            //renderLocation(),
          ]
        )
      );
    }
  }


  tapLocation(context) {
    List<Widget> actions = [];
    if(GlobalUI.locationsAll) {
      actions.add(
        TextButton(
          child: Text("Show all locations"),
          onPressed: () {
            updateLocation("");
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      var str = "";
      for(var item in GlobalData.locations) {
        str += item.id+",";
      }
      actions.add(
        TextButton(
          child: Text("Show all locations"),
          onPressed: () {
            updateLocation(str);
            Navigator.of(context).pop();
          },
        ),
      );
    }
    for(var item in GlobalData.locations) {
      actions.add(TextButton(
        child: Text(item.name),
        onPressed: () {
          updateLocation(item.id);
          Navigator.of(context).pop();
        },
      ));
    }
    actions.add(
      TextButton(
        child: Text("Cancel"),
        onPressed: () { Navigator.of(context).pop(); },
      ),
    );
    AlertDialog alert = AlertDialog(
      title: Text("Switch location"),
      content: Text(""),
      actions: actions,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  updateLocation(id) {
    GlobalUI.location = id;
    HomePage.appState.updateLocation();
    CalendarPage.appState.updateData();
    setState(() {
      location = id;
    });
  }
}