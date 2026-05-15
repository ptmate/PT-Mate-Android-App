import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReactionsPage extends StatefulWidget {
  final String id;
  final ModelPost item;
  const ReactionsPage(this.id, this.item);
  static _ReactionsPageState appState = _ReactionsPageState();
  @override
  _ReactionsPageState createState() {
    return ReactionsPage.appState = new _ReactionsPageState();
  }
}

class _ReactionsPageState extends State<ReactionsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String post = "";
  List reactions = [];
  ModelPost item = ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
  String img = "";
  

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      img = "";
    });
    if(GlobalData.space.image != "") {
      getImage();
    }
    configureData();
  }


  updateData() {
    configureData();
  }


  configureData() {
    var list = [];
    var ar = item.reaction1.split(",");
    for(var person in ar) {
      if(person != "") {
        list.add(ModelBest(person, getName(person), 0, 0, 0, 0, DateTime.now(), "react-like-active"));
      }
    }
    ar = item.reaction2.split(",");
    for(var person in ar) {
      if(person != "") {
        list.add(ModelBest(person, getName(person), 0, 0, 0, 0, DateTime.now(), "react-party-active"));
      }
    }
    ar = item.reaction3.split(",");
    for(var person in ar) {
      if(person != "") {
        list.add(ModelBest(person, getName(person), 0, 0, 0, 0, DateTime.now(), "react-smile-active"));
      }
    }
    ar = item.reaction4.split(",");
    for(var person in ar) {
      if(person != "") {
        list.add(ModelBest(person, getName(person), 0, 0, 0, 0, DateTime.now(), "react-sad-active"));
        
      }
    }
    if(list.length > 0) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    setState(() {
      reactions = list;
    });
  }


  getName(id) {
    var label = "Member";
    for(var client in GlobalData.clients) {
      if(client.id == id) {
        label = client.name;
      }
    }
    if(id == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    if(id == GlobalData.space.client) {
      label = "You";
    }
    return label;
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
              child: TitleLabelBack("Reactions"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getContent(),
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


  getContent() {
    List<Widget> items = [];
    for(var rea in reactions) {
      items.add(ListPerson(rea.name, getTitle(rea.type), getClientImage(rea.id), rea.type, getClientAvatar(rea.id)));
    }
    return items;
  }


  String getClientImage(id) {
    var label = "";
    for(var item in GlobalData.clients) {
      if(item.id == id) {
        label = item.image;
      }
    }
    if(id == GlobalData.space.id) {
      label = img;
    }
    return label;
  }


  String getClientAvatar(id) {
    var label = "";
    for(var item in GlobalData.clients) {
      if(item.id == id) {
        label = item.avatar;
      }
    }
    return label;
  }


  getImage() async {
    final ref = FirebaseStorage.instance.ref().child(GlobalData.space.image);
    var url = await ref.getDownloadURL();
    setState(() {
      img = url;
    });
    updateData();
  }


  String getTitle(base) {
    var label = "loved the post";
    if(base == "react-party-active") {
      label = "celebrated the post";
    }
    if(base == "react-smile-active") {
      label = "liked the post";
    }
    if(base == "react-sad-active") {
      label = "reacted with sadness";
    }
    return label;
  }

}
