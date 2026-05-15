import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/tools/edit-notes.dart';
import 'package:ptmate_client/main.dart';


class NotesPage extends StatefulWidget {
  static _NotesPageState appState = _NotesPageState();
  @override
  _NotesPageState createState(){
    return NotesPage.appState = new _NotesPageState();
  }
}


class _NotesPageState extends State<NotesPage> {

  List<ModelNote> notes = [];


  @override
  void initState() {
    super.initState();
    List<ModelNote> tmp = [];
    for(var item in GlobalData.notes) {
      tmp.add(item);
    }
    tmp.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      notes = tmp;
    });
  }


  updateData() {
    if(this.mounted) {
      List<ModelNote> tmp = [];
      for(var item in GlobalData.notes) {
        tmp.add(item);
      }
      tmp.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        notes = tmp;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack("Private notes"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getContent()
                ),
              ),
            ),
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getContent() {
    List<Widget> items = [];
    if(notes.length == 0) {
      items.add(
        EmptyMessage("empty-forms", "No notes yet", "Here you can store private\nand personal notes")
      );
    } else {
      for(var note in GlobalData.notes) {
        items.add(
          Container(
            width: MediaQuery.of(context).size.width-40,
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width-120,
                  child: Text(
                    HelperCal.getSpecialDateYear(note.date),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditNotesPage(note.id, note)),);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: SvgPicture.asset("assets/images/nav/edit.svg", color: AppColors.PrimaryColor, width: 24, height: 24),
                  )
                ),
                Container(width: 10),
                InkWell(
                  onTap: () {
                    tapMessage(note, context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: SvgPicture.asset("assets/images/common/send.svg", color: AppColors.PrimaryColor, width: 24, height: 24),
                  )
                )
              ]
            ),
          ),
        );
        items.add(
          Container(
            width: MediaQuery.of(context).size.width-40,
            margin: EdgeInsets.only(bottom: 40),
            child: Text(
              note.text,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          )
        );
      }
      items.add(Container(height: 10));
    }
    items.add(
      BtnSecondarySmall(label: "Add a note", clickFn: tapAdd,),
    );
    return items;
  }


  tapAdd() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditNotesPage("", ModelNote("", "", DateTime.now()))),);
  }


  tapMessage(item, context) {
    List<Widget> actions = [];
    actions.add(
      TextButton(
        child: Text(GlobalData.space.name),
        onPressed: () {
          sendMessage(item, GlobalData.chat, "pt");
          Navigator.of(context).pop();
        },
      ),
    );
    for(var act in GlobalData.chatsStaff) {
      actions.add(
        TextButton(
          child: Text(act.name),
          onPressed: () {
          sendMessage(item, act, "staff");
          Navigator.of(context).pop();
        },
        ),
      );
    }
    for(var act in GlobalData.chats) {
      actions.add(
        TextButton(
          child: Text(act.name),
          onPressed: () {
            sendMessage(item, act, "group");
            Navigator.of(context).pop();
          },
        ),
      );
    }
    actions.add(
      TextButton(
        child: Text("Cancel"),
        onPressed: () { Navigator.of(context).pop(); },
      )
    );
    AlertDialog alert = AlertDialog(
      title: Text("Send note"),
      content: Text("Send this note via in-app messaging to"),
      actions: actions,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  sendMessage(item, chat, type) {
    var ref = "messagingGroup/"+GlobalData.space.id+"/"+chat.id;
    if(type == "pt") {
      ref = "messaging/"+GlobalData.space.id+GlobalUser.uid;
    }
    if(type == "staff") {
      ref = "messaging/"+chat.id;
    }
    var add = "";
    if(type == "group") {
      add = " @ "+chat.name;
    }
    FirebaseSender.sendChatMessage(ref, item.text, "");
    var tokens = [GlobalData.space.token];
    for(var cl in chat.clients) {
      for(var client in GlobalData.clients) {
        if(client.uid == cl.id && client.uid != GlobalUser.uid && client.token != "") {
          tokens.add(client.token);
        }
      }
    }
    for(var st in chat.staff) {
      for(var sta in GlobalData.allStaff) {
        if(sta.id == st.id && sta.token != "") {
          tokens.add(sta.token);
        }
      }
    }
    FirebaseSender.sendPushMessage("", GlobalUser.name+add, item.text, "chat", chat.id, tokens);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Note successfully sent"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));
  }

}