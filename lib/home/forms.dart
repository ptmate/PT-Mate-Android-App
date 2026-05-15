import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/variables.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/card-double.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/tools/form.dart';
import 'package:ptmate_client/main.dart';


class FormsPage extends StatefulWidget {
  static _FormsPageState appState = _FormsPageState();
  @override
  _FormsPageState createState(){
    return FormsPage.appState = new _FormsPageState();
  }
}


class _FormsPageState extends State<FormsPage> {

  List documents = GlobalData.documents;


  @override
  void initState() {
    super.initState();
    setState(() {
      documents = GlobalData.documents;
    });
  }


  updateData() {
    if(this.mounted) {
    setState(() {
      documents = GlobalData.documents;
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
              child: TitleLabelBack("Forms & Docs"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getForms()
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


  _getForms() {
    List<Widget> items = [];
    if(GlobalData.space.forms.length > 0) {
      items.add(SubtitleLabel("Forms"));
      for(var form in GlobalData.space.forms) {
        items.add(
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FormPage(form.id, form)),);
            },
            child: CardDouble(form.name, _getLines(form, "line1")+"\n"+_getLines(form, "line2"), GlobalUI.gradients[0], "form.svg", false)
          ),
        );
      }
    }
    if(documents.length > 0) {
      items.add(SubtitleLabel("Public documents"));
      for(var item in documents) {
        if(item.date.isBefore(DateTime.now())) {
          items.add(
            InkWell(
              onTap: () async {
                final ref = FirebaseStorage.instance.ref().child('/documents/'+GlobalData.space.id+'/'+item.id+'.'+item.ext);
                var url = await ref.getDownloadURL();
                launchUrl(Uri.parse(url));
                //Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentsPage()),);
              },
              child: CardDouble(item.name, item.ext+" file\nUploaded "+GlobalUI.dateFull.format(item.date), _getColor(item.ext), _getIcon(item.ext), false)
            ),
          );
        }
      }
    }
    if(GlobalData.space.forms.length == 0 && documents.length == 0) {
      items.add(
        EmptyMessage("empty-forms", "No forms or documents", "You don't have any forms\nto fill out yet.")
      );
    }
    return items;
  }


  _getLines(form, line) {
    var label = "Form";
    if(form.pre && line == "line1") {
      label = "Pre Exercise Questionnaire";
    }
    if(line == "line2") {
      label = "Not completed yet";
      if(form.date.isAfter(DateTime(2020))) {
        label = "Completed "+HelperCal.getSpecialDateYear(form.date);
      }
    }
    return label;
  }


  _getColor(ext) {
    var color = GlobalUI.gradients[0];
    if(ext == "pdf") {
      color = "-red";
    }
    if(ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "gif") {
      color = GlobalUI.gradients[3];
    }
    if(ext == "doc" || ext == "docx") {
      color = GlobalUI.gradients[1];
    }
    return color;
  }


  _getIcon(ext) {
    var icon = "documents.svg";
    if(ext == "pdf") {
      icon = "doc-pdf.svg";
    }
    if(ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "gif") {
      icon = "doc-image.svg";
    }
    if(ext == "doc" || ext == "docx") {
      icon = "doc-doc.svg";
    }
    return icon;
  }

}