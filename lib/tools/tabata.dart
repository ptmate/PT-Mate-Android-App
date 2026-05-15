import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/formlabel.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/timer.dart';


class TabataPage extends StatefulWidget {
  @override
  _TabataPageState createState() => _TabataPageState();
}


class _TabataPageState extends State<TabataPage> {


  int rounds = 1;
  TextEditingController _field = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _field.text = "1";
  }


  void _updateRounds(value) {
    int num = 0;
    if(value != "") {
      num = int.parse(_field.text);
    }
    setState(() {
      rounds = num;
    });
  }

  void _startTimer() {
    if(rounds == 0) {
      showAlertDialog();
    } else {
      var ints = [20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10];
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimerPage("", "tabata", rounds, ints, ModelBlock("", 0, "", 0, 0, false, "", "", [], true, 0, 0, [], false, "", [], [], [], ""))));
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
      content: Text("Please enter the number of rounds."),
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
              child: TitleLabelBack("Tabata"),
            ),
            
            FormLabel("Rounds"),

            // Textfields
            Container (
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _field,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Rounds of 4 min',
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (text) {
                  _updateRounds(text);
                },
              )
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