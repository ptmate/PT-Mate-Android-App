import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/sender.dart';

class RatingPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  const RatingPage(this.id, this.item);
  static _RatingPageState appState = _RatingPageState();
  @override
  _RatingPageState createState() {
    return RatingPage.appState = new _RatingPageState();
  }
}

class _RatingPageState extends State<RatingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelSession item = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");
  int rate = 0;
  String dark = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
    if(GlobalUI.dark) {
      setState(() {
        dark = "-dark";
      });
    }
  }

  updateValue(val) {
    setState(() {
      rate = val;
    });
  }

  rateSession() {
    var name = "class";
    if(item.availability) {
      name = "session";
    }
    if (rate != 0) {
      var rating = [];
      for (var value in item.rating) {
        rating.add(value);
      }
      rating.add(GlobalData.space.client + "," + rate.toString());
      FirebaseSender.rateSession(id, rating, item.type);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You rated the "+name),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
      ));

      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var name = "class";
    var name2 = "CLASS";
    if(item.availability) {
      name = "Session";
      name2 = "SESSION";
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: TitleLabelBack("Rate "+name),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    updateValue(1);
                  },
                  child: SvgPicture.asset(
                      rate > 0
                          ? "assets/images/common/rate-on"+dark+".svg"
                          : "assets/images/common/rate-off"+dark+".svg",
                      width: 50,
                      height: 50),
                ),
                InkWell(
                  onTap: () {
                    updateValue(2);
                  },
                  child: SvgPicture.asset(
                      rate > 1
                          ? "assets/images/common/rate-on"+dark+".svg"
                          : "assets/images/common/rate-off"+dark+".svg",
                      width: 50,
                      height: 50),
                ),
                InkWell(
                  onTap: () {
                    updateValue(3);
                  },
                  child: SvgPicture.asset(
                      rate > 2
                          ? "assets/images/common/rate-on"+dark+".svg"
                          : "assets/images/common/rate-off"+dark+".svg",
                      width: 50,
                      height: 50),
                ),
                InkWell(
                  onTap: () {
                    updateValue(4);
                  },
                  child: SvgPicture.asset(
                      rate > 3
                          ? "assets/images/common/rate-on"+dark+".svg"
                          : "assets/images/common/rate-off"+dark+".svg",
                      width: 50,
                      height: 50),
                ),
                InkWell(
                  onTap: () {
                    updateValue(5);
                  },
                  child: SvgPicture.asset(
                      rate > 4
                          ? "assets/images/common/rate-on"+dark+".svg"
                          : "assets/images/common/rate-off"+dark+".svg",
                      width: 50,
                      height: 50),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: BtnPrimary(
                label: "RATE "+name2,
                clickFn: rateSession,
              ),
            )
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
