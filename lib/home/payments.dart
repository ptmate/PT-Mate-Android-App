import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/card-double.dart';
import 'package:ptmate_client/account/invoice.dart';
import 'package:ptmate_client/account/receipt.dart';
import 'package:ptmate_client/main.dart';


class PaymentsPage extends StatefulWidget {
  static _PaymentsPageState appState = _PaymentsPageState();
  @override
  _PaymentsPageState createState(){
    return PaymentsPage.appState = new _PaymentsPageState();
  }
}


class _PaymentsPageState extends State<PaymentsPage> {

  List<ModelPayment> payments = GlobalData.payments;


  @override
  void initState() {
    super.initState();
    List<ModelPayment> tmp = [];
    for(var item in GlobalData.payments) {
      tmp.add(item);
    }
    for(var item in GlobalData.invoices) {
      tmp.add(ModelPayment(item.id, "Invoice "+item.number, "invoice", getInvoiceStatus(item), item.date, item.price, "", "", "", DateTime.now()));
    }
    tmp.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      payments = tmp;
    });
  }


  updateData() {
    if(this.mounted) {
      List<ModelPayment> tmp = [];
      for(var item in GlobalData.payments) {
        tmp.add(item);
      }
      for(var item in GlobalData.invoices) {
        tmp.add(ModelPayment(item.id, "Invoice "+item.number, "invoice", getInvoiceStatus(item), item.date, item.price, "", "", "", DateTime.now()));
      }
      tmp.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        payments = tmp;
      });
    }
  }


  getInvoiceStatus(item) {
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


  getName(item) {
    var label = item.name;
    if(label.indexOf('Invoice') != -1 || label.indexOf('Subscription') != -1) {
      label = 'Membership';
    }
    return label;
  }


  getRefund(item) {
    var label = '';
    if(item.refund.isAfter(GlobalUI.dateTime.parse("01/01/1901 00:00"))) {
      label = " (Refunded "+HelperCal.getSpecialDateBasic(item.refund)+")";
    }
    return label;
  }


  _openURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
              child: TitleLabelBack("Payments"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getPayments()
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


  _getPayments() {
    List<Widget> items = [];
    if(payments.length == 0) {
      items.add(
        EmptyMessage("empty-payment", "No payments yet", "Here you'll see the list\nof all your payments")
      );
    } else {
      for(var item in payments) {
        //String label = String.fromCharCodes(new Runes('\u0024'));
        String label = GlobalUI.curSym+(item.amount/100).toStringAsFixed(2)+getRefund(item);
        String sublabel = getName(item)+"\n"+HelperCal.getSpecialDate(item.date);
        String icon = "card.svg";
        if(item.type == "Cash") {
          icon = "cash.svg";
        }
        if(item.type == "invoice") {
          icon = "invoice.svg";
          label = item.name;
          sublabel = GlobalUI.curSym+item.amount.toStringAsFixed(2)+" ("+item.last4+")\n"+HelperCal.getSpecialDate(item.date);
        }

        items.add(
          InkWell(
            onTap: () {
              if(item.type == "invoice") {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InvoicePage(item.id)),);
              } else {
                if(item.receipt != "" && !GlobalData.space.showHabits) {
                  _openURL(item.receipt);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiptPage(item.id)),);
                }
              }
              
            },
            child: CardDouble(label, sublabel, GlobalUI.gradients[1], icon, false)
          )
        );
      }
    }
    return items;
  }

}