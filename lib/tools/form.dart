import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/tools/edit-form.dart';
import 'package:ptmate_client/main.dart';


class FormPage extends StatefulWidget {
  final String id;
  final ModelForm item;
  const FormPage(this.id, this.item);

  static _FormPageState appState = _FormPageState();
  @override
  _FormPageState createState(){
    return FormPage.appState = new _FormPageState();
  }
}


class _FormPageState extends State<FormPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelClient client = ModelClient("", "", "", "", "", "", false, "");
  ModelForm item = ModelForm("", "", DateTime(1900), false, 1, "", false, []);


  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.item.id;
      item = widget.item;
    });
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
              child: TitleLabelBack(('Form')),
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
    for(var sec in item.sections) {
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
      if(sec.type == 'text') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: MediaQuery.of(context).size.width,
            child: DataLabel(sec.label, sec.response == "" ? "-" : sec.response)
          )
        );
      }
      if(sec.type == 'yesno') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: MediaQuery.of(context).size.width,
            child: DataLabel(sec.label, _getYesno(sec))
          )
        );
      }
      if(sec.type == 'selection') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: MediaQuery.of(context).size.width,
            child: DataLabel(sec.multiple ? sec.label+" (Multiple selection)" : sec.label, _getSelection(sec))
          )
        );
      }
      if(sec.type == 'rating') {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: MediaQuery.of(context).size.width,
            child: DataLabel(sec.label, sec.response == "" ? "-" : sec.response+" out of "+sec.num.toString())
          )
        );
      }
    }
    var label = "FILL OUT";
    var add = true;
    if(item.date.isAfter(DateTime(1900))) {
      label = "UPDATE RESPONSE";
      if(item.lock) {
        add = false;
      }
    }
    if(add) {
      items.add(BtnTertiary(label: label, clickFn: _tapUpdate,));
    }
    return items;
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


  _getSelection(sec) {
    var label = "-";
    if(sec.response != "") {
      label = "";
      var ar = sec.response.split(',');
      for(var a in ar) {
        label += sec.options[int.parse(a)]+"\n";
      }
      label = label.substring(0, label.length-1);
    }
    return label;
  }


  _tapUpdate() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditFormPage(id, item)),);
  }
}