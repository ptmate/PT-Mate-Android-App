import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/components/tab.dart';
import 'package:ptmate_client/components/trainingspace.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/calculator.dart';
import 'package:ptmate_client/training/benchmark.dart';
import 'package:ptmate_client/training/plan.dart';
import 'package:ptmate_client/training/program.dart';

class TrainingPage extends StatefulWidget {
  static _TrainingPageState appState = _TrainingPageState();
  @override
  _TrainingPageState createState() {
    return TrainingPage.appState = new _TrainingPageState();
  }
}

class _TrainingPageState extends State<TrainingPage> {
  String current = "sessions";
  List<ModelSession> sessions = [];
  List<ModelProgram> programs = [];
  List<ModelPlan> plans = [];
  List<ModelBest> best = [];
  List<ModelProgram> benchmark = [];
  String dark = "";

  getTrainer(id) {
    var label = "your trainer";
    for (var item in GlobalData.spaces) {
      if (item.id == id) {
        label = item.name;
      }
    }
    return label;
  }

  @override
  void initState() {
    super.initState();
    List<ModelSession> tsessions = [];
    List<ModelProgram> bench = [];
    List ids = [];
    var add = false;
    for (var item in GlobalData.sessions) {
      if (!tsessions.contains(item) && item.attendance == 3) {
        if (item.type == "pt") {
          tsessions.add(item);
          if (item.program.benchmark && !ids.contains(item.program.id)) {
            bench.add(item.program);
            ids.add(item.program.id);
          }
        } else if (item.clients.contains(GlobalData.space.client)) {
          add = true;
        }
        for (var cl in GlobalData.space.linked) {
          if (item.clients.contains(cl.id)) {
            add = true;
          }
        }
        if (add) {
          tsessions.add(item);
          if (item.program.benchmark && !ids.contains(item.program.id)) {
            bench.add(item.program);
            ids.add(item.program.id);
          }
        }
      }
    }

    for (var item2 in GlobalData.training) {
      if (!tsessions.contains(item2) && item2.attendance == 3) {
        tsessions.add(item2);
        if (item2.program.benchmark && !ids.contains(item2.program.id)) {
          bench.add(item2.program);
          ids.add(item2.program.id);
        }
      }
    }

    if (!GlobalData.space.active) {
      tsessions = [];
    }
    if (GlobalUI.dark) {
      setState(() {
        dark = "-dark";
      });
    }

    setState(() {
      sessions = tsessions;
      programs = GlobalData.programs;
      plans = GlobalData.plans;
      best = GlobalData.best;
      benchmark = bench;
    });
    sessions.sort((a, b) => b.date.compareTo(a.date));
    programs.sort((a, b) => a.name.compareTo(b.name));
    plans.sort((a, b) => a.name.compareTo(b.name));
    best.sort((a, b) => a.name.compareTo(b.name));
    benchmark.sort((a, b) => a.name.compareTo(b.name));
  }

  updateData() {
    if (this.mounted) {
      List<ModelSession> tsessions = [];
      for (var item in GlobalData.sessions) {
        if (!tsessions.contains(item) && item.attendance == 3) {
          if (item.type == "pt") {
            tsessions.add(item);
          } else if (item.clients.contains(GlobalData.space.client)) {
            tsessions.add(item);
          }
        }
      }
      if (!GlobalData.space.active) {
        tsessions = [];
      }
      for (var item2 in GlobalData.training) {
        if (!tsessions.contains(item2) && item2.attendance == 3) {
          tsessions.add(item2);
        }
      }
      setState(() {
        sessions = tsessions;
        programs = GlobalData.programs;
        plans = GlobalData.plans;
        best = GlobalData.best;
      });
      sessions.sort((a, b) => b.date.compareTo(a.date));
      programs.sort((a, b) => a.name.compareTo(b.name));
      plans.sort((a, b) => a.name.compareTo(b.name));
      best.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  switchTab(val) {
    setState(() {
      current = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            alignment: Alignment.topLeft,
            child: Column(children: [
              Container(
                  height: 160,
                  padding: EdgeInsets.only(top: 35),
                  alignment: Alignment.topLeft,
                  color: AppColors.bgColor,
                  child: Column(
                    children: [
                      TrainingSpace(),
                      Container(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                          child: Row(
                            children: [
                              TabLabel(
                                  label: "Sessions",
                                  active: current == "sessions" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "sessions"),
                              TabLabel(
                                  label: "Programs",
                                  active: current == "programs" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "programs"),
                              TabLabel(
                                  label: "Plans",
                                  active: current == "plans" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "plans"),
                              TabLabel(
                                  label: "Best",
                                  active: current == "best" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "best"),
                            ],
                          )),
                    ],
                  )),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _createContent(),
                      )))
            ])),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _createContent() {
    List<Widget> items = [];
    if (current == "sessions") {
      items = _getSessions();
    } else if (current == "programs") {
      items = _getPrograms();
    } else if (current == "plans") {
      items = _getPlans();
    } else if (current == "best") {
      items = [];
      for (var bn in benchmark) {
        items.add(_getBenchmark(bn));
      }
      items += _getBest();
    }
    return items;
  }

  _getSessionLocation(item) {
    var label = HelperCal.getSpecialDate(item.date) +
        " h\n" +
        HelperCal.getDuration(item.duration, "hours");
    if (item.locationName != "") {
      label = HelperCal.getSpecialDate(item.date) +
          " h - " +
          HelperCal.getDuration(item.duration, "hours") +
          "\n" +
          item.locationName;
    }

    return label;
  }

  _getSessions() {
    List<Widget> items = [];
    if (sessions.length > 0) {
      for (var i = 0; i < sessions.length; i++) {
        var item = sessions[i];
        items.add(InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultsPage(item.id, item)),
              );
            },
            child: ListDefault(
                item.name,
                _getSessionLocation(item),
                "View results",
                HelperCal.getTypeColor(item.type, item.availability),
                HelperCal.getTypeImage(item.type, item.availability),
                false)));
      }
    } else {
      items.add(EmptyMessage("empty-session", "No past sessions",
          "Please note that sessions\nare deleted after 60 days"));
    }
    return items;
  }

  _getPrograms() {
    List<Widget> items = [];
    if (programs.length > 0) {
      for (var i = 0; i < programs.length; i++) {
        var item = programs[i];
        var plural = (item.blocks.length == 1 ? "" : "s");
        items.add(InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProgramPage(item.id, item, "", true)),
              );
            },
            child: ListDefault(
                item.name,
                item.blocks.length.toString() +
                    " block" +
                    plural +
                    "\n" +
                    item.movements.toString() +
                    " movements",
                "sent by " + getTrainer(item.creator),
                HelperTrain.getColor(item.time),
                item.time.toString() + "'",
                true)));
      }
    } else {
      items.add(EmptyMessage("empty-programs", "No programs yet",
          "Ask your trainer to\nsend you a program."));
    }
    return items;
  }

  _getPlans() {
    List<Widget> items = [];
    if (plans.length > 0) {
      for (var plan in plans) {
        var plural = (plan.weeks.length == 1 ? "" : "s");
        var status = "-";
        var small = "Currently not doing it";
        var color = "-grey" + dark;
        var end = plan.date.add(Duration(days: plan.weeks.length * 7 + 15));
        if (end.isAfter(DateTime.now())) {
          color = GlobalUI.gradients[0];
          status = HelperTrain.getPlanCompletion(plan).toString() + "%";
          small =
              HelperTrain.getPlanCompletion(plan).toString() + "% completed";
          if (HelperTrain.getPlanCompletion(plan) == 100) {
            color = "-vividgreen";
          }
        }
        items.add(InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlanPage(plan.id, plan)),
              );
            },
            child: ListDefault(
                plan.name,
                plan.weeks.length.toString() + " week" + plural + "\n" + small,
                "sent by " + getTrainer(plan.creator),
                color,
                status,
                true)));
      }
    } else {
      items.add(EmptyMessage("empty-plans", "No plans yet",
          "Ask your trainer to\nsend you a training plan."));
    }
    return items;
  }

  _getBest() {
    DateFormat df = DateFormat("d MMM yyyy");
    List<Widget> items = [];
    if (best.length > 0) {
      for (var i = 0; i < best.length; i++) {
        items.add(InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CalculatorPage(
                          best[i].value,
                        )),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    best[i].name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                    child: Text(
                      getBestInfo(best[i]),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 14,
                      ),
                    )),
              ],
            )
            //)
            ));
      }
    } else {
      if (benchmark.length == 0) {
        items.add(EmptyMessage("empty-best", "No 1 rep best yet",
            "You don't have any 1 rep best recorded in your sessions yet."));
      }
    }
    return items;
  }

  _getBenchmark(item) {
    if (benchmark.length > 0) {
      var plural = (item.blocks.length == 1 ? "" : "s");
      return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BenchmarkPage(item.id, item)),
            );
          },
          child: ListDefault(
              item.name,
              item.blocks.length.toString() +
                  " block" +
                  plural +
                  "\n" +
                  item.movements.toString() +
                  " movements",
              "Tap to view results",
              HelperTrain.getColor(item.time),
              item.time.toString() + "'",
              true));
    }
  }

  getBestInfo(best) {
    DateFormat df = DateFormat("d MMM yyyy");
    var label = best.value.toString() + " kg\n" + df.format(best.date);
    if (best.actual > 0 && best.percent > 0 && best.percent != 100) {
      label = best.actual.toString() +
          " kg at " +
          best.percent.toString() +
          "% (1RM: " +
          best.value.toString() +
          " kg)\n" +
          df.format(best.date);
    }
    if (GlobalUser.lbs) {
      label = (best.value * GlobalUI.lbsUp).toStringAsFixed(1) +
          " lbs\n" +
          df.format(best.date);
      if (best.actual > 0 && best.percent > 0 && best.percent != 100) {
        label = (best.actual * GlobalUI.lbsUp).toStringAsFixed(1) +
            " lbs at " +
            best.percent.toString() +
            "% (1RM: " +
            (best.value * GlobalUI.lbsUp).toStringAsFixed(1) +
            " lbs)\n" +
            df.format(best.date);
      }
    }
    return label;
  }

  getPlanStatus() {}
}
