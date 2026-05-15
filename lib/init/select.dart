import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/card-avatar.dart';
import 'package:ptmate_client/init/connect.dart';


class SelectPage extends StatefulWidget {
  _SelectPageState createState() => _SelectPageState();
}


class _SelectPageState extends State<SelectPage> {


  @override
  void initState() {
    super.initState();
  }


  _gotoNext(item) {
    GlobalData.space = item;
    Navigator.push(context, PageRoutes.sharedAxis(()=>ConnectPage(), SharedAxisTransitionType.horizontal));
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: MediaQuery(child: Container(
          color: AppColors.bgColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 30),
            child: Column (
              children: [
                Text(
                  "Choose your\ntraining space",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 40,
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                  child: Column (
                    children: _getSpaces()
                  )
                )
                
                
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }


  _getSpaces() {
    List<Widget> items = [];
    for(var item in GlobalData.spaces) {
      String label = item.business;
      String sublabel = item.email+"\n"+item.phone;
      if(item.business == null) {
        label = item.name;
        //sublabel = item.email+"\n"+item.phone;
      }
      items.add(
        InkWell(
          onTap: () {
            _gotoNext(item);
          },
          child: CardAvatar(label, sublabel, item.image, 60, 24, "")
        )
        
      );
    }

    return items;
  }
}