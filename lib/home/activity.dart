import 'package:flutter/material.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';

import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/account/invoice.dart';
import 'package:ptmate_client/account/receipt.dart';
import 'package:ptmate_client/health/habit.dart';
import 'package:ptmate_client/tools/form.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/main.dart';


class ActivityPage extends StatefulWidget {
  static _ActivityPageState appState = _ActivityPageState();
  @override
  _ActivityPageState createState(){
    return ActivityPage.appState = new _ActivityPageState();
  }
}


class _ActivityPageState extends State<ActivityPage> {

  List<ModelNotification> activity = [];


  @override
  void initState() {
    super.initState();
    getActivity();
  }


  updateData() {
    if(this.mounted) {
      getActivity();
    }
  }


  getActivity() {
    List<ModelNotification> tmp = [];
    var date = DateTime.now().subtract(Duration(days: 15));
    if(GlobalData.space.active) {
      // Sessions
      for(var item in GlobalData.sessions) {
        if(item.type == "pt" || item.type == "training" || item.clients.contains(GlobalData.space.client)) {
          // Bookings
          for(var bk in item.bookings) {
            if(bk.contains(GlobalData.space.client) && bk.contains("booking")) {
              var ar = bk.split("||");
              var date = item.date;
              if(ar.length > 3) {
                  date = DateTime.fromMillisecondsSinceEpoch(int.parse(ar[3]) * 1000);
              }
              tmp.add(ModelNotification(item.id, "You booked in", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nBooked in "+HelperCal.getSpecialDateBasic(date), "session", date, "booking"));
            }
            // Family
            for(var li in GlobalData.space.linked) {
              if(bk.contains(li.id) && bk.contains("booking")) {
                var ar = bk.split("||");
                var date = item.date;
                if(ar.length > 3) {
                    date = DateTime.fromMillisecondsSinceEpoch(int.parse(ar[3]) * 1000);
                }
                tmp.add(ModelNotification(item.id, li.name+" booked in", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nBooked in "+HelperCal.getSpecialDateBasic(date), "session", date, "booking"));
              }
            }
            if(bk.contains(GlobalData.space.client) && bk.contains("cancellation")) {
              var ar = bk.split("||");
              var date = item.date;
              if(ar.length > 3) {
                  date = DateTime.fromMillisecondsSinceEpoch(int.parse(ar[3]) * 1000);
              }
              tmp.add(ModelNotification(item.id, "You cancelled a booking", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nCancelled "+HelperCal.getSpecialDateBasic(date), "session", date, "booking"));
            }
            // Family
            for(var li in GlobalData.space.linked) {
              if(bk.contains(li.id) && bk.contains("cancellation")) {
                var ar = bk.split("||");
                var date = item.date;
                if(ar.length > 3) {
                    date = DateTime.fromMillisecondsSinceEpoch(int.parse(ar[3]) * 1000);
                }
                tmp.add(ModelNotification(item.id, li.name+" cancelled a booking", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nCancelled "+HelperCal.getSpecialDateBasic(date), "session", date, "booking"));
              }
            }
          }
          // Comments
          for(var comm in item.comments) {
            if(comm.date.isAfter(date)) {
              tmp.add(ModelNotification(item.id, "New session comment", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\n"+HelperCal.getSpecialDateBasic(comm.date), "session", comm.date, "comment"));
            }
          }
          // High fives
          for(var hf in item.highfives) {
            var ar = hf.split( "||");
            var date = DateTime.now();
            if(ar.length > 3) {
              if(ar[3] != '' && !ar[3].contains('.')) {
                var hd = double.parse(ar[3]);
                date = DateTime.fromMillisecondsSinceEpoch(hd.toInt() * 1000);
              }
            } else {
              if(ar.length > 2) {
                if(ar[2] != '') {
                  var hd = double.parse(ar[2]);
                  date = DateTime.fromMillisecondsSinceEpoch(hd.toInt() * 1000);
                }
              }
            }
            var name = "another member";
            if(ar[0] == GlobalData.space.client) {
              for(var client in GlobalData.clients) {
                  if(client.id == ar[1]) {
                    name = client.name;
                  }
              }
              tmp.add(ModelNotification(item.id, "You received a high five", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nFrom "+name+" - "+HelperCal.getSpecialDateBasic(date), "session", date, "highfive"));
            } else if(ar[1] == GlobalData.space.client) {
              for(var client in GlobalData.clients) {
                if(client.id == ar[0]) {
                  name = client.name;
                }
              }
              tmp.add(ModelNotification(item.id, "You gave a high five", item.name+" - "+HelperCal.getSpecialDateBasic(item.date)+"\nTo "+name+" - "+HelperCal.getSpecialDateBasic(date), "session", date, "highfive"));
            }
          }
        }
      }
      // Payments
      for(var item in GlobalData.payments) {
        if(item.date.isAfter(date)) {
          tmp.add(ModelNotification(item.id, "Payment made", GlobalUI.curSym+(item.amount/100).toStringAsFixed(2)+"\n"+HelperCal.getSpecialDateBasic(item.date), "payment", item.date, item.receipt));
        }
      }
      // Invoices
      for(var item in GlobalData.invoices) {
        if(item.date.isAfter(date)) {
          tmp.add(ModelNotification(item.id, "Invoice", GlobalUI.curSym+item.price.toStringAsFixed(2)+"\nSent "+HelperCal.getSpecialDateBasic(item.date), "invoice", item.date, ""));
        }
      }
      // Habits
      if(GlobalData.space.showHabits) {
        for(var habit in GlobalData.habits) {
          var date2 = DateTime.now().add(new Duration(days: 500));
          if(habit.start.isBefore(DateTime.now()) && habit.end.isAfter(DateTime.now())) {
            var add = true;
            for(var d in habit.days) {
              if(d.contains(GlobalUI.date.format(DateTime.now()))) {
                add = false;
              }
            }
            if(add) {
              tmp.add(ModelNotification(habit.id, habit.name, habit.amount.toString()+" "+habit.unit+" per "+(habit.interval == 1 ? 'day' : 'week')+"\nStarted "+HelperCal.getSpecialDateYear(habit.start), "habit", date2, "habit"));
            }
          }
        }
      }
      // Forms
      if(GlobalData.space.showForms) {
        for(var form in GlobalData.space.forms) {
          if(form.date.isAfter(date)) {
            tmp.add(ModelNotification(form.id, "Form filled", form.name+"\n"+HelperCal.getSpecialDateBasic(form.date), "form", form.date, ""));
          }
        }
      }
      tmp.sort((a, b) => b.date.compareTo(a.date));
    }
    setState(() {
      activity = tmp;
    });
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
              child: TitleLabelBack("Activity"),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getActivity()
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


  _getActivity() {
    List<Widget> items = [];
    if(activity.length == 0) {
      items.add(
        EmptyMessage("empty-activity", "You're up to date", "Here you can see an overview\nof what's happened in the last 14 days")
      );
    } else {
      for(var item in activity) {
        items.add(
          InkWell(
            onTap: () {
              if(item.type == "invoice") {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InvoicePage(item.id)),);
              } else if(item.type == "payment") {
                if(item.link != "" && !GlobalData.space.showHabits) {
                  _openURL(item.link);
                } else if(GlobalData.space.showHabits) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiptPage(item.id)),);
                }
              } else if(item.type == "habit") {
                for(var hab in GlobalData.habits) {
                  if(hab.id == item.id) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HabitPage(item.id, hab)),);
                  }
                }
              } else if(item.type == "form") {
                for(var form in GlobalData.space.forms) {
                  if(form.id == item.id) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FormPage(form.id, form)),);
                  }
                }
              } else if(item.type == "session") {
                for(var session in GlobalData.sessions) {
                  if(session.id == item.id) {
                    if(session.date.isBefore(DateTime.now())) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage(session.id, session)),);
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SessionPage(session.id, session)),);
                    }
                  }
                }
              }
            },
            child: ListDefault(item.name, item.desc, "", _getGradient(item), _getIcon(item), false)
          )
        );
      }
    }
    return items;
  }


  _getIcon(item) {
    var icon = "card.svg";
    if(item.type == "payment") {
      if(item.link == "") {
        icon = "cash.svg";
      }
    }
    if(item.type == "invoice") {
      icon = "invoice.svg";
    }
    if(item.type == "habit") {
      icon = "habit.svg";
    }
    if(item.type == "session") {
      icon = "session-event.svg";
      if(item.link == "comment") {
        icon = "comment.svg";
      }
      if(item.link == "highfive") {
        icon = "highfive.svg";
      }
    }
    return icon;
  }


  _getGradient(item) {
    var gradient = GlobalUI.gradients[0];
    if(item.type == "payment" || item.type == "invoice") {
      gradient = GlobalUI.gradients[1];
    }
    if(item.type == "habit" || item.type == "form") {
      gradient = GlobalUI.gradients[3];
    }
    return gradient;
  }

}