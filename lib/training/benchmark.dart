import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/calendar/running.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:url_launcher/url_launcher.dart';


class BenchmarkPage extends StatefulWidget {
  final String id;
  final ModelProgram item;
  const BenchmarkPage(this.id, this.item);
  static _BenchmarkPageState appState = _BenchmarkPageState();
  @override
  _BenchmarkPageState createState(){
    return BenchmarkPage.appState = new _BenchmarkPageState();
  }
}


class _BenchmarkPageState extends State<BenchmarkPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelProgram item = ModelProgram("", "", "", 0, 0, "", [], false, "");
  List<ModelSession> sessions = [];


  @override
  void initState() {
    super.initState();
    List<ModelSession> tsessions = [];

    for(var item in GlobalData.sessions) {
      if(!tsessions.contains(item) && item.attendance == 3) {
        if(item.type == "pt") {
          if(item.program != null) {
            if(item.program.id == widget.id) {
              tsessions.add(item);
            }
          }
        } else if(item.clients != null) {
          if(item.clients.contains(GlobalData.space.client)) {
            if(item.program != null) {
              if(item.program.id == widget.id) {
              tsessions.add(item);
            }
            }
          }
        }
      }
    }
    for(var item2 in GlobalData.training) {
      if(!tsessions.contains(item2) && item2.attendance == 3) {
        if(item2.program != null) {
          if(item2.program.id == widget.id) {
              tsessions.add(item2);
            }
        }
      }
    }

    setState(() {
      id = widget.id;
      item = widget.item;
      sessions = tsessions;
    });
    sessions.sort((a, b) => b.date.compareTo(a.date));
  }


  updateData() {
    /*if(this.mounted && plan != "") {
      ModelProgram tmp = ModelProgram("", "", "", 0, 0, "", [], false);
      for(var prog in GlobalData.programs) {
        if(prog.id == id) {
          tmp = prog;
        }
      }
      setState(() {
        item = tmp;
      });
    }*/
  }


  tapVideo() async {
    await launch(item.video);
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
              child: TitleLabelBack("Program"),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getBlocks()
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


  _getBlocks() {
    List<Widget> items = [];
    items.add(
      Container (
        margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
        padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage("assets/images/common/gradient"+HelperTrain.getColor(item.time)+".png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Text(
          item.time.toString()+"'",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 34,
          ),
        ),
      ),
    );
    items.add(
      Text(
        item.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
    items.add(
      Container (
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Text(
          item.desc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
          ),
        ),
      )
    );
    if(item.video != "") {
      items.add(
        Container (
          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: BtnTertiary(label: "Watch video", clickFn: tapVideo,),
        )
      );
    }
    for(var block in item.blocks) {
      var subtitle = GlobalUI.cats[block.cat].toUpperCase();
      if(block.name != "") {
        subtitle = block.name.toUpperCase();
      }
      items.add(
        TitleDoubleLabel(GlobalUI.titles[block.type].toUpperCase()+HelperTrain.getBlockInfo(block).toUpperCase(), subtitle, "program", "", block.id)
      );
      if(!block.simple) {
        for(var ex in block.movements) {
          items.add(
            Container(
              padding: EdgeInsets.fromLTRB(0,0,0,5),
              //height: 85,
              width: double.maxFinite,

              child: Card(
                elevation: 3,
                color: AppColors.boxColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget> [
                    Container (
                      margin: EdgeInsets.fromLTRB(20, 13, 20, 5),
                      width: MediaQuery.of(context).size.width-100,
                      child: Text(
                        HelperTrain.getMovementName(ex, block),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container (
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      width: MediaQuery.of(context).size.width-100,
                      child: Text(
                        HelperTrain.getMovementInfo(ex, block),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                        ),
                      )
                    ),
                    Container (
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      width: MediaQuery.of(context).size.width-100,
                      child: _getResults(ex, block)
                    )
                  ]
                )
              ),
              
            )
          );
        }
      }
      if(block.notes != "") {
        items.add(
          Container (
            width: MediaQuery.of(context).size.width-70,
            padding: EdgeInsets.only(top: 7),
            child: Text(
              block.notes,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: (block.simple ? 15 : 11),
              ),
            )
          )
        );
      }
    }
    
    return items;
  }


  _getResults(ex, block) {
    List<Widget> items = [];
    for(var session in sessions) {
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width-100)/3,
              child: Text(
                DateFormat("d MMM yyyy").format(session.date),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 11,
                ),
              ),
              ),
            Container(
              width: (MediaQuery.of(context).size.width-100)/3,
              child: Text(
                _getReps(ex.id, block.id, session),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 11,
                ),
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width-100)/3,
              child: Text(
                _getWeight(ex.id, block.id, session),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        )
      );
    }

    return Column(
      children: items,
    );
  }


  _getReps(move, block, session) {
    var label = "-";
    for(var blck in session.program.blocks) {
      if(blck.id == block) {
        for(var mov in blck.movements) {
          var unit = " reps";
          if(mov.tool == 6 || mov.tool == 7 || mov.tool == 25) {
            unit = " m";
          }
          if(mov.tool == 27) {
            unit = " cal";
          }
          if(mov.tool == 28) {
            unit = " sec";
          }
          if(mov.unit != "") {
            if(mov.unit == 'dist') {
              unit = "m";
            }
            if(mov.unit == 'cals') {
              unit = "cal";
            }
            if(mov.unit == 'time') {
              unit = "s";
            }
          }
          if(mov.id == move && session.type != "group") {
            label = mov.resReps.toString()+unit;
            if(mov.resReps == 0) {
              label = "-";
            }
            if(mov.resRepsRounds != "") {
              label = mov.resRepsRounds.toString()+unit;
            }
          }
          if(mov.id == move && session.type == "group") {
            var client = 0;
            for(var i=0; i<session.clients.length; i++) {
              if(session.clients[i] == GlobalData.space.client) {
                client = i;
              }
            }
            var ar1 = mov.resRepsGroup.split("-");
            var ar2 = mov.resRepsRounds.split("|");
            if(ar1.length > client) {
              if(ar1[client] != "0" && ar1[client] != "") {
                label = ar1[client].toString()+unit;
              }
            }
            if(ar2.length > client) {
              if(ar2[client] != "") {
                label = ar2[client].toString()+unit;
              }
            }
          }
        }
      }
    }
    return label;
  }


  _getWeight(move, block, session) {
    var label = "-";
    for(var blck in session.program.blocks) {
      if(blck.id == block) {
        for(var mov in blck.movements) {
          var unit = " kg";
          if(GlobalUser.lbs) {
            unit = " lbs";
          }
          if(mov.id == move && session.type != "group") {
            label = mov.resWeight.toString()+unit;
            if(GlobalUser.lbs) {
              label = (mov.resWeight*GlobalUI.lbsUp).toStringAsFixed(1)+unit;
            }
            if(mov.resWeight == 0) {
              label = "-";
            }
            if(mov.resWeightRounds != "") {
              label = mov.resWeightRounds.toString()+unit;
              if(GlobalUser.lbs) {
                label = (mov.resWeightRounds*GlobalUI.lbsUp).toStringAsFixed(1)+unit;
              }
            }
            if(!GlobalUI.exToolsWeight.contains(mov.tool)) {
              label = "";
            }
          }
          if(mov.id == move && session.type == "group") {
            var client = 0;
            for(var i=0; i<session.clients.length; i++) {
              if(session.clients[i] == GlobalData.space.client) {
                client = i;
              }
            }
            var ar1 = mov.resWeightGroup.split("-");
            var ar2 = mov.resWeightRounds.split("|");
            if(ar1.length > client) {
              if(ar1[client] != "0" && ar1[client] != "") {
                label = ar1[client].toString()+unit;
                if(GlobalUser.lbs) {
                  label = (ar1[client]*GlobalUI.lbsUp).toStringAsFixed(1)+unit;
                }
              }
            }
            if(ar2.length > client) {
              if(ar2[client] != "") {
                label = ar2[client].toString()+unit;
                if(GlobalUser.lbs) {
                  label = (ar2[client]*GlobalUI.lbsUp).toStringAsFixed(1)+unit;
                }
              }
            }
            if(!GlobalUI.exToolsWeight.contains(mov.tool)) {
              label = "";
            }
          }
        }
      }
    }
    return label;
  }

}