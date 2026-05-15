import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/home/reactions.dart';
import 'package:ptmate_client/home/reply.dart';
import 'package:ptmate_client/main.dart';

class ReplyItem extends StatefulWidget {
  final ModelPost item;
  const ReplyItem(this.item);
  static _ReplyItemState appState = _ReplyItemState();
  @override
  _ReplyItemState createState() {
    return ReplyItem.appState = new _ReplyItemState();
  }
}

class _ReplyItemState extends State<ReplyItem> {
//class ReplyItem extends StatelessWidget {

  /*final ModelPost item;
  final String img = "";*/
  ModelPost item =
      ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
  String img = "";
  String dark = "";

  //ReplyItem(this.item) : super();
  void initState() {
    super.initState();
    if (GlobalUI.dark) {
      dark = "-dark";
    }
    setState(() {
      img = widget.item.image;
      item = widget.item;
    });
    /*if(img != "") {
      getImage();
    }*/
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

  getName() {
    var label = "Member";
    if (item.author == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id) {
        label = cl.name;
      }
    }
    /*for(var st in GlobalData.staff) {
      if(item.author == st.id) {
        label = st.name;
      }
    }*/
    if (item.author == GlobalUser.uid) {
      label = "You";
    }
    return label;
  }

  String getInitials() {
    String inits = "";
    var arr = ["", ""];
    if (item.author == GlobalData.space.id) {
      arr = GlobalData.space.name.split(" ");
    }
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id) {
        arr = cl.name.split(" ");
      }
    }
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

  String getIcon(type) {
    var label = "assets/images/list/react-" + type + ".svg";
    if (GlobalUI.dark) {
      label = "assets/images/list/react-" + type + "-dark.svg";
    }

    return label;
  }

  String getAvatar() {
    var label = "";
    if (item.author == GlobalData.space.id) {
      label = GlobalData.space.image;
    }
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id) {
        label = cl.image;
      }
    }
    if (item.author == GlobalUser.uid) {
      label = GlobalUser.image;
    }
    return label;
  }

  String getAvatarImage() {
    var label = "";
    for (var cl in GlobalData.clients) {
      if (item.author == cl.id) {
        label = cl.avatar;
      }
    }
    return label;
  }

  tapReaction(list, label) {
    var ref = FirebaseDatabase.instance.ref().child("community/" +
        GlobalData.space.id +
        "/" +
        item.parent +
        "/comments/" +
        item.id);
    if (list.contains(GlobalUser.uid)) {
      var arr = list.split(",");
      arr.removeAt(0);
      arr.removeWhere((item) => item == GlobalUser.uid);
      var tmp = '';
      for (var r in arr) {
        tmp += ',' + r;
      }
      list = tmp;
    } else {
      list += ',' + GlobalUser.uid;
    }
    ref.update({label: list});
  }

  tapEdit(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostReplyPage(item.id, item)),
    );
  }

  tapReactions(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReactionsPage(item.id, item)),
    );
  }

  renderEdit(context) {
    if (item.author == GlobalUser.uid) {
      return (InkWell(
          onTap: () {
            tapEdit(context);
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

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
        //height: 105,
        width: double.maxFinite,
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 7),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 12, 0),
                        child: Avatar(getInitials(), 24, getAvatar(), 12,
                            getAvatarImage())),
                    Container(
                        width: MediaQuery.of(context).size.width - 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getName(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
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
                    renderEdit(context),
                  ],
                ),
                Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.fromLTRB(20, 16, 0, 16),
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
                Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    tapReaction(item.reaction1, 'reaction1');
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction1 == ''
                                              ? getIcon("like")
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
                                    tapReaction(item.reaction2, 'reaction2');
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction2 == ''
                                              ? getIcon("party")
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
                                    tapReaction(item.reaction3, 'reaction3');
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction3 == ''
                                              ? getIcon("smile")
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
                                    tapReaction(item.reaction4, 'reaction4');
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          (item.reaction4 == ''
                                              ? getIcon("sad")
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
                          getReactions()
                        ])),
              ],
            )));
  }

  getReactions() {
    if (item.reaction1 == "" &&
        item.reaction2 == "" &&
        item.reaction3 == "" &&
        item.reaction4 == "") {
      return Container();
    } else {
      return (InkWell(
        onTap: () {
          tapReactions(context);
        },
        child: SvgPicture.asset("assets/images/list/reactions" + dark + ".svg",
            width: 40, height: 20),
      ));
    }
  }
}
