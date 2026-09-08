import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/nav.dart';
import 'package:ptmate_client/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';
import 'package:image_picker/image_picker.dart';

class PostPage extends StatefulWidget {
  final String id;
  final ModelPost item;
  const PostPage(this.id, this.item);
  static _PostPageState appState = _PostPageState();
  @override
  _PostPageState createState() {
    return PostPage.appState = new _PostPageState();
  }
}

class _PostPageState extends State<PostPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String post = "";
  ModelPost item = ModelPost("", "", "", DateTime.now(), "", "", "", "", "", "", 0, "");
  String text = "";
  bool newImage = false;
  String imgOrig = "";
  String img = "";
  var _image;
  final picker = ImagePicker();
  TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      _field.text = item.text;
      imgOrig = widget.item.image;
    });
  }

  void _updateValue(value) {
    setState(() {
      text = value;
    });
  }


  sendPost() {
    if (text != "") {
      var image = "";
      var msg = "Post updated";
      if(item.id == "") {
        msg = "Post created";
        var key = FirebaseSender.createPostId();
        if(newImage) {
          image = "images/community/"+GlobalData.space.id+"/"+key+".jpg";
          FirebaseSender.updatePostImage(key, _image);
        }
        int seq = (DateTime.now().millisecondsSinceEpoch/1000).toInt()*10000;
        GlobalData.community.add(
          ModelPost(key, _field.text, image, DateTime.now(), GlobalData.space.id, "", "", "", "", "", seq, "")
        );
        FirebaseSender.createPost(key, _field.text, image);
        var tokens = [GlobalData.space.token];
        
        for(var client in GlobalData.clients) {
          if(client.token != "" && client.id != GlobalData.space.client && client.token != "") {
            tokens.add(client.token);
          }
        }
        FirebaseSender.sendPushMessage("", "New post",  GlobalUser.name+" created a new post.", "community", key, tokens);
      } else {
        if(!newImage) {
          image = item.image;
        } else {
          image = "images/community/"+GlobalData.space.id+"/"+item.id+".jpg";
        }
        item.text = _field.text;
        item.image = image;
        FirebaseSender.updatePost(item.id, _field.text, image);
        if(newImage) {
          FirebaseSender.updatePostImage(item.id, _image);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
      ));
      HomePage.appState.updateData();
      Nav.appState.move();
      HomePage.appState.posts = GlobalData.community;
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
        Nav.appState.move2();
      });
    }
  }


  tapDelete() {
    AlertDialog alert = AlertDialog(
      title: Text("Delete this post?"),
      content: Text("Are you sure you want to delete this post?"),
      actions: [
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            deletePost();
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


  deletePost() {
    FirebaseSender.deletePost(id, item.image);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Post successfully deleted"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    for(var i=0; i<GlobalData.community.length; i++) {
      if(GlobalData.community[i].id == item.id) {
        GlobalData.community.removeAt(i);
      }
    }
    HomePage.appState.posts = GlobalData.community;
    Nav.appState.move();
    Future.delayed(const Duration(milliseconds: 1000), () {
      HomePage.appState.updateData();
      Navigator.pop(context);
      Nav.appState.move2();
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
              child: TitleLabelBack(item.id == "" ? "New Post" : "Edit Post"),
            ),
            Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container (
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 60),
                    child: Container (
                      padding: EdgeInsets.all(5),
                      width: double.maxFinite-40,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldAltColor,
                      ),
                      child: InkWell(
                        onTap: () {
                          chooseImage();
                        },
                        child: getImageView(newImage, imgOrig, img, _image, 1)
                      ),
                    )
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
                    )
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: BtnPrimary(
                      label: (item.id == "" ? "CREATE POST" : "UPDATE POST"),
                      clickFn: sendPost,
                    ),
                  ),
                  getDelete()
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


  getDelete() {
    if(item.id != "") {
      return (
        Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: BtnTertiary(label: 'DELETE THIS POST', clickFn: tapDelete,)
        )
      );
    } else {
      return Container();
    }
  }


  getImageView(vn, vio, vimg, vi, num) {
    if(!newImage && imgOrig != "") {
      if (img == "") {
        getImage();
      }
      final decImage = ImageUrlResolver.safeDecorationImage(vimg, fit: BoxFit.contain);
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container (
          foregroundDecoration: decImage != null ? BoxDecoration(image: decImage) : null,
        )
      );
    } else if(!newImage && imgOrig == "") {
      return SvgPicture.asset("assets/images/common/no-image-trans.svg", width: 110, height: 110);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container (
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(vi),
              fit: BoxFit.contain),
              //fit: BoxFit.fill),
          ),
        )
      );
    }
  }


  void getImage() async {
    final target = img.isNotEmpty ? img : (item.url.isNotEmpty ? item.url : imgOrig);
    if (target.isEmpty) return;
    final url = await ImageUrlResolver.resolveUrl(target, contextTag: 'PostPage');
    if (url != null && mounted) {
      setState(() {
        img = url;
        item.url = url;
      });
    }
  }


  chooseImage() {
    AlertDialog alert = AlertDialog(
      title: Text("Add an image"),
      content: Text("Please choose an option"),
      actions: [
        TextButton(
          child: Text("Take a picture"),
          onPressed: () {
            pickImageCamera();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Select from library"),
          onPressed: () {
            pickImageLibrary();
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


  Future pickImageCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 65, maxHeight: 800, maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {
          newImage = true;
        });
      } else {
        print('No image selected.');
      }
    });
  }


  Future pickImageLibrary() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxHeight: 800, maxWidth: 800);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {
          newImage = true;
        });
      } else {
        print('No image selected.');
      }
    });
  }

}
