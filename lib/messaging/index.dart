import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/title.dart';
import 'package:ptmate_client/components/trainingspace.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/messaging/chat.dart';

class MessagingPage extends StatefulWidget {
  static _MessagingPageState appState = _MessagingPageState();
  @override
  _MessagingPageState createState() {
    return MessagingPage.appState = new _MessagingPageState();
  }
}

class _MessagingPageState extends State<MessagingPage> {
  List chats = GlobalData.chats;
  List chatsStaff = GlobalData.chatsStaff;
  ModelChat chat = GlobalData.chat;

  @override
  void initState() {
    super.initState();
    var tmp = GlobalData.chats;
    var tmp2 = GlobalData.chatsStaff;
    if (!GlobalData.space.active || GlobalData.space.restricted) {
      tmp = [];
      tmp2 = [];
    }
    setState(() {
      chat = GlobalData.chat;
      chats = tmp;
      chatsStaff = tmp2;
    });
  }

  updateData() {
    if (this.mounted) {
      var tmp = GlobalData.chats;
      var tmp2 = GlobalData.chatsStaff;
      if (!GlobalData.space.active || GlobalData.space.restricted) {
        tmp = [];
        tmp2 = [];
      }
      setState(() {
        chat = GlobalData.chat;
        chats = tmp;
        chatsStaff = tmp2;
      });
    }
  }

  String getChatInfo(chat) {
    var label = "";
    if (chat.messages.length == 0 || chat.messages == null) {
      label = "Tap to start\na conversation";
    } else {
      var date = DateTime(2017, 9, 7, 17, 30);
      label = "Last message:\n" + HelperCal.getSpecialDate(date);
      for (var item in chat.messages) {
        if (item.date.isAfter(date) && item.date.isBefore(DateTime.now())) {
          date = item.date;
          label = "Last message:\n" + HelperCal.getSpecialDate(date);
        }
      }
    }
    return label;
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
                            children: _getContent())))
              ],
            )),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  String getInitials() {
    String inits = "";
    var arr = GlobalData.space.name.split(" ");
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

  _getContent() {
    List<Widget> items = [];
    items.add(
      TitleLabel("Messaging", false),
    );
    if (GlobalData.space.restricted) {
      items.add(EmptyMessage("empty-chats", "Unavailable",
          "Messaging is unavailable\nfor your account."));
    } else {
      items.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(chat.id, chat, "pt")),
            );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              height: 105,
              width: double.maxFinite,
              child: Card(
                  elevation: 3,
                  color: AppColors.boxColor,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 15),
                      child: Avatar(
                          getInitials(), 60, GlobalData.space.image, 24, ""),
                    ),
                    Align(alignment: Alignment.topLeft, child: getBullet(chat)),
                    Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                        width: 200,
                        child: Text(
                          GlobalData.space.name,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                          width: 200,
                          child: Text(
                            getChatInfo(chat),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 14,
                            ),
                          ))
                    ])
                  ])),
            ),
          )));
    }

    for (var item in chatsStaff) {
      items.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(item.id, item, "staff")),
            );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            height: 105,
            width: double.maxFinite,
            child: Card(
                elevation: 3,
                color: AppColors.boxColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 0, 15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: AppColors.AvatarColor,
                    ),
                    child: SvgPicture.asset("assets/images/list/user.svg",
                        width: 60, height: 60),
                  ),
                  Align(alignment: Alignment.topLeft, child: getBullet(item)),
                  Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                      width: 200,
                      child: Text(
                        item.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                        width: 200,
                        child: Text(
                          getChatInfo(item),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 14,
                          ),
                        ))
                  ]),
                ])),
          )));
    }

    for (var item in chats) {
      items.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(item.id, item, "group")),
            );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            height: 105,
            width: double.maxFinite,
            child: Card(
                elevation: 3,
                color: AppColors.boxColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 0, 15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: AppColors.AvatarColor,
                    ),
                    child: SvgPicture.asset(
                        "assets/images/list/session-group.svg",
                        width: 60,
                        height: 60),
                  ),
                  Align(alignment: Alignment.topLeft, child: getBullet(item)),
                  Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                      width: 200,
                      child: Text(
                        item.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                        width: 200,
                        child: Text(
                          getChatInfo(item),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 14,
                          ),
                        ))
                  ]),
                ])),
          )));
    }
    return items;
  }

  getBullet(chat) {
    var show = false;
    var date = DateTime.now();
    for (var client in chat.clients) {
      if (client.id == GlobalUser.uid) {
        date = client.date;
      }
    }
    for (var item in chat.messages) {
      if (item.date.isAfter(date) &&
          item.date.isBefore(DateTime.now()) &&
          item.sender != GlobalUser.uid) {
        show = true;
      }
    }
    if (show) {
      return Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.fromLTRB(0, 15, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.AlertColor,
        ),
      );
    } else {
      return Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.fromLTRB(0, 15, 5, 0),
      );
    }
  }
}
