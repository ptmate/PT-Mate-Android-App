import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/components/avatar-square.dart';
import 'package:ptmate_client/main.dart';


class MembershipPage extends StatefulWidget {
  @override
  _MembershipPageState createState() => _MembershipPageState();
}


class _MembershipPageState extends State<MembershipPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
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
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack(('Membership')),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: 
                    _getContent(),
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
    items.add(Container(height: 30));
    items.add(
      Card(
        elevation: 3,
        color: AppColors.boxColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          width: double.maxFinite,
          //padding: EdgeInsets.fromLTRB(20,20,20,20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/common/gradient.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Training space
              Container (
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                width: double.maxFinite,
                decoration: BoxDecoration(color: AppColors.WhiteColor.withOpacity(0.1)),
                child: Row (
                  children: <Widget> [
                    Container (
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: AvatarSquare(getInitialsSpace(), 30, GlobalData.space.image, 14),
                    ),
                    RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: AppColors.WhiteColor,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: GlobalData.space.business+"\n", style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: GlobalData.space.active ? "Active" : "Inactive"),
                      ],
                    ),
                  )
                  ]
                )
              ),
              Container(height: 20),
              // Content
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Avatar(getInitials(), 110, GlobalUser.image, 40, GlobalUser.avatar),
                    Container(height: 20),
                    Text(
                      GlobalUser.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.WhiteColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 34,
                      ),
                    ),
                    Text(
                      "Membership #: "+GlobalData.space.client+"\n\n"+GlobalUser.email+"\n"+GlobalUser.phone,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.WhiteColor,
                        fontSize: 14,
                      ),
                    ),
                    Container(height: 60),
                    Container(
                      color: AppColors.WhiteColor,
                      child: QrImageView(
                        data: GlobalData.space.client,
                        version: QrVersions.auto,
                        size: 100,
                        gapless: false,
                      ),
                    ),
                  ]
                )
              )
            ]
          )
        )
      )
    );
    return items;
  }


  String getInitials() {
    String inits = "";
    var arr = GlobalUser.name.split(" ");
    for(var item in arr) {
      if(item != "") {
        inits += item[0];
      }
    }
    if(inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }


  String getInitialsSpace() {
    String inits = "";
    String label = GlobalData.space.name;
    if(GlobalData.space.business != "" && GlobalData.space.business != null) {
      label = GlobalData.space.business;
    }
    var arr = label.split(" ");
    for(var item in arr) {
      if(item != "") {
        inits += item[0];
      }
    }
    if(inits == "") {
      inits = "-";
    }
    return inits.toUpperCase();
  }

}