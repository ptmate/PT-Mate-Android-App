import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/calendar/index.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/components/button-tertiary-small.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/home/post.dart';
import 'package:ptmate_client/home/reply.dart';
import 'package:ptmate_client/home/reactions.dart';
import 'package:ptmate_client/messaging/image.dart';


class PostItem extends StatefulWidget {
  final ModelPost item;
  const PostItem(this.item);
  static _PostItemState appState = _PostItemState();
  @override
  _PostItemState createState() {
    return PostItem.appState = new _PostItemState();
  }
  //_PostItemState createState() => _PostItemState();
}


class _PostItemState extends State<PostItem> {

  ModelPost item = ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
  String img = "";
  String val = "";
  String r1 = "";
  String r2 = "";
  String r3 = "";
  String r4 = "";
  var dark = "";

  
  void initState() {
    super.initState();
    if(GlobalUI.dark) {
      dark = "-dark";
    }
    setState(() {
      img = widget.item.image;
      item = widget.item;
      r1 = widget.item.reaction1;
      r2 = widget.item.reaction2;
      r3 = widget.item.reaction3;
      r4 = widget.item.reaction4;
    });
    if(img != "") {
      getImage();
    }
  }


  updateData() {
    if (this.mounted) {
      var tmp = ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
      var timg = "";
      var tr1 = "";
      var tr2 = "";
      var tr3 = "";
      var tr4 = "";
      for(var pos in GlobalData.community) {
        if(pos.id == item.id) {
          tmp = pos;
          timg = pos.image;
          tr1 = pos.reaction1;
          tr2 = pos.reaction2;
          tr3 = pos.reaction3;
          tr4 = pos.reaction4;
        }
      }
      setState(() {
        item = tmp;
        img = timg;
        r1 = tr1;
        r2 = tr2;
        r3 = tr3;
        r4 = tr4;
      });
    }
  }


  getNumber(list) {
    var label = 0;
    if(list != '') {
      var arr = list.split(",");
      if(arr.length > 0) {
        label = arr.length-1;
      }
    }
    return label.toString();
  }


  getName() {
    var label = "";
    if(item.author == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    for(var cl in GlobalData.clients) {
      if(item.author == cl.id) {
        label = cl.name;
      }
    }
    if(item.author == GlobalData.space.client) {
      label = "You";
    }
    return label;
  }


  String getInitials() {
    String inits = "";
    var arr = ["", ""];
    if(item.author == GlobalData.space.id) {
      arr = GlobalData.space.name.split(" ");
    }
    for(var cl in GlobalData.clients) {
      if(item.author == cl.id) {
        arr = cl.name.split(" ");
      }
    }
    for(var item in arr) {
      if(item != "") {
        inits += item[0];
      }
    }
    if(inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }


  String getAvatar() {
    var label = "";
    if(item.author == GlobalData.space.id) {
      label = GlobalData.space.image;
    }
    for(var cl in GlobalData.clients) {
      if(item.author == cl.id) {
        label = cl.image;
      }
    }
    if(item.author == GlobalData.space.client) {
      label =GlobalUser.image;
    }
    return label;
  }


  String getAvatarImage() {
    var label = "";
    for(var cl in GlobalData.clients) {
      if(item.author == cl.id) {
        label = cl.avatar;
      }
    }
    if(item.author == GlobalData.space.client) {
      label =GlobalUser.avatar;
    }
    return label;
  }


  tapReaction(list, label) {
    var tmp = '';
    var ref = FirebaseDatabase.instance.ref().child("community/"+GlobalData.space.id+"/"+item.id);
    if(list.contains(GlobalData.space.client)) {
      var arr = list.split(",");
      arr.removeAt(0);
      arr.removeWhere((item) => item == GlobalData.space.client);
      for(var r in arr) {
        tmp += ','+r;
      }
      list = tmp;
    } else {
      list += ','+GlobalData.space.client;
    }
    ref.update({
      label: list
    });
    if(label == 'reaction1') {
      setState(() {
        r1 = list;
      });
    } else if(label == 'reaction2') {
      setState(() {
        r2 = list;
      });
    } else if(label == 'reaction3') {
      setState(() {
        r3 = list;
      });
    } else if(label == 'reaction4') {
      setState(() {
        r4 = list;
      });
    }
    
  }


  tapEdit(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(item.id, item)),);
  }


  tapReply(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostReplyPage("", ModelPost("", "", "", DateTime.now(), "", "", "", "", "", item.id, 0, item.url))),);
  }


  tapReactions(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReactionsPage(item.id, item)),);
  }


  renderImage() {
    if(item.image != '') {
      getImage();
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePage("", "", item.url != "" ? item.url : item.image)));
        },
        child: Container (
          margin: EdgeInsets.only(top: 15),
          width: MediaQuery.of(context).size.width-25,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: AppColors.FieldColor,
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
            child: Container (
              foregroundDecoration: (img != "" && img.startsWith("http")) ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(img),
                  fit: BoxFit.cover),
              ) : null,
            )
          )
        )
      );
    } else {
      return Container();
    }
  }


  renderEdit(context) {
    if(item.author == GlobalData.space.client) {
      return (
        InkWell(
          onTap: () {
            tapEdit(context);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            child: SvgPicture.asset("assets/images/nav/edit.svg", color: AppColors.PrimaryColor, width: 16, height: 16),
          )
        )
      );
    } else {
      return Container();
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,10),
      //height: 105,
      width: double.maxFinite,

      child: Card(
        elevation: 3,
        color: AppColors.boxColor,
        surfaceTintColor: Colors.transparent,
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
                    child: Avatar(getInitials(), 32, getAvatar(), 14, getAvatarImage())
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width-150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getName(),
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
                    )
                  ),
                  renderEdit(context),
                ],
              ),
              renderImage(),
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
                )
              ),

              // Reactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          tapReaction(r1, 'reaction1');
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset((r1 == '' ? "assets/images/list/react-like"+dark+".svg" : "assets/images/list/react-like-active.svg"), width: 20, height: 20),
                            Container(width: 3),
                            Text(
                              getNumber(r1),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: (r1 == '' ? AppColors.fieldAltColor : AppColors.textColor),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ),
                      Container(width: 18),
                      InkWell(
                        onTap: () {
                          tapReaction(r2, 'reaction2');
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset((r2 == '' ? "assets/images/list/react-party"+dark+".svg" : "assets/images/list/react-party-active.svg"), width: 20, height: 20),
                            Container(width: 3),
                            Text(
                              getNumber(r2),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: (r2 == '' ? AppColors.fieldAltColor : AppColors.textColor),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ),
                      Container(width: 18),
                      InkWell(
                        onTap: () {
                          tapReaction(r3, 'reaction3');
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset((r3 == '' ? "assets/images/list/react-smile"+dark+".svg" : "assets/images/list/react-smile-active.svg"), width: 20, height: 20),
                            Container(width: 3),
                            Text(
                              getNumber(r3),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: (r3 == '' ? AppColors.fieldAltColor : AppColors.textColor),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ),
                      Container(width: 18),
                      InkWell(
                        onTap: () {
                          tapReaction(item.reaction4, 'reaction4');
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset((r4 == '' ? "assets/images/list/react-sad"+dark+".svg" : "assets/images/list/react-sad-active.svg"), width: 20, height: 20),
                            Container(width: 3),
                            Text(
                              getNumber(r4),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: (r4 == '' ? AppColors.fieldAltColor : AppColors.textColor),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ),
                    ],
                  ),
                  getReactions(),
                ],
              ),

              // Button
              Container(height: 17),
              Material (
                color: Colors.transparent,
                child: InkWell (
                    onTap: () {
                      tapReply(context);
                    },
                    child: Text (
                      "REPLY",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.PrimaryColor,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    )
                    
                  )
              ),
              Container(height: 10),
            ],
          )
        )
      ),
    );
  }


  getReactions() {
    if(item.reaction1 == "" && item.reaction2 == "" && item.reaction3 == "" && item.reaction4 == "") {
      return Container();
    } else {
      return (
        InkWell(
          onTap: () {
            tapReactions(context);
          },
          child: SvgPicture.asset("assets/images/list/reactions"+dark+".svg", width: 40, height: 20),
        )
      );
    }
  }


  void getImage() async {
    final ref = FirebaseStorage.instance.ref().child(item.image);
    var url = await ref.getDownloadURL();
    setState(() {
      img = url;
    });
  }
}
