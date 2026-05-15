import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/account/invoice.dart';
import 'package:ptmate_client/main.dart';


class PayInvoicePage extends StatefulWidget {
  final String id;
  final String invoice;
  const PayInvoicePage(this.id, this.invoice);

  static _PayInvoicePageState appState = _PayInvoicePageState();
  @override
  _PayInvoicePageState createState(){
    return PayInvoicePage.appState = new _PayInvoicePageState();
  }
}


class _PayInvoicePageState extends State<PayInvoicePage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  bool active = false;
  String mode = "card";
  String method = "old";
  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field5 = TextEditingController();
  String product = "Please select";
  String client = GlobalData.space.client;
  List<String> clients = [];
  String invoice = "";
  ModelInvoice item = ModelInvoice("", "", "", "", 0, 0, DateTime.now(), DateTime.now(), "", "", "");


  @override
  void initState() {
    super.initState();
    List<String> tmp1 = [GlobalData.space.client];
    var tmp = ModelInvoice("", "", "", "", 0, 0, DateTime.now(), DateTime.now(), "", "", "");
    for(var inv in GlobalData.invoices) {
      if(inv.id == widget.invoice) {
        tmp = inv;
      }
    }
    setState(() {
      id = widget.id;
      clients = tmp1;
      invoice = widget.invoice;
      item = tmp;
    });
  }


  @override
  void dispose() {
    super.dispose();
    setState(() {
      active = false;
    });
  }


  updateData() {
    if(this.mounted && active) {
      for(var log in GlobalData.logs2) {
        if(log.title == "chargeerror") {
          if(active) {
            setState(() {
              active = false;
            });
            showAlertError("Error processing payment", log.message);
          }
          FirebaseSender.deleteLog2(log.id);
        }
      }
    }
  }


  showAlertError(title, message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
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


  updateClient() {
    if(this.mounted && active) {
      setState(() {
        active = false;
      });
      topupClient();
    } 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: render()
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  render() {
    if(active) {
      return renderLoading();
    } else {
      return renderForm();
    }
  }


  renderLoading() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Text(
        "Connecting to Stripe\nThis may take a moment",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.PrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }


  renderForm() {
    return Container(
      color: AppColors.bgColor,
      padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: <Widget>[
          Container (
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TitleLabelBack('Pay Invoice '+item.number),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(height: 40),
                  Row(
                    children: [
                      Container (
                        width: MediaQuery.of(context).size.width-120,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Text(
                          "Item",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.AvatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container (
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width: 80,
                        child: Text(
                          "Price",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.AvatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container (
                        width: MediaQuery.of(context).size.width-120,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text(
                          getProductInfo("name"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container (
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        width: 80,
                        child: Text(
                          getProductInfo("price"),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  renderGSTLine(),
                  _renderGST(),
                  Container(
                    height: 1,
                    color: AppColors.AvatarColor,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  ),
                  Row(
                    children: [
                      Container (
                        width: MediaQuery.of(context).size.width-120,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text(
                          "Total",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container (
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        width: 80,
                        child: Text(
                          GlobalUI.curSym+item.price.toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 30),
                  _renderCard(),

                  Container(height: 40),
                  _getButton()
                  
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }


  renderGSTLine() {
    if(item.gst != 0) {
      return (
        Container(
          height: 1,
          color: AppColors.AvatarColor,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        )
      );
    } else {
      return Container();
    }
  }


  _renderGST() {
    if(item.gst != 0) {
      return 
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Row(
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
        )
      );
    } else {
      return Container();
    }
  }


  _renderCard() {
    if(mode == "card") {
      if(method == "new" || GlobalData.space.billing[1] == "") {
        return Column(
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 40, 0, 30),
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
          ],
        );
      } else {
        return Column(
          children: [
            Container(height: 20,),
            Text(
              "Saved card\n"+GlobalData.space.billing[2]+" ending "+GlobalData.space.billing[3],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
            BtnTertiary(label: "Use another card", clickFn: setNew,)
          ],
        );
      }
    } else {
      return Container();
    }
  }


  _getButton() {
    if(mode == "card") {
      if(GlobalData.space.billing[1] == "") {
        return BtnPrimary(label: 'Make payment', clickFn: createCard,);
      } else {
        return BtnPrimary(label: 'Make payment', clickFn: _makePayment,);
      }
    }
  }


  setCard() {
    setState(() {
      mode = "card";
    });
  }


  setNew() {
    setState(() {
      method = "new";
    });
  }


  _makePayment() {
    if(method == "new") {
      createCard();
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("Pay using saved card?"),
        content: Text("Are you sure you want to pay Invoice "+item.number+" using the saved card?"),
        actions: [
          TextButton(
            child: Text("Yes, pay now"),
            onPressed: () {
              executePayment();
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
  }


  executePayment() {
    var stock = false;
    var ar = item.product.split(",");
    for(var a in ar) {
      for(var prod in GlobalData.productsAll) {
        if(prod.id == a && prod.stock == 0) {
          stock = true;
        }
      }
    }
    if(!stock) {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
      var email = "noemail@ptmate.net";
      if(GlobalUser.email != "") {
          email = GlobalUser.email;
      }
      var fee = item.price*0.5;
      var date = GlobalUI.dateTime.format(DateTime.now());
      
      var currency = "aud";
      if(GlobalData.space.country == "us") {
        currency = "usd";
      }
      if(GlobalData.space.country == "nz") {
        currency = "nzd";
      }

      callable.call(
        <String, dynamic>{
          "account": GlobalData.space.stripe,
          "amount": (item.price*100).toInt(),
          "fee": fee,
          "pack": "Invoice: "+item.number,
          "customer": GlobalData.space.customer,
          "client": GlobalData.space.client,
          "date": date,
          "currency": currency,
          "type": "pay",
          "email": email,
          "ptype": "other",
          "user": item.account,
          "invoice": invoice,
          "uid": GlobalData.space.id,
          "product": "Invoice "+item.number,
          "desc": getProductInfo("desc"),
          "payer": GlobalUser.uid
        },
      );

      setState(() {
        active = true;
      });
    } else {

    }
  }


  createCard() {
    var stock = false;
    var ar = item.product.split(",");
    for(var a in ar) {
      for(var prod in GlobalData.productsAll) {
        if(prod.id == a && prod.stock == 0) {
          stock = true;
        }
      }
    }
    // add stock stuff
    if(!stock) {
      if(_field1.text != "" && _field2.text != "" && _field3.text != "" && _field4.text != "" && _field5.text != "") {
        var email = "noemail@ptmate.net";
        if(GlobalUser.email != "") {
            email = GlobalUser.email;
        }
        var fee = item.price*0.5;
        var date = GlobalUI.dateTime.format(DateTime.now());
        setState(() {
          active = true;
        });

        var currency = "aud";
        if(GlobalData.space.country == "us") {
          currency = "usd";
        }
        if(GlobalData.space.country == "nz") {
          currency = "nzd";
        }
        
        if((GlobalData.space.customer != "" && GlobalData.space.billing[1] == "") || (GlobalData.space.customer != "" && GlobalData.space.billing[1] != "")) {
          if(GlobalData.space.billing[1] != "") {
            HttpsCallable callable1 = FirebaseFunctions.instance.httpsCallable('connectedManageClientCardV2');
            callable1.call(
              <String, dynamic>{
                "type": "delete",
                "account": GlobalData.space.stripe,
                "customer": GlobalData.space.customer,
                "card": GlobalData.space.billing[1]
              },
            );
          }
          HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "amount": (item.price*100).toInt(),
              "fee": fee,
              "pack": "Invoice: "+item.number,
              "email": email,
              "customer": GlobalData.space.customer,
              "client": GlobalData.space.client,
              "date": date,
              "currency": currency,
              "type": "card",
              "ptype": "other",
              "user": item.account,
              "invoice": invoice,
              "uid": GlobalData.space.id,
              "product": "Invoice "+item.number,
              "desc": getProductInfo("desc"),
              "payer": GlobalUser.uid
            },
          );
        } else if(GlobalData.space.customer == "" && GlobalData.space.billing[1] == "") {
          HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "amount": (item.price*100).toInt(),
              "fee": fee,
              "pack": "Invoice: "+item.number,
              "email": email,
              "clientname": GlobalUser.name,
              "client": GlobalData.space.client,
              "date": date,
              "currency": currency,
              "type": "account",
              "ptype": "other",
              "user": item.account,
              "invoice": invoice,
              "uid": GlobalData.space.id,
              "product": "Invoice: "+item.number,
              "stock": stock,
              "desc": getProductInfo("desc"),
              "payer": GlobalUser.uid
            },
          );
        }
      } else {
        _showAlert();
      }
    } else {
      AlertDialog alert = AlertDialog(
      title: Text("Nothing left in stock"),
        content: Text("You can't pay for Invoice "+item.number+" because the stock is empty."),
        actions: [
          TextButton(
            child: Text("Got it"),
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


  topupClient() {
    var hasCreditGS = false;
    var hasCredit11 = false;

    var combinedGS = 0;
    var combined11 = 0;
    var account = item.account;

    var cgs = ModelInvoiceCount("", 0);
    var c11 = ModelInvoiceCount("", 0);

    var products = [];
    var ar = item.product.split(",");
    for(var a in ar) {
      for(var prod in GlobalData.products) {
        if(prod.id == a) {
          products.add(prod);
        }
      }
    }
    for(var product in products) {
      var sessions11 = product.sessions11;
      if(product.stype == "11") {
        sessions11 = product.sessions;
      }

      if(product.stock != -1) {
        if(product.stock != 0) {
          FirebaseSender.updateStock(product.id, product.stock-1);
        }
      }
      
      var expdate = DateTime.now().add(Duration(days: product.expires));
      if(product.expType == "month") {
        expdate = DateTime(DateTime.now().year, (DateTime.now().month + int.parse(product.expires)), DateTime.now().day);
      }

      if(product.type != "other") {
        if(product.expires != 0) {
          var totalGS = 0;
          var total11 = 0;
          var num = 0;
          for(var cred1 in GlobalData.packs) {
            if(cred1.group && product.stype == "both" || product.stype == "group" && cred1.done > cred1.paid && !cred1.expires) {
              if(cred1.account == account || (cred1.account == "" && account == "")) {
                totalGS = cred1.done-cred1.paid-combinedGS;
                if(totalGS > product.sessions) {
                  totalGS = product.sessions;
                }
                if(totalGS < 0) {
                  totalGS = 0;
                }
                combinedGS += totalGS;
                num = cred1.paid+combinedGS;
                cgs.cid = cred1.id;
                cgs.paid = num;
              }
            }
            if(!cred1.group && (product.stype == "both" || product.stype == "11") && cred1.done > cred1.paid && !cred1.expires) {
              if(cred1.account == account || (cred1.account == "" && account == "")) {
                total11 = cred1.done-cred1.paid-combined11;
                if(total11 > sessions11) {
                    total11 = sessions11;
                }
                if(total11 < 0) {
                  total11 = 0;
                }
                combined11 += total11;
                num = cred1.paid+combined11;
                c11.cid = cred1.id;
                c11.paid = num;
              }
            }
          }

          if(product.stype == "both" || product.stype == "group") {
            FirebaseSender.updateClientCreditsExpires("", product.sessions, true, totalGS, 0, expdate, item.account, product.name, product.id);
          }
          if(product.stype == "both" || product.stype == "11") {
            FirebaseSender.updateClientCreditsExpires("", product.sessions, false, total11, 0, expdate, item.account, product.name, product.id);
          }
      
        } else {
          // Check for existing credits
          for(var cred in GlobalData.space.packs) {
            if(cred.group && (product.stype == "both" || product.stype == "group")) {
              if(cred.account == account || (cred.account == "" && account == "")) {
                hasCreditGS = true;
                var num1 = cred.paid+product.sessions;
                FirebaseSender.updateClientPack(cred.id, num1, true, item.account);
              }
            }
            if(!cred.group && (product.stype == "both" || product.stype == "11")) {
              if(cred.account == account || (cred.account == "" && account == "")) {
                hasCredit11 = true;
                var num2 = cred.paid+sessions11;
                FirebaseSender.updateClientPack(cred.id, num2, false, item.account);
              }
            }
          }

          // Create new credit entries
          if(!hasCreditGS && (product.stype == "both" || product.stype == "group")) {
            FirebaseSender.updateClientCredits("", 0, product.sessions, true, item.account);
          }
          if(!hasCredit11 && (product.stype == "both" || product.stype == "11")) {
            FirebaseSender.updateClientCredits("", 0, sessions11, true, item.account);
          }
        }
      }
    }

    if(cgs.cid != "") {
      FirebaseSender.updateCreditSessions(cgs.cid, cgs.paid);
    }
    if(c11.cid != "") {
      FirebaseSender.updateCreditSessions(c11.cid, c11.paid);
    }

    FirebaseSender.sendPushMessage(GlobalData.space.token, "Payment made", GlobalUser.name+" just paid Invoice "+item.number+" ("+GlobalUI.curSym+item.price.toStringAsFixed(2)+").", "payment", "payment", []);
    InvoicePage.appState.message = "Payment successfully processed";
    InvoicePage.appState.showMessage();
    Navigator.pop(context);
  }

}