import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-group.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/toggle.dart';
import 'package:ptmate_client/main.dart';


class SettingsPage extends StatefulWidget {
  static _SettingsPageState appState = _SettingsPageState();
  @override
  _SettingsPageState createState(){
    return SettingsPage.appState = new _SettingsPageState();
  }
}


class _SettingsPageState extends State<SettingsPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool lbs = false;
  bool reminder = true;
  bool email = true;
  int country = 0;
  List<String> cnames = ["Australia", "New Zealand", "United States"];
  List<String> ccodes = ["au", "nz", "us"];


  @override
  void initState() {
    super.initState();
    lbs = GlobalUser.lbs;
    reminder = GlobalUser.reminder;
    country = 0;
    if(GlobalUser.country == "us") {
      country = 1;
    }
  }


  updateData() {
    if(this.mounted) {
      setState(() {
        lbs = GlobalUser.lbs;
        reminder = GlobalUser.reminder;
        email = GlobalData.space.clientEmailReminder;
      });
    }
  }


  _updateType1() { setState(() { lbs = false; }); }
  _updateType2() { setState(() { lbs = true; }); }


  _selectLocation(id) {
    if(id != "Location") {
      var tmp = 2;
      if(id == "Australia") {
        tmp = 0;
      } else if(id == "New Zealand") {
        tmp = 1;
      }
      setState(() {
        country = tmp;
      });
    }
  }


  _setReminder() {
    var tmp = reminder;
    tmp = !tmp;
    setState(() {
      reminder = tmp;
    });
  }


  _setEmail() {
    var tmp = email;
    tmp = !tmp;
    setState(() {
      email = tmp;
    });
  }


  _tapUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Settings successfully updated"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
      )
    );
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
    GlobalUser.lbs = lbs;
    GlobalUser.country = ccodes[country];
    FirebaseSender.updateUserSettings(ccodes[country], lbs, reminder, email);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Settings"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    
                    Container (
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      width: MediaQuery.of(context).size.width - 40,
                      child: Text(
                        "HEALTH LOG UNITS",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.45),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: Row(
                        children: [
                          BtnGroup(label: 'kg/cm', items: 2, active: (lbs == false ? true : false), clickFn: _updateType1,),
                          BtnGroup(label: 'lb/in', items: 2, active: (lbs == true ? true : false), clickFn: _updateType2,),
                        ],
                      )
                    ),

                    Container (
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      width: MediaQuery.of(context).size.width - 40,
                      child: Text(
                        "LOCATION",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.45),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: Container (
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: cnames[country],
                          selectedItemBuilder: (BuildContext context) {
                            return cnames.map((String value) {
                              return Container(
                                padding: EdgeInsets.only(top: 13),
                                  child: Text(
                                  value,
                                  style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
                                )
                              );
                            }).toList();
                          },
                          items: cnames
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.BgColorDark,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(color: AppColors.textColor),
                          onChanged: (String? newValue) {
                            _selectLocation(newValue);
                            /*setState(() {
                              product = newValue!;
                            });*/
                          },
                        )
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'SESSION REMINDER NOTIFICATION',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setReminder();
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Send session reminders', reminder),
                      ),
                    ),

                    _getEmail(),
                    Container(height: 40),

                    BtnPrimary(label: "Save changes", clickFn: _tapUpdate)
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getEmail() {
    if(GlobalData.space.emailReminder) {
      return (
        Column(
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              alignment: Alignment.topLeft,
              child: Text(
                'Booking email confirmation',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              )
            ),
            InkWell(
              onTap: () {
                _setEmail();
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Send booking confirmation via email', email),
              ),
            ),
          ]
        
        ,)
      );
    } else {
      return Container();
    }
  }

}