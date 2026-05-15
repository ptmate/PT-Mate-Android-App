import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/formlabel.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/timer.dart';
import 'package:ptmate_client/_data/variables.dart';


class CountUpPage extends StatefulWidget {
  @override
  _CountUpPageState createState() => _CountUpPageState();
}


class _CountUpPageState extends State<CountUpPage> {

  int min = 0;
  int sec = 0;
  
  void _updateMin(value) {
    int num = 0;
    if(value != "") {
      num = int.parse(value);
    }
    setState(() {
      min = num;
    });
  }

  void _updateSec(value) {
    int num = 0;
    if(value != "") {
      num = int.parse(value);
    }
    setState(() {
      sec = num;
    });
  }

  void _startTimer() {
    if(min == 0 && sec == 0) {
      showAlertDialog();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimerPage("", "countup", min*60+sec, [], ModelBlock("", 0, "", 0, 0, false, "", "", [], true, 0, 0, [], false, "", [], [], [], ""))));
    }
  }

  showAlertDialog() {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { Navigator.of(context).pop(); },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Can't start timer"),
      content: Text("Please set a cut off time."),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
              child: TitleLabelBack("Count Up"),
            ),
            
            FormLabel("Cut off time"),

            // Textfields
            Row(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(20, 10, 10, 0),
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Minutes',
                    suffix: Text("min"),
                    suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (text) {
                    _updateMin(text);
                  },
                )),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    autofocus: false,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Seconds',
                      suffix: Text("sec"),
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (text) {
                      _updateSec(text);
                    },
                  ),
                ),
              ],
            ),
            
            // Button
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: BtnPrimary(label: "Start timer", clickFn: _startTimer)
              )
            )
            
            
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

}