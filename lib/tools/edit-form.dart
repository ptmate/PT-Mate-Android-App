import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-group.dart';
import 'package:ptmate_client/main.dart';


class EditFormPage extends StatefulWidget {
  final String id;
  final ModelForm item;
  const EditFormPage(this.id, this.item);

  static _EditFormPageState appState = _EditFormPageState();
  @override
  _EditFormPageState createState(){
    return EditFormPage.appState = new _EditFormPageState();
  }
}


class _EditFormPageState extends State<EditFormPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelForm item = ModelForm("", "", DateTime(1900), false, 1, "", false, []);
  List<ModelSection> sections = [];
  List<TextEditingController> ctrl = [];


  @override
  void initState() {
    super.initState();
    ctrl = [];
    
    setState(() {
      id = widget.item.id;
      item = widget.item;
    });

    for (var i=0; i<item.sections.length; i++) {
      ctrl.add(TextEditingController());
      ctrl[ctrl.length-1].text = item.sections[i].response;
      if(item.sections[i].type == "yesno") {
        ctrl[ctrl.length-1].text = item.sections[i].detail;
      }
    }

    sections = [];
    for(var sec in item.sections) {
      sections.add(
        ModelSection(sec.id, sec.seq, sec.type, sec.label, sec.num, sec.multiple, sec.answer1, sec.answer2, sec.response, sec.detail, sec.options, sec.mandatory)
      );
    }
  }


  updateData() {
    if(this.mounted) {
      var frm = ModelForm("", "", DateTime(1900), false, 1, "", false, []);
      for(var fm in GlobalData.space.forms) {
        if(fm.id == id) {
          frm = fm;
        }
      }
      setState(() {
        id = frm.id;
        item = frm;
      });
    }
  }


  _updateText(pos, value) {
    if(sections[pos].type == 'yesno') {
      sections[pos].detail = value;
    } else {
      sections[pos].response = value;
    }
  }


  _updateYesno(pos, value) {
    var tmp = sections;
    tmp[pos].response = value;
    if(tmp[pos].type == "yesno") {
      if((!tmp[pos].answer1 && value == "0") || (!tmp[pos].answer2 && value == "1")) {
        tmp[pos].detail = "";
        ctrl[pos].text = "";
      }
    }
    setState(() {
      sections = tmp;
    });
  }


  _updateSelection(pos, value) {
    var tmp = sections;
    if(!tmp[pos].multiple) {
      tmp[pos].response = value;
    } else {
      var ar = tmp[pos].response.split(",");
      var label = "";
      if(ar.contains(value)) {
        ar.remove(value);
      } else {
        ar.add(value);
      }
      for(var a in ar) {
        if(a != "") {
          label += a+",";
        }
      }
      if(label.length > 0) {
        label = label.substring(0, label.length-1);
      }
      tmp[pos].response = label;
    }
    setState(() {
      sections = tmp;
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
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack(('Response')),
            ),
            Container(
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: 
                    _getSections(),
                  
                ),
              ),
            ),
            Container(height: 20),
            BtnPrimary(label: 'Save', clickFn: _tapUpdate,)
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getSections() {
    List<Widget> items = [];
    items.add(Container(height: 30));
    for(var i=0; i<sections.length; i++) {
      var sec = sections[i];
      if(sec.type == 'header') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 45),
            width: MediaQuery.of(context).size.width,
            child: Text(
              sec.label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          )
        );
      }
      if(sec.type == 'paragraph') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 45),
            width: MediaQuery.of(context).size.width,
            child: Text(
              sec.label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          )
        );
      }
      // Text field
      if(sec.type == 'text') {
        items.add(
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  sec.label,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 45),
                width: MediaQuery.of(context).size.width-40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: ctrl[i],
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Answer',
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  onChanged: (text) {
                    _updateText(i, text);
                  },
                )),
            ]
        ));
      }
      // Yes / No
      if(sec.type == 'yesno') {
        items.add(
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  sec.label+(sec.mandatory ? "*" : ""),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container (
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: Row(
                  children: [
                    Container (
                      height: 40,
                      width: (MediaQuery.of(context).size.width-44)/2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: (sec.response == "0" ? AppColors.boxColor : AppColors.fieldColor),
                      ),
                      child: InkWell (
                        onTap: () {
                          _updateYesno(i, "0");
                        },
                        child: Container (
                          padding: EdgeInsets.only(top: 10),
                          child: Text (
                            "Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: (sec.response == "0" ? FontWeight.w600 : FontWeight.w400),
                              fontSize: 16,
                            ),
                          )
                        )
                      )
                    ),
                    Container (
                      height: 40,
                      width: (MediaQuery.of(context).size.width-44)/2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: (sec.response == "1" ? AppColors.boxColor : AppColors.fieldColor),
                      ),
                      child: InkWell (
                        onTap: () {
                          _updateYesno(i, "1");
                        },
                        child: Container (
                          padding: EdgeInsets.only(top: 10),
                          child: Text (
                            "No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: (sec.response == "1" ? FontWeight.w600 : FontWeight.w400),
                              fontSize: 16,
                            ),
                          )
                        )
                      )
                    )
                  ],
                )
              ),
              _getDetail(i),
              Container(height: 30)
            ]
          )
        );
      }
      if(sec.type == 'selection') {
        items.add(
          Column(
            children: _getSelection(i)
          )
        );
      }
      // Rating
      if(sec.type == 'rating') {
        List<Widget> btns = [];
        for(var j=0; j<sec.num; j++) {
          btns.add(
            Container (
              height: 40,
              width: (MediaQuery.of(context).size.width-44)/sec.num,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: (sec.response == (j+1).toString() ? AppColors.boxColor : AppColors.fieldColor),
              ),
              child: InkWell (
                onTap: () {
                  _updateYesno(i, (j+1).toString());
                },
                child: Container (
                  padding: EdgeInsets.only(top: 10),
                  child: Text (
                    (j+1).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: (sec.response == (j+1).toString() ? FontWeight.w600 : FontWeight.w400),
                      fontSize: 16,
                    ),
                  )
                )
              )
            ),
          );
        }
        items.add(
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  sec.label+(sec.mandatory ? "*" : ""),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container (
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 45),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: Row(
                  children: btns,
                )
              ),
            ]
          )
        );
      }
    }
    return items;
  }


  _getDetail(i) {
    var show = false;
    if(sections[i].answer1 && sections[i].response == "0") {
      show = true;
    }
    if(sections[i].answer2 && sections[i].response == "1") {
      show = true;
    }
    if(show) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
        width: MediaQuery.of(context).size.width-40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: AppColors.fieldColor,
        ),
        child: TextField(
          keyboardType: TextInputType.text,
          controller: ctrl[i],
          style: TextStyle(color: AppColors.textColor),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Provide details',
            labelStyle: TextStyle(color: AppColors.textColor),
          ),
          onChanged: (text) {
            _updateText(i, text);
          },
        ));
    } else {
      return Container();
    }
  }


  _getYesno(sec) {
    var label = "-";
    var vals = ["Yes", "No"];
    if(sec.response != "") {
      label = vals[int.parse(sec.response)];
      if(sec.detail != "") {
        label += "\n"+sec.detail;
      }
    }
    return label;
  }


  _getSelection(i) {
    List<Widget> items = [];
    var sec = sections[i];
    items.add(
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        width: MediaQuery.of(context).size.width,
        child: Text(
          (sec.multiple ? sec.label+" (Multiple selection)" : sec.label)+(sec.mandatory ? "*" : ""),
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
    for(var j=0; j<sec.options.length; j++) {
      items.add(
        Container(
          width: MediaQuery.of(context).size.width-40,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: InkWell(
            onTap: () {
              _updateSelection(i, j.toString());
            },
            child: Row(
              children: [
                SvgPicture.asset(_getSelected(sec, j), width: 20, height: 20),
                Container(width: 10),
                Container(
                  width: MediaQuery.of(context).size.width-80,
                  child: Text(
                    sec.options[j],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ]
            )
          )
        )
      );
    }
    items.add(Container(height: 35));
    return items;
  }


  _getSelected(sec, i) {
    var ar = sec.response.split(",");
    var label = "assets/images/list/terms-off.svg";
    if(ar.contains(i.toString())) {
      label = "assets/images/list/terms-on.svg";
    }
    return label;
  }


  _tapUpdate() {
    var passed = true;
    for(var sec in sections) {
      if(sec.mandatory && sec.response == "") {
        passed = false;
      }
    }
    if(passed) {
      FirebaseSender.saveForm(item, sections);
      FirebaseSender.sendPushMessage(GlobalData.space.token, "Form completed", GlobalUser.name+" just completed "+item.name, "form", id, []);
      _showConfirmation("Response successfully updated");
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("Check mandatory questions"),
        content: Text("Please answer all the questions marked with *"),
        actions: [
          TextButton(
            child: Text("Got it"),
            onPressed: () { Navigator.of(context).pop(); },
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
  }


  _showConfirmation(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }
}