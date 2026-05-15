import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/home/card.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';


class CardsPage extends StatefulWidget {
  static _CardsPageState appState = _CardsPageState();
  @override
  _CardsPageState createState(){
    return CardsPage.appState = new _CardsPageState();
  }
}


class _CardsPageState extends State<CardsPage> {

  List<ModelPayment> payments = GlobalData.payments;
  String card = "";
  var dark = "";
  bool updating = false;
  bool active = false;


  @override
  void initState() {
    super.initState();
    if(GlobalUI.dark) {
      dark = "-dark";
    }
  }


  @override
  void dispose() {
    super.dispose();
    setState(() {
      active = false;
    });
  }


  updateData() {
    if(this.mounted) {
      card = GlobalData.space.billing[1];
      if(active) {
        for (var log in GlobalData.logs) {
          if(log.type == "carddeleted") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Card successfully deleted"),
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
          } else if(log.title == "carddeleteerror") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error deleting card"),
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
              child: TitleLabelBack("Card"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getContent()
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
    items.add(
      Container(
        child: Stack(
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/common/creditcard'+dark+'.svg',
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width-40,
              height: (MediaQuery.of(context).size.height-40)*0.75,
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  _getLogo(),
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Card number".toUpperCase(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.45),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          GlobalData.space.billing[3],
                          textAlign: TextAlign.left,
                          
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  ),
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Expiry".toUpperCase(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.45),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          (GlobalData.space.billing[3] == "" ? "-" : GlobalData.space.billing[4]),
                          textAlign: TextAlign.left,
                          
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  ),
                  Container(height: 40),
                  Text(
                    "This card will be used for any purchases and membership payments.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 11,
                    ),
                  ),
                  Container(height: 60),
                  BtnPrimary(label: 'Add another card', clickFn: addCard,),
                  Container(height: 20),
                  BtnTertiary(label: 'Remove this card', clickFn: removeCard,),
                ],
              ),
            ),
          ],
        ),
      )
    );
    return items;
  }


  _getLogo() {
    if(GlobalData.space.billing[2] == "Visa") {
      return Container(
        width: MediaQuery.of(context).size.width-40,
        height: 30,
        margin: EdgeInsets.only(bottom: 30),
        child: SvgPicture.asset(
          'assets/images/list/logo-visa'+dark+'.svg',
          alignment: Alignment.topLeft,
          width: 70,
          height: 30,
        ),
      );
    } else if(GlobalData.space.billing[2] == "MasterCard") {
      return Container(
        width: MediaQuery.of(context).size.width-40,
        height: 30,
        margin: EdgeInsets.only(bottom: 30),
        child: SvgPicture.asset(
          'assets/images/list/logo-mastercard'+dark+'.svg',
          alignment: Alignment.topCenter,
          width: 70,
          height: 30,
        ),
      );
    } else {
      return Container(height: 44, margin: EdgeInsets.only(bottom: 30));
    }
  }


  addCard() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CardPage()),);
  }


  removeCard() {
    AlertDialog alert = AlertDialog(
      title: Text("Remove this card?"),
      content: Text("Are you sure you want to remove "+GlobalData.space.billing[2]+" **** "+GlobalData.space.billing[3]+" as a payment method for "+GlobalData.space.business+"?"),
      actions: [
        TextButton(
          child: Text("Remove card"),
          onPressed: () {
            deleting();
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


  deleting() {
    print("remove the card");
    setState(() {
      updating = true;
      active = true;
    });
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedManageClientCardV2');
    callable.call(
      <String, dynamic>{
        "type": "clear",
        "account": GlobalData.space.stripe,
        "customer": GlobalData.space.billing[0],
        "card": GlobalData.space.billing[1],
        "client": GlobalData.space.client,
        "trainer": GlobalData.space.id,
        "uid": GlobalUser.uid,
      },
    );
  }

}