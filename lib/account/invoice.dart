import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/avatar.dart';
import 'package:ptmate_client/home/pay-invoice.dart';


class InvoicePage extends StatefulWidget {
  final String id;
  const InvoicePage(this.id);
  static _InvoicePageState appState = _InvoicePageState();
  @override
  _InvoicePageState createState(){
    return InvoicePage.appState = new _InvoicePageState();
  }
}


class _InvoicePageState extends State<InvoicePage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  String message = "";
  ModelInvoice item = ModelInvoice("", "", "", "", 0, 0, DateTime.now(), DateTime.now(), "", "", "");
  


  @override
  void initState() {
    super.initState();
    ModelInvoice tmp = ModelInvoice("", "", "", "", 0, 0, DateTime.now(), DateTime.now(), "", "", "");
    for(var inv in GlobalData.invoices) {
      if(inv.id == widget.id) {
        tmp = inv;
      }
    }
    setState(() {
      id = widget.id;
      item = tmp;
    });
  }


  updateData() {
    if(this.mounted) {
      ModelInvoice tmp = ModelInvoice("", "", "", "", 0, 0, DateTime.now(), DateTime.now(), "", "", "");
      for(var inv in GlobalData.invoices) {
        if(inv.id == id) {
          tmp = inv;
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


  getInvoiceStatus() {
    var label = "Open";
    if(item.status == "paid") {
      label = "Paid";
    }
    if(item.status == "void") {
      label = "Void";
    }
    if(item.status == "open" && item.due.isBefore(DateTime.now())) {
      label = "Overdue";
    }
    return label;
  }


  getProductInfo(type) {
    var label = "";
    var ar = item.product.split(",");
    for(var a in ar) {
      for(var prod in GlobalData.productsAll) {
        if(prod.id == a && type == "name") {
            label += "\n"+prod.name;
        }
        if(prod.id == a && type == "price") {
            label += "\n"+GlobalUI.curSym+prod.price.toStringAsFixed(2);
        }
        if(prod.id == a && type == "desc") {
            label += "\n"+prod.desc;
        }
      }
    }
    if(label != "") {
      var sfinal = label.substring(1);
      label = sfinal.toString();
    }
    return label;
  }


  _tapPrimary() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PayInvoicePage("", item.id)),);
  }


  _tapSecondary() {
    var gststr1 = "";
    var gststr2 = "";
    if(item.gst != 0) {
      gststr1 = GlobalUI.curSym+item.gst.toStringAsFixed(2);
      gststr2 = "GST included";
    }
    var footer = GlobalData.space.invoice;
    if(item.notes != "") {
        footer = item.notes+"\n\n"+GlobalData.space.invoice;
    }
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendInvoiceV2');
    callable.call(
      <String, dynamic>{
        "email": GlobalUser.email,
        "name": GlobalData.space.business,
        "address": GlobalData.space.address,
        "number": item.number,
        "date": GlobalUI.dateFull.format(item.date),
        "client": GlobalUser.name,
        "phone": GlobalUser.phone,
        "product": getProductInfo("name"),
        "price": getProductInfo("price"),
        "total": GlobalUI.curSym+(item.price).toStringAsFixed(2),
        "link": "https://ptmate.me/"+GlobalData.space.id+"/admin/pay-invoice/"+item.id,
        "footer": footer,
        "due": GlobalUI.dateFull.format(item.due),
        "gst1": gststr1,
        "gst2": gststr2,
        "desc": getProductInfo("desc"),
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
              child: TitleLabelBack("Invoice"),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
              child: Text(
                getInvoiceStatus(),
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
                        "Invoice "+item.number+"\n"+GlobalUI.dateFull.format(item.date)+"\nDue "+GlobalUI.dateFull.format(item.due),
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
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      width: double.maxFinite,
                      child: Text(
                        "Bill to",
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
                        GlobalUser.name+"\n"+GlobalUser.phone,
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
                          getProductInfo("name"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          getProductInfo("price"),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ]
                    ),
                    _getDesc(),
                    _getGST(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount due",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          GlobalUI.curSym+(item.price).toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                        (item.notes == "" ? GlobalData.space.invoice : item.notes+"\n\n"+GlobalData.space.invoice),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Container(height: 40),

                    _getButton(),
                    Container(height: 20),
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


  _getGST() {
    if(item.gst != 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "GST included",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          Text(
            GlobalUI.curSym+(item.gst).toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ]
      );
    } else {
      return Container();
    }
  }


  _getDesc() {
    var label = getProductInfo("desc");
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


  _getButton() {
    if(item.status == "open") {
      return BtnPrimary(label: "Pay now", clickFn: _tapPrimary);
    } else {
      return Container();
    }
  }


  showMessage() {
    if(this.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
        )
      );
    }
  }

}