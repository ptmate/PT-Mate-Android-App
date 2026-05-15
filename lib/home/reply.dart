import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/sender.dart';


class PostReplyPage extends StatefulWidget {
  final String id;
  final ModelPost item;
  const PostReplyPage(this.id, this.item);
  static _PostReplyPageState appState = _PostReplyPageState();
  @override
  _PostReplyPageState createState() {
    return PostReplyPage.appState = new _PostReplyPageState();
  }
}

class _PostReplyPageState extends State<PostReplyPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String post = "";
  ModelPost item = ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
  String text = "";
  TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      _field.text = item.text;
    });
  }

  void _updateValue(value) {
    setState(() {
      text = value;
    });
  }

  sendPost() {
    if (text != "") {
      var msg = "You replied";
      if(item.id != "") {
        msg = "Reply updated";
        FirebaseSender.updateReply(id, item.parent, _field.text);
      } else {
        FirebaseSender.createReply(item.parent, _field.text);
        var tokens = [GlobalData.space.token];
        for(var client in GlobalData.clients) {
          if(client.token != "" && client.id != GlobalData.space.client && client.token != "") {
            tokens.add(client.token);
          }
        }
        FirebaseSender.sendPushMessage("", "New reply to a post",  GlobalUser.name+" just replied to a post.", "community", item.parent, tokens);
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


  tapDelete() {
    AlertDialog alert = AlertDialog(
      title: Text("Delete this reply?"),
      content: Text("Are you sure you want to delete this reply?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deleteReply();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () { Navigator.of(context).pop(); },
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


  deleteReply() {
    FirebaseSender.deleteReply(id, item.image);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Reply successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
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
              child: TitleLabelBack(item.id == "" ? "New Reply" : "Edit Reply"),
            ),
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
                    labelText: 'Text',
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
                label: (item.id == "" ? "SEND" : "UPDATE REPLY"),
                clickFn: sendPost,
              ),
            ),
            getDelete()
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  getDelete() {
    if(item.id != "") {
      return (
        Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: BtnTertiary(label: 'DELETE THIS REPLY', clickFn: tapDelete,)
        )
      );
    } else {
      return Container();
    }
  }
}
