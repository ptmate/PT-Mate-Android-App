import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/button-primary-small.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/button-primary-small.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/tools/timer.dart';
import 'package:ptmate_client/tools/sets.dart';
import 'package:ptmate_client/calendar/editresults.dart';
import 'package:ptmate_client/calendar/image.dart';


class RunningPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  const RunningPage(this.id, this.item);
  static _RunningPageState appState = _RunningPageState();
  @override
  _RunningPageState createState() {
    return RunningPage.appState = new _RunningPageState();
  }
}

class _RunningPageState extends State<RunningPage> {

  
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelSession item = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");
  bool setup = true;
  bool finished = false;
  int current = 0;



  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
  }


  updateData() {
    if (this.mounted) {
      ModelSession tmp = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");
      for (var sess in GlobalData.training) {
        if (sess.id == id) {
          tmp = sess;
        }
      }
      setState(() {
        id = id;
        item = tmp;
      });
    }
  }


  updateBlock() {
    if(!this.mounted) return;
    if (item.program == null || item.program.blocks == null || item.program.blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No program blocks to update."),
        backgroundColor: AppColors.PrimaryColor,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if(item.program.blocks[current].logResults) {
        var tmp = current;
        Future.delayed(const Duration(milliseconds: 700), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditResultsPage(id, item, item.program.blocks[tmp])));
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if(current < item.program.blocks.length-1) {
            setState(() {
              current = tmp+1;
            });
          } else {
            setState(() {
              finished = true;
            });
          }

        });
      } else {
        if(current < item.program.blocks.length-1) {
          setState(() {
            current = current+1;
          });
        } else {
          setState(() {
            finished = true;
          });
        }
      }
    }


  abortSession() {
    if(setup || finished) {
      Navigator.pop(context);
    } else {
      AlertDialog alert = AlertDialog(
      title: Text("End session?"),
        content: Text("Do you want to end this session now without completing it? Remember that you can always log your results later."),
        actions: [
          TextButton(
            child: Text("End session now"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Cancel"),
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


  startBlock() {
    if (item.program == null || item.program.blocks == null || item.program.blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No program blocks to start."),
        backgroundColor: AppColors.PrimaryColor,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    var block = item.program.blocks[current];
    var ints = [];
    var rounds = 0;
    var type = "";

    if(setup) {
      setState(() {
        setup = false;
      });
      FirebaseSender.createSession(item);
      FirebaseSender.sendPushMessage(GlobalData.space.token, "New training session", GlobalUser.name+" just started a Training Session.", "client", GlobalData.space.client, []);
    }

    if(block.type == 0) { // AMRAP
      rounds = block.rounds;
      type = "amrap";
    } else if(block.type == 1) { // EMOM
      rounds = block.rounds;
      type = "emom";
      if(block.emom) {
        ints = [block.movements[0].work];
      } else {
        for(var ex in block.movements) {
          ints.add(ex.work);
        }
      }
    } else if(block.type == 2) { // Intervals
      rounds = block.rounds;
      type = "intervals";
      if(block.emom) {
        ints = [block.movements[0].work, block.movements[0].rest];
      } else {
        for(var ex in block.movements) {
          ints.add(ex.work);
          ints.add(ex.rest);
        }
      }
    } else if(block.type == 3) { // Tabata
      ints = [20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10];
      rounds = block.rounds;
      type = "tabata";
    } else if(block.type == 4) {
      rounds = block.rounds; // No time
      type = "notime";
    } else if(block.type == 5) { // For time
      rounds = block.rounds;
      type = "fortime";
    }

    if(block.type != 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimerPage("", type, rounds, ints, block)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SetsPage("", rounds, block)));
    }
  }


  @override
  Widget build(BuildContext context) {
    if(!finished) {
      return _getDefault();
    } else {
      return _getFinished();
    }
  }


  _getFinished() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        child: InkWell (
          onTap: () {
            abortSession();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container (
                  padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
                  child: SvgPicture.asset("assets/images/list/terms-on.svg", width: 150, height: 150)
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Session finished\nTap to go back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              )
            ],
          )
        )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getDefault() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.bgColor,
        body: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Column(
            children: <Widget>[
              Row (
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
                    child: Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: double.maxFinite,
                      child: Row(
                        children: <Widget> [
                          IconButton(
                            icon: SvgPicture.asset("assets/images/nav/header-back.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
                            iconSize: 30,
                            onPressed: () {
                              abortSession();
                            },
                          ),
                          Text(
                            "Training",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 40,
                            ),
                          ),
                        ]
                      ),
                    )
                  ),
                ]
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
                child: Text(
                  item.program.name,
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
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _getContent()))),
            ],
          ),
        ),
      )
    );
  }


  _getContent() {
    if (item.program == null || item.program.blocks == null || item.program.blocks.isEmpty) {
      return <Widget>[];
    }
    List<Widget> items = [];
    for(var i=0; i<item.program.blocks.length; i++) {
      var block = item.program.blocks[i];
      if(i < current) {
        items.add(
          TitleDoubleLabel(GlobalUI.titles[block.type] + HelperTrain.getBlockInfo(block), GlobalUI.cats[block.cat], "DONE", item.id, block.id)
        );
        items.add(
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditResultsPage(id, item, item.program.blocks[i])));
            },
            child: CardText(_getContentText(block), (block.simple ? "View details" : "Tap to edit results"), "")
          )
        );
      } else if(i == current) {
        items.add(
          TitleDoubleLabel(GlobalUI.titles[block.type] + HelperTrain.getBlockInfo(block), GlobalUI.cats[block.cat], "UP NEXT", item.id, block.id)
        );
        if(!block.simple) {
          for (var ex in block.movements) {
            items.add(
              InkWell (
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExImagePage(ex)),);
                },
                child: CardText(HelperTrain.getMovementName(ex, block), HelperTrain.getMovementInfo(ex, block), ex.notes)
              )
            );
          }
        }
        if (block.notes != "") {
          items.add(Container(
              width: MediaQuery.of(context).size.width - 70,
              padding: EdgeInsets.only(top: 7),
              child: Text(
                block.notes,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: (block.simple ? 15 : 11),
                ),
              )));
        }
        items.add(
          Container (
            padding: EdgeInsets.only(top: 20),
            child: BtnPrimarySmall(label: "START THIS BLOCK", clickFn: startBlock,)
          )
        );
      } else {
        items.add(
          Opacity(
            opacity: 0.4,
            child: TitleDoubleLabel(GlobalUI.titles[block.type] + HelperTrain.getBlockInfo(block), GlobalUI.cats[block.cat], "PENDING", item.id, block.id)
          )
        );
      }
    }

    return items;
  }


  _getContentText(block) {
    var label = block.movements.length.toString()+(block.movements.length == 1 ? "movement" : " movements");
    if(block.simple) {
      label = "Block completed";
    }
    return label;
  }
}
