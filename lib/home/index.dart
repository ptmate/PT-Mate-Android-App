import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/calendar/event.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/components/button-action.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/components/post-reply.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/title.dart';
import 'package:ptmate_client/components/trainingspace.dart';
import 'package:ptmate_client/home/activity.dart';
import 'package:ptmate_client/home/card.dart';
import 'package:ptmate_client/home/cards.dart';
import 'package:ptmate_client/home/credits.dart';
import 'package:ptmate_client/home/forms.dart';
import 'package:ptmate_client/home/membership.dart';
import 'package:ptmate_client/home/new-debit.dart';
import 'package:ptmate_client/home/new-payment.dart';
import 'package:ptmate_client/home/payments.dart';
import 'package:ptmate_client/home/post.dart';
import 'package:ptmate_client/home/reactions.dart';
import 'package:ptmate_client/home/reply.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/messaging/chat.dart';
import 'package:ptmate_client/messaging/image.dart';
import 'package:ptmate_client/tools/index.dart';
import 'package:ptmate_client/training/program.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  static _HomePageState appState = _HomePageState();
  @override
  _HomePageState createState() {
    return HomePage.appState = new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  var name = GlobalUser.name.split(" ");
  List<ModelSession> sessions = [];
  List<ModelPost> posts = [];

  var dark = "";
  String message = "";

  @override
  void initState() {
    super.initState();
    getSpaceBilling(GlobalData.space.id, GlobalData.space.client);
    getSessions();
    getPosts();
    checkNotification();
    checkVersion();
    if (GlobalUI.dark) {
      dark = "-dark";
    }
    if (GlobalUser.token != "" &&
        GlobalUser.token != GlobalUI.token &&
        GlobalData.space.id != "" &&
        GlobalData.space.id != "none") {
      FirebaseSender.updateUserToken();
    }

    if (GlobalUI.isSignup) {
      Intercom.instance.initialize('gwe4xp9u',
          iosApiKey: 'ios_sdk-5e6ac56f4f7192309cec932c1fbf1773f3050a19',
          androidApiKey:
              'android_sdk-95b13592d44ecd1140031b7000446696845b7de7');
      Intercom.instance.loginIdentifiedUser(userId: "member");
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (GlobalData.space.stripe == "") {
          Intercom.instance.displayCarousel("43601978");
        } else {
          Intercom.instance.displayCarousel("43601943");
        }
        for (var loc in GlobalData.allLocations) {
          if (GlobalData.space.newLocations.contains(loc.id) &&
              !loc.clients.contains(GlobalData.space.client)) {
            var tmp1 = [];
            for (var cl in loc.clients) {
              tmp1.add(cl);
            }
            tmp1.add(GlobalData.space.client);
            FirebaseSender.updateLocation(loc.id, tmp1);
          }
        }
        for (var gr in GlobalData.allGroups) {
          if (GlobalData.space.newGroups.contains(gr.id) &&
              !gr.clients.contains(GlobalData.space.client)) {
            var tmp2 = [];
            for (var cl in gr.clients) {
              tmp2.add(cl);
            }
            tmp2.add(GlobalData.space.client);
            FirebaseSender.updateGroup(gr.id, tmp2);
          }
        }
        GlobalUI.isSignup = false;
      });
    }
  }

  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String v1 = ver.replaceAll(".", "");
    String v2 = GlobalUI.appver.replaceAll(".", "");

    String version = "Android - App " + packageInfo.version;
    if (GlobalUI.mobile != version) {
      FirebaseSender.updateAppVersion();
    }

    if (int.parse(v1) < int.parse(v2) && this.mounted) {
      AlertDialog alert = AlertDialog(
        title: Text("App out of date"),
        content: Text(
            "Your using an old version of the app that may cause issues and unexpected crashes. Please go to the App Store and update it to the latest version."),
        actions: [
          TextButton(
            child: Text("Got it"),
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
  }

  checkNotification() {
    Timer(Duration(milliseconds: 300), () {
      if (GlobalUI.notification[0] != "") {
        if (GlobalUI.notification[0] == "chat" &&
            GlobalUI.notification[1] == GlobalData.space.id) {
          if (GlobalUI.notification[2] == GlobalData.chat.id) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatPage(GlobalData.chat.id, GlobalData.chat, "pt")),
            );
          } else {
            for (var item in GlobalData.chats) {
              if (item.id == GlobalUI.notification[2]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(item.id, item, "group")),
                );
              }
            }
            for (var item in GlobalData.chatsStaff) {
              if (item.id == GlobalUI.notification[2]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(item.id, item, "staff")),
                );
              }
            }
          }
        } else if (GlobalUI.notification[0] == "session" &&
            GlobalUI.notification[1] == GlobalData.space.id) {
          for (var item in GlobalData.sessions) {
            if (item.id == GlobalUI.notification[2]) {
              if (item.attendance == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultsPage(item.id, item)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SessionPage(item.id, item)),
                );
              }
            }
          }
        }
        GlobalUI.notification = ["", "", ""];
      }
    });
  }

  updateData() {
    if (this.mounted) {
      setState(() {
        name = GlobalUser.name.split(" ");
      });
      getSessions();
    }
  }

  updateLocation() {
    if (this.mounted) {
      getSessions();
      getPosts();
    }
  }

  _openURL(url) async {
    /*if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }*/
    await launch(url);
  }

  getSessions() {
    List<ModelSession> items = [];
    // Sessions
    for (var item in GlobalData.sessions) {
      List clients = [];
      List waiting = [];
      clients = item.clients;
      waiting = item.waiting;
      var date = item.date.add(new Duration(minutes: item.duration));
      var dmax = DateTime.now().add(new Duration(days: 7));
      if (GlobalUI.location == "" ||
          GlobalUI.location.contains(item.location)) {
        if (date.isAfter(DateTime.now()) &&
            item.type == "pt" &&
            item.date.isBefore(dmax)) {
          items.add(item);
        }
        if (date.isAfter(DateTime.now()) &&
            item.date.isBefore(dmax) &&
            item.type == "group" &&
            (clients.contains(GlobalData.space.client) ||
                waiting.contains(GlobalData.space.client))) {
          items.add(item);
        }
        if (GlobalData.space.linked.length > 0) {
          for (var cl in GlobalData.space.linked) {
            if (date.isAfter(DateTime.now()) &&
                item.date.isBefore(dmax) &&
                item.type == "group" &&
                (clients.contains(cl.id) || waiting.contains(cl.id))) {
              items.add(item);
            }
          }
        }
      }
    }
    // Events
    for (var item in GlobalData.events) {
      List clients = [];
      List waiting = [];
      clients = item.clients;
      waiting = item.waiting;
      var date = item.date.add(new Duration(minutes: item.duration));
      var dmax = DateTime.now().add(new Duration(days: 7));
      if (GlobalUI.location == "" ||
          GlobalUI.location.contains(item.location)) {
        if (date.isAfter(DateTime.now()) &&
            item.date.isBefore(dmax) &&
            (clients.contains(GlobalData.space.client) ||
                waiting.contains(GlobalData.space.client))) {
          items.add(item);
        }
        if (GlobalData.space.linked.length > 0) {
          for (var cl in GlobalData.space.linked) {
            if (date.isAfter(DateTime.now()) &&
                item.date.isBefore(dmax) &&
                (clients.contains(cl) || waiting.contains(cl))) {
              items.add(item);
            }
          }
        }
      }
    }
    if (!GlobalData.space.active) {
      items = [];
    }

    // add training plan sessions here
    for (var item in GlobalData.plans) {
      var end = item.date.add(Duration(days: item.weeks.length * 7 + 15));
      if (end.isAfter(DateTime.now()) &&
          HelperTrain.getPlanCompletion(item) < 100) {
        var program = HelperTrain.getNextPlan(item);
        items.add(ModelSession(
            item.name,
            DateTime.now(),
            "Training Session",
            program.time,
            [],
            [],
            [],
            GlobalUser.uid,
            "training",
            item.id,
            2,
            0,
            DateTime.now(),
            true,
            [],
            [],
            program,
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
            ""));
      }
    }

    setState(() {
      sessions = items;
    });
    sessions.sort((a, b) => a.date.compareTo(b.date));
  }

  getPosts() {
    var items = GlobalData.community;
    items.sort((b, a) => a.seq.compareTo(b.seq));
    setState(() {
      posts = items;
    });
  }

  String getSmallText(item) {
    String label = "";
    if (item.type == "pt") {
      label = "with " + GlobalData.space.name;
    } else {
      List list = item.clients ?? [];
      if (list.length > 0) {
        label = list.length.toString() + " booked in";
      } else {
        label = "No bookings yet";
      }
      if (list.contains(GlobalData.space.client)) {
        label = "Booked in";
      }
      List list2 = item.waiting ?? [];
      if (list2.contains(GlobalData.space.client)) {
        label = "Waiting list";
      }
      if (GlobalData.space.linked.length > 0) {
        for (var cl in GlobalData.space.linked) {
          if (list.contains(cl.id)) {
            label = cl.name + " booked in";
          }
          if (list2.contains(cl.id)) {
            label = cl.name + " on waiting list";
          }
        }
      }
    }
    return label;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            padding: EdgeInsets.only(top: 35),
            child: Column(
              children: [
                TrainingSpace(),
                Expanded(
                    child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 15),
                                    child: Avatar(
                                        getInitials(),
                                        60,
                                        GlobalUser.image,
                                        24,
                                        GlobalUser.avatar),
                                  ),
                                  TitleLabel("Hello " + name[0], true),
                                ],
                              ),
                              Container(height: 50),
                              _actionRows(),
                              Container(height: 20),
                              SubtitleLabel("Upcoming sessions"),
                              Column(children: _getSessions()),
                              Container(height: 10),
                              BtnSecondarySmall(
                                label: "View activity",
                                clickFn: tapActivity,
                              ),
                              Container(height: 20),
                              Column(children: _getCommunity()),
                            ])))
              ],
            )),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getSessions() {
    //List items = List();
    List<Widget> items = [];
    if (sessions.length > 0) {
      for (var item in sessions) {
        if (item.type == "training") {
          items.add(InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProgramPage(
                          item.program.id, item.program, item.link, true)),
                );
              },
              child: ListDefault(
                  item.name,
                  item.program.name +
                      "\n" +
                      HelperCal.getDuration(item.duration, "hours"),
                  item.id,
                  HelperCal.getTypeColor(item.type, item.availability),
                  HelperCal.getTypeImage(item.type, item.availability),
                  false)));
        } else if (item.type == "event") {
          items.add(InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventPage(item.id, item)),
                );
              },
              child: ListDefault(
                  item.name,
                  getSessionInfo(item),
                  getSmallText(item),
                  HelperCal.getTypeColor(item.type, item.availability),
                  HelperCal.getTypeImage(item.type, item.availability),
                  false)));
        } else {
          var name = item.name;
          if (item.availability) {
            name = "1:1 Availability";
          }
          if (item.link != "") {
            name += " (Virtual)";
          }
          var dt = HelperCal.getSpecialDate(item.date) + " h";
          var showLink = false;
          //item.date.isAfter(DateTime.now().add(new Duration(minutes: -5)))
          var dt5 = item.date.add(new Duration(minutes: -5));
          if (item.link != "" && DateTime.now().isAfter(dt5)) {
            showLink = true;
            dt = "Tap to join the session";
            if (item.type == "group" && !item.availability) {
              dt = "Tap to join the class";
            }
          }
          items.add(InkWell(
              onTap: () {
                if (showLink) {
                  _openURL(item.link);
                } else {
                  if (item.attendance == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultsPage(item.id, item)),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionPage(item.id, item)),
                    );
                  }
                }
              },
              child: ListDefault(
                  name,
                  getSessionInfo2(dt, item),
                  getSmallText(item),
                  HelperCal.getTypeColor(item.type, item.availability),
                  HelperCal.getTypeImage(item.type, item.availability),
                  false)));
        }
      }
    } else {
      items.add(EmptyLabel("empty-calendar", "Nothing\nscheduled"));
    }
    return items;
  }

  getSessionInfo(item) {
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

  getSessionInfo2(dt, item) {
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
    if (item.availability && item.name != "1:1 availability") {
      label = item.name +
          "\n" +
          HelperCal.getSpecialDate(item.date) +
          " h - " +
          HelperCal.getDuration(item.duration, "hours");
    }
    return label;
  }

  // Community

  _getCommunity() {
    List<Widget> items = [];
    if (GlobalData.space.community && !GlobalData.space.restricted) {
      items.add(SubtitleLabel("Your feed"));
      if (posts.length > 3 && GlobalData.space.communityPost) {
        items.add(BtnSecondarySmall(
          label: "New Post",
          clickFn: tapPost,
        ));
        items.add(Container(height: 39));
      }
      if (posts.length != 0) {
        for (var item in posts) {
          if (item.parent == "") {
            items.add(
                //PostItem(item)
                renderPost(item));
          } else {
            items.add(ReplyItem(item));
          }
        }
      } else {
        items.add(EmptyLabel("empty-comments", "You're up\nto date"));
      }
      items.add(Container(height: 30));
      if (GlobalData.space.communityPost) {
        items.add(BtnSecondarySmall(
          label: "New Post",
          clickFn: tapPost,
        ));
      }
    } else {
      items.add(Container());
    }
    return items;
  }

  renderPost(ModelPost item) {
    if (item.date.isBefore(DateTime.now())) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        //height: 105,
        width: double.maxFinite,

        child: Card(
            elevation: 3,
            surfaceTintColor: Colors.transparent,
            color: AppColors.boxColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                            child: Avatar(getInitials(), 32, getAvatar(item),
                                14, getAvatarImage(item))),
                        Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getName(item),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  HelperCal.getSpecialDate(item.date),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            )),
                        renderEdit(item),
                      ],
                    ),
                    renderImage(item),
                    Container(
                        width: double.maxFinite,
                        margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: Text(
                          item.text,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        )),

                    // Reactions
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    tapReaction(
                                        item.reaction1, 'reaction1', item);
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction1 == ''
                                              ? "assets/images/list/react-like" +
                                                  dark +
                                                  ".svg"
                                              : "assets/images/list/react-like-active.svg"),
                                          width: 20,
                                          height: 20),
                                      Container(width: 3),
                                      Text(
                                        getNumber(item.reaction1),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: (item.reaction1 == ''
                                              ? AppColors.fieldAltColor
                                              : AppColors.textColor),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  )),
                              Container(width: 18),
                              InkWell(
                                  onTap: () {
                                    tapReaction(
                                        item.reaction2, 'reaction2', item);
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction2 == ''
                                              ? "assets/images/list/react-party" +
                                                  dark +
                                                  ".svg"
                                              : "assets/images/list/react-party-active.svg"),
                                          width: 20,
                                          height: 20),
                                      Container(width: 3),
                                      Text(
                                        getNumber(item.reaction2),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: (item.reaction2 == ''
                                              ? AppColors.fieldAltColor
                                              : AppColors.textColor),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  )),
                              Container(width: 18),
                              InkWell(
                                  onTap: () {
                                    tapReaction(
                                        item.reaction3, 'reaction3', item);
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction3 == ''
                                              ? "assets/images/list/react-smile" +
                                                  dark +
                                                  ".svg"
                                              : "assets/images/list/react-smile-active.svg"),
                                          width: 20,
                                          height: 20),
                                      Container(width: 3),
                                      Text(
                                        getNumber(item.reaction3),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: (item.reaction3 == ''
                                              ? AppColors.fieldAltColor
                                              : AppColors.textColor),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  )),
                              Container(width: 18),
                              InkWell(
                                  onTap: () {
                                    tapReaction(
                                        item.reaction4, 'reaction4', item);
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction4 == ''
                                              ? "assets/images/list/react-sad" +
                                                  dark +
                                                  ".svg"
                                              : "assets/images/list/react-sad-active.svg"),
                                          width: 20,
                                          height: 20),
                                      Container(width: 3),
                                      Text(
                                        getNumber(item.reaction4),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: (item.reaction4 == ''
                                              ? AppColors.fieldAltColor
                                              : AppColors.textColor),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          getReactions(item),
                        ]),

                    // Button
                    Container(height: 17),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () {
                              tapReply(item);
                            },
                            child: Text(
                              "REPLY",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.PrimaryColor,
                                fontFamily: "Oswald",
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ))),
                    Container(height: 10),
                  ],
                ))),
      );
    } else {
      return Container();
    }
  }

  renderImage(ModelPost item) {
    if (item.image != '') {
      getImage(item);
      return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePage("", "", item.url != "" ? item.url : item.image)));
          },
          child: Container(
              margin: EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width - 25,
              height: MediaQuery.of(context).size.width - 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.FieldColor,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    foregroundDecoration: (item.url != "" && item.url.startsWith("http")) ? BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(item.url), fit: BoxFit.cover),
                    ) : null,
                  ))));
    } else {
      return Container();
    }
  }

  getReactions(ModelPost item) {
    if (item.reaction1 == "" &&
        item.reaction2 == "" &&
        item.reaction3 == "" &&
        item.reaction4 == "") {
      return Container();
    } else {
      return (InkWell(
        onTap: () {
          tapReactions(item);
        },
        child: SvgPicture.asset("assets/images/list/reactions" + dark + ".svg",
            width: 40, height: 20),
      ));
    }
  }

  void getImage(ModelPost item) async {
    String img = "";
    final ref = FirebaseStorage.instance.ref().child(item.image);
    var url = await ref.getDownloadURL();
    item.url = url;
    if (!mounted) return;
    setState(() {
      img = url;
    });
  }

  String getAvatar(item) {
    var label = "";
    if (item.author == GlobalData.space.id) {
      label = GlobalData.space.image;
    }
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id || item.author == cl.uid) {
        label = cl.image;
      }
    }
    if (item.author == GlobalData.space.client) {
      label = GlobalUser.image;
    }
    return label;
  }

  String getAvatarImage(item) {
    var label = "";
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id || item.author == cl.uid) {
        label = cl.avatar;
      }
    }
    if (item.author == GlobalData.space.client) {
      label = GlobalUser.avatar;
    }
    return label;
  }

  getNumber(list) {
    var label = 0;
    if (list != '') {
      var arr = list.split(",");
      if (arr.length > 0) {
        label = arr.length - 1;
      }
    }
    return label.toString();
  }

  getName(ModelPost item) {
    var label = "Member";
    if (item.author == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id) {
        label = cl.name;
      }
    }
    if (item.author == GlobalData.space.client) {
      label = "You";
    }
    for (var st in GlobalData.allStaff) {
      if (item.author == st.id) {
        label = st.name;
      }
    }
    return label;
  }

  renderEdit(ModelPost item) {
    if (item.author == GlobalData.space.client) {
      return (InkWell(
          onTap: () {
            tapEdit(item);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            child: SvgPicture.asset("assets/images/nav/edit.svg",
                color: AppColors.PrimaryColor, width: 16, height: 16),
          )));
    } else {
      return Container();
    }
  }

  tapReaction(list, label, ModelPost item) {
    var tmp = '';
    var r1 = item.reaction1;
    var r2 = item.reaction2;
    var r3 = item.reaction3;
    var r4 = item.reaction4;
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + item.id);
    if (list.contains(GlobalData.space.client)) {
      var arr = list.split(",");
      arr.removeAt(0);
      arr.removeWhere((item) => item == GlobalData.space.client);
      for (var r in arr) {
        tmp += ',' + r;
      }
      list = tmp;
    } else {
      list += ',' + GlobalData.space.client;
    }
    ref.update({label: list});
    if (label == 'reaction1') {
      setState(() {
        r1 = list;
      });
    } else if (label == 'reaction2') {
      setState(() {
        r2 = list;
      });
    } else if (label == 'reaction3') {
      setState(() {
        r3 = list;
      });
    } else if (label == 'reaction4') {
      setState(() {
        r4 = list;
      });
    }
  }

  tapEdit(item) {
    print(item.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostPage(item.id, item)),
    );
  }

  tapReply(item) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostReplyPage(
              "",
              ModelPost("", "", "", DateTime.now(), "", "", "", "", "", item.id,
                  0, item.url))),
    );
  }

  tapPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostPage(
              "",
              ModelPost(
                  "", "", "", DateTime.now(), "", "", "", "", "", "", 0, ""))),
    );
  }

  tapReactions(item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReactionsPage(item.id, item)),
    );
  }

  // Actions

  _actionRows() {
    if (GlobalData.space.parent != "") {
      return Column(
        children: [
          BtnAction(
              label1: "Membership card",
              label2: "Forms & documents",
              clickFn1: tapMembershipCard,
              clickFn2: tapForms),
        ],
      );
    } else {
      if (GlobalData.space.stripe != "") {
        return Column(
          children: [
            BtnAction(
                label1: "Your membership",
                label2: "Make a payment",
                clickFn1: tapMembership,
                clickFn2: tapPayment),
            BtnAction(
                label1: "Forms & documents",
                label2: (GlobalData.invoices.length == 0
                    ? "Payment history"
                    : "Payments & Invoices"),
                clickFn1: tapForms,
                clickFn2: tapHistory),
            BtnAction(
                label1: "Payment method",
                label2: "Membership card",
                clickFn1: tapMethod,
                clickFn2: tapMembershipCard),
          ],
        );
      } else {
        return Column(
          children: [
            BtnAction(
                label1: "Your membership",
                label2: "Forms & documents",
                clickFn1: tapMembership,
                clickFn2: tapForms),
            BtnAction(
                label1: "Membership card",
                label2: (GlobalData.invoices.length == 0
                    ? "Payment history"
                    : "Payments & Invoices"),
                clickFn1: tapMembershipCard,
                clickFn2: tapHistory),
          ],
        );
      }
    }
  }

  tapActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityPage()),
    );
  }

  tapMembership() async {
    // await getSpaceBilling(GlobalData.space.id, GlobalData.space.client);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreditsPage()),
    );
  }

  static Future<void> getSpaceBilling(id, client,
      {bool hasRetried = false}) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref("clients/$id/$client").get();

      final raw = snapshot.value;

      /// 🔴 Handle empty snapshot
      if (raw == null || raw is! Map) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"step": "empty snapshot"});

        /// 🔁 Retry only once
        if (!hasRetried) {
          FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
              "", {"retry": "triggered (empty snapshot)"});

          await Future.delayed(const Duration(seconds: 2));
          return getSpaceBilling(id, client, hasRetried: true);
        }

        return;
      }

      Map data = raw;

      /// 🔴 Skip if both null (safety)
      if (data["credits"] == null && data["subscriptions"] == null) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"step": "credits & subscriptions null"});

        /// 🔁 Retry only once
        if (!hasRetried) {
          FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
              "", {"retry": "triggered (both null)"});

          await Future.delayed(const Duration(seconds: 2));
          return getSpaceBilling(id, client, hasRetried: true);
        }

        return;
      }

      /// 🔴 Partial-safe clearing (IMPORTANT)
      bool hasCredits = data["credits"] != null && data["credits"] is Map;
      bool hasSubscriptions =
          data["subscriptions"] != null && data["subscriptions"] is Map;

      if (hasCredits) {
        GlobalData.packs = [];
      }

      if (hasSubscriptions) {
        GlobalData.debits = [];
      }

      bool expires = false;
      DateTime expiry = DateTime.now();

      /// ================== CREDITS ==================
      if (hasCredits) {
        FirebaseSender.addBookingLog(
            "new_splash_loading_membership_screen", "", {"credits": "found"});

        data["credits"].forEach((index, pack) {
          try {
            if (pack == null || pack is! Map) {
              FirebaseSender.addBookingLog(
                  "new_splash_loading_membership_screen",
                  "",
                  {"credits_error": "pack null"});
              return;
            }

            expiry = DateTime.now();
            expires = false;

            if (pack["expires"] != null && pack["expires"] is int) {
              expiry =
                  DateTime.fromMillisecondsSinceEpoch(pack["expires"] * 1000);
              expires = true;
            }

            GlobalData.packs.add(ModelPack(
              index,
              (pack["group"] is bool ? pack["group"] : false),
              (pack["sessionsPaid"] is int ? pack["sessionsPaid"] : 0),
              (pack["sessionsTotal"] is int ? pack["sessionsTotal"] : 0),
              expires,
              expiry,
              (pack["account"] is String ? pack["account"] : ""),
              (pack["name"] is String ? pack["name"] : ""),
              (pack["product"] is String ? pack["product"] : ""),
            ));
          } catch (e) {
            FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
                "", {"credits_error": "$e"});
          }
        });
      } else {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"credits": "null", "hasSubscriptions": hasSubscriptions});
      }

      /// ================== SUBSCRIPTIONS ==================
      if (hasSubscriptions) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"subscriptions": "found"});

        data["subscriptions"].forEach((index, sub) {
          try {
            if (sub == null || sub is! Map) {
              FirebaseSender.addBookingLog(
                  "new_splash_loading_membership_screen",
                  "",
                  {"subscriptions_error": "sub null"});
              return;
            }

            double price =
                (sub["price"] is num) ? (sub["price"] as num).toDouble() : 0.0;

            DateTime nextDate = DateTime.now();
            if (sub["next"] is int) {
              nextDate =
                  DateTime.fromMillisecondsSinceEpoch(sub["next"] * 1000);
            }

            GlobalData.debits.add(ModelDebit(
              index,
              (sub["name"] is String ? sub["name"] : "Membership"),
              (sub["billing"] is String ? sub["billing"] : "week"),
              (sub["interval"] is int ? sub["interval"] : 1),
              price,
              nextDate,
              (sub["group"] is bool ? sub["group"] : true),
              (sub["sessions"] is int ? sub["sessions"] : 0),
              (sub["sessions11"] is int ? sub["sessions11"] : 0),
              (sub["status"] is String ? sub["status"] : "active"),
              (sub["account"] is String ? sub["account"] : ""),
              (sub["is11"] is bool ? sub["is11"] : false),
              (sub["done"] is int ? sub["done"] : 0),
              (sub["done11"] is int ? sub["done11"] : 0),
              (sub["pause"] is String ? sub["pause"] : ""),
              (sub["plan"] is String ? sub["plan"] : ""),
            ));
          } catch (e) {
            FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
                "", {"subscriptions_error": "$e"});
          }
        });
      } else {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"subscriptions": "null", "hasCredits": hasCredits});
      }

      /// ================== UI UPDATE ==================
      ConnectPage.appState.updateData();
      HomePage.appState.updateData();
      AccountPage.appState.updateData();
      ToolsPage.appState.updateData();
    } catch (e) {
      FirebaseSender.addBookingLog(
          "new_splash_loading_membership_screen", "", {"outer_error": "$e"});
    }
  }

  tapPayment() {
    if (GlobalData.products.length > 0) {
      var simple = true;
      for (var item in GlobalData.products) {
        if (item.type == "subscription") {
          simple = false;
        }
      }
      if (simple) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPaymentPage("", "", "")),
        );
      } else {
        AlertDialog alert = AlertDialog(
          title: Text("Make a payment"),
          content: Text(""),
          actions: [
            TextButton(
              child: Text("One time payment"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewPaymentPage("", "", "")),
                );
              },
            ),
            TextButton(
              child: Text("Set up a membership"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewDebitPage("")),
                );
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
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("No products available"),
        content: Text(
            "There are no products available for purchase. Please speak to your trainer."),
        actions: [
          TextButton(
            child: Text("OK"),
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
  }

  tapForms() {
    if (GlobalData.space.showForms) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FormsPage()),
      );
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("Not available"),
        content: Text("Forms are currently not available."),
        actions: [
          TextButton(
            child: Text("OK"),
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
  }

  tapHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentsPage()),
    );
  }

  tapMethod() {
    if (GlobalData.space.billing[1] == "") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CardPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CardsPage()),
      );
    }
  }

  tapMembershipCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MembershipPage()),
    );
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
