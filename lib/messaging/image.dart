import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ImagePage extends StatefulWidget {
  final String image;
  final String id;
  final String post;
  static _ImagePageState appState = _ImagePageState();
  const ImagePage(this.id, this.image, this.post);
  @override
  _ImagePageState createState() {
    return ImagePage.appState = new _ImagePageState();
  }
}


class _ImagePageState extends State<ImagePage> {


  String img = "";


  @override
  void initState() {
    super.initState();
    getImage();
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: AppColors.BgColorDark,
      body: MediaQuery(child: Container(
        color: AppColors.TextColor,
        padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Column(
          children: <Widget>[
            Container (
              margin: EdgeInsets.only(bottom: 30),
              child: TitleLabelBack(""),
            ),
            Image.network(img)
          ]
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  getImage() async {
    if(widget.post == "") {
      final ref = FirebaseStorage.instance.ref().child("images/messaging/"+widget.id+"/"+widget.image+".jpg");
      var url = await ref.getDownloadURL();
      setState(() {
        img = url;
      });
    } else {
      final ref = FirebaseStorage.instance.ref().child(widget.post);
      var url = await ref.getDownloadURL();
      setState(() {
        img = url;
      });
    }
    
  }


}