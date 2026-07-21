import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/subtitle.dart';

class LeaderboardPage extends StatefulWidget {
  final String id;
  final String block;
  final String type;
  const LeaderboardPage(this.id, this.block, this.type);
  static _LeaderboardPageState appState = _LeaderboardPageState();
  @override
  _LeaderboardPageState createState() {
    return LeaderboardPage.appState = new _LeaderboardPageState();
  }
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String title = "Leaderboard";
  String subtitle = "Block";
  ModelSession item = ModelSession(
      "",
      DateTime.now(),
      "",
      0,
      [],
      [],
      [],
      "",
      "",
      "",
      0,
      0,
      DateTime.now(),
      false,
      [],
      [],
      ModelProgram("", "", "", 0, 0, "", [], false, ""),
      [],
      false,
      DateTime.now(),
      "",
      "",
      [],
      [],
      "",
      "",
      [],
      [],
      "");
  ModelBlock block = ModelBlock("", 0, "", 0, 0, false, "", "", [], false, 0, 0,
      [], false, "", [], [], [], "");
  List list = [];
  List hlist = [];

  @override
  void initState() {
    super.initState();
    var st = "Leaderboard";
    if (widget.type != "results" ||
        !GlobalData.space.comments ||
        !GlobalData.space.showHabits) {
      st = "History";
    }
    setState(() {
      id = widget.id;
      title = st;
    });
    configureData();
  }

  configureData() {
    var tmpitem = ModelSession(
        "",
        DateTime.now(),
        "",
        0,
        [],
        [],
        [],
        "",
        "",
        "",
        0,
        0,
        DateTime.now(),
        false,
        [],
        [],
        ModelProgram("", "", "", 0, 0, "", [], false, ""),
        [],
        false,
        DateTime.now(),
        "",
        "",
        [],
        [],
        "",
        "",
        [],
        [],
        "");
    var tmpblock = ModelBlock("", 0, "", 0, 0, false, "", "", [], false, 0, 0,
        [], false, "", [], [], [], "");
    for (var sess in GlobalData.sessions) {
      if (sess.id == id) {
        tmpitem = sess;
        for (var bl in sess.program.blocks) {
          if (bl.id == widget.block) {
            tmpblock = bl;
            subtitle = GlobalUI.titles[tmpblock.type] +
                HelperTrain.getBlockInfo(tmpblock);
          }
        }
      }
    }
    for (var sess1 in GlobalData.training) {
      if (sess1.id == id) {
        tmpitem = sess1;
        for (var bl1 in sess1.program.blocks) {
          if (bl1.id == widget.block) {
            tmpblock = bl1;
            subtitle = GlobalUI.titles[tmpblock.type] +
                HelperTrain.getBlockInfo(tmpblock);
          }
        }
      }
    }
    for (var sess2 in GlobalData.archive) {
      if (sess2.id == id) {
        tmpitem = sess2;
        for (var bl2 in sess2.program.blocks) {
          if (bl2.id == widget.block) {
            tmpblock = bl2;
            subtitle = GlobalUI.titles[tmpblock.type] +
                HelperTrain.getBlockInfo(tmpblock);
          }
        }
      }
    }
    if (id == "") {
      for (var prog in GlobalData.programs) {
        for (var bl3 in prog.blocks) {
          if (bl3.id == widget.block) {
            tmpblock = bl3;
            subtitle = GlobalUI.titles[tmpblock.type] +
                HelperTrain.getBlockInfo(tmpblock);
          }
        }
      }
    }
    setState(() {
      id = widget.id;
      item = tmpitem;
      block = tmpblock;
    });
    if (widget.type == "results" &&
        GlobalData.space.showHabits &&
        GlobalData.space.comments) {
      configureBoard();
    }
    configureHistory();
  }

  configureBoard() {
    List tlist = [];
    if (item.id != "") {
      if (item.type == "group") {
        var num = 0;
        for (var cl in item.clients) {
          tlist.add(ModelLeaderboard(
              cl,
              getResult(cl, item.id, num)[0],
              getResult(cl, item.id, num)[1],
              getResult(cl, item.id, num)[2],
              getResult(cl, item.id, num)[3],
              num,
              item.id,
              getHighfives(cl, item.highfives),
              item.date,
              item.type));
          num++;
        }
      } else {
        tlist.add(ModelLeaderboard(
            GlobalData.space.client,
            getResult(GlobalData.space.client, item.id, 0)[0],
            getResult(GlobalData.space.client, item.id, 0)[1],
            getResult(GlobalData.space.client, item.id, 0)[2],
            getResult(GlobalData.space.client, item.id, 0)[3],
            0,
            item.id,
            getHighfives(GlobalData.space.client, item.highfives),
            item.date,
            item.type));
      }
      for (var sess in GlobalData.sessions) {
        if (sess.id != item.id &&
            GlobalUI.date.format(sess.date) ==
                GlobalUI.date.format(item.date)) {
          for (var bl in sess.program.blocks) {
            if (bl.id == block.id) {
              if (sess.type == "group") {
                var num1 = 0;
                for (var cl1 in sess.clients) {
                  tlist.add(ModelLeaderboard(
                      cl1,
                      getResult(cl1, sess.id, num1)[0],
                      getResult(cl1, sess.id, num1)[1],
                      getResult(cl1, sess.id, num1)[2],
                      getResult(cl1, sess.id, num1)[3],
                      num1,
                      sess.id,
                      getHighfives(cl1, sess.highfives),
                      sess.date,
                      sess.type));
                  num1++;
                }
              } else {
                tlist.add(ModelLeaderboard(
                    GlobalData.space.client,
                    getResult(GlobalData.space.client, sess.id, 0)[0],
                    getResult(GlobalData.space.client, sess.id, 0)[1],
                    getResult(GlobalData.space.client, sess.id, 0)[2],
                    getResult(GlobalData.space.client, sess.id, 0)[3],
                    0,
                    sess.id,
                    getHighfives(GlobalData.space.client, sess.highfives),
                    sess.date,
                    sess.type));
              }
            }
          }
        }
      }
    }
    tlist.sort((a, b) => b.total.compareTo(a.total));
    setState(() {
      list = tlist;
    });
  }

  configureHistory() {
    var tlist = [];
    for (var sess in GlobalData.sessions) {
      for (var bl in sess.program.blocks) {
        if (bl.id == block.id && sess.clients.length > 0) {
          if (sess.type == "group") {
            var num1 = 99999;
            for (var i = 0; i < sess.clients.length; i++) {
              if (sess.clients[i] == GlobalData.space.client) {
                num1 = i;
              }
            }
            if (num1 != 99999) {
              var tot1 = getResult(sess.clients[num1], sess.id, num1)[3];
              if (tot1 > 0) {
                tlist.add(ModelLeaderboard(
                    sess.clients[num1],
                    getResult(sess.clients[num1], sess.id, num1)[0],
                    getResult(sess.clients[num1], sess.id, num1)[1],
                    getResult(sess.clients[num1], sess.id, num1)[2],
                    tot1,
                    num1,
                    sess.id,
                    getHighfives(sess.clients[num1], sess.highfives),
                    sess.date,
                    sess.type));
              }
            }
          } else {
            var tot2 = getResult(GlobalData.space.client, sess.id, 0)[3];
            if (tot2 > 0) {
              tlist.add(ModelLeaderboard(
                  GlobalData.space.client,
                  getResult(GlobalData.space.client, item.id, 0)[0],
                  getResult(GlobalData.space.client, item.id, 0)[1],
                  getResult(GlobalData.space.client, item.id, 0)[2],
                  getResult(GlobalData.space.client, item.id, 0)[3],
                  0,
                  item.id,
                  getHighfives(GlobalData.space.client, item.highfives),
                  item.date,
                  item.type));
            }
          }
        }
      }
    }
    for (var sess in GlobalData.archive) {
      for (var bl in sess.program.blocks) {
        if (bl.id == block.id && sess.clients.length > 0) {
          if (sess.type == "group") {
            var num1 = 99999;
            for (var i = 0; i < sess.clients.length; i++) {
              if (sess.clients[i] == GlobalData.space.client) {
                num1 = i;
              }
            }
            if (num1 != 99999) {
              var tot1 = getResult(sess.clients[num1], sess.id, num1)[3];
              if (tot1 > 0) {
                tlist.add(ModelLeaderboard(
                    sess.clients[num1],
                    getResult(sess.clients[num1], sess.id, num1)[0],
                    getResult(sess.clients[num1], sess.id, num1)[1],
                    getResult(sess.clients[num1], sess.id, num1)[2],
                    tot1,
                    num1,
                    sess.id,
                    getHighfives(sess.clients[num1], sess.highfives),
                    sess.date,
                    sess.type));
              }
            }
          } else {
            var tot2 = getResult(GlobalData.space.client, sess.id, 0)[3];
            if (tot2 > 0) {
              tlist.add(ModelLeaderboard(
                  GlobalData.space.client,
                  getResult(GlobalData.space.client, item.id, 0)[0],
                  getResult(GlobalData.space.client, item.id, 0)[1],
                  getResult(GlobalData.space.client, item.id, 0)[2],
                  getResult(GlobalData.space.client, item.id, 0)[3],
                  0,
                  item.id,
                  getHighfives(GlobalData.space.client, item.highfives),
                  item.date,
                  item.type));
            }
          }
        }
      }
    }
    for (var sess in GlobalData.training) {
      for (var bl in sess.program.blocks) {
        if (bl.id == block.id && sess.clients.length > 0) {
          var tot2 = getResult(GlobalData.space.client, sess.id, 0)[3];
          if (tot2 > 0) {
            tlist.add(ModelLeaderboard(
                GlobalData.space.client,
                getResult(GlobalData.space.client, item.id, 0)[0],
                getResult(GlobalData.space.client, item.id, 0)[1],
                getResult(GlobalData.space.client, item.id, 0)[2],
                getResult(GlobalData.space.client, item.id, 0)[3],
                0,
                item.id,
                getHighfives(GlobalData.space.client, item.highfives),
                item.date,
                item.type));
          }
        }
      }
    }
    tlist.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      hlist = tlist;
    });
  }

  getResult(cid, sess, pos) {
    var val1 = 0;
    var val2 = "";
    var val3 = 0;
    double total = 0;
    if (block.type == 0) {
      val1 = getAmrap(cid, sess, pos)[0];
      val2 = getAmrap(cid, sess, pos)[1];
      total = getAmrap(cid, sess, pos)[2];
    } else if (block.type == 5) {
      val1 = getForTime(cid, sess, pos)[0];
      val2 = getForTime(cid, sess, pos)[1];
      val3 = getForTime(cid, sess, pos)[2];
      total = getForTime(cid, sess, pos)[3];
    } else {
      val1 = getScore(cid, sess, pos)[0];
      val2 = getScore(cid, sess, pos)[1];
      total = getScore(cid, sess, pos)[2];
    }
    return [val1, val2, val3, total];
  }

  // Score

  getScore(cid, sess, pos) {
    var tblock = block;
    var value = 0;
    double weight = 0;
    double weightsum = 0;
    var lweight = "";
    double total = 0;
    var type = "group";

    if (sess != widget.id || widget.id == "") {
      for (var sitem in GlobalData.sessions) {
        if (sitem.id == sess) {
          for (var bl in sitem.program.blocks) {
            if (bl.id == block.id) {
              tblock = bl;
              type = sitem.type;
            }
          }
        }
      }
    }

    if (!tblock.simple) {
      for (var mitem in tblock.movements) {
        // Classes
        if (type == "group") {
          var ar = mitem.resRepsGroup.split("-");
          var ar2 = mitem.resWeightGroup.split("-");
          if (ar.length > pos) {
            if (ar[pos] != "") {
              value += int.parse(ar[pos]);
            }
          }
          if (ar2.length > pos) {
            if (ar2[pos] == "" || ar2[pos] == "0" || ar2[pos] == "0.0") {
              weight += 1;
            } else {
              weight += double.parse(ar2[pos]);
              weightsum += double.parse(ar2[pos]);
            }
          }
          // 1:1 & Training
        } else {
          value += mitem.resReps;
          if (mitem.resWeight > 0) {
            weight += mitem.resWeight;
            weightsum += mitem.resWeight;
          } else {
            weight += 1;
          }
        }
      }
      if (weightsum > 0) {
        lweight = " - " +
            weightsum.toStringAsFixed(2) +
            (GlobalUser.lbs ? "lb" : "kg");
      }
      total = weight * (value).toDouble();
    } else {
      weight = 0;
      lweight = "-";
      total = 0;
      if (tblock.valueSimple.length > pos) {
        weight = 2;
        value = (tblock.valueSimple[pos]).toInt();
        if (tblock.valueSimple[pos] != 0) {
          lweight = (block.valueSimple[pos]).toString();
          if (tblock.unitSimple != "weight") {
            lweight = (block.valueSimple[pos].toInt()).toString();
          }
          if (tblock.unitSimple == "reps") {
            lweight += " reps";
          }
          if (tblock.unitSimple == "weight") {
            lweight += GlobalData.space.lbs ? " lb" : " kg";
          }
          if (tblock.unitSimple == "distance") {
            lweight += " m";
          }
          if (tblock.scaledSimple.length > pos) {
            if (tblock.scaledSimple[pos]) {
              lweight += " (Scaled)";
              weight = 1;
            }
          }
          total = weight * (value).toDouble();
        }
      }
    }
    return [value, lweight, total];
  }

  // Get high fives

  getHighfives(client, highfives) {
    var num = 0;
    for (var hitem in highfives) {
      var ar = hitem.split("||");
      if (ar[0] == client) {
        num += 1;
      }
    }
    return num;
  }

  // AMRAP

  getAmrap(cid, sess, pos) {
    var tblock = block;
    var value = 0;
    double weight = 0;
    double weightsum = 0;
    var lweight = "";
    double total = 0;
    var type = "group";
    // other session here
    if (sess != widget.id || widget.id == "") {
      for (var sitem in GlobalData.sessions) {
        if (sitem.id == sess) {
          for (var bl in sitem.program.blocks) {
            if (bl.id == block.id) {
              tblock = bl;
              type = sitem.type;
            }
          }
        }
      }
    }
    if (!block.simple) {
      for (var mitem in tblock.movements) {
        // Classes
        if (type == "group") {
          var ar = mitem.resRepsGroup.split("-");
          var ar2 = mitem.resWeightGroup.split("-");
          if (ar.length > pos) {
            if (ar[pos] != "") {
              value += int.parse(ar[pos]);
            }
          }
          if (ar2.length > pos) {
            if (ar2[pos] == "" || ar2[pos] == "0" || ar2[pos] == "0.0") {
              weight += 1;
            } else {
              weight += double.parse(ar2[pos]);
              weightsum += double.parse(ar2[pos]);
            }
          }
          // 1:1 & Training
        } else {
          value += mitem.resReps;
          if (mitem.resWeight > 0) {
            weight += mitem.resWeight;
            weightsum += mitem.resWeight;
          } else {
            weight += 1;
          }
        }
      }
      if (weightsum > 0) {
        lweight = " - " +
            weightsum.toStringAsFixed(2) +
            (GlobalUser.lbs ? "lb" : "kg");
      }
      total = weight * (value).toDouble();
    } else {
      lweight = "-";
      weight = 2;
      if (tblock.amrapSimple.length > pos) {
        lweight = tblock.amrapSimple[pos] + " rounds";
        if (tblock.scaledSimple.length > pos) {
          if (tblock.scaledSimple[pos]) {
            lweight += " (Scaled)";
            weight = 1;
          }
        }
        var ar = tblock!.amrapSimple[pos].split("+");
        if (ar.length > 1) {
          total = double.parse(ar[0]) * 1000 + double.parse(ar[1]) * weight;
        }
        if (tblock.amrapSimple[pos] == "0+0") {
          lweight = "-";
        }
      }
    }
    if (lweight == "0 rounds") {
      lweight = "-";
    }
    return [value, lweight, total];
  }

  // For time

  getForTime(cid, sess, pos) {
    var tblock = block;
    var value = 0;
    var time = 0;
    double weight = 0;
    double weightsum = 0;
    var lweight = "";
    double total = 0;
    var type = "group";
    // other session here
    if (sess != widget.id || widget.id == "") {
      for (var sitem in GlobalData.sessions) {
        if (sitem.id == sess) {
          for (var bl in sitem.program.blocks) {
            if (bl.id == block.id) {
              tblock = bl;
              type = sitem.type;
            }
          }
        }
      }
    }
    if (tblock.timeResGroup.length > pos) {
      time = tblock.timeResGroup[pos];
    }
    if (!block.simple) {
      for (var mitem in tblock.movements) {
        // Class
        if (type == "group") {
          var ar = mitem.resRepsGroup.split("-");
          var ar2 = mitem.resWeightGroup.split("-");
          if (ar.length > pos) {
            if (ar[pos] != "") {
              value += int.parse(ar[pos]);
            }
          }
          if (ar2.length > pos) {
            if (ar2[pos] == "" || ar2[pos] == "0" || ar2[pos] == "0.0") {
              weight += 1;
            } else {
              weight += double.parse(ar2[pos]);
              weightsum += double.parse(ar2[pos]);
            }
          }
          // 11 & Training
        } else {
          value += mitem.resReps;
          if (mitem.resWeight > 0) {
            weight += mitem.resWeight;
            weightsum += mitem.resWeight;
          } else {
            weight += 1;
          }
        }
      }
      if (weightsum > 0) {
        lweight = " - " +
            weightsum.toStringAsFixed(2) +
            (GlobalUser.lbs ? "lb" : "kg");
      }
    } else {
      lweight = "";
      if (time != 0) {
        value = 1;
        weight = 2;
        if (tblock.scaledSimple.length > pos) {
          if (tblock.scaledSimple[pos]) {
            lweight += " (Scaled)";
            weight = 1;
          }
        }
      }
    }
    if (time == 0 && value != 0) {
      time = tblock!.rounds - 1;
    }
    if (time < tblock.rounds && !tblock.simple && time > 0) {
      value = 0;
      for (var mitem in tblock!.movements) {
        value += mitem.reps * tblock.cycles;
      }
      if (value == 0) {
        value = 1;
      }
    }
    total = weight * (value).toDouble() * (tblock!.rounds - time).toDouble();
    if (time == 0 && value == 0) {
      total = 0;
    }
    return [value, lweight, time, total];
  }

  updateData() {
    if (this.mounted) {
      configureData();
    }
  }

  String getClient(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.name;
      }
    }
    if (id == GlobalData.space.client) {
      label = "You";
    }
    return label;
  }

  String getClientImage(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.image;
      }
    }
    return label;
  }

  String getClientAvatar(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.avatar;
      }
    }
    return label;
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
                child: TitleLabelBack(title),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
                child: Text(
                  subtitle,
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
                          children: _getContent())))
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

  _getContent() {
    List<Widget> items = [];
    items.add(Container(height: 30));
    for (var cl in list) {
      if (cl.id != GlobalData.space.client) {
        items.add(InkWell(
            onTap: () {
              tapHighfive(cl.id, cl.session);
            },
            child: ListPerson(
                getClient(cl.id),
                _getLeaderInfo(cl),
                getClientImage(cl.id),
                "HIGH FIVE" +
                    (cl.highfives == 0
                        ? ""
                        : " (" + cl.highfives.toString() + ")"),
                getClientAvatar(cl.id))));
      } else {
        items.add(ListPerson(getClient(cl.id), _getLeaderInfo(cl),
            getClientImage(cl.id), "", getClientAvatar(cl.id)));
      }
    }

    if (widget.type == "results" &&
        GlobalData.space.showHabits &&
        GlobalData.space.comments &&
        hlist.length > 0) {
      items.add(Container(height: 10));
      items.add(SubtitleLabel("History"));
      items.add(Container(height: 10));
    }

    for (var cl in hlist) {
      if (cl.total != 0) {
        items.add(Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: double.maxFinite,
            child: Column(children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 12, 0, 1),
                width: MediaQuery.of(context).size.width - 40,
                child: Text(
                  _getHistoryInfo(cl),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Text(
                    _getSessionInfo(cl.session),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                  )),
            ])));
      }
    }
    return items;
  }

  _getLeaderInfo(client) {
    var label = "";
    // AMRAP
    if (block.type == 0) {
      var round = 0;
      for (var mitem in block!.movements) {
        round += mitem.reps;
      }
      if (block.simple) {
        label = client.weight;
      } else {
        var rounds = (client.reps / round).toInt();
        var reps = client.reps - rounds * round;
        label = (rounds).toString() +
            "+" +
            (reps).toString() +
            " rounds" +
            client.weight;
        if (client.reps == 0) {
          label = "-";
        }
      }
      // For time
    } else if (block.type == 5) {
      var mins = (client.time / 60).toInt();
      var secs = client.time - mins * 60;
      var lsecs = (secs).toString();
      if (secs < 10) {
        lsecs = "0" + (secs).toString();
      }
      label = (mins).toString() + ":" + lsecs + " min" + client.weight;
      if (client.time == block.rounds - 1 && client.reps != 0) {
        label = (client.reps).toString() + " reps" + client.weight;
      }
      if (client.total == 0) {
        label = "-";
      }
    } else {
      label = (client.reps).toString() + " total reps" + client.weight;
      if (client.reps == 0) {
        label = "-";
      }
      if (block.simple) {
        label = client.weight;
      }
    }
    return label;
  }

  _getHistoryInfo(client) {
    var label = "- No result";
    if (block.type == 0) {
      if (block.simple) {
        label = client.weight == "-" ? "- No result -" : client.weight;
      } else {
        var round = 0;
        for (var mitem in block.movements) {
          round += mitem.reps;
        }
        var rounds = (client.reps / round).toInt();
        var reps = client.reps - rounds * round;
        label = rounds.toString() +
            "+" +
            reps.toString() +
            " rounds" +
            client.weight;
        if (client.reps == 0) {
          label = "- No result -";
        }
      }
    } else if (block.type == 5) {
      var mins = (client.time / 60).toInt();
      var secs = client.time - mins * 60;
      var lsecs = secs.toString();
      if (secs < 10) {
        lsecs = "0" + secs.toString();
      }
      label = mins.toString() + ":" + lsecs + " min" + client.weight;
      if (client.time == block!.rounds - 1 && client.reps != 0) {
        label = client.reps.toString() + " reps" + client.weight;
      }
      if (client.total == 0) {
        label = "- No result -";
      }
    } else {
      label = client.reps.toString() + " total reps" + client.weight;
      if (client.reps == 0) {
        label = "- No result -";
      }
      if (block.simple) {
        label = client.weight == "-" ? "- No result -" : client.weight;
      }
    }
    return label;
  }

  _getSessionInfo(sess) {
    var label = "Session";
    for (var s1 in GlobalData.sessions) {
      if (s1.id == sess) {
        label = s1.name + " - " + HelperCal.getSpecialDateYear(s1.date);
      }
    }
    for (var s2 in GlobalData.training) {
      if (s2.id == sess) {
        label = s2.name + " - " + HelperCal.getSpecialDateYear(s2.date);
      }
    }
    for (var s3 in GlobalData.archive) {
      if (s3.id == sess) {
        label = s3.name + " - " + HelperCal.getSpecialDateYear(s3.date);
      }
    }
    return label;
  }

  tapHighfive(client, sessid) {
    var sess = item;
    for (var s in GlobalData.sessions) {
      if (s.id == sessid) {
        sess = s;
      }
    }
    var list = [];
    for (var hf in sess.highfives) {
      list.add(hf);
    }
    list.add(client +
        "||" +
        GlobalData.space.client +
        "||" +
        ((DateTime.now().millisecondsSinceEpoch / 1000).toInt()).toString());
    FirebaseSender.updateHighfives(sessid, list);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("High five!"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));
    var token = "";
    for (var cl in GlobalData.clients) {
      if (cl.id == client) {
        token = cl.token;
      }
    }
    if (token != "") {
      FirebaseSender.sendPushMessage(
          token,
          "High five!",
          "You received a high five from " +
              GlobalUser.name +
              " for " +
              sess.name +
              " " +
              HelperCal.getSpecialDate(sess.date) +
              ".",
          "session",
          "",
          []);
    }
  }
}
