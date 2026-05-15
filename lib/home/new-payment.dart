import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/account/product.dart';
import 'package:ptmate_client/main.dart';

class NewPaymentPage extends StatefulWidget {
  final String id;
  final String invoice;
  final String product;
  const NewPaymentPage(this.id, this.invoice, this.product);

  static _NewPaymentPageState appState = _NewPaymentPageState();
  @override
  _NewPaymentPageState createState() {
    return NewPaymentPage.appState = new _NewPaymentPageState();
  }
}

class _NewPaymentPageState extends State<NewPaymentPage> {
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
  List<String> products = [];
  ModelProduct current =
      ModelProduct("", "", "", "", 0, 1, "group", 0, 0, "", 0, "", "", -1);
  int paidGS = 0;
  int totalGS = 0;
  String packGS = "";
  int psessionsGS = 0;
  int ppaidGS = 0;
  int paid11 = 0;
  int total11 = 0;
  String pack11 = "";
  int psessions11 = 0;
  int ppaid11 = 0;
  String account = "";
  String invoice = "";

  @override
  void initState() {
    super.initState();
    List<String> tmp1 = [GlobalData.space.client];
    List<String> tmp2 = ["Please select"];
    var acc = "";
    if (GlobalData.space.linked.length > 0) {
      acc = GlobalData.space.client;
      for (var cl in GlobalData.space.linked) {
        tmp1.add(cl.id);
      }
      tmp1.add("all");
    }
    print('--------------------');
    print(tmp1.length);
    for (var prod in GlobalData.products) {
      if (prod.type != "subscription") {
        tmp2.add(prod.id);
      }
    }
    var tmp = "Please select";
    if (widget.product != "") {
      tmp = widget.product;
      _getProduct(widget.product);
    }

    setState(() {
      id = widget.id;
      clients = tmp1;
      products = tmp2;
      account = acc;
      invoice = widget.invoice;
      product = tmp;
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
    if (this.mounted && active) {
      for (var log in GlobalData.logs2) {
        if (log.title == "chargeerror") {
          if (active) {
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
          onPressed: () {
            Navigator.of(context).pop();
          },
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
    if (this.mounted && active) {
      setState(() {
        active = false;
      });
      FirebaseSender.sendPushMessage(
          GlobalData.space.token,
          "Payment made",
          GlobalUser.name +
              " just purchased " +
              current.name +
              " for " +
              GlobalUI.curSym +
              current.price.toStringAsFixed(2) +
              ".",
          "payment",
          "payment",
          []);
      AccountPage.appState.message = "Payment successfully processed";
      AccountPage.appState.showMessage();
      HomePage.appState.message = "Payment successfully processed";
      HomePage.appState.showMessage();
      Navigator.pop(context);
    }
  }

  getPaid() {
    var tmp1 = "";
    var tmp2 = 0;
    var tmp3 = 0;
    var tmpp1 = 0;
    var tmpp2 = 0;

    var tmp11 = "";
    var tmp12 = 0;
    var tmp13 = 0;
    var tmpp11 = 0;
    var tmpp12 = 0;

    // Family only
    if (account != "") {
      for (var item in GlobalData.packs) {
        if (item.group &&
            current.stype != "11" &&
            item.account == account &&
            !item.expires) {
          tmp1 = item.id;
          tmp2 = item.done;
          tmp3 = item.paid;
        }
        if (!item.group &&
            current.stype != "group" &&
            item.account == account &&
            !item.expires) {
          tmp11 = item.id;
          tmp12 = item.done;
          tmp13 = item.paid;
        }
      }
    } else {
      // all
      if (tmp11 == "" && tmp11 == "") {
        for (var item in GlobalData.packs) {
          if (item.group &&
              current.stype != "11" &&
              !item.expires &&
              item.account == "") {
            tmp1 = item.id;
            tmp2 = item.done;
            tmp3 = item.paid;
          }
          if (!item.group &&
              current.stype != "group" &&
              !item.expires &&
              item.account == "") {
            tmp11 = item.id;
            tmp12 = item.done;
            tmp13 = item.paid;
          }
        }
      }
    }

    if (current.expires != 99999) {
      // Group
      if (tmp2 < tmp3 || tmp2 == tmp3) {
        tmp1 = "";
      } else {
        tmpp1 = tmp2 - tmp3;
        if (tmpp1 > current.sessions) {
          tmpp1 = current.sessions;
        }
        tmpp2 = tmp3 + tmpp1;
      }
      // 1:1
      if (tmp12 < tmp13 || tmp12 == tmp13) {
        tmp11 = "";
      } else {
        tmpp11 = tmp12 - tmp13;
        var ses = current.sessions;
        if (current.stype == "both") {
          ses = current.sessions11;
        }
        if (tmpp11 > ses) {
          tmpp11 = ses;
        }
        tmpp12 = tmp13 + tmpp11;
      }
    } else {
      tmp3 += current.sessions;
      if (current.stype == "11") {
        tmp13 += current.sessions;
      } else {
        tmp13 += current.sessions11;
      }
    }

    packGS = tmp1;
    totalGS = tmp2;
    paidGS = tmp3;
    psessionsGS = tmpp1;
    ppaidGS = tmpp2;

    pack11 = tmp11;
    total11 = tmp12;
    paid11 = tmp13;
    psessions11 = tmpp11;
    ppaid11 = tmpp12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: render()),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

  render() {
    if (active) {
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

  renderDetails() {
    var desc = false;
    for (var prod in GlobalData.productsAll) {
      if (prod.id == product && prod.desc != "") {
        desc = true;
      }
    }
    if (desc) {
      return BtnTertiary(
        label: 'Product info',
        clickFn: _viewDetails,
      );
    } else {
      return Container();
    }
  }

  renderForm() {
    return Container(
      color: AppColors.bgColor,
      padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child:
                TitleLabelBack((invoice == '' ? 'New Payment' : 'Pay Invoice')),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(height: 40),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    "For",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: AppColors.fieldColor,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: client,
                      underline: SizedBox(),
                      selectedItemBuilder: (BuildContext context) {
                        return clients.map((String value) {
                          return Container(
                              padding: EdgeInsets.only(top: 13),
                              child: Text(
                                _getClient(value),
                                style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ));
                        }).toList();
                      },
                      items:
                          clients.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _getClient(value),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.BgColorDark,
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      style: TextStyle(color: AppColors.textColor),
                      onChanged: (String? newValue) {
                        var acc = "";
                        if (GlobalData.space.linked.length > 0 &&
                            newValue! != "all") {
                          acc = newValue!;
                        }
                        setState(() {
                          client = newValue!;
                          account = acc;
                        });
                      },
                    )),
                Container(
                  width: double.maxFinite,
                  padding: (invoice == ""
                      ? EdgeInsets.fromLTRB(0, 0, 0, 10)
                      : EdgeInsets.fromLTRB(0, 0, 0, 0)),
                  child: Text(
                    "Product*",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: (invoice == ""
                        ? AppColors.fieldColor
                        : AppColors.bgColor),
                  ),
                  child: renderProductSelection(),
                ),
                renderDetails(),
                Container(height: 30),
                _renderPrice(),
                Container(height: 30),
                _renderCard(),
                _renderEmpty(),
                Container(height: 40),
                _getButton()
              ]),
            ),
          ),
        ],
      ),
    );
  }

  renderProductSelection() {
    if (invoice == "") {
      return (DropdownButton<String>(
        isExpanded: true,
        value: product,
        underline: SizedBox(),
        selectedItemBuilder: (BuildContext context) {
          return products.map((String value) {
            return Container(
                padding: EdgeInsets.only(top: 13),
                child: Text(
                  _getProduct(value),
                  style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ));
          }).toList();
        },
        items: products.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              _getProduct(value),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.BgColorDark,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        style: TextStyle(color: AppColors.textColor),
        onChanged: (String? newValue) {
          setState(() {
            product = newValue!;
          });
        },
      ));
    } else {
      return (Container(
          width: double.maxFinite,
          child: Text(
            _getProduct(product),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 24,
            ),
          )));
    }
  }

  _getTitle() {
    var number = "Unlimited";
    var number2 = "unlimited";
    var s = "es";
    var s2 = "s";
    var type = "class";
    if (current.stype == "11") {
      type = "1:1 session";
      s = "s";
    }
    if (current.sessions > 0) {
      number = (current.sessions).toString();
      if (current.sessions == 0) {
        s = "";
      }
    }
    if (current.sessions11 > 0) {
      number2 = (current.sessions11).toString();
      if (current.sessions11 == 0) {
        s2 = "";
      }
    }
    var label = number + " " + type + s;
    if (current.stype == "both") {
      label = number + " " + type + s + " & " + number2 + " 1:1 session" + s2;
    }
    return label;
  }

  _renderPrice() {
    if (product != "Please select") {
      String type = current.stype == "group"
          ? " Class"
          : (current.stype == "11" ? " 1:1 session" : " Class & 1:1 session");
      String title = _getTitle();
      String small = _getPackInfo();
      if (current.type == "other") {
        title = "Other";
        small = "";
      }
      return (Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            GlobalUI.curSym + current.price.toStringAsFixed(2),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 24,
            ),
          ),
          Text(
            small,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
            ),
          ),
        ],
      ));
    } else {
      return Container();
    }
  }

  _renderCard() {
    if (product != "Please select" && mode == "card" && current.price != 0) {
      if (method == "new" || GlobalData.space.billing[1] == "") {
        return Column(
          children: [
            Container(
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
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  onChanged: (text) {
                    //_updateSec(text);
                  },
                )),
            Container(
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
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16)
                  ],
                  onChanged: (text) {
                    //_updateSec(text);
                  },
                )),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2)
                      ],
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
                          color: AppColors.TextColor,
                          fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2)
                    ],
                    onChanged: (text) {
                      //_updateMin(text);
                    },
                  ),
                ),
              ],
            ),
            Container(
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
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3)
                  ],
                  onChanged: (text) {
                    //_updateSec(text);
                  },
                )),
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              height: 20,
            ),
            Text(
              "Saved card\n" +
                  GlobalData.space.billing[2] +
                  " ending " +
                  GlobalData.space.billing[3],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
            BtnTertiary(
              label: "Use another card",
              clickFn: setNew,
            )
          ],
        );
      }
    } else {
      return Container();
    }
  }

  _renderEmpty() {
    if (product != "Please select" && mode == "card" && current.price == 0) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: EmptyLabel(
            "", "This will to up\nyour client without\ncharging them."),
      );
    } else {
      return Container();
    }
  }

  _getButton() {
    if (product != "Please select") {
      if (mode == "card") {
        if (GlobalData.space.billing[1] == "") {
          return BtnPrimary(
            label: 'Make payment',
            clickFn: createCard,
          );
        } else {
          return BtnPrimary(
            label: 'Make payment',
            clickFn: _makePayment,
          );
        }
      } else if (mode == "empty") {
        return BtnPrimary(
          label: 'Log payment',
          clickFn: _logPayment,
        );
      }
    } else {
      return Container();
    }
  }

  _getClient(id) {
    var label = "Deleted or inactive client";
    for (var lnk in GlobalData.space.linked) {
      if (lnk.id == id) {
        label = lnk.name;
      }
    }
    if (id == GlobalData.space.client) {
      label = "Yourself";
    }
    if (id == "all") {
      label = "All family members";
    }
    return label;
  }

  _getProduct(id) {
    var label = "Product";
    for (var prod in GlobalData.productsAll) {
      if (prod.id == id) {
        label = prod.name;
      }
      if (prod.id == product) {
        getPaid();
        current = prod;
      }
    }
    if (id == "Please select") {
      label = "Please select";
    }
    return label;
  }

  _getPackInfo() {
    var label = "This pack doesn't expire";
    if (current.expires != 99999) {
      var edate = DateTime.now().add(Duration(days: current.expires));
      if (current.expType == 'months') {
        edate = DateTime(DateTime.now().year,
            DateTime.now().month + current.expires, DateTime.now().day);
      }
      label = "Sessions of this pack expire " + GlobalUI.dateFull.format(edate);
      if (current.stype == "group") {
        label =
            "Classes of this pack expire " + GlobalUI.dateFull.format(edate);
      }
      if (current.stype == "both") {
        label = "This pack expires " + GlobalUI.dateFull.format(edate);
      }
    }
    return label;
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

  _viewDetails() {
    var name = "Product";
    var desc = "";
    for (var prod in GlobalData.productsAll) {
      if (prod.id == product) {
        name = prod.name;
        desc = prod.desc;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductPage(name, desc)),
    );
  }

  _makePayment() {
    if (method == "new") {
      createCard();
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("Pay using saved card?"),
        content: Text("Are you sure you want to purchase " +
            current.name +
            " using the saved card?"),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
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

  _logPayment() {
    FirebaseSender.saveCashPayment(current.name, (current.price * 100).toInt());
    if (current.type != 'other') {
      if (current.expires != 99999) {
        var edate = DateTime.now().add(Duration(days: current.expires));
        if (current.expType == 'months') {
          edate = DateTime(DateTime.now().year,
              DateTime.now().month + current.expires, DateTime.now().day);
        }
        if (current.stype != "11") {
          FirebaseSender.updateClientCreditsExpires(
              packGS,
              current.sessions,
              true,
              psessionsGS,
              ppaidGS,
              edate,
              account,
              current.name,
              current.id);
        }
        if (current.stype != "group") {
          var ses = current.sessions;
          if (current.stype == "both") {
            ses = current.sessions11;
          }
          FirebaseSender.updateClientCreditsExpires(pack11, ses, false,
              psessions11, ppaid11, edate, account, current.name, current.id);
        }
      } else {
        if (current.stype != "11") {
          FirebaseSender.updateClientCredits(
              packGS, totalGS, paidGS, true, account);
        }
        if (current.stype != "group") {
          FirebaseSender.updateClientCredits(
              pack11, total11, paid11, false, account);
        }
      }
    }
    AccountPage.appState.message = "Payment successfully processed";
    AccountPage.appState.showMessage();
    Navigator.pop(context);
  }

  executePayment() {
    if (current.stock != 0) {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
      var email = "noemail@ptmate.net";
      if (GlobalUser.email != "") {
        email = GlobalUser.email;
      }
      var fee = current.price * 0.5;
      var date = GlobalUI.dateTime.format(DateTime.now());
      var name = current.name;
      if (current.name.length > 21) {
        //name = String(current.name.prefix(21))
      }
      var edate = DateTime.now().add(Duration(days: current.expires));
      if (current.expType == 'months') {
        edate = DateTime(DateTime.now().year,
            DateTime.now().month + current.expires, DateTime.now().day);
      }
      var sessions11 = current.sessions;
      if (current.stype == "both") {
        sessions11 = current.sessions11;
      }
      var expires = 0;
      if (current.expires != 99999) {
        expires = (edate.millisecondsSinceEpoch / 1000).toInt();
      }
      var currency = "aud";
      if (GlobalData.space.country == "us") {
        currency = "usd";
      }
      if (GlobalData.space.country == "nz") {
        currency = "nzd";
      }
      var stock = -1;
      if (current.stock != -1) {
        stock = current.stock - 1;
      }

      callable.call(
        <String, dynamic>{
          "account": GlobalData.space.stripe,
          "amount": (current.price * 100).toInt(),
          "fee": fee,
          "pack": name,
          "customer": GlobalData.space.customer,
          "client": GlobalData.space.client,
          "date": date,
          "currency": currency,
          "type": "pay",
          "stype": current.stype,
          "sessionsGS": current.sessions,
          "paidGS": paidGS,
          "creditsGS": packGS,
          "email": email,
          "creditseGS": packGS,
          "sessionseGS": psessionsGS,
          "paidnewGS": ppaidGS,
          "sessions11": sessions11,
          "paid11": paid11,
          "credits11": pack11,
          "creditse11": pack11,
          "sessionse11": psessions11,
          "paidnew11": ppaid11,
          "expires": expires,
          "ptype": current.type,
          "user": account,
          "invoice": invoice,
          "uid": GlobalData.space.id,
          "product": current.id,
          "stock": stock,
          "desc": current.desc,
          "payer": GlobalUser.uid
        },
      );

      setState(() {
        active = true;
      });
    } else {}
  }

  createCard() {
    if (current.stock != 0) {
      if (_field1.text != "" &&
          _field2.text != "" &&
          _field3.text != "" &&
          _field4.text != "" &&
          _field5.text != "") {
        var email = "noemail@ptmate.net";
        if (GlobalUser.email != "") {
          email = GlobalUser.email;
        }
        var fee = current.price * 0.5;
        var date = GlobalUI.dateTime.format(DateTime.now());
        var name = current.name;
        if (current.name.length > 21) {
          //name = String(current.name.prefix(21))
        }
        setState(() {
          active = true;
        });

        var edate = DateTime.now().add(Duration(days: current.expires));
        if (current.expType == 'months') {
          edate = DateTime(DateTime.now().year,
              DateTime.now().month + current.expires, DateTime.now().day);
        }
        var expires = 0;
        if (current.expires != 99999) {
          expires = (edate.millisecondsSinceEpoch / 1000).toInt();
        }

        var sessions11 = current.sessions;
        if (current.stype == "both") {
          sessions11 = current.sessions11;
        }

        var currency = "aud";
        if (GlobalData.space.country == "us") {
          currency = "usd";
        }
        if (GlobalData.space.country == "nz") {
          currency = "nzd";
        }

        var stock = -1;
        if (current.stock != -1) {
          stock = current.stock - 1;
        }

        if ((GlobalData.space.customer != "" &&
                GlobalData.space.billing[1] == "") ||
            (GlobalData.space.customer != "" &&
                GlobalData.space.billing[1] != "")) {
          if (GlobalData.space.billing[1] != "") {
            HttpsCallable callable1 = FirebaseFunctions.instance
                .httpsCallable('connectedManageClientCardV2');
            callable1.call(
              <String, dynamic>{
                "type": "delete",
                "account": GlobalData.space.stripe,
                "customer": GlobalData.space.customer,
                "card": GlobalData.space.billing[1]
              },
            );
          }
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "amount": (current.price * 100).toInt(),
              "fee": fee,
              "pack": name,
              "email": email,
              "customer": GlobalData.space.customer,
              "client": GlobalData.space.client,
              "date": date,
              "currency": currency,
              "type": "card",
              "stype": current.stype,
              "sessionsGS": current.sessions,
              "paidGS": paidGS,
              "creditsGS": packGS,
              "creditseGS": packGS,
              "sessionseGS": psessionsGS,
              "paidnewGS": ppaidGS,
              "sessions11": sessions11,
              "paid11": paid11,
              "credits11": pack11,
              "creditse11": pack11,
              "sessionse11": psessions11,
              "paidnew11": ppaid11,
              "expires": expires,
              "ptype": current.type,
              "user": account,
              "invoice": invoice,
              "uid": GlobalData.space.id,
              "product": current.id,
              "stock": stock,
              "desc": current.desc,
              "payer": GlobalUser.uid
            },
          );
        } else if (GlobalData.space.customer == "" &&
            GlobalData.space.billing[1] == "") {
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('connectedPaymentV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "amount": (current.price * 100).toInt(),
              "fee": fee,
              "pack": name,
              "email": email,
              "clientname": GlobalUser.name,
              "client": GlobalData.space.client,
              "date": date,
              "currency": currency,
              "type": "account",
              "stype": current.stype,
              "sessionsGS": current.sessions,
              "paidGS": paidGS,
              "creditsGS": packGS,
              "creditseGS": packGS,
              "sessionseGS": psessionsGS,
              "paidnewGS": ppaidGS,
              "sessions11": sessions11,
              "paid11": paid11,
              "credits11": pack11,
              "creditse11": pack11,
              "sessionse11": psessions11,
              "paidnew11": ppaid11,
              "expires": expires,
              "ptype": current.type,
              "user": account,
              "invoice": invoice,
              "uid": GlobalData.space.id,
              "product": current.id,
              "stock": stock,
              "desc": current.desc,
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
        content: Text("You can't purchase " +
            current.name +
            " because the stock is empty."),
        actions: [
          TextButton(
            child: Text("Got it"),
            onPressed: () {
              Navigator.of(context).pop();
            },
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
    if (_field1.text == "") {
      label = "Name on card\n";
    }
    if (_field2.text == "") {
      label += "Card number\n";
    }
    if (_field3.text == "" || _field4.text == "") {
      label += "Card expiry\n";
    }
    if (_field5.text == "") {
      label += "Card CVV";
    }
    AlertDialog alert = AlertDialog(
      title: Text("Please review the following"),
      content: Text(label),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
