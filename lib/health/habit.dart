import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/components/data-column.dart';
import 'package:ptmate_client/components/list-habit.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/billing.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:ptmate_client/calendar/comments.dart';
import 'package:ptmate_client/health/habit-day.dart';
import 'package:ptmate_client/components/list-comment.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';


class HabitPage extends StatefulWidget {
  final String id;
  final ModelHabit item;
  const HabitPage(this.id, this.item);
  static _HabitPageState appState = _HabitPageState();
  @override
  _HabitPageState createState(){
    return HabitPage.appState = new _HabitPageState();
  }
}


class _HabitPageState extends State<HabitPage> {

  
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelHabit item = ModelHabit("", "", "", 0, "", 0, DateTime.now(), DateTime.now(), []);


  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
  }


  updateData() {
    if(this.mounted) {
      ModelHabit tmp = ModelHabit("", "", "", 0, "", 0, DateTime.now(), DateTime.now(), []);
      for(var habit in GlobalData.habits) {
        if(habit.id == id) {
          tmp = habit;
        }
      }
      setState(() {
        id = id;
        item = tmp;
      });
    }
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
              child: TitleLabelBack("Habit"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
              child: Text(
                item.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _getContent()
              )
            )
            )
            
            
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getContent() {
    //List items = List();
    List<Widget> items = [];
    items.add(
      Card(
        elevation: 3,
        color: AppColors.boxColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container (
                  padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                  width: MediaQuery.of(context).size.width-50,
                  child: DataLabelCol("Measurement", item.amount.toString()+" "+item.unit+" per "+(item.interval == 1 ? "day" : "week"), (MediaQuery.of(context).size.width-70)),
                ),
              ]
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container (
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  width: (MediaQuery.of(context).size.width-50)*0.5,
                  child: DataLabelCol("Start", HelperCal.getSpecialDateYear(item.start), ((MediaQuery.of(context).size.width-70)*0.5)),
                ),
                Container (
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  width: (MediaQuery.of(context).size.width-50)*0.5,
                  child: DataLabelCol("End", _getEnd(), ((MediaQuery.of(context).size.width-70)*0.5)),
                ),
              ]
            ),
            Container (
              padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
              width: MediaQuery.of(context).size.width-50,
              child: Text(
                "Compliance",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              color: AppColors.fieldColor,
              alignment: Alignment.topLeft,
              margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
              height: 3,
              child: Container(
                color: _getCompliance('color'),
                width: _getCompliance('bar'),
                height: 3,
              )
            ),
            Container (
              padding: EdgeInsets.fromLTRB(15, 5, 0, 20),
              width: (MediaQuery.of(context).size.width-50),
              child: Text(
                _getCompliance('number')+'%',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 20,
                ),
              ),
            ),
          ]
        )
      ),
    );

    items.add(
      Container(
        width: double.maxFinite,
        child: _getList(),
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      )
    );
    return items;
  }


  _getList() {
    List<Widget> items = [];
    var diff = DateTime.now().difference(item.start).inDays+1;
    for(var i=diff-1; i>=0; i--) {
      var status = "Pending";
      var color = AppColors.AvatarColor;
      for(var day in item.days) {
        if(day.contains(GlobalUI.date.format(item.start.add(Duration(days: i)))) && day.contains("||1||")) {
          status = "Achieved";
          color = AppColors.GreenColor;
        }
        if(day.contains(GlobalUI.date.format(item.start.add(Duration(days: i)))) && day.contains("||2||")) {
          status = "Not achieved";
          color = AppColors.RedColor;
        }
      }
      items.add(
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HabitDayPage(item.id, item, GlobalUI.date.format(item.start.add(Duration(days: i))))),);
          },
          child: ListHabit(HelperCal.getSpecialDateYear(item.start.add(Duration(days: i))), "Tap to edit", status, color)
        )
        
      );
    }
    
    
    return Column(children: items,);
  }


  _getEnd() {
    var label = "-";
    if(item.end.isBefore(GlobalUI.date.parse("01/01/2999"))) {
      label = HelperCal.getSpecialDateYear(item.end);
    }
    return label;
  }


  _getCompliance(type) {
    var max = MediaQuery.of(context).size.width-80;
    var diff = DateTime.now().difference(item.start).inDays+1;
    double per = 0;
    double value = 0;
    var color = AppColors.RedColor;
    if(diff != 0) {
      var good = 0;
      for(var i=0; i<diff; i++) {
        var dlabel = GlobalUI.date.format(item.start.add(Duration(days: i)));
        for(var d in item.days) {
          if(d.contains(dlabel) && d.contains("||1||")) {
            good++;
          }
        }
      }
      per = good/diff;
      value = max*per;
    }
    if(type == "bar") {
      return value;
    } else if(type == "number") {
      return ((per*100).round()).toStringAsFixed(0);
    } else {
      if(per > 0.29 && per < 0.80) {
        color = AppColors.OrangeColor;
      } else if(per > 0.79) {
        color = AppColors.GreenColor;
      }
      return color;
    }
  }


}