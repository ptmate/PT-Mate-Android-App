import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/formlabel.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-primary-small.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/timer.dart';


class IntervalsPage extends StatefulWidget {
  @override
  _IntervalsPageState createState() => _IntervalsPageState();
}


class _IntervalsPageState extends State<IntervalsPage> {


  int rounds = 0;
  List wmin = [0];
  List wsec = [0];
  List rmin = [0];
  List rsec = [0];
  List list1 = [TextEditingController(text: "0")];
  List list2 = [TextEditingController(text: "0")];
  List list3 = [TextEditingController(text: "0")];
  List list4 = [TextEditingController(text: "0")];

  
  void _updateRounds(value) {
    int num = 0;
    if(value != "") {
      num = int.parse(value);
    }
    setState(() {
      rounds = num;
    });
  }


  void _startTimer() {
    var passed = true;
    var fail1 = false;
    var fail2 = false;
    if(rounds == 0) {
      passed = false;
      fail1 = true;
    }
    for(var i=0; i<wmin.length; i++) {
      if(wmin[i] == 0 && wsec[i] == 0) {
        passed = false;
        fail2 = true;
      }
    }
    if(!passed) {
      showAlertDialog(fail1, fail2);
    } else {
      var ints = [];
      for(var i=0; i<wmin.length; i++) {
        var work = wmin[i]*60+wsec[i];
        var rest = rmin[i]*60+rsec[i];
        ints.add(work);
        ints.add(rest);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimerPage("", "intervals", rounds, ints, ModelBlock("", 0, "", 0, 0, false, "", "", [], true, 0, 0, [], false, "", [], [], [], ""))));
    }
  }


  showAlertDialog(fail1, fail2) {
    // set up the button
    var text = "Please review the following:\n";
    if(fail1) {
      text += "Enter the number of rounds\n";
    }
    if(fail2) {
      text += "Select work time for all intervals\n";
    }
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { Navigator.of(context).pop(); },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Can't start timer"),
      content: Text(text),
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


  _updateMin(pos, value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    var tmp = wmin;
    tmp[pos] = val;
    setState(() {
      wmin = tmp;
    });
  }

  _updateSec(pos, value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    var tmp = wsec;
    tmp[pos] = val;
    setState(() {
      wsec = tmp;
    });
  }


  _updateMinRest(pos, value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    var tmp = rmin;
    tmp[pos] = val;
    setState(() {
      rmin = tmp;
    });
  }

  _updateSecRest(pos, value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    var tmp = rsec;
    tmp[pos] = val;
    setState(() {
      rsec = tmp;
    });
  }


  addInterval() {
    var tmp1 = wmin;
    var tmp2 = wsec;
    var tmp3 = rmin;
    var tmp4 = rsec;
    var tmp5 = list1;
    var tmp6 = list2;
    var tmp7 = list3;
    var tmp8 = list4;
    tmp5.add(TextEditingController(text: "0"));
    tmp6.add(TextEditingController(text: "0"));
    tmp7.add(TextEditingController(text: "0"));
    tmp8.add(TextEditingController(text: "0"));
    tmp1.add(0);
    tmp2.add(0);
    tmp3.add(0);
    tmp4.add(0);
    setState(() {
      wmin = tmp1;
      wsec = tmp2;
      rmin = tmp3;
      rsec = tmp4;
      list1 = tmp5;
      list2 = tmp6;
      list3 = tmp7;
      list4 = tmp8;
    });
  }


  deleteInterval(i) {
    var tmp1 = wmin;
    var tmp2 = wsec;
    var tmp3 = rmin;
    var tmp4 = rsec;
    var tmp5 = list1;
    var tmp6 = list2;
    var tmp7 = list3;
    var tmp8 = list4;
    tmp1.removeAt(i);
    tmp2.removeAt(i);
    tmp3.removeAt(i);
    tmp4.removeAt(i);
    tmp5.removeAt(i);
    tmp6.removeAt(i);
    tmp7.removeAt(i);
    tmp8.removeAt(i);
    setState(() {
      wmin = tmp1;
      wsec = tmp2;
      rmin = tmp3;
      rsec = tmp4;
      list1 = tmp5;
      list2 = tmp6;
      list3 = tmp7;
      list4 = tmp8;
    });
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
              child: TitleLabelBack("Intervals"),
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: renderIntervals(),
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


  renderIntervals() {
    List<Widget> items = [];
    items.add(
      FormLabel("Rounds")
    );
    items.add(
      Container (
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: AppColors.fieldColor,
        ),
        child: TextField(
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: AppColors.textColor),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Total rounds',
            labelStyle: TextStyle(color: AppColors.textColor),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: (text) {
            _updateRounds(text);
          },
        )
      )
    );


    for(var i=0; i<rmin.length; i++) {
      items.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Card(
            elevation: 3,
            color: AppColors.boxColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "INTERVAL "+(i+1).toString(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    renderDelete(i)
                  ]
                ),
                
                Container(
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 6),
                  child: Text(
                    "WORK TIME",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.45),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldAltColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: wmin[i].toString()),
                        controller: list1[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Minutes',
                          suffix: Text("min"),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (text) {
                          _updateMin(i, text);
                        },
                      )
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldAltColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: wsec[i].toString()),
                        controller: list2[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Seconds',
                          suffix: Text("sec"),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (text) {
                          _updateSec(i, text);
                        },
                      ),
                    ),
                  ],
                ),
                
                Container(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 6),
                  child: Text(
                    "REST TIME",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.45),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(15, 0, 5, 20),
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldAltColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: rmin[i].toString()),
                        controller: list3[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Minutes',
                          suffix: Text("min"),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (text) {
                          _updateMinRest(i, text);
                        },
                      )
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 20),
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldAltColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: rsec[i].toString()),
                        controller: list4[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Seconds',
                          suffix: Text("sec"),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (text) {
                          _updateSecRest(i, text);
                        },
                      ),
                    ),
                  ],
                ),
              ]
            ),
          )
        )
      );
    }

    items.add(
      Container (
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: BtnPrimarySmall(label: "ADD INTERVAL", clickFn: addInterval,)
      )
    );
    items.add(
      Container (
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: BtnPrimary(label: "START TIMER", clickFn: _startTimer,)
      )
    );
    return items;
  }


  renderDelete(i) {
    if(i > 0) {
      return Container (
        margin: EdgeInsets.only(right: 15),
        child: InkWell (
          onTap: () {
            deleteInterval(i);
          },
          child: SvgPicture.asset("assets/images/nav/delete.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
        )
      );
    } else {
      return Container();
    }
  }


}