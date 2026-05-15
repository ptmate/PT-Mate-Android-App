import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/components/card-double.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:url_launcher/url_launcher.dart';


class DocumentsPage extends StatefulWidget {
  const DocumentsPage();

  static _DocumentsPageState appState = _DocumentsPageState();
  @override
  _DocumentsPageState createState(){
    return DocumentsPage.appState = new _DocumentsPageState();
  }
}


class _DocumentsPageState extends State<DocumentsPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack(('Documents')),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: 
                    _getDocuments(),
                  
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


  _getDocuments() {
    List<Widget> items = [];
    items.add(Container(height: 30));
    for(var item in documents) {
      if(item.date.isBefore(DateTime.now())) {
        items.add(
          InkWell(
            onTap: () async {
              final ref = FirebaseStorage.instance.ref().child('/documents/'+GlobalData.space.id+'/'+item.id+'.'+item.ext);
              var url = await ref.getDownloadURL();
              print(url);
              launchUrl(Uri.parse(url));
              //Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentsPage()),);
            },
            child: CardDouble(item.name, item.ext+" file\nUploaded "+GlobalUI.dateFull.format(item.date), _getColor(item.ext), _getIcon(item.ext), false)
          ),
        );
      }
    }
    return items;
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