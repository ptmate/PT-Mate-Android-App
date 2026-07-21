import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/calendar/comments.dart';
import 'package:ptmate_client/calendar/editresults.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:ptmate_client/calendar/rating.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/button-tertiary-small.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/list-comment.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  const ResultsPage(this.id, this.item);
  static _ResultsPageState appState = _ResultsPageState();
  @override
  _ResultsPageState createState() {
    return ResultsPage.appState = new _ResultsPageState();
  }
}

class _ResultsPageState extends State<ResultsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
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
  bool rating = true;
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
      ModelSession tmp = ModelSession(
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
      for (var sess in GlobalData.sessions) {
        if (sess.id == id) {
          tmp = sess;
        }
      }
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

  getRate() {
    double number = 0;
    int sum = 0;
    for (var rate in item.rating) {
      var arr = rate.split(',');
      sum += int.parse(arr[1]);
    }
    if (item.rating.length > 0) {
      number = sum / (item.rating.length * 5) * 100;
    }
    return number;
  }

  showBtnRate() {
    var show = true;
    var name = "CLASS";
    if (item.availability) {
      name = "SESSION";
    }
    for (var rate in item.rating) {
      var arr = rate.split(',');
      if (arr[0] == GlobalData.space.client) {
        show = false;
      }
    }
    if (show) {
      return BtnTertiarySmall(label: "RATE " + name, clickFn: tapRating);
    }
  }

  String getClient(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.name;
      }
    }
    if (id == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    if (id == GlobalData.space.client) {
      label = "You";
    }
    for (var st in GlobalData.allStaff) {
      if (id == st.id) {
        label = st.name;
      }
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
    if (id == GlobalData.space.id) {
      label = GlobalData.space.image;
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

  tapRating() {
    Navigator.push(
        context,
        PageRoutes.sharedAxis(() => RatingPage(item.id, item),
            SharedAxisTransitionType.vertical));
  }

  tapComment() {
    Navigator.push(
        context,
        PageRoutes.sharedAxis(() => CommentsPage(item.id, item, ""),
            SharedAxisTransitionType.vertical));
  }

  tapUpdate(block) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditResultsPage(item.id, item, block)),
    );
  }

  tapDelete() {
    AlertDialog alert = AlertDialog(
      title: Text("Delete session?"),
      content: Text("Are you sure you want to delete this training session?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deleteSession();
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

  deleteSession() {
    FirebaseSender.deleteSession(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Session successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }

  tapVideo() async {
    await launch(item.program.video);
  }

  getSubtitle() {
    var label = HelperCal.getSpecialDate(item.date);
    if (item.locationName != "") {
      DateFormat dateTime = DateFormat("d MMM HH:mm");
      label = dateTime.format(item.date) + " - " + item.locationName;
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
              Row(children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
                  child: TitleLabelBack(
                      item.type == "training" ? "Training" : item.name),
                  width: MediaQuery.of(context).size.width - 50,
                ),
                _getButton()
              ]),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
                child: Text(
                  getSubtitle(),
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
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getButton() {
    if (item.type == "training") {
      return InkWell(
        onTap: () {
          tapDelete();
        },
        child: SvgPicture.asset("assets/images/nav/delete.svg",
            color: AppColors.PrimaryColor, width: 30, height: 30),
      );
    } else {
      return Container();
    }
  }

  _getContent() {
    //List items = List();
    List<Widget> items = [];
    if (GlobalData.space.comments) {
      items.add(Container(
          padding: EdgeInsets.fromLTRB(50, 10, 0, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 13,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/common/rating' + dark + '.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      alignment: Alignment.topLeft,
                      width: getRate(),
                      height: 13,
                      child: SvgPicture.asset(
                        "assets/images/common/rating" + dark + ".svg",
                        width: 100,
                        height: 13,
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.topLeft,
                      ),
                    )),
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getRate().toString() == "NaN"
                        ? ""
                        : (getRate() / 20).toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.AvatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  )),
              Align(alignment: Alignment.topRight, child: showBtnRate()),
            ],
          )));
    }
    if (item.desc != "") {
      items.add(Container(
        width: double.maxFinite,
        child: Text(
          item.desc,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      ));
    }
    var name = "class";
    if (item.availability) {
      name = "session";
    }
    if (item.program.id == "") {
      items.add(EmptyMessage("empty-programs", "No program",
          "This " + name + " does not have\na program attached."));
    } else {
      item.program.blocks.sort((a, b) => a.id.compareTo(b.id));
      if (item.program.video != "") {
        items.add(Container(
          margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: BtnTertiary(
            label: "Watch video",
            clickFn: tapVideo,
          ),
        ));
      }
      for (var block in item.program.blocks) {
        var type = "results";
        if (!block.logResults) {
          type = "";
        }
        if (item.type == "training" || item.type == "pt") {
          type = "training";
        }
        items.add(
          TitleDoubleLabel(
              GlobalUI.titles[block.type].toUpperCase() +
                  HelperTrain.getBlockInfo(block).toUpperCase(),
              GlobalUI.cats[block.cat].toUpperCase(),
              type,
              item.id,
              block.id),
        );
        if (!block.simple) {
          for (var ex in block.movements) {
            items.add(InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExImagePage(ex)),
                  );
                },
                child: CardText(HelperTrain.getMovementName(ex, block),
                    HelperTrain.getMovementInfo(ex, block), ex.notes)));
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
        if (block.logResults &&
            (item.clients.contains(GlobalData.space.client) ||
                item.type == "pt" ||
                item.type == "training")) {
          items.add(Material(
              color: Colors.transparent,
              child: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width - 40,
                  child: InkWell(
                      onTap: () {
                        tapUpdate(block);
                      },
                      child: Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "UPDATE RESULTS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.PrimaryColor,
                              fontFamily: "Oswald",
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ))))));
        }
      }
    }
    if (item.type == "group" && GlobalData.space.showBooked) {
      items.add(SubtitleLabel("Attendees"));
      for (var client in item.clients) {
        if (GlobalData.space.comments) {
          var num = 0;
          var label = "No high fives yet";
          for (var hf in item.highfives) {
            var ar = hf.split("||");
            if (ar[0] == client) {
              num++;
            }
          }
          if (num > 0) {
            label = num.toString() + " high five" + (num == 1 ? "" : "s");
          }
          items.add(InkWell(
              onTap: () {
                tapHighfive(client);
              },
              child: ListPerson(
                  getClient(client),
                  label,
                  getClientImage(client),
                  "HIGH FIVE",
                  getClientAvatar(client))));
        } else {
          items.add(ListPerson(getClient(client), "Attended",
              getClientImage(client), "", getClientAvatar(client)));
        }
      }
    }

    if (GlobalData.space.comments) {
      var highfives = [];
      for (var hf in item.highfives) {
        var ar = hf.split("||");
        if (ar[0] == GlobalData.space.client) {
          var date = DateTime.fromMillisecondsSinceEpoch(
              (num.parse(ar[2]) * 1000).toInt());
          highfives.add(ModelClientChat(ar[1], date, "", ""));
        }
      }
      if (highfives.length > 0) {
        items.add(SubtitleLabel("Your high fives"));
        for (var hf in highfives) {
          items.add(ListPerson(
              getClient(hf.id),
              "Received " + HelperCal.getSpecialDateBasic(hf.date),
              getClientImage(hf.id),
              "",
              getClientAvatar(hf.id)));
        }
      }

      items.add(SubtitleLabel("Comments"));
      if (item.comments.length == 0) {
        items.add(EmptyLabel("", "No comments yet"));
      } else {
        items.add(Container(height: 20));
        for (var comment in item.comments) {
          if (comment.sender == GlobalData.space.client ||
              comment.sender == GlobalUser.uid) {
            items.add(InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageRoutes.sharedAxis(
                          () => CommentsPage(item.id, item, comment.id),
                          SharedAxisTransitionType.vertical));
                },
                child: ListComment(
                    getClient(comment.sender),
                    HelperCal.getSpecialDate(comment.date),
                    getClientImage(comment.sender),
                    comment.text,
                    "EDIT",
                    getClientAvatar(comment.sender))));
          } else {
            items.add(ListComment(
                getClient(comment.sender),
                HelperCal.getSpecialDate(comment.date),
                getClientImage(comment.sender),
                comment.text,
                "",
                getClientAvatar(comment.sender)));
          }
        }
        items.add(Container(height: 20));
      }
      items.add(
          BtnSecondarySmall(label: "WRITE A COMMENT", clickFn: tapComment));
    }

    return items;
  }

  tapHighfive(client) {
    var list = [];
    for (var hf in item.highfives) {
      list.add(hf);
    }
    list.add(client +
        "||" +
        GlobalData.space.client +
        "||" +
        ((DateTime.now().millisecondsSinceEpoch / 1000).toInt()).toString());
    FirebaseSender.updateHighfives(item.id, list);
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
              item.name +
              " " +
              HelperCal.getSpecialDate(item.date) +
              ".",
          "session",
          "",
          []);
    }
  }
}
