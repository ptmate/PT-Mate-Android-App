import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/home/new-payment.dart';


class ReceiptPage extends StatefulWidget {
  final String id;
  const ReceiptPage(this.id);
  static _ReceiptPageState appState = _ReceiptPageState();
  @override
  _ReceiptPageState createState(){
    return ReceiptPage.appState = new _ReceiptPageState();
  }
}


class _ReceiptPageState extends State<ReceiptPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelPayment item = ModelPayment("", "", "", "", DateTime.now(), 0, "", "", "", DateTime.now());
  


  @override
  void initState() {
    super.initState();
    ModelPayment tmp = ModelPayment("", "", "", "", DateTime.now(), 0, "", "", "", DateTime.now());
    for(var pay in GlobalData.payments) {
      if(pay.id == widget.id) {
        tmp = pay;
      }
    }
    setState(() {
      id = widget.id;
      item = tmp;
    });
  }


  updateData() {
    if(this.mounted) {
      ModelPayment tmp = ModelPayment("", "", "", "", DateTime.now(), 0, "", "", "", DateTime.now());
      for(var pay in GlobalData.payments) {
        if(pay.id == widget.id) {
          tmp = pay;
        }
      }
      setState(() {
        item = tmp;
      });
    }
  }


  String getInitials() {
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


  getMethod() {
    var label = "Other payment method";
    if(item.type != "Cash") {
      label = item.type+" - "+item.last4;
    }
    return label;
  }


  _tapSecondary() {
    var gst1 = "";
    var gst2 = "";
    if(GlobalData.space.gst != 0) {
      gst1 = "GST included";
      var mul = (item.amount/100)/11;
      var num = (mul/10)*GlobalData.space.gst;
      gst2 = GlobalUI.curSym+(num).toStringAsFixed(2);
      if(GlobalData.space.country != "au") {
        gst1 = "VAT included";
      }
    }
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendReceiptV2');
    callable.call(
      <String, dynamic>{
        "email": GlobalUser.email,
        "name": GlobalData.space.business,
	      "address": GlobalData.space.address,
        "number": item.id,
        "method": getMethod(),
        "date": GlobalUI.dateFull.format(item.date),
        "phone": GlobalData.space.phone,
        "product": item.name,
        "price": (item.amount/100).toStringAsFixed(2),
        "businessemail": GlobalData.space.email,
        "client": GlobalUser.name,
        "gst1": gst1,
        "gst2": gst2,
        "desc": item.desc,
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Email successfully sent"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
      )
    );
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
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: TitleLabelBack("Receipt"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
              child: Text(
                item.id,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row (
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Avatar(getInitials(), 60, GlobalData.space.image, 20, "")],
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: double.maxFinite,
                      child: Text(
                        GlobalData.space.business,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      child: Text(
                        GlobalData.space.address,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      child: Text(
                        "Amount paid: "+GlobalUI.curSym+(item.amount/100).toStringAsFixed(2)+"\nPaid: "+GlobalUI.dateFull.format(item.date)+getRefund()+"\nPayment method: "+getMethod(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Container(
                      height: 1,
                      color: AppColors.fieldColor,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                    ),
                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      width: double.maxFinite,
                      child: Text(
                        "Bill to",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                    ),
                    Container (
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      child: Text(
                        GlobalUser.name+"\n"+GlobalUser.email,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    ),

                    Container(
                      height: 1,
                      color: AppColors.fieldColor,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Item",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.AvatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Price",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.AvatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getName(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          GlobalUI.curSym+(item.amount/100).toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ]
                    ),
                    _getDesc(),
                    getGST(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount due",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          GlobalUI.curSym+(item.amount/100).toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ]
                    ),

                    Container(
                      height: 1,
                      color: AppColors.fieldColor,
                      margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      child: Text(
                        "If you have any questions, please contact us at "+GlobalData.space.email+" or "+GlobalData.space.phone+".",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Container(height: 40),
                    BtnTertiary(label: "RESEND VIA EMAIL", clickFn: _tapSecondary)
                  ]
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


  getGST() {
    if(GlobalData.space.gst > 0) {
      var gst1 = "GST included";
      var mul = (item.amount/100)/11;
      var num = (mul/10)*GlobalData.space.gst;
      var gst2 = GlobalUI.curSym+(num).toStringAsFixed(2);
      if(GlobalData.space.country != "au") {
        gst1 = "VAT included";
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            gst1,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          Text(
            gst2,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ]
      );
    } else {
      return Container();
    }
  }


  _getDesc() {
    var label = '';
    if(item.desc != "") {
      label = item.desc;
    }
    if(label != '') {
      return 
        Container(
          width: double.maxFinite-100,
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          )
        );
    } else {
      return Container();
    }
  }


  getName() {
    var label = item.name;
    if(label.indexOf('Invoice') != -1 || label.indexOf('Subscription') != -1) {
      label = 'Membership';
    }
    return label;
  }


  getRefund() {
    var label = '';
    if(item.refund.isAfter(GlobalUI.dateTime.parse("01/01/1901 00:00"))) {
      label = " (Refunded "+HelperCal.getSpecialDateBasic(item.refund)+")";
    }
    return label;
  }

}