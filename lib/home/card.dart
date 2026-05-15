import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';


class CardPage extends StatefulWidget {
  static _CardPageState appState = _CardPageState();
  @override
  _CardPageState createState(){
    return CardPage.appState = new _CardPageState();
  }
}


class _CardPageState extends State<CardPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field5 = TextEditingController();
  bool updating = false;
  bool active = false;


  updateData() {
    if(this.mounted && active) {
      for(var log in GlobalData.logs) {
        if(log.type == "cardcreated") {
          //_scaffoldKey.currentState?.showSnackBar(SnackBar(
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Card successfully added"),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.GreenColor,
            )
          );
          FirebaseSender.deleteLog(log.id);
          setState(() {
            updating = false;
            active = false;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pop(context);
          });
        } else if(log.title == "cardnewerror") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error adding card"),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.RedColor,
            )
          );
          setState(() {
            updating = false;
            active = false;
          });
          FirebaseSender.deleteLog(log.id);
        }
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
    setState(() {
      active = false;
    });
  }


  createCard() {
    if(_field1.text != "" && _field2.text != "" && _field3.text != "" && _field4.text != "" && _field5.text != "") {
      setState(() {
        updating = true;
        active = true;
      });
      if(GlobalData.space.billing[0] == '') {
        HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedManageClientCardV2');
        callable.call(
          <String, dynamic>{
            "type": "customer",
            "account": GlobalData.space.stripe,
            "name": _field1.text,
            "card": _field2.text,
            "month": _field3.text,
            "year": _field4.text,
            "cvc": _field5.text,
            "clientname": GlobalUser.name,
            "email": GlobalUser.email,
            "client": GlobalData.space.client,
            "uid": GlobalData.space.id,
            "user": GlobalUser.uid,
          },
        );
      } else {
        HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedManageClientCardV2');
        callable.call(
          <String, dynamic>{
            "type": "card",
            "account": GlobalData.space.stripe,
            "name": _field1.text,
            "card": _field2.text,
            "month": _field3.text,
            "year": _field4.text,
            "cvc": _field5.text,
            "customer": GlobalData.space.billing[0],
            "client": GlobalData.space.client,
            "uid": GlobalData.space.id,
            "user": GlobalUser.uid,
          },
        );
      }
      
    } else {
      _showAlert();
    }
  }


  _showAlert() {
    String label = "";
    if(_field1.text == "") {
      label = "Name on card\n";
    }
    if(_field2.text == "") {
      label += "Card number\n";
    }
    if(_field3.text == "" || _field4.text == "") {
      label += "Card expiry\n";
    }
    if(_field5.text == "") {
      label += "Card CVV";
    }
    AlertDialog alert = AlertDialog(
    title: Text("Please review the following"),
      content: Text(label),
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: switchElements()
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  switchElements() {
    if(!updating) {
      return showForm();
    } else {
      return showOverlay();
    }
  }


  showForm() {
    return Column(
      children: <Widget>[
        Container (
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: TitleLabelBack("Add Card"),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                checkExisting(),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.name,
                    controller: _field1,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Name on card*',
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    onChanged: (text) {
                      //_updateSec(text);
                    },
                  )
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _field2,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Card number*',
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                    onChanged: (text) {
                      //_updateSec(text);
                    },
                  )
                ),

                Row(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 30),
                        width: MediaQuery.of(context).size.width / 2 - 30,       
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: AppColors.fieldColor,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _field3,
                          style: TextStyle(color: AppColors.textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Exp Month*',
                            suffixStyle: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w700),
                            labelStyle: TextStyle(color: AppColors.textColor),
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                          onChanged: (text) {
                            //_updateMin(text);
                          },
                        )),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 30),
                      width: MediaQuery.of(context).size.width / 2 - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _field4,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Exp Year*',
                          suffixStyle: TextStyle(
                              color: AppColors.TextColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        onChanged: (text) {
                          //_updateMin(text);
                        },
                      ),
                    ),
                  ],
                ),

                Container (
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _field5,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'CVV*',
                      suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                    onChanged: (text) {
                      //_updateSec(text);
                    },
                  )
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: BtnPrimary(label: "ADD CARD", clickFn: createCard,),
                )
              ]
            ),
          ),
        ),
      ],
    );
  }


  showOverlay() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Text(
        "Adding card\nThis may take a moment",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.PrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }


  checkExisting() {
    if(GlobalData.space.billing[2] != "") {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: Text(
          "Your current saved card will be deleted.",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

}