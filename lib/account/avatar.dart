import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/account/update.dart';
import 'package:ptmate_client/init/register.dart';
import 'package:ptmate_client/main.dart';


class AvatarPage extends StatefulWidget {
  final String origin;
  const AvatarPage(this.origin);
  static _AvatarPageState appState = _AvatarPageState();
  @override
  _AvatarPageState createState() {
    return AvatarPage.appState = new _AvatarPageState();
  }
}


class _AvatarPageState extends State<AvatarPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool updating = false;
  bool active = false;
  String origin = "register";


  @override
  void dispose() {
    super.dispose();
    setState(() {
      active = false;
      origin = widget.origin;
    });
  }


  selectImage(item) {
    GlobalUser.avatar = item;
    if(origin == "register") {
      RegisterPage.appState.newImage = true;
      RegisterPage.appState.avatar = item;
      RegisterPage.appState.updateAvatar();
      Navigator.of(context).pop();
    } else {
      UpdatePage.appState.newImage = true;
      UpdatePage.appState.img = "";
      UpdatePage.appState.avatar = item;
      UpdatePage.appState.updateAvatar();
      Navigator.of(context).pop();
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
              padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
              child: TitleLabelBack("Select image"),
            ),
            Expanded(
              child: GridView.count(
                primary: false,
                padding: EdgeInsets.all(0),
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                crossAxisCount: 3,
                children: getItems(),
              )
            )
          ]
        )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    ));
  }


  getItems() {
    List<Widget> items = [];
    //var px = 0;
    //var py = 0;
    for(var item in GlobalUI.avatars) {
      items.add(
        InkWell (
          onTap: () {
            selectImage(item);
          },
          child: Image.asset("assets/images/avatar/avatar-"+item+".jpg"),
        )
      );
    }
    return items;
  }

}