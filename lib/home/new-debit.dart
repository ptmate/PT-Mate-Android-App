import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/main.dart';


class NewDebitPage extends StatefulWidget {
  final String id;
  const NewDebitPage(this.id);

  static _NewDebitPageState appState = _NewDebitPageState();
  @override
  _NewDebitPageState createState(){
    return NewDebitPage.appState = new _NewDebitPageState();
  }
}


class _NewDebitPageState extends State<NewDebitPage> {


  //final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  bool active = false;
  String method = "old";
  String cancels = "notset";
  TextEditingController _field1 = TextEditingController();
  TextEditingController _field2 = TextEditingController();
  TextEditingController _field3 = TextEditingController();
  TextEditingController _field4 = TextEditingController();
  TextEditingController _field5 = TextEditingController();
  TextEditingController _fieldDate = TextEditingController();
  TextEditingController _fieldDateEnd = TextEditingController();
  String client = GlobalData.space.client;
  String product = "Please select";
  List<String> clients = [];
  List<String> products = [];
  ModelProduct current = ModelProduct("", "", "", "", 0, 1, "", 0, 0, "", 0, "", "", -1);
  ModelClient currentc = ModelClient("", "", "", "", "", "", false, "");
  String account = "";


  @override
  void initState() {
    super.initState();
    List<String> tmp1 = [GlobalData.space.client];
    List<String> tmp2 = ["Please select"];
    String tmp3 = GlobalData.space.client;
    var acc = "";
    _fieldDate.text = GlobalUI.dateFull.format(DateTime.now());
    ModelClient tmp4 = ModelClient("", "", "", "", "", "", false, "");
    if(GlobalData.space.linked.length > 0) {
      acc = GlobalData.space.client;
      for(var cl in GlobalData.space.linked) {
        tmp1.add(cl.id);
      }
      tmp1.add("all");
    }
    for(var prod in GlobalData.products) {
      if(prod.type == "subscription") {
        tmp2.add(prod.id);
      }
    }
    if(widget.id != "") {
      tmp3 = widget.id;
      for(var cl in GlobalData.clients) {
        if(cl.id == widget.id) {
          tmp4 = cl;
        }
      }
    }
    setState(() {
      id = widget.id;
      clients = tmp1;
      products = tmp2;
      client = tmp3;
      currentc = tmp4;
      account = acc;
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
        if(log.title == "debiterror" || log.title == "debitcancelerror") {
          if(active) {
            setState(() {
              active = false;
            });
            showAlertError("Error creating membership", log.message);
          }
          FirebaseSender.deleteLog(log.id);
        }
      }
      for(var log in GlobalData.logs2) {
        if(log.title == "debiterror" || log.title == "debitcancelerror") {
          if(active) {
            setState(() {
              active = false;
            });
            showAlertError("Error creating membership", log.message);
          }
          FirebaseSender.deleteLog(log.id);
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
      FirebaseSender.sendPushMessage(GlobalData.space.token, "Membership set up", GlobalUser.name+" just set up "+current.name+".", "payment", "payment", []);
      AccountPage.appState.message = "Membership set up";
      AccountPage.appState.showMessage();
      Navigator.pop(context);
    } 
  }


  _selectDate(BuildContext context) async {
    var date = DateFormat("dd MMMM yyyy");
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse(_fieldDate.text),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)));
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          _fieldDate.text = date.format(picked);
        });
      }
  }


  _selectDateEnd(BuildContext context) async {
    var date = DateFormat("dd/MM/yyyy");
    var ini = _fieldDateEnd.text;
    if(ini == '') {
      ini = date.format(DateTime.now());
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse(ini),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 700)));
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          cancels = "set";
          _fieldDateEnd.text = date.format(picked);
        });
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
            child: TitleLabelBack(('New Membership')),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(height: 40),

                  Container (
                    width: double.maxFinite,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      "For".toUpperCase(),
                      
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.45),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container (
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
                              style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
                            )
                          );
                        }).toList();
                      },
                      items: clients
                          .map<DropdownMenuItem<String>>((String value) {
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
                        if(GlobalData.space.linked.length > 0 && newValue! != "all") {
                          acc = newValue!;
                        }
                        setState(() {
                          client = newValue!;
                          account = acc;
                        });
                      },
                    )
                  ),

                  Container (
                    width: double.maxFinite,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      "Product*".toUpperCase(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.45),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container (
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: AppColors.fieldColor,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: product,
                      underline: SizedBox(),
                      selectedItemBuilder: (BuildContext context) {
                        return products.map((String value) {
                          return Container(
                            padding: EdgeInsets.only(top: 13),
                              child: Text(
                              _getProduct(value),
                              style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
                            )
                          );
                        }).toList();
                      },
                      items: products
                          .map<DropdownMenuItem<String>>((String value) {
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
                          setState(() {
                            product = newValue!;
                          });
                        });
                      },
                    )
                  ),
                  
                  Container(height: 10),
                  _renderDate(),
                  Container(height: 10),
                  _renderPrice(),
                  Container(height: 20),
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


  _renderPrice() {
    if(product != "Please select") {
      String title = _getPackInfo();
      String small = "Paid "+current.billing+"ly";
      if(current.interval > 1) {
        small = "Paid every "+current.interval.toString()+" "+current.billing+"s";
      }
      if(GlobalData.space.linked.length > 0) {
        small = "Assigned to all family members\nPaid "+current.billing+"ly";
        if(account != "") {
          if(account == client) {
            small = "Assigned to yourself\nPaid "+current.billing+"ly";
          } else if(account != "" && account != client) {
            for(var lk in GlobalData.space.linked) {
              if(lk == account) {
                small = "Assigned to "+_getFamilyName(lk)+"\nPaid "+current.billing+"ly";
              }
            }
          }
        }
      }
      return (
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor.withOpacity(0.45),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            Text(
              GlobalUI.curSym+current.price.toStringAsFixed(2),
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
        )
      );
    } else {
      return Container();
    }
  }


  _renderDate() {
    if(product != "Please select") {
      return Container (
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: AppColors.fieldColor,
        ),
        child: GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              keyboardType: TextInputType.name,
              controller: _fieldDate,
              style: TextStyle(color: AppColors.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'First charge*',
                suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                labelStyle: TextStyle(color: AppColors.textColor),
              ),
              onChanged: (text) {
                //_updateSec(text);
              },
            )
          )
        )
      );
    } else {
      return Container();
    }
  }


  _renderCard() {
    if(product != "Please select") {
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
    if(product != "Please select") {
      if(GlobalData.space.billing[0] != "" && GlobalData.space.billing[1] != "") {
        return BtnPrimary(label: 'Set up membership', clickFn: _makePayment,);
      } else {
        return BtnPrimary(label: 'Set up membership', clickFn: createCard,);
      }
      
    } else {
      return Container();
    }
  }


  _getClient(id) {
    var label = "All family members";
    for(var cl in GlobalData.clients) {
      if(cl.id == id) {
        label = cl.name;
      }
      if(cl.id == client) {
        /*setState(() {
          currentc = cl;
        });*/
        currentc = cl;
      }
    }
    if(id == GlobalData.space.client) {
      label = "Yourself";
    }
    return label;
  }


  _getProduct(id) {
    var label = "Product";
    for(var prod in GlobalData.products) {
      if(prod.id == id) {
        label = prod.name;
      }
      if(prod.id == product) {
        /*setState(() {
          current = prod;
        });*/
        current = prod;
      }
    }
    if(id == "Please select") {
      label = "Please select";
    }
    return label;
  }


  _getPackInfo() {
    var number = "Unlimited";
    var number2 = "unlimited";
    var s = "es";
    var s2 = "s";
    var type = "class";
    if(current.stype == "11") { type = "1:1 session"; s = "s"; }
    if(current.sessions > 0) {
      number = (current.sessions).toString();
      if(current.sessions == 0) { s = ""; }
    }
    if(current.sessions11 > 0) {
      number2 = (current.sessions11).toString();
      if(current.sessions11 == 0) { s2 = ""; }
    }
    var label = number+" "+type+s;
    if(current.stype == "both") {
      label = number+" "+type+s+" & "+number2+" 1:1 session"+s2;
    }
    return label;
  }


  setNew() {
    setState(() {
      method = "new";
    });
  }


  _getFamilyName(id) {
    var label = "";
    for(var cl in GlobalData.clients) {
      if(cl.id == id) {
        label = cl.name;
      }
    }
    return label;
  }


  _makePayment() {
    if(current.stock != 0) {
      if(method == "new") {
        createCard();
      } else {
        AlertDialog alert = AlertDialog(
          title: Text("Membership using saved card?"),
          content: Text("Are you sure you want to set up a membership using your saved card?"),
          actions: [
            TextButton(
              child: Text("Yes, create it now"),
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
  }


  _logPayment() {
    
  }


  executePayment() {
    
    var group = "no";
    var sessions11 = 0;
    if(current.stype == "group") { group = "yes"; }
    if(current.stype == "both") {
      group = "both";
      sessions11 = current.sessions11;
    }

    var stock = -1;
    if(current.stock != -1) {
      stock = current.stock-1;
    }

    var dtp = GlobalUI.dateFull.parse(_fieldDate.text);
    var dt1 = new DateTime(dtp.year, dtp.month, dtp.day, 1, 30, 0, 0, 0);
    var dt = (dt1.toUtc().millisecondsSinceEpoch/1000).toInt();
    var dtp21 = GlobalUI.dateFull.parse(_fieldDate.text);
    var dt21 = new DateTime(dtp21.year, dtp21.month, dtp21.day, 1, 30, 0, 0, 0);

    var dt2 = null;
    if(_fieldDateEnd.text != "") {
      dt21 = GlobalUI.date.parse(_fieldDateEnd.text);
      dt2 = (dt21.toUtc().millisecondsSinceEpoch/1000).toInt().toString();
    }
    //var dt2 = (dt21.toUtc().millisecondsSinceEpoch/1000).toInt();
    var date = GlobalUI.dateTime.format(DateTime.now());

    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedCreateSubscriptionV2');
    callable.call(
      <String, dynamic>{
        "account": GlobalData.space.stripe,
        "customer": GlobalData.space.billing[0],
        "client": GlobalData.space.client,
        "product": current.product,
        "plan": current.id,
        "planname": current.name,
        "price": (current.price*100).toInt(),
        "billing": current.billing,
        "date": date,
        "group": group,
        "type": "create",
        "start": dt.toString(),
        "trial": "set",
        "sessions": current.sessions,
        "sessions11": sessions11,
        "cancels": cancels,
        "end": dt2.toString(),
        "user": account,
        "uid": GlobalData.space.id,
        "stock": stock,
        "count": current.interval,
      },
    );

    setState(() {
      active = true;
    });
  }


  createCard() {
    if(current.stock != 0) {
      if(_field1.text != "" && _field2.text != "" && _field3.text != "" && _field4.text != "" && _field5.text != "") {

        var group = "no";
        var sessions11 = 0;
        if(current.stype == "group") { group = "yes"; }
        if(current.stype == "both") {
          group = "both";
          sessions11 = current.sessions11;
        }
        var email = GlobalUser.email;

        var dt1 = GlobalUI.dateFull.parse(_fieldDate.text);
        var dt = (dt1.toUtc().millisecondsSinceEpoch/1000).toInt();
        var dt21 = GlobalUI.dateFull.parse(_fieldDate.text);

        var dt2 = null;
        if(_fieldDateEnd.text != "") {
          dt21 = GlobalUI.date.parse(_fieldDateEnd.text);
          dt2 = (dt21.toUtc().millisecondsSinceEpoch/1000).toInt().toString();
        }
        //var dt2 = (dt21.toUtc().millisecondsSinceEpoch/1000).toInt();
        var date = GlobalUI.dateTime.format(DateTime.now());

        setState(() {
          active = true;
        });

        var stock = -1;
        if(current.stock != -1) {
          stock = current.stock-1;
        }
        
        if((GlobalData.space.billing[0] != "" && GlobalData.space.billing[1] == "") || (GlobalData.space.billing[0] != "" && GlobalData.space.billing[1] != "")) {
          if(GlobalData.space.billing[1] != "") {
            HttpsCallable callable1 = FirebaseFunctions.instance.httpsCallable('connectedManageClientCardV2');
            callable1.call(
              <String, dynamic>{
                "type": "delete",
                "account": GlobalData.space.stripe,
                "customer": GlobalData.space.billing[0],
                "card": GlobalData.space.billing[1],
                "uid": GlobalData.space.id,
              },
            );
          }
          HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedCreateSubscriptionV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "customer": GlobalData.space.billing[0],
              "client": GlobalData.space.client,
              "product": current.product,
              "plan": current.id,
              "planname": current.name,
              "price": (current.price*100).toInt(),
              "billing": current.billing,
              "date": date, "group": group,
              "type": "card",
              "start": dt.toString(),
              "trial": "set",
              "sessions": current.sessions,
              "sessions11": sessions11,
              "cancels": cancels,
              "end": dt2.toString(),
              "user": account,
              "uid": GlobalData.space.id,
              "stock": stock,
              "count": current.interval,
            },
          );
        } else if(GlobalData.space.billing[0] == "" && GlobalData.space.billing[1] == "") {
          HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('connectedCreateSubscriptionV2');
          callable.call(
            <String, dynamic>{
              "account": GlobalData.space.stripe,
              "name": _field1.text,
              "card": _field2.text,
              "month": _field3.text,
              "year": _field4.text,
              "cvc": _field5.text,
              "clientname": GlobalUser.name,
              "email": email,
              "client": GlobalData.space.client,
              "product": current.product,
              "plan": current.id,
              "planname": current.name,
              "price": (current.price*100).toInt(),
              "billing": current.billing,
              "date": date,
              "group": group,
              "type": "account",
              "start": dt.toString(),
              "trial": "set",
              "sessions": current.sessions,
              "sessions11": sessions11,
              "cancels": cancels,
              "end": dt2.toString(),
              "user": account,
              "uid": GlobalData.space.id,
              "stock": stock,
              "count": current.interval,
            },
          );
        }
      } else {
        _showAlert();
      }
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

}