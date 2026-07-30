import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/account/settings.dart';
import 'package:ptmate_client/account/update.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/components/button-primary-small.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/login.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  static _AccountPageState appState = _AccountPageState();
  @override
  _AccountPageState createState() {
    return AccountPage.appState = new _AccountPageState();
  }
}

class _AccountPageState extends State<AccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = GlobalUser.name;
  String email = GlobalUser.email;
  String phone = GlobalUser.phone;
  // DateTime bstring = GlobalUI.date.parse(GlobalUser.birth);
  String birth = GlobalUser.birth;
  String height = (GlobalUser.height / 100).toString() + " m";
  String goal = GlobalData.space.goal;
  String ecName = GlobalUser.ecName;
  String ecPhone = GlobalUser.ecPhone;
  int ecType = GlobalUser.ecType;
  String message = "";
  String version = "-";

  @override
  void initState() {
    super.initState();
    // birth = GlobalUI.dateFull.format(bstring);
    String hgt = (GlobalUser.height / 100).toString() + " m";
    if (GlobalUser.lbs) {
      var b = GlobalUser.height / 2.54;
      var h1 = (b / 12).toInt();
      var h2 = (b - (h1 * 12)).toStringAsFixed(0);
      hgt = h1.toString() + "'" + h2 + " ft";
    }
    height = hgt;
    getAppVersion();
  }

  updateData() {
    if (this.mounted) {
      // bstring = GlobalUI.date.parse(GlobalUser.birth);
      String hgt = (GlobalUser.height / 100).toString() + " m";
      if (GlobalUser.lbs) {
        var b = GlobalUser.height / 2.54;
        var h1 = (b / 12).toInt();
        var h2 = (b - (h1 * 12)).toStringAsFixed(0);
        hgt = h1.toString() + "'" + h2 + " ft";
      }
      setState(() {
        name = GlobalUser.name;
        email = GlobalUser.email;
        phone = GlobalUser.phone;
        // birth = GlobalUI.dateFull.format(bstring);
        height = hgt;
        goal = GlobalData.space.goal;
        ecName = GlobalUser.ecName;
        ecPhone = GlobalUser.ecPhone;
        ecType = GlobalUser.ecType;
      });
    }
  }

  _tapUpdate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdatePage()),
    );
  }

  _tapUpdateSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  _tapSpace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrainerPage(true)),
    );
  }

  _tapLogout() {
    AlertDialog alert = AlertDialog(
      title: Text("Log out"),
      content: Text("Do you want to log out?"),
      actions: [
        TextButton(
          child: Text("Log out"),
          onPressed: () {
            _logoutUser();
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

  _logoutUser() async {
    FirebaseSender.updateToken(GlobalUser.uid, "");
    GlobalUser.uid = "";
    GlobalUser.name = "";
    GlobalUser.email = "";
    GlobalUser.phone = "";
    GlobalUser.birth = "";
    GlobalUser.goal = "";
    GlobalUser.image = "";
    GlobalUser.height = 0;
    GlobalUser.spaces = 0;

    GlobalData.space = ModelSpace(
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ["", "", "", "", ""],
        [],
        [],
        false,
        false,
        true,
        false,
        "",
        "",
        0,
        0,
        false,
        false,
        "default",
        "",
        [],
        false,
        "",
        24,
        "",
        [],
        false,
        false,
        "au",
        false,
        "",
        false,
        true,
        false,
        "",
        "",
        false,
        true,
        "",
        0,
        0,
        false,
        [],
        []);
    GlobalData.chat = ModelChat("", "", "", [], [], []);
    GlobalData.spaces = [];
    GlobalData.training = [];
    GlobalData.sessions = [];
    GlobalData.programs = [];
    GlobalData.plans = [];
    GlobalData.payments = [];
    GlobalData.best = [];
    GlobalData.clients = [];
    GlobalData.packs = [];
    GlobalData.debits = [];
    GlobalData.chats = [];
    GlobalData.logs = [];

    await FirebaseAuth.instance.signOut().then((value) => Navigator.push(
        context,
        PageRoutes.sharedAxis(
            () => LoginPage(), SharedAxisTransitionType.horizontal)));
  }

  _tapDelete() {
    Connector.getPlansSpace();
    AlertDialog alert = AlertDialog(
      title: Text("Delete your account?"),
      content: Text(
          "Your account and all of its data, including programs and sessions, will be deleted and you'll be disconnected from your training spaces."),
      actions: [
        TextButton(
          child: Text("Delete account"),
          onPressed: () {
            Navigator.of(context).pop();
            _confirmDelete();
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

  _confirmDelete() {
    AlertDialog alert = AlertDialog(
      title: Text("Note: This action cannot be undone"),
      content:
          Text("Are you sure you want to proceed and delete your account?"),
      actions: [
        TextButton(
          child: Text("Delete account"),
          onPressed: () {
            _deleteAccount();
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

  _deleteAccount() async {
    var user = FirebaseAuth.instance.currentUser!;
    user.delete();

    for (var plan in GlobalData.plansSpace) {
      if (plan.sent.contains(GlobalData.space.client)) {
        var sent = [];
        for (var sn in plan.sent) {
          if (sn != GlobalData.space.client) {
            sent.add(sn);
          }
        }
        FirebaseSender.updatePlanClients(plan.id, sent);
      }
    }

    FirebaseDatabase.instance
        .ref()
        .child("usersClients/" + GlobalUser.uid)
        .remove();
    FirebaseDatabase.instance
        .ref()
        .child("sessions/" + GlobalUser.uid)
        .remove();
    FirebaseDatabase.instance
        .ref()
        .child("workouts/" + GlobalUser.uid)
        .remove();
    FirebaseDatabase.instance.ref().child("log/" + GlobalUser.uid).remove();
    for (var space in GlobalData.spaces) {
      FirebaseDatabase.instance
          .ref()
          .child("clients/" + space.id + "/" + space.client)
          .update({
        "uid": "",
      });
      FirebaseDatabase.instance
          .ref()
          .child("messaging/" + space.id + GlobalUser.uid)
          .remove();
    }

    // Log out
    GlobalUser.uid = "";
    GlobalUser.name = "";
    GlobalUser.email = "";
    GlobalUser.phone = "";
    GlobalUser.birth = "";
    GlobalUser.goal = "";
    GlobalUser.ecName = "";
    GlobalUser.ecPhone = "";
    GlobalUser.ecType = 99;
    GlobalUser.image = "";
    GlobalUser.height = 0;
    GlobalUser.spaces = 0;

    GlobalData.space = ModelSpace(
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ["", "", "", "", ""],
        [],
        [],
        false,
        false,
        true,
        false,
        "",
        "",
        0,
        0,
        false,
        false,
        "default",
        "",
        [],
        false,
        "",
        24,
        "",
        [],
        false,
        false,
        "au",
        false,
        "",
        false,
        true,
        false,
        "",
        "",
        false,
        true,
        "",
        0,
        0,
        false,
        [],
        []);
    GlobalData.chat = ModelChat("", "", "", [], [], []);
    GlobalData.spaces = [];
    GlobalData.training = [];
    GlobalData.sessions = [];
    GlobalData.programs = [];
    GlobalData.plans = [];
    GlobalData.payments = [];
    GlobalData.best = [];
    GlobalData.clients = [];
    GlobalData.packs = [];
    GlobalData.debits = [];
    GlobalData.chats = [];
    GlobalData.logs = [];

    await FirebaseAuth.instance.signOut().then((value) => Navigator.push(
        context,
        PageRoutes.sharedAxis(
            () => LoginPage(), SharedAxisTransitionType.horizontal)));
  }

  _openURL(url) async {
    /*if (await canLaunch(url)) {
      await canLaunch(url);
    } else {
      throw 'Could not launch $url';
    }*/
    await launchUrl(url);
  }

  _tapLeave(item) {
    var title = item.name;
    if (item.business != null && item.business != "") {
      title = item.business;
    }
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(
          "Do you want to leave this training space? Note that your data will be kept by your gym/trainer. Please contact them if you want them to delete it."),
      actions: [
        TextButton(
          child: Text("Leave training space"),
          onPressed: () {
            leaveSpace(item);
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

  leaveSpace(item) {
    if (GlobalData.spaces.length > 0) {
      GlobalData.spaces.removeWhere((space) => space.id == item.id);
    } else {
      GlobalData.spaces = [];
    }
    FirebaseSender.disconnectSpace(item);

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("You left the training space"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (GlobalData.spaces.length == 0) {
        GlobalData.space = ModelSpace(
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ["", "", "", "", ""],
            [],
            [],
            false,
            false,
            true,
            false,
            "",
            "",
            0,
            0,
            false,
            false,
            "default",
            "",
            [],
            false,
            "",
            24,
            "",
            [],
            false,
            false,
            "au",
            false,
            "",
            false,
            true,
            false,
            "",
            "",
            false,
            true,
            "",
            0,
            0,
            false,
            [],
            []);
        Navigator.push(
            context,
            PageRoutes.sharedAxis(
                () => TrainerPage(false), SharedAxisTransitionType.horizontal));
      } else {
        GlobalData.space = GlobalData.spaces[0];
        Navigator.push(
            context,
            PageRoutes.sharedAxis(
                () => ConnectPage(), SharedAxisTransitionType.horizontal));
      }
    });
  }

  String getInitials() {
    String inits = "";
    var arr = GlobalUser.name.split(" ");
    for (var item in arr) {
      if (item != "") {
        inits += item[0];
      }
    }
    if (inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

  String getCardImage(name) {
    String label = "card-generic.svg";
    if (name == "Visa") {
      label = "card-visa.svg";
    }
    if (name == "MasterCard" || name == "Mastercard") {
      label = "card-mastercard.svg";
    }
    return label;
  }

  String getEC() {
    var label = "-";
    if (GlobalUser.ecName != "") {
      label = GlobalUser.ecName;
      if (GlobalUser.ecType != 99) {
        label += " (" + GlobalUI.ecTypes[GlobalUser.ecType] + ")";
      }
      if (GlobalUser.ecPhone != "") {
        label += "\n" + GlobalUser.ecPhone;
      }
    }
    return label;
  }

  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    setState(() {
      version = ver;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TitleLabelBack("Your Account"),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 30, 0, 50),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60.0),
                                    color: AppColors.PrimaryColor,
                                  ),
                                  child: Avatar(getInitials(), 110,
                                      GlobalUser.image, 40, GlobalUser.avatar),
                                )),
                            DataLabel("Name", name),
                            DataLabel("Email", email),
                            DataLabel("Phone", phone),
                            DataLabel("Date of birth", birth),
                            DataLabel("Height", height),
                            DataLabel(
                                "Training focus", goal == "" ? "-" : goal),
                            DataLabel("Emergency contact", getEC()),
                            Container(
                              padding: EdgeInsets.only(bottom: 30),
                              child: BtnPrimarySmall(
                                  label: "Update details", clickFn: _tapUpdate),
                            ),
                            SubtitleLabel("Settings"),
                            Container(
                              width: MediaQuery.of(context).size.width - 40,
                              padding: EdgeInsets.only(bottom: 30),
                              child: Text(
                                "Update your preferences and your location",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 30),
                              child: BtnPrimarySmall(
                                  label: "Update settings",
                                  clickFn: _tapUpdateSettings),
                            ),
                            SubtitleLabel("Training Spaces"),
                            Column(
                              children: _getSpaces(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                              child: BtnPrimarySmall(
                                  label: "Add another", clickFn: _tapSpace),
                            ),
                            Container(height: 30),
                            BtnTertiary(label: "Log out", clickFn: _tapLogout),
                            SubtitleLabel("Links"),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: InkWell(
                                    onTap: () {
                                      var url1 =
                                          "https://www.ptmate.net/mobile/terms-conditions";
                                      if (GlobalUser.country == "us") {
                                        url1 =
                                            "https://www.ptmate.net/mobile/terms-conditions/us";
                                      }
                                      _openURL(url1);
                                    },
                                    child: Text(
                                      "Terms & Conditions",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: InkWell(
                                    onTap: () {
                                      var url2 =
                                          "https://www.ptmate.net/mobile/privacy-policy";
                                      if (GlobalUser.country == "us") {
                                        url2 =
                                            "https://www.ptmate.net/mobile/privacy-policy/us";
                                      }
                                      _openURL(url2);
                                    },
                                    child: Text(
                                      "Privacy Policy",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: InkWell(
                                    onTap: () {
                                      _openURL("https://help.ptmate.net");
                                    },
                                    child: Text(
                                      "Help Centre",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 40, 0, 30),
                                    child: Text(
                                      "PT Mate Member Version " + version,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 12,
                                      ),
                                    )),
                                Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () {
                                          _tapDelete();
                                        },
                                        child: Text(
                                          "DELETE ACCOUNT",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.AlertColor,
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        )))
                              ],
                            )
                          ])))
            ])),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getSpaces() {
    List<Widget> items = [];
    for (var item in GlobalData.spaces) {
      String label = item.business;
      String sublabel = item.name;
      if (!item.active) {
        sublabel = "Inactive";
      }
      items.add(InkWell(
          onTap: () {
            _tapLeave(item);
          },
          child: ListPerson(label, sublabel, item.image, "LEAVE", "")));
    }
    return items;
  }

  showMessage() {
    if (this.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
      ));
    }
  }
}
