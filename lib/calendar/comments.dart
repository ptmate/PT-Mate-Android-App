import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/sender.dart';

class CommentsPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  final String comment;
  const CommentsPage(this.id, this.item, this.comment);
  static _CommentsPageState appState = _CommentsPageState();
  @override
  _CommentsPageState createState() {
    return CommentsPage.appState = new _CommentsPageState();
  }
}

class _CommentsPageState extends State<CommentsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String comment = "";
  ModelSession item = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");
  String text = "";
  TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    var tmp = "";
    if(widget.comment != "") {
      for(var cmt in widget.item.comments) {
        if(cmt.id == widget.comment) {
          tmp = cmt.text;
        }
      }
    }
    setState(() {
      id = widget.id;
      item = widget.item;
      comment = widget.comment;
      _field.text = tmp;
    });
  }

  void _updateValue(value) {
    setState(() {
      text = value;
    });
  }

  sendComment() {
    if (text != "") {
      var msg = "Comment added";
      var name = item.name;
      if(item.availability) {
        name = "1:1 Availability";
      }
      if(comment != "") {
        msg = "Comment updated";
        FirebaseSender.updateComment(id, text, item.type, comment);
      } else {
        var tokens = [GlobalData.space.token];
        FirebaseSender.addComment(id, text, item.type);
        for(var client in GlobalData.clients) {
          if(item.clients.contains(client.id) || item.invitees.contains(client.id) || item.waiting.contains(client.id)) {
            tokens.add(client.token);
          }
        }
        FirebaseSender.sendPushMessage("", "New comment", GlobalUser.name+" commented on "+name+" "+HelperCal.getSpecialDate(item.date) +".", "session", id, tokens);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
      ));

      // Send push notifications to clients

      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: TitleLabelBack(comment == "" ? "New Comment" : "Edit Comment"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        controller: _field,
                        minLines: 1,
                        maxLines: 25,
                        autofocus: true,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your comment',
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          _updateValue(text);
                        },
                      )),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: BtnPrimary(
                        label: "SEND",
                        clickFn: sendComment,
                      ),
                    )
                  ]
                )
              )
            )
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
