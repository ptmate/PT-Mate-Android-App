import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/button-group.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/sender.dart';


class HabitDayPage extends StatefulWidget {
  final String id;
  final ModelHabit item;
  final String date;
  const HabitDayPage(this.id, this.item, this.date);
  static _HabitDayPageState appState = _HabitDayPageState();
  @override
  _HabitDayPageState createState() {
    return HabitDayPage.appState = new _HabitDayPageState();
  }
}

class _HabitDayPageState extends State<HabitDayPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String date = "";
  int status = 0;
  ModelHabit item = ModelHabit("", "", "", 0, "", 1, DateTime.now(), DateTime.now(), []);
  String text = "";
  TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    List arr = [];
    String stat = "0";
    String notes = "";
    for(var day in widget.item.days) {
      if(day.contains(widget.date)) {
        arr = day.split("||");
        stat = arr[1];
        if(arr.length > 2) {
          notes = arr[2];
        }
      }
    }
    setState(() {
      id = widget.id;
      item = widget.item;
      date = widget.date;
      status = int.parse(stat);
      _field.text = notes;
    });
  }

  void _updateValue(value) {
    setState(() {
      text = value;
    });
  }


  _updateType1() { setState(() { status = 1; }); }
  _updateType2() { setState(() { status = 2; }); }


  updateDay() {
    List days = [];
    for(var item in item.days) {
      if(!item.contains(date)) {
        days.add(item);
      }
    }
    if(item.interval == 1) {
      days.add(date+"||"+status.toString()+"||"+_field.text);
    } else {
      var d = GlobalUI.date.parse(date);
      var i = 0;
      var sd = item.start;
      while(item.start.add(Duration(days: i*7)).isBefore(d.add(Duration(days: 1)))) {
        sd = item.start.add(Duration(days: i*7));
        i++;
      }
      var d1 = GlobalUI.date.format(sd);
      var d2 = GlobalUI.date.format(sd.add(Duration(days: 1)));
      var d3 = GlobalUI.date.format(sd.add(Duration(days: 2)));
      var d4 = GlobalUI.date.format(sd.add(Duration(days: 3)));
      var d5 = GlobalUI.date.format(sd.add(Duration(days: 4)));
      var d6 = GlobalUI.date.format(sd.add(Duration(days: 5)));
      var d7 = GlobalUI.date.format(sd.add(Duration(days: 6)));
      days.add(d1+","+d2+","+d3+","+d4+","+d5+","+d6+","+d7+"||"+status.toString()+"||"+_field.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Changes successfully saved"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));
    FirebaseSender.updateHabit(item.id, days);

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
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
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
              child: TitleLabelBack(item.interval == 1 ? "Day" : "Week"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 50),
              child: Text(
                _getSubtitle(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),

            Container (
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              width: MediaQuery.of(context).size.width - 40,
              child: Text(
                (item.interval == 1 ? "DAILY " : "WEEKLY")+" GOAL ACHIEVED?",
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
              margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: Row(
                children: [
                  BtnGroup(label: 'Achieved', items: 2, active: (status == 1 ? true : false), clickFn: _updateType1,),
                  BtnGroup(label: 'Not achieved', items: 2, active: (status == 2 ? true : false), clickFn: _updateType2,),
                ],
              )
            ),

            Container (
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              width: MediaQuery.of(context).size.width - 40,
              child: Text(
                "NOTES",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(0.45),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),

            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  controller: _field,
                  minLines: 1,
                  maxLines: 25,
                  autofocus: false,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Notes (optional)',
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  onChanged: (text) {
                    _updateValue(text);
                  },
                )),
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: BtnPrimary(
                label: "SAVE CHANGES",
                clickFn: updateDay,
              ),
            ),
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

  
  _getSubtitle() {
    var label = "";
    var d = GlobalUI.date.parse(date);
    label = HelperCal.getSpecialDateYear(d);
    if(item.interval == 7) {
      var i = 0;
      var sd = item.start;
      while(item.start.add(Duration(days: i*7)).isBefore(d.add(Duration(days: 1)))) {
        sd = item.start.add(Duration(days: i*7));
        i++;
      }
      label = HelperCal.getSpecialDateBasic(sd)+" - "+HelperCal.getSpecialDateBasic(sd.add(Duration(days: 6)));
    }

    return label;
  }
}
