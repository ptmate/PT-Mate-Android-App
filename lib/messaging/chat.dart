import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/messaging/image.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';

class ChatPage extends StatefulWidget {
  final String id;
  final ModelChat item;
  final String type;
  const ChatPage(this.id, this.item, this.type);
  static _ChatPageState appState = _ChatPageState();
  @override
  _ChatPageState createState() {
    return ChatPage.appState = new _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelChat item = ModelChat("", "", "", [], [], []);
  String type = "";
  List images = [];
  bool update = true;
  TextEditingController _field = TextEditingController();
  var _image;
  final picker = ImagePicker();
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      type = widget.type;
    });
    List tmp = [];
    for (var msg in item.messages) {
      if (msg.image != "") {
        tmp.add({"orig": msg.image, "url": ""});
        getImage(msg.image);
      }
    }
    setState(() {
      images = tmp;
    });
    if (id != "") {
      FirebaseSender.updateChatDate(widget.id, widget.type);
    }
  }

  updateData() {
    if (this.mounted) {
      ModelChat tmp = ModelChat("", "", "", [], [], []);
      for (var chat in GlobalData.chats) {
        if (chat.id == id) {
          tmp = chat;
        }
      }
      for (var chat in GlobalData.chatsStaff) {
        if (chat.id == id) {
          tmp = chat;
        }
      }
      if (GlobalData.chat.id == id) {
        tmp = GlobalData.chat;
      }
      setState(() {
        id = id;
        item = tmp;
      });
      List tmp2 = [];
      for (var msg in item.messages) {
        if (msg.image != "") {
          tmp2.add({"orig": msg.image, "url": ""});
          getImage(msg.image);
        }
      }
      setState(() {
        images = tmp2;
      });
    }
  }

  @override
  void dispose() {
    if (update) {
      FirebaseSender.updateChatDate(id, type);
    }
    super.dispose();
  }

  sendMessage() {
    if (_field.text != "") {
      var ref = "messagingGroup/" + GlobalData.space.id + "/" + item.id;
      if (type == "pt") {
        ref = "messaging/" + GlobalData.space.id + GlobalUser.uid;
      }
      if (type == "staff") {
        ref = "messaging/" + id;
      }
      var add = "";
      if (type == "group") {
        add = " @ " + item.name;
      }
      FirebaseSender.sendChatMessage(ref, _field.text, "");
      var tokens = [GlobalData.space.token];
      for (var cl in item.clients) {
        for (var client in GlobalData.clients) {
          if (client.uid == cl.id &&
              client.uid != GlobalUser.uid &&
              client.token != "") {
            tokens.add(client.token);
          }
        }
      }
      for (var st in item.staff) {
        for (var sta in GlobalData.allStaff) {
          if (sta.id == st.id && sta.token != "") {
            tokens.add(sta.token);
          }
        }
      }
      FirebaseSender.sendPushMessage(
          "", GlobalUser.name + add, _field.text, "chat", id, tokens);
      setState(() {
        _field.text = "";
      });
    }
  }

  tapLeave() {
    AlertDialog alert = AlertDialog(
      title: Text("Leave this chat?"),
      content: Text("Are you sure you want to leave " + item.name + "?"),
      actions: [
        TextButton(
          child: Text("Leave chat"),
          onPressed: () {
            leaveChat();
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

  leaveChat() {
    setState(() {
      update = false;
    });
    FirebaseSender.leaveChat(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("You left the chat"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
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

  String getMessageImage(id) {
    var label = "";
    for (var item in images) {
      if (item["orig"] == id) {
        label = item["url"];
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
              Row(children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
                  child: TitleLabelBack("Chat"),
                  width: MediaQuery.of(context).size.width - 50,
                ),
                _getButton()
              ]),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
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
              _getCenter(),
              Container(
                  color: AppColors.bgColor,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          chooseImage();
                        },
                        child: SvgPicture.asset(
                            "assets/images/nav/form-camera.svg",
                            color: AppColors.PrimaryColor,
                            width: 45,
                            height: 45),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          width: MediaQuery.of(context).size.width - 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: AppColors.fieldColor,
                          ),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            controller: _field,
                            style: TextStyle(color: AppColors.textColor),
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type something",
                              hintStyle: TextStyle(color: AppColors.textColor),
                            ),
                          )),
                      InkWell(
                          onTap: () {
                            sendMessage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.5),
                              color: AppColors.PrimaryColor,
                            ),
                            child: SvgPicture.asset(
                                "assets/images/nav/form-send.svg",
                                width: 45,
                                height: 45),
                          ))
                    ],
                  ))
            ],
          ),
        ),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getButton() {
    if (type == "group") {
      return InkWell(
        onTap: () {
          tapLeave();
        },
        child: SvgPicture.asset("assets/images/nav/header-leave.svg",
            color: AppColors.PrimaryColor, width: 30, height: 30),
      );
    } else {
      return Container();
    }
  }

  _getCenter() {
    if (item.messages.length == 0) {
      return Expanded(
          child: Container(
              alignment: Alignment.center,
              child: EmptyMessage("empty-chats", "No messages",
                  "Note that messages will\nbe deleted after 30 days")));
    } else {
      Timer(
        Duration(seconds: 1),
        () => _controller.jumpTo(_controller.position.maxScrollExtent),
      );
      return Expanded(
          child: SingleChildScrollView(
              controller: _controller,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getContent())));
    }
  }

  _getContent() {
    List<Widget> items = [];
    for (var msg in item.messages) {
      if (msg.date.isBefore(DateTime.now())) {
        if (msg.sender == GlobalUser.uid) {
          items.add(Container(
              padding: EdgeInsets.fromLTRB(100, 30, 0, 10),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (type == "group" ? "You - " : "") +
                        HelperCal.getSpecialDate(msg.date),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              margin: EdgeInsets.only(top: 7),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: (GlobalData.space.theme == 'blue'
                                    ? AppColors.BlueColor
                                    : AppColors.PrimaryColor),
                              ),
                              child: getMessageYou(msg))))
                ],
              )));
        } else {
          var name = "";
          if (msg.name != "") {
            name = msg.name + " - ";
          }
          items.add(Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name + HelperCal.getSpecialDate(msg.date),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              margin: EdgeInsets.only(top: 7),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: AppColors.fieldColor,
                              ),
                              child: getMessage(msg))))
                ],
              )));
        }
      }
    }

    return items;
  }

  getMessage(msg) {
    if (msg.image != "") {
      final imgUrl = getMessageImage(msg.image);
      return Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImagePage(id, msg.image, "")));
            },
            child: ImageUrlResolver.safeImageNetwork(
              imgUrl,
              fallback: Container(),
              contextTag: 'ChatPageIncoming',
            ),
          ),
          Text(
            msg.text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
            ),
          )
        ],
      );
    } else {
      return SelectableText(
        msg.text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 16,
        ),
      );
    }
  }

  getMessageYou(msg) {
    if (msg.image != "") {
      final imgUrl = getMessageImage(msg.image);
      return Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImagePage(id, msg.image, "")));
            },
            child: ImageUrlResolver.safeImageNetwork(
              imgUrl,
              fallback: Container(),
              contextTag: 'ChatPageOutgoing',
            ),
          ),
          Text(
            msg.text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.WhiteColor,
              fontSize: 16,
            ),
          )
        ],
      );
    } else {
      return SelectableText(
        msg.text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.WhiteColor,
          fontSize: 16,
        ),
      );
    }
  }

  getImage(image) async {
    final target = "images/messaging/" + id + "/" + image + ".jpg";
    final url = await ImageUrlResolver.resolveUrl(target, contextTag: 'ChatPage');
    if (url != null && mounted) {
      var tmp = images;
      for (var item in tmp) {
        if (item["orig"] == image) {
          item["url"] = url;
        }
      }
      setState(() {
        images = tmp;
      });
    }
  }

  chooseImage() {
    AlertDialog alert = AlertDialog(
      title: Text("Send an image"),
      content: Text("Please choose an option"),
      actions: [
        TextButton(
          child: Text("Take a picture"),
          onPressed: () {
            pickImageCamera();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Select from library"),
          onPressed: () {
            pickImageLibrary();
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

  Future pickImageCamera() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 65,
        maxHeight: 800,
        maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var name = DateFormat("ddMMyyyy-HHmmss").format(DateTime.now());
        var fullId = "messaging/" + id;
        if (type == "group") {
          fullId = "messagingGroup/" + GlobalData.space.id + "/" + id;
        }
        FirebaseSender.sendChatMessage(fullId, "Tap to view image", name);
        FirebaseSender.uploadImage(id, _image, name);
      } else {
        print('No image selected.');
      }
    });
  }

  Future pickImageLibrary() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 65,
        maxHeight: 800,
        maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var name = DateFormat("ddMMyyyy-HHmmss").format(DateTime.now());
        var fullId = "messaging/" + id;
        if (type == "group") {
          fullId = "messagingGroup/" + GlobalData.space.id + "/" + id;
        }
        FirebaseSender.sendChatMessage(fullId, "Tap to view image", name);
        FirebaseSender.uploadImage(id, _image, name);
      } else {
        print('No image selected.');
      }
    });
  }
}
