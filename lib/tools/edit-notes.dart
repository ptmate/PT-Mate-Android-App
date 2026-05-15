import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/sender.dart';


class EditNotesPage extends StatefulWidget {
  final String id;
  final ModelNote item;
  const EditNotesPage(this.id, this.item);
  static _EditNotesPageState appState = _EditNotesPageState();
  @override
  _EditNotesPageState createState() {
    return EditNotesPage.appState = new _EditNotesPageState();
  }
}

class _EditNotesPageState extends State<EditNotesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String note = "";
  ModelNote item = ModelNote("", "", DateTime.now());
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

  sendNote() {
    if (text != "") {
      var msg = "Note successfully created";
      if(item.id != "") {
        msg = "Note successfully updated";
        FirebaseSender.updateNote(id, _field.text);
      } else {
        FirebaseSender.createNote(_field.text);
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
      title: Text("Delete this note?"),
      content: Text("Are you sure you want to delete this note?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deleteNote();
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


  deleteNote() {
    FirebaseSender.deleteNote(item.id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Note successfully deleted"),
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
              child: TitleLabelBack(item.id == "" ? "Add Note" : "Edit Note"),
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
                label: (item.id == "" ? "ADD NOTE" : "UPDATE NOTE"),
                clickFn: sendNote,
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
          child: BtnTertiary(label: 'DELETE THIS NOTE', clickFn: tapDelete,)
        )
      );
    } else {
      return Container();
    }
  }
}
