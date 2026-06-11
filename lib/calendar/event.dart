import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/theme.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/billing.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:ptmate_client/calendar/comments.dart';
import 'package:ptmate_client/components/list-comment.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';


class EventPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  const EventPage(this.id, this.item);
  static _EventPageState appState = _EventPageState();
  @override
  _EventPageState createState(){
    return EventPage.appState = new _EventPageState();
  }
}


class _EventPageState extends State<EventPage> {

  
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";
  ModelSession item = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");


  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
  }


  updateData() {
    if(this.mounted) {
      ModelSession tmp = ModelSession("", DateTime.now(), "", 0, [], [], [], "", "", "", 0, 0, DateTime.now(), false, [], [], ModelProgram("", "", "", 0, 0, "", [], false, ""), [], false, DateTime.now(), "", "", [], [], "", "", [], [], "");
      for(var sess in GlobalData.events) {
        if(sess.id == id) {
          tmp = sess;
        }
      }
      setState(() {
        id = id;
        item = tmp;
      });
    }
  }

  
  String getClient(id) {
    var label = "Client";
    for(var item in GlobalData.clients) {
      if(item.id == id) {
        label = item.name;
      }
    }
    if(id == GlobalData.space.client) {
      label = "You";
    }
    if(id == GlobalData.space.id) {
      label =GlobalData.space.name;
    }
    for(var st in GlobalData.allStaff) {
      if(id == st.id) {
        label = st.name;
      }
    }
    return label;
  }


  String getClientImage(id) {
    var label = "Client";
    for(var item in GlobalData.clients) {
      if(item.id == id) {
        label = item.image;
      }
    }
    if(id == GlobalData.space.id) {
      label =GlobalData.space.image;
    }
    return label;
  }


  String getClientAvatar(id) {
    var label = "";
    for(var item in GlobalData.clients) {
      if(item.id == id) {
        label = item.avatar;
      }
    }
    return label;
  }


  tapComment() {
    Navigator.push(
        context,
        PageRoutes.sharedAxis(() => CommentsPage(item.id, item, ""),
            SharedAxisTransitionType.vertical));
  }


  tapBook() {
    int max = 0;
    if(item.max != null) {
      max = item.max;
    }
    List clients = [];
    if(item.clients != null) {
      clients = item.clients;
    }
    if(item.unlocked.isBefore(DateTime.now()) && (item.locked.isAfter(DateTime.now()) || GlobalData.space.allowBookings)) {
      if(max == 0 || (max > 0 && clients.length < max)) {
        updateBooking("add", GlobalData.space.client);
      } else {
        showBookingFull();
      }
    } else {
      showBookingDisabled();
    }
  }


  tapCancelBooking() {
    if(item.locked.isAfter(DateTime.now())) {
      AlertDialog alert = AlertDialog(
      title: Text("Cancel booking?"),
        content: Text("Are you sure you want to cancel your booking for this event? "),
        actions: [
          TextButton(
            child: Text("Yes, cancel booking"),
            onPressed: () {
              updateBooking("remove", GlobalData.space.client);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Do nothing"),
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
    } else {
      AlertDialog alert = AlertDialog(
      title: Text("Bookings locked in"),
        content: Text("Bookings are locked in for this event. Please contact your trainer."),
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


  updateBooking(type, client) {
    List clients = [];
    List waiting = [];
    bool show = true;
    var cname = GlobalUser.name;
    var cemail = GlobalUser.email;
    if (client != GlobalData.space.client) {
      for (var cl in GlobalData.space.linked) {
        if (cl.id == client) {
          cname = cl.name;
        }
      }
      for (var conn in GlobalData.connect) {
        if (conn.client == client && conn.email != "") {
          cemail = conn.email;
        }
      }
    }
    if(item.waiting != null) {
      waiting = item.waiting;
    }

    String msg = "You're now booked in";
    if(type == "add") {
      // book in
      for(var cl in item.clients) {
        clients.add(cl);
      }
      clients.add(client);
      FirebaseSender.addActivity("bookingevent", GlobalUser.uid+","+item.id);
      FirebaseSender.sendPushMessage(GlobalData.space.token, "Event booking", GlobalUser.name+" just booked into "+item.name+" "+HelperCal.getSpecialDate(item.date) +".", "event", id, []);
      sendEmailConfirmation("booked", cemail, cname);

      // Local Notifications
      HelperCal.addScheduledNotification(item, GlobalData.schedule);
    } else {
      for(var cl in item.clients) {
        if(cl != client) {
          clients.add(cl);
        }
      }
      // If waiting list
      var name = item.name;
      FirebaseSender.sendPushMessage(GlobalData.space.token, "Event booking cancelled", GlobalUser.name+" just cancelled their booking for "+name+" "+HelperCal.getSpecialDate(item.date) +".", "event", id, []);

      if(waiting.length > 0) {
        clients.add(waiting[0]);
        updateWaiting("first", "");
        for(var client in GlobalData.clients) {
        if(client.id == waiting[0] && client.token != "") {
          FirebaseSender.sendPushMessage(client.token, "You are booked in now", "You are now booked into "+name+" "+HelperCal.getSpecialDate(item.date) +".", "event", id, []);
        }
      }
      }

      // Local Notifications
      HelperCal.removeScheduledNotification(item, GlobalData.schedule);

      msg = "Booking successfully cancelled";
      FirebaseSender.addActivity("bookingeventcancelled", GlobalUser.uid+","+item.id);
      sendEmailConfirmation("canceled", cemail, cname);
    }

    FirebaseSender.bookSession(item.id, clients, "events", []);
    // Show message
    if(show) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
        )
      );
    }
    
  }


  sendEmailConfirmation(type, email, clientName) {
    if(GlobalData.space.emailReminder && GlobalData.space.clientEmailReminder) {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable("sendReminderV2");
      callable.call(
        <String, dynamic>{
          "type": type,
          "name": GlobalData.space.business,
          "email": email,
          "clientName": clientName,
          "session": item.name,
          "time": GlobalUI.dateTime.format(item.date),
          "id": GlobalData.space.id,
          "color": HelperTheme.getEmailColor(),
          "image": HelperTheme.getEmailImage(),
        },
      );
    }
  }


  tapVideo() async {
    await launch(item.program.video);
  }


  updateWaiting(type, client) {
    List clients = [];
    var cname = GlobalUser.name;
    var cemail = GlobalUser.email;
    if (client != GlobalData.space.client) {
      for (var cl in GlobalData.space.linked) {
        if (cl.id == client) {
          cname = cl.name;
        }
      }
      for (var conn in GlobalData.connect) {
        if (conn.client == client && conn.email != "") {
          cemail = conn.email;
        }
      }
    }
    String msg = "You entered the waiting list";
    if(type == "add") {
      for(var cl in item.waiting) {
        clients.add(cl);
      }
      clients.add(client);
    } else if(type == "remove") {
      for(var cl in item.waiting) {
        if(cl != client) {
          clients.add(cl);
        }
      }
      msg = "Removed from waiting list";
    } else {
      for(var cl in item.waiting) {
        clients.add(cl);
      }
      clients.removeAt(0);
      // Push notification here
    }
    FirebaseSender.waitSession(item.id, clients, "events");
    if(type != "first") {
      // Show message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.GreenColor,
        )
      );
    }
  }


  tapCancelWaiting() {
    AlertDialog alert = AlertDialog(
    title: Text("Leave waiting list?"),
      content: Text("Are you sure you want to leave the waiting list and give up your spot?"),
      actions: [
        TextButton(
          child: Text("Leave waiting list"),
          onPressed: () {
            updateWaiting("remove", GlobalData.space.client);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Do nothing"),
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


  showBookingFull() {
    var title = "No available spots";
    var msg = "At this moment there are no available spots for this event. Do you want to enter the waiting list and move up if a spot becomes available?";
    AlertDialog alert = AlertDialog(
    title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          child: Text("Enter waiting list"),
          onPressed: () {
            updateWaiting("add", GlobalData.space.client);
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


  showBookingDisabled() {
    var text = "Bookings for this event will open "+HelperCal.getSpecialDate(item.unlocked)+". Please come back later to book in.";
    if(item.locked.isBefore(DateTime.now())) {
      text = "Bookings for this event are closed. Please contact your trainer to book in.";
    }
    AlertDialog alert = AlertDialog(
    title: Text("Booking not available"),
      content: Text(text),
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
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
              child: TitleLabelBack(item.name),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
              child: Text(
                HelperCal.getSpecialDate(item.date),
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _getContent()
              )
            )
            )
            
            
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  _getContent() {
    //List items = List();
    List<Widget> items = [];
    if(item.desc != "") {
      items.add(
        Container(
          width: double.maxFinite,
          child: Text(
            item.desc,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        )
      );
    }
    if(GlobalData.space.showBooked) {
      items.add(
        SubtitleLabel("Booked in")
      );
      if(item.clients == null || item.clients.length == 0) {
        items.add(
          EmptyLabel("", "No bookings yet")
        );
      } else {
        for(var client in item.clients) {
          items.add(
            ListPerson(getClient(client), "Booked in", getClientImage(client), "", getClientAvatar(client))
          );
        }
      }
      if(item.waiting != null) {
        if(item.waiting.length > 0) {
          items.add(
            SubtitleLabel("Waiting list")
          );
          for(var client in item.waiting) {
            items.add(
              ListPerson(getClient(client), "On the waiting list", getClientImage(client), "", getClientAvatar(client))
            );
          }
        }
      }
    }

    List list1 = [];
    if(item.clients != null) {
      list1 = item.clients;
    }
    List list2 = [];
    if(item.waiting != null) {
      list2 = item.waiting;
    }

    if(!GlobalData.space.restricted && GlobalData.space.linked.length == 0) {
      if(list1.contains(GlobalData.space.client)) {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
            child: BtnTertiary(label: "CANCEL BOOKING", clickFn: tapCancelBooking)
          )
        );
      } else if(list2.contains(GlobalData.space.client)) {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
            child: BtnTertiary(label: "LEAVE WAITING LIST", clickFn: tapCancelWaiting)
          )
        );
      } else {
        items.add(
          Container(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
            child: BtnPrimary(label: "BOOK IN", clickFn: tapBook)
          )
        );
      }
    } else if(!GlobalData.space.restricted && GlobalData.space.linked.length > 0) {
      items.add(
        Container(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
          child: BtnPrimary(label: "MANAGE BOOKINGS", clickFn: tapManage)
        )
      );
    }
    return items;
  }


  tapManage() {
    int max = 0;
    if(item.max != null) {
      max = item.max;
    }
    List clients = [];
    List waiting = [];
    if(item.clients != null) {
      clients = item.clients;
    }
    if(item.waiting != null) {
      waiting = item.waiting;
    }
    bool full = true;
    if(item.unlocked.isBefore(DateTime.now()) && (item.locked.isAfter(DateTime.now()) || GlobalData.space.allowBookings)) {
      if(max == 0 || (max > 0 && clients.length < max)) {
        full = false;
      }
    } else {
      showBookingDisabled();
    }

    if(item.unlocked.isBefore(DateTime.now()) && (item.locked.isAfter(DateTime.now()) || GlobalData.space.allowBookings)) {
      List<Widget> items = [];
      if(clients.contains(GlobalData.space.client)) {
        items.add(
          TextButton(
          child: Text("Cancel your booking"),
          onPressed: () {
            updateBooking("remove", GlobalData.space.client);
            Navigator.of(context).pop();
          },)
        );
      } else {
        if(waiting.contains(GlobalData.space.client)) {
          items.add(
            TextButton(
            child: Text("Remove yourself from waiting list"),
            onPressed: () {
              updateWaiting("remove", GlobalData.space.client);
              Navigator.of(context).pop();
            },)
          );
        } else {
          if(full) {
            items.add(
              TextButton(
              child: Text("Add yourself to waiting list"),
              onPressed: () {
                updateWaiting("add", GlobalData.space.client);
                Navigator.of(context).pop();
              },)
            );
          } else {
            items.add(
              TextButton(
              child: Text("Book yourself in"),
              onPressed: () {
                updateBooking("add", GlobalData.space.client);
                Navigator.of(context).pop();
              },)
            );
          }
        }
      }

      for(var pr in GlobalData.space.linked) {
        if(clients.contains(pr.id)) {
          items.add(
            TextButton(
            child: Text("Cancel booking for "+pr.name),
            onPressed: () {
              updateBooking("remove", pr.id);
              Navigator.of(context).pop();
            },)
          );
        } else {
          if(waiting.contains(pr.id)) {
            items.add(
              TextButton(
              child: Text("Remove "+pr.name+" from waiting list"),
              onPressed: () {
                updateWaiting("remove", pr.id);
                Navigator.of(context).pop();
              },)
            );
          } else {
            if(full) {
              items.add(
                TextButton(
                child: Text("Add "+pr.name+" to waiting list"),
                onPressed: () {
                  updateWaiting("add", pr.id);
                  Navigator.of(context).pop();
                },)
              );
            } else {
              items.add(
                TextButton(
                child: Text("Book in "+pr.name),
                onPressed: () {
                  updateBooking("add", pr.id);
                  Navigator.of(context).pop();
                },)
              );
            }
          }
        }
      }

      items.add(
          TextButton(
          child: Text("Cancel"),
          onPressed: () { Navigator.of(context).pop(); },)
        );

      AlertDialog alert = AlertDialog(
      title: Text("Please select"),
      content: Text("Choose the profile whose booking you'd like to manage"),
      actions: items,
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