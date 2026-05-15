import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/title.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/card-simple.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/countup.dart';
import 'package:ptmate_client/tools/countdown.dart';
import 'package:ptmate_client/tools/intervals.dart';
import 'package:ptmate_client/tools/tabata.dart';
import 'package:ptmate_client/tools/calculator.dart';
import 'package:ptmate_client/tools/notes.dart';
import 'package:ptmate_client/account/index.dart';



class ToolsPage extends StatefulWidget {
  const ToolsPage();

  static _ToolsPageState appState = _ToolsPageState();
  @override
  _ToolsPageState createState(){
    return ToolsPage.appState = new _ToolsPageState();
  }
}


class _ToolsPageState extends State<ToolsPage> {
 

 List documents = GlobalData.documents;
 String dark = "";

 @override
  void initState() {
    super.initState();
    setState(() {
      documents = GlobalData.documents;
    });
    if(GlobalUI.dark) {
      setState(() {
        dark = "-dark";
      });
    }
  }


 updateData() {
  if(this.mounted) {
    setState(() {
      documents = GlobalData.documents;
    });
  }
}

 @override
 Widget build(BuildContext context) {
  
  return Scaffold(
    backgroundColor: AppColors.bgColor,
    body: MediaQuery(child: Container(
      color: AppColors.bgColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TitleLabel("Tools", false),
            SubtitleLabel("Timers"),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CountUpPage()),);
              },
              child: CardSimple("Count Up", "Set a time cap", GlobalUI.gradients[0], "timer-up.svg"),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CountDownPage()),);
              },
              child: CardSimple("Count Down", "Set a start time", GlobalUI.gradients[1], "timer-down.svg"),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => IntervalsPage()),);
              },
              child: CardSimple("Intervals", "Work & rest times", GlobalUI.gradients[2], "timer-intervals.svg"),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TabataPage()),);
              },
              child: CardSimple("Tabata", "20 sec on, 10 sec off", "-yellow", "timer-tabata.svg"),
            ),
            SubtitleLabel("Calculators"),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CalculatorPage(0)),);
              },
              child: CardSimple("Percentage", "Calculate weight", GlobalUI.gradients[3], "calculator.svg"),
            ),
            SubtitleLabel("About"),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()),);
              },
              child: CardSimple("Account Settings", "Update your preferences", "-grey"+dark, "user.svg")
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage()),);
              },
              child: CardSimple("Private notes", "Manage your personal notes", "-grey"+dark, "documents.svg")
            ),
          ],
        ),
      ),
    ),
    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    ),
  );
 }

}