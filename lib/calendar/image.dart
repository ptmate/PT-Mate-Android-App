import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/list-text.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:url_launcher/url_launcher.dart';


class ExImagePage extends StatefulWidget {
  final ModelMovement item;
  static _ExImagePageState appState = _ExImagePageState();
  const ExImagePage(this.item);
  @override
  _ExImagePageState createState() {
    return ExImagePage.appState = new _ExImagePageState();
  }
}


class _ExImagePageState extends State<ExImagePage> {


  ModelMovement item = ModelMovement("", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", "", "", "", "", "", "", "", "", "", "");
  String img = "";
  String desc = "";
  String video = "";
  bool opened = false;
  List<ModelHistory> items = [];


  @override
  void initState() {
    super.initState();
    getImage();

    if(GlobalData.archive.length == 0) {
      Connector.getSessionsArchive();
    }

    setState(() {
      item = widget.item;
      desc = widget.item.desc;
    });
    if(widget.item.desc == "") {
      for(var ex in GlobalData.movements) {
        if(ex.id == widget.item.id) {
          setState(() {
            desc = ex.desc;
            video = ex.video;
          });
        }
      }
    }
    configureData();
  }


  updateData() {
    if (this.mounted) {
      for(var ex in GlobalData.movements) {
        if(ex.id == widget.item.id) {
          setState(() {
            desc = ex.desc;
            video = ex.video;
          });
        }
      }
      configureData();
    }
  }


  configureData() {
    items = [];
    for(var sess in GlobalData.archive) {
      if(sess.type == "pt" || (sess.type == "group" && sess.clients.contains(GlobalData.space.client))) {
        if(sess.program != null) {
          for(var bl in sess.program.blocks) {
            for(var ex in bl.movements) {
              if(ex.id == item.id) {
                var reps = ex.reps.toString();
                var weight = ex.weight.toString();
                var unit1 = " "+ex.unit;
                var unit2 = GlobalUser.lbs ? " lb" : " kg";
                var unit2a = " "+ex.weightType;
                if(ex.weightType == "per" || ex.weightType == '') { unit2a = '%'; }
                if(ex.repsRounds != "") { reps = ex.repsRounds.toString(); }
                if(ex.weightRounds != "") { weight = ex.weightRounds; }
                if(ex.type == "pt") {
                  if(ex.resReps > 0) { reps = ex.resReps.toString(); }
                  if(ex.resRepsRounds != "") { reps = ex.resRepsRounds.toString(); }
                  if(ex.resWeight > 0) { weight = ex.resWeight.toString(); }
                  if(ex.resWeightRounds != "") { weight = ex.resWeightRounds.toString(); }
                  if(ex.resWeight == 0 && ex.resWeightRounds == "") { unit2 = unit2a; }
                } else {
                  if(sess.clients.length > 0) {
                    var cl = 0;
                    for(var i=0; i<sess.clients.length; i++) {
                      if(sess.clients[i] == GlobalData.space.client) {
                        cl = i;
                      }
                    }
                    if(ex.resRepsGroup != "") {
                      var ar = ex.resRepsGroup.split('-');
                      if(ar[0] == '') { ar.removeAt(0); }
                      if(ar.length > cl) { reps = ar[cl]; }
                    }
                    if(ex.resRepsRounds != "") {
                      var ar = ex.resRepsRounds.split('|');
                      if(ar[0] == '') { ar.removeAt(0); }
                      if(ar.length > cl) { reps = ar[cl]; }
                    }
                    if(ex.resWeightGroup != "") {
                      var ar = ex.resWeightGroup.split('-');
                      if(ar[0] == '') { ar.removeAt(0); }
                      if(ar.length > cl) { weight = ar[cl]; }
                    }
                    if(ex.resWeightRounds != "") {
                      var ar = ex.resWeightRounds.split('|');
                      if(ar[0] == '') { ar.removeAt(0); }
                      if(ar.length > cl) { weight = ar[cl]; }
                    }
                  }
                }
                if(weight == '' || weight == ex.weight.toString() || weight == ex.weightRounds) { unit2 = unit2a; }
                if(reps == '0') {
                  reps = '-';
                } else {
                  reps += unit1;
                }
                items.add(ModelHistory(sess.id, ex.tool, sess.date, GlobalUI.titles[bl.type], reps, weight+unit2));
              }
            }
          }
        }
      }
    }
  }


  _toggleHistory() {
    setState(() {
      opened = !opened;
    });
  }


  tapVideo() {
    launch(video);
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Movement"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
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
                padding: EdgeInsets.fromLTRB(20, 30, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container (
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Image.network(img)
                    ),
                    getWeights(),
                    getHistory(),
                    Container (
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: Text(
                        desc,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    getButton()
                  ]
                )
              )
            )
          ]
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  getWeights() {
    var title = "1 rep max";
    var l1 = "-";
    var l2 = "-";
    var dt = GlobalUI.dateTime.parse("01/01/1900 00:00");
    var dv = DateFormat("d MMM");
    for(var bs in GlobalData.best) {
      if(bs.id == item.id) {
        l1 = bs.actual.toStringAsFixed(1)+" kg";
        l2 = HelperCal.getSpecialDateYear(bs.date);
        if(GlobalUser.lbs) {
          l1 = (bs.actual*GlobalUI.lbsUp).toStringAsFixed(1)+" lbs";
        }
        if(bs.actual != bs.value) {
          title = "Heaviest";
        }
      }
    }
    if(GlobalUI.exToolsWeight.contains(item.tool)) {
      return (
        Container(
          margin: EdgeInsets.only(bottom: 15),
          child: CardText(title, l1+"\n"+l2,""),
        )
      );
    } else {
      return Container();
    }
  }


  getHistory() {
    List<Widget> itms = [];
    if(items.length > 0) {
      if(opened) {
        itms.add(Container(height: 20));
        itms.add(BtnTertiary(label: "HIDE HISTORY", clickFn: _toggleHistory));
        itms.add(Container(height: 20));
        for(var w in items) {
          itms.add(ListText(HelperCal.getSpecialDate(w.date), w.name+"\n"+w.reps+' with '+w.weight));
        }
        itms.add(Container(height: 40));
      } else {
        itms.add(Container(height: 20));
        itms.add(BtnTertiary(label: "SHOW HISTORY", clickFn: _toggleHistory));
        itms.add(Container(height: 40));
      }
    }
    return Column(children: itms,);
  }


  getButton() {
    var video = "";
    for(var ex in GlobalData.movements) {
      if(ex.id == item.id && ex.video != "") {
        video = ex.video;
      }
    }
    if(video == "") {
      return Container();
    } else {
      return BtnPrimary(label: "WATCH VIDEO", clickFn: tapVideo);
    }
  }


  getImage() async {
    if(widget.item.image == "") {
      setState(() {
        img = 'https://www.ptmate.app/img/no-image.png';
      });
    } else if(widget.item.image.indexOf('adm-') != -1) {
      setState(() {
        img = 'https://www.ptmate.app/img/exercises/'+widget.item.image+'.jpg';
      });
    } else {
      final ref = FirebaseStorage.instance.ref().child('/images/exercises/'+widget.item.image);
      var url = await ref.getDownloadURL();
      setState(() {
        img = url;
      });
    }
    
  }


}