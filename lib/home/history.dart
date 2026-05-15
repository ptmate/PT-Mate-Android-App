import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:intl/intl.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/main.dart';


class HistoryPage extends StatefulWidget {
  final String title;
  final List<ModelSession> items;
  const HistoryPage(this.title, this.items);
  static _HistoryPageState appState = _HistoryPageState();
  @override
  _HistoryPageState createState() {
    return HistoryPage.appState = new _HistoryPageState();
  }
}


class _HistoryPageState extends State<HistoryPage> {

  List<ModelSession> sessions = [];
  String title = "Sessions";


  @override
  void initState() {
    super.initState();
    List<ModelSession> tmp = widget.items;
    tmp.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      sessions = tmp;
      title = widget.title;
    });
  }


  updateData() {
    if(this.mounted) {
      //update
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack(title),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getSessions()
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


  _getSessions() {
    List<Widget> items = [];
    print(sessions.length);
    if(sessions.length == 0) {
      print("adding empty");
      items.add(
        EmptyMessage("empty-session", "No classes or sessions", "There are no classes\nor 1:1 sessions")
      );
    } else {
      for(var item in sessions) {
        var name = item.name;
        if(item.availability) {
          name = "1:1 Availability";
        }
        items.add(
          InkWell(
            onTap: () {
              tapSession(item);
            },
            child: ListDefault(name, getSessionInfo(item), "", HelperCal.getTypeColor(item.type, item.availability), HelperCal.getTypeImage(item.type, item.availability), false)
          )
        );
      }
    }
    return items;
  }


  getSessionInfo(item) {
    var label = DateFormat("HH:mm").format(item.date)+" h\n"+HelperCal.getDuration(item.duration, "hours");
    if(item.locationName != "") {
      label = DateFormat("HH:mm").format(item.date)+" h - "+HelperCal.getDuration(item.duration, "hours")+"\n"+item.locationName;
    }
    if(item.availability && item.name != "1:1 availability") {
      label = item.name+"\n"+DateFormat("HH:mm").format(item.date)+" h - "+HelperCal.getDuration(item.duration, "hours");
    }
    return label;
  }


  tapSession(item) {
    var name = "class";
    if(item.availability) {
      name = "session";
    }
    if(GlobalData.space.active) {
      if(item.date.isBefore(DateTime.now())) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage(item.id, item)),);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SessionPage(item.id, item)),);
      }
    }
  }

}