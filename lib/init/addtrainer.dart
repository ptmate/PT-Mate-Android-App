import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:animations/animations.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/init/success.dart';



class AddTrainerPage extends StatefulWidget {
  final ModelSpace item;
  static _AddTrainerPageState appState = _AddTrainerPageState();
  const AddTrainerPage(this.item);
  //_AddTrainerPageState createState() => _AddTrainerPageState();
  _AddTrainerPageState createState(){
    return AddTrainerPage.appState = new _AddTrainerPageState();
  }
}


class _AddTrainerPageState extends State<AddTrainerPage> with TickerProviderStateMixin {


  var item;
  var clients;
  var token;
  TextEditingController _field = TextEditingController();


  @override
  void initState() {
    super.initState();
    setState(() {
      item = widget.item;
      clients = [];
      token = widget.item.token;
    });
    Connector.getAllClients(widget.item.id);
    Connector.getTrainerToken(widget.item.id);
  }


  updateData() {
    if (this.mounted) {
      setState(() {
        clients = GlobalData.trainerClients;
        token = GlobalUI.spaceToken;
      });
    }
  }


  tapConnect() {
    if(_field.text == item.pin && item.id != "" && item != null) {
      var client = "";
      for(var item in clients) {
        if(item.name == GlobalUser.email || item.image == GlobalUser.phone || item.token == GlobalUser.name) {
          client = item.id;
        }
      }
      GlobalData.spaces.add(item);
      GlobalData.space = item;
      var type = "";
      GlobalUI.isSignup = true;
      FirebaseSender.connectSpace(item, item.id, client, GlobalUser.ecName, GlobalUser.ecPhone, GlobalUser.ecType);
      if(GlobalData.space.showForms && GlobalData.space.pre != "") {
        Connector.getForms();
        type = "form";
      }
      Navigator.push(context, PageRoutes.sharedAxis(()=>SuccessPage(type), SharedAxisTransitionType.horizontal));
    } else {
      AlertDialog alert = AlertDialog(
      title: Text("Can't connect to trainer/gym"),
      content: Text("The PIN you entered is incorrect."),
      actions: [
        TextButton(
          child: Text("OK"),
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
  }


  String getName() {
    String label = item.name;
    if(item.business != null && item.business != "") {
      label = item.business;
    }
    return label;
  }


  String getInitials() {
    String inits = "";
    String label = item.name;
    if(item.business != "" && item.business != null) {
      label = item.business;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
          child: Column (
            children: [
              TitleLabelBack(""),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                width: 110,
                height: 110,
                child: Avatar(getInitials(), 110, item.image, 36, ""),
              ),
              Text(
                "Connect to\ntraining space",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 40,
                ),
              ),
              Container (
                padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                width: double.maxFinite,
                child: Text(
                  getName(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),

              Container (
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: double.maxFinite,
                child: Text(
                  "Enter their PIN to connect",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Textfields
            Container (
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _field,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Enter their PIN',
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
              )
            ),
            Text(
              "Unless stated otherwise by your coach,\nthis is your space's phone number",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            
            // Button
            Container(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
              child: BtnPrimary(label: "CONNECT", clickFn: tapConnect)
            )

            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
