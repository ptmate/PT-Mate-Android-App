import 'package:flutter/material.dart';
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

class ProgramPage extends StatefulWidget {
  final String id;
  final ModelProgram item;
  final String plan;
  final bool interactive;
  const ProgramPage(this.id, this.item, this.plan, this.interactive);
  static _ProgramPageState appState = _ProgramPageState();
  @override
  _ProgramPageState createState() {
    return ProgramPage.appState = new _ProgramPageState();
  }
}

class _ProgramPageState extends State<ProgramPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelProgram item = ModelProgram("", "", "", 0, 0, "", [], false, "");
  String plan = "";
  bool interactive = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      plan = widget.plan;
      interactive = widget.interactive;
    });
  }

  updateData() {
    if (this.mounted && plan != "") {
      ModelProgram tmp = ModelProgram("", "", "", 0, 0, "", [], false, "");
      for (var prog in GlobalData.programs) {
        if (prog.id == id) {
          tmp = prog;
        }
      }
      setState(() {
        item = tmp;
      });
    }
  }

  void tapStartProgram() {
    var sid = FirebaseSender.createSessionId();
    var session = ModelSession(
        sid,
        DateTime.now(),
        "Training Session",
        item.time,
        [],
        [],
        [],
        GlobalUser.uid,
        "training",
        "",
        3,
        0,
        DateTime.now(),
        true,
        [],
        [],
        item,
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunningPage(sid, session)),
    );
  }

  void tapDeleteProgram() {
    AlertDialog alert = AlertDialog(
      title: Text("Delete program?"),
      content:
          Text("Are you sure you want to delete this program from your list?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deleteProgram();
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

  deleteProgram() {
    FirebaseSender.deleteProgram(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Program successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }

  tapVideo() async {
    await launch(item.video);
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
                child: TitleLabelBack("Program"),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _getBlocks())))
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
      Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
        padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage("assets/images/common/gradient" +
                HelperTrain.getColor(item.time) +
                ".png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Text(
          item.time.toString() + "'",
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
    if (item.video != "") {
      items.add(Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: BtnTertiary(
          label: "Watch video",
          clickFn: tapVideo,
        ),
      ));
    }
    for (var block in item.blocks) {
      var subtitle = GlobalUI.cats[block.cat].toUpperCase();
      if (block.name != "") {
        subtitle = block.name.toUpperCase();
      }
      items.add(TitleDoubleLabel(
          GlobalUI.titles[block.type].toUpperCase() +
              HelperTrain.getBlockInfo(block).toUpperCase(),
          subtitle,
          "program",
          "",
          block.id));
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
    }
    if (plan == "") {
      items.add(Container(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
          child: BtnPrimary(
              label: "DO THIS PROGRAM NOW", clickFn: tapStartProgram)));
      items.add(
          BtnTertiary(label: "DELETE THIS PROGRAM", clickFn: tapDeleteProgram));
    } else {
      if (interactive) {
        items.add(Container(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
            child: BtnPrimary(
                label: "DO THIS PROGRAM NOW", clickFn: tapStartProgram)));
      }
    }

    return items;
  }
}
