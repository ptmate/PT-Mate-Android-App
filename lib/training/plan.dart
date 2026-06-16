import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-secondary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/card-double.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/training/program.dart';

class PlanPage extends StatefulWidget {
  final String id;
  final ModelPlan item;
  const PlanPage(this.id, this.item);
  static _PlanPageState appState = _PlanPageState();
  @override
  _PlanPageState createState() {
    return PlanPage.appState = new _PlanPageState();
  }
}

class _PlanPageState extends State<PlanPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelPlan item = ModelPlan("", "", "", DateTime.now(), "", 0, "", [], [], []);
  String dark = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
    if (GlobalUI.dark) {
      setState(() {
        dark = "-dark";
      });
    }
  }

  updateData() {
    if (this.mounted) {
      ModelPlan tmp =
          ModelPlan("", "", "", DateTime.now(), "", 0, "", [], [], []);
      for (var plan in GlobalData.plans) {
        if (plan.id == id) {
          tmp = plan;
        }
      }
      setState(() {
        item = tmp;
      });
    }
  }

  void tapDeletePlan() {
    Connector.getPlansSpace();
    AlertDialog alert = AlertDialog(
      title: Text("Delete training plan?"),
      content: Text(
          "Are you sure you want to delete this training plan? Your current progress won't be affected."),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deletePlan();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
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

  deletePlan() {
    for (var plan in GlobalData.plansSpace) {
      if (plan.id == id) {
        var sent = [];
        for (var sn in plan.sent) {
          if (sn != GlobalData.space.client) {
            sent.add(sn);
          }
        }
        FirebaseSender.updatePlanClients(plan.id, sent);
      }
    }
    FirebaseSender.deletePlan(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Training Plan successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }

  gotoSession(id) {
    ModelSession? sess;
    for (var tr in GlobalData.training) {
      if (tr.program.id == id) {
        sess = tr;
      }
    }
    if (sess != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultsPage(sess!.id, sess!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Training session not found"),
        backgroundColor: AppColors.PrimaryColor,
        duration: Duration(seconds: 2),
      ));
    }
  }

  startPlan() {
    AlertDialog alert = AlertDialog(
      title: Text("Start training plan?"),
      content: Text(
          "Do you want to start this training plan now? Note that you will have to do the programs in order, and you can't skip any.Your overall progress will be displayed on top of this page."),
      actions: [
        TextButton(
          child: Text("Start plan now"),
          onPressed: () {
            initializePlan();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
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

  restartPlan() {
    AlertDialog alert = AlertDialog(
      title: Text("Restart training plan?"),
      content: Text(
          "Do you want to restart this training plan now? Note that all your previous progress has been saved."),
      actions: [
        TextButton(
          child: Text("Restart plan now"),
          onPressed: () {
            initializePlan();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
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

  initializePlan() {
    FirebaseSender.startPlan(id);
    FirebaseSender.sendPushMessage(
        GlobalData.space.token,
        "Training Plan started",
        GlobalUser.name + " just started the training plan " + item.name + ".",
        "plan",
        item.id, []);
    // Push notifications

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Training Plan started"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));
  }

  getProgram(id) {
    var pro = null;
    for (var prog in item.programs) {
      if (prog.id == id) {
        pro = prog;
      }
    }
    return pro;
  }

  String getProgramInfo(pid) {
    var label = "";
    for (var prog in item.programs) {
      if (prog.id == pid) {
        label = prog.name + "\n" + HelperCal.getDuration(prog.time, "hour");
      }
    }
    return label;
  }

  String getProgramTime(id) {
    var label = "";
    for (var prog in item.programs) {
      if (prog.id == id) {
        label = prog.time.toString();
      }
    }
    return label;
  }

  String getProgramColor(id) {
    var color = GlobalUI.gradients[0];
    for (var prog in item.programs) {
      if (prog.id == id) {
        color = HelperTrain.getColor(prog.time);
      }
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TitleLabelBack("Training Plan"),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _getContent())))
            ],
          ),
        ),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getContent() {
    var end = item.date.add(Duration(days: item.weeks.length * 7 + 15));
    if (end.isAfter(DateTime.now())) {
      return _getActive();
    } else {
      return _getInactive();
    }
  }

  _getActive() {
    var color = GlobalUI.gradients[0];
    if (HelperTrain.getPlanCompletion(item) == 100) {
      color = "-vividgreen";
    }
    List<Widget> items = [];
    items.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
        padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage("assets/images/common/gradient" + color + ".png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Text(
          HelperTrain.getPlanCompletion(item).toString() + "%",
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
    items.add(Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Text(
        item.desc,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 16,
        ),
      ),
    ));

    var current = "done";
    for (var week in item.weeks) {
      var days = [
        week.day1,
        week.day2,
        week.day3,
        week.day4,
        week.day5,
        week.day6,
        week.day7
      ];
      items.add(SubtitleLabel(week.name));
      for (var i = 0; i < 7; i++) {
        var arr = days[i].split(",");
        arr.removeAt(0);
        for (var prog in arr) {
          var status = HelperTrain.getPlanStatus(item.date, prog);
          if (status == "done") {
            items.add(InkWell(
                onTap: () {
                  gotoSession(prog);
                },
                child: CardDouble(
                    "Day " + (i + 1).toString(),
                    getProgramInfo(prog),
                    "-vividgreen",
                    "plan-done.svg",
                    false)));
          } else {
            if (current == "done") {
              items.add(InkWell(
                  onTap: () {
                    var progItem = getProgram(prog);
                    if (progItem != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProgramPage(
                                prog, progItem, item.id, true)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Program not found"),
                        backgroundColor: AppColors.PrimaryColor,
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  child: CardDouble(
                      "Day " + (i + 1).toString(),
                      getProgramInfo(prog),
                      "-vividgreen",
                      "plan-now.svg",
                      false)));
            } else {
              items.add(InkWell(
                  onTap: () {
                    var progItem = getProgram(prog);
                    if (progItem != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProgramPage(
                                prog, progItem, item.id, false)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Program not found"),
                        backgroundColor: AppColors.PrimaryColor,
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  child: CardDouble(
                      "Day " + (i + 1).toString(),
                      getProgramInfo(prog),
                      "-grey" + dark,
                      "session-training.svg",
                      false)));
            }
            current = status;
          }
        }
        if (days[i] == '') {
          items.add(Opacity(
              child: CardDouble("Day " + (i + 1).toString(), "Rest day",
                  "-grey" + dark, "-", true),
              opacity: 0.4));
        }
      }
    }

    items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
        child: BtnSecondary(label: "RESTART THIS PLAN", clickFn: restartPlan)));
    items.add(BtnTertiary(
        label: "DELETE THIS TRAINING PLAN", clickFn: tapDeletePlan));

    return items;
  }

  _getInactive() {
    List<Widget> items = [];
    items.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
        padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(
                "assets/images/common/gradient-grey" + dark + ".png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Text(
          "-",
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
    items.add(Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Text(
        item.desc +
            "\n\nYou can start the plan by tapping the button. Note that you'll have to complete the training plan in order.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 16,
        ),
      ),
    ));
    items.add(Container(height: 20));
    items.add(BtnTertiary(label: "Start this plan", clickFn: startPlan));
    for (var week in item.weeks) {
      var days = [
        week.day1,
        week.day2,
        week.day3,
        week.day4,
        week.day5,
        week.day6,
        week.day7
      ];
      items.add(SubtitleLabel(week.name));
      for (var i = 0; i < 7; i++) {
        var arr = days[i].split(",");
        arr.removeAt(0);
        for (var prog in arr) {
          items.add(InkWell(
              onTap: () {
                var progItem = getProgram(prog);
                if (progItem != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProgramPage(prog, progItem, item.id, false)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Program not found"),
                    backgroundColor: AppColors.PrimaryColor,
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: CardDouble(
                  "Day " + (i + 1).toString(),
                  getProgramInfo(prog),
                  getProgramColor(prog),
                  getProgramTime(prog) + "'",
                  true)));
        }
        if (days[i] == '') {
          items.add(Opacity(
              child: CardDouble("Day " + (i + 1).toString(), "Rest day",
                  "-grey" + dark, "-", true),
              opacity: 0.4));
        }
      }
    }

    items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
        child:
            BtnPrimary(label: "START THIS TRAINING PLAN", clickFn: startPlan)));
    items.add(BtnTertiary(
        label: "DELETE THIS TRAINING PLAN", clickFn: tapDeletePlan));

    return items;
  }
}
