import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/calendar/event.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/trainingspace.dart';
import 'package:ptmate_client/main.dart';

class CalendarPage extends StatefulWidget {
  static _CalendarPageState appState = _CalendarPageState();
  @override
  _CalendarPageState createState() {
    return CalendarPage.appState = new _CalendarPageState();
  }
}

class _CalendarPageState extends State<CalendarPage> {
  //String current = "7days";
  int day = 7;
  String current = GlobalUI.date.format(DateTime.now());
  List<ModelSession> sessions = [];
  List<ModelSession> events = [];

  @override
  void initState() {
    super.initState();
    createList();
  }

  updateData() {
    if (this.mounted) {
      createList();
    }
  }

  createList() {
    List<ModelSession> tsessions = [];
    List<ModelSession> tevents = [];
    for (var item in GlobalData.sessions) {
      if (GlobalUI.location == "" ||
          GlobalUI.location.contains(item.location)) {
        if (!tsessions.contains(item) &&
            GlobalUI.date.format(item.date) == current) {
          if (item.type == "pt") {
            tsessions.add(item);
          } else {
            var add = false;
            if (item.invitees.length == 0 ||
                item.invitees.contains(GlobalData.space.client)) {
              add = true;
            }
            for (var li in GlobalData.space.linked) {
              if (item.invitees.contains(li.id)) {
                add = true;
              }
            }
            // SHOW AS UNAVAILABLE NOW
            /*if(item.memberships.length > 0) {
              add = false;
              for(var deb in GlobalData.debits) {
                if(item.memberships.contains(deb.plan)) {
                  add = true;
                }
              }
              for(var cred in GlobalData.packs) {
                if(item.memberships.contains(cred.product)) {
                  add = true;
                }
              }
            }
            if(add && item.groups.length > 0) {
              add = false;
              for(var gr in GlobalData.groups) {
                if(item.groups.contains(gr.id) && gr.clients.contains(GlobalData.space.client)) {
                  add = true;
                }
                for(var li in GlobalData.space.linked) {
                  if(item.groups.contains(gr.id) && gr.clients.contains(li.id)) {
                    add = true;
                  }
                }
              }
            }*/
            if (item.availability && item.clients.length > 0) {
              add = false;
            }
            if (!add) {
              if (item.clients.contains(GlobalData.space.client)) {
                add = true;
              }
            }
            if (add) {
              tsessions.add(item);
            }
          }
        }
        // Events
        for (var item in GlobalData.events) {
          if (GlobalUI.location == "" ||
              GlobalUI.location.contains(item.location)) {
            var add = false;
            if (item.invitees.length == 0 ||
                item.invitees.contains(GlobalData.space.client)) {
              add = true;
            }
            for (var li in GlobalData.space.linked) {
              if (item.invitees.contains(li.id)) {
                add = true;
              }
            }
            if (add && item.groups.length > 0) {
              add = false;
              for (var gr in GlobalData.groups) {
                if (item.groups.contains(gr.id) &&
                    gr.clients.contains(GlobalData.space.client)) {
                  add = true;
                }
                for (var li in GlobalData.space.linked) {
                  if (item.groups.contains(gr.id) &&
                      gr.clients.contains(li.id)) {
                    add = true;
                  }
                }
              }
            }
            if (add &&
                !tevents.contains(item) &&
                GlobalUI.date.format(item.date) == current) {
              tevents.add(item);
            }
          }
        }

        if (!GlobalData.space.active) {
          tsessions = [];
          tevents = [];
        }
        setState(() {
          sessions = tsessions;
          events = tevents;
        });
        sessions.sort((a, b) => a.date.compareTo(b.date));
        events.sort((a, b) => a.date.compareTo(b.date));
      }
    }
  }

  switchTab(val) {
    var d1 = DateTime.now().subtract(Duration(days: 7));
    var d2 = d1.add(Duration(days: val));
    var date = GlobalUI.date.format(d2);
    setState(() {
      current = date;
      day = val;
    });
    createList();
  }

  String getSmallText(item) {
    String label = "";
    if (item.type == "pt") {
      label = "with " + GlobalData.space.name;
    } else {
      List list = item.clients ?? [];
      if (list.length > 0) {
        label = list.length.toString() + " booked in";
        if (item.availability) {
          label = "Someone booked in";
        }
        if (item.attendance == 3) {
          label = list.length.toString() + " Attended";
        }
      } else {
        label = "No bookings yet";
        if (item.date.isBefore(DateTime.now())) {
          label = "No bookings";
        }
        if (item.attendance == 3) {
          label = "Nobody attended";
        }
        if (item.availability) {
          label = "Not booked yet";
        }
      }
      if (!GlobalData.space.showBooked) {
        label = 'Tap to book in';
      }
      if (list.contains(GlobalData.space.client)) {
        label = "Booked in";
        if (item.attendance == 3) {
          label = "attended";
        }
      }
      List list2 = item.waiting ?? [];
      if (list2.contains(GlobalData.space.client)) {
        label = "Waiting list";
      }
      if (GlobalData.space.linked.length > 0) {
        for (var cl in GlobalData.space.linked) {
          if (list.contains(cl.id) && !list.contains(GlobalData.space.client)) {
            label = cl.name + " Booked in";
            if (item.attendance == 3) {
              label = cl.name + " attended";
            }
          }
          if (list2.contains(cl.id) &&
              !list2.contains(GlobalData.space.client)) {
            label = cl.name + " on waiting list";
          }
        }
      }
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            alignment: Alignment.topLeft,
            child: Column(children: [
              Container(
                  padding: EdgeInsets.only(top: 35),
                  alignment: Alignment.topLeft,
                  color: AppColors.bgColor,
                  child: Column(
                    children: [
                      TrainingSpace(),
                      Container(
                          //height: 78,
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          alignment: Alignment.topLeft,
                          color: AppColors.bgColor,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: _getDays()))),
                    ],
                  )),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _getSessions())))
            ])),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getDays() {
    List<Widget> items = [];
    for (var i = 0; i < 37; i++) {
      var bg = AppColors.bgColor;
      var tc = AppColors.textColor;
      var d1 = DateTime.now().subtract(Duration(days: 7));
      var d2 = d1.add(Duration(days: i));
      var df1 = DateFormat("EEE");
      var df2 = DateFormat("d");
      if (day == i) {
        bg = AppColors.PrimaryColor;
        tc = AppColors.WhiteColor;
      }
      items.add(InkWell(
          onTap: () {
            switchTab(i);
          },
          child: Container(
              width: 40,
              height: 48,
              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: bg,
              ),
              child: Column(children: [
                Text(
                  df2.format(d2),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tc,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                Text(
                  df1.format(d2),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tc,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                )
              ]))));
    }
    return items;
  }

  _getSessions() {
    List<Widget> items = [];
    var df = DateFormat("EEE, d MMM");
    var date = GlobalUI.date.parse(current);
    items.add(SubtitleLabel(HelperCal.getSpecialDateBasic(date)));
    print(sessions.toString());
    for (var item in sessions) {
      var name = item.name;
      if (item.availability) {
        name = "1:1 Availability";
      }
      items.add(InkWell(
          onTap: () {
            tapSession(item);
          },
          child: ListDefault(
              name,
              getSessionInfo(item),
              getSmallText(item),
              HelperCal.getTypeColor(item.type, item.availability),
              HelperCal.getTypeImage(item.type, item.availability),
              false)));
    }
    // Events
    for (var item in events) {
      var d1 = DateTime(item.date.year, item.date.month, item.date.day, 0, 0);
      var name = item.name;
      if (DateFormat("dd/MM/yyyy").format(item.date) ==
              DateFormat("dd/MM/yyyy").format(date) &&
          item.date.isAfter(DateTime.now())) {
        items.add(InkWell(
            onTap: () {
              tapEvent(item);
            },
            child: ListDefault(
                name,
                getSessionInfo(item),
                getSmallText(item),
                HelperCal.getTypeColor(item.type, item.availability),
                HelperCal.getTypeImage(item.type, item.availability),
                false)));
      }
    }
    if (sessions.length == 0 && events.length == 0) {
      items.add(EmptyLabel("empty-calendar", "Nothing\nscheduled"));
    }
    return items;
  }

  _getDaySessions(label, date) {
    //List daysessions = List<Widget>();
    List<Widget> daysessions = [];
    daysessions.add(SubtitleLabel(label));
    List items = [];
    // Sessions
    for (var item in sessions) {
      var d1 = DateTime(item.date.year, item.date.month, item.date.day, 0, 0);
      var name = item.name;
      if (item.availability) {
        name = "1:1 Availability";
      }
      //int diff = DateTime(item.date.year, item.date.month, item.date.day, item.date.hour, item.date.minute).difference(DateTime(date.year, date.month, date.day, 0, 0)).inDays;
      if (DateFormat("dd/MM/yyyy").format(item.date) ==
              DateFormat("dd/MM/yyyy").format(date) &&
          item.date.isAfter(DateTime.now())) {
        //if(diff == 0) {
        items.add(InkWell(
            onTap: () {
              tapSession(item);
            },
            child: ListDefault(
                name,
                getSessionInfo(item),
                getSmallText(item),
                HelperCal.getTypeColor(item.type, item.availability),
                HelperCal.getTypeImage(item.type, item.availability),
                false)));
      }
    }
    // Events
    for (var item in events) {
      var d1 = DateTime(item.date.year, item.date.month, item.date.day, 0, 0);
      var name = item.name;
      if (DateFormat("dd/MM/yyyy").format(item.date) ==
              DateFormat("dd/MM/yyyy").format(date) &&
          item.date.isAfter(DateTime.now())) {
        items.add(InkWell(
            onTap: () {
              tapEvent(item);
            },
            child: ListDefault(
                name,
                getSessionInfo(item),
                getSmallText(item),
                HelperCal.getTypeColor(item.type, item.availability),
                HelperCal.getTypeImage(item.type, item.availability),
                false)));
      }
    }

    if (items.length == 0) {
      daysessions.add(EmptyLabel("empty-calendar", "Nothing\nscheduled"));
    } else {
      for (var item in items) {
        daysessions.add(item);
      }
    }
    return daysessions;
  }

  getSessionInfo(item) {
    var label = DateFormat("HH:mm").format(item.date) +
        " h\n" +
        HelperCal.getDuration(item.duration, "hours");
    if (item.locationName != "") {
      label = DateFormat("HH:mm").format(item.date) +
          " h - " +
          HelperCal.getDuration(item.duration, "hours") +
          "\n" +
          item.locationName;
    }
    if (item.availability && item.name != "1:1 availability") {
      label = item.name +
          "\n" +
          DateFormat("HH:mm").format(item.date) +
          " h - " +
          HelperCal.getDuration(item.duration, "hours");
    }
    return label;
  }

  tapSession(item) {
    FirebaseSender.addBookingLog("class_tap", item.id, {
      "class_name": item.name,
      "date": item.date.toString(),
      "type": item.type,
      "availability": item.availability,
      "memberships": item.memberships,
      "groups": item.groups,
      "clients": item.clients,
      "waiting": item.waiting,
      "max": item.max,
      "locationName": item.locationName,
      "trainer": item.trainer,
    });
    var name = "class";
    if (item.availability) {
      name = "session";
    }
    if (GlobalData.space.active) {
      if (checkAccess(item)) {
        if (item.date.isBefore(DateTime.now())) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResultsPage(item.id, item)),
          );
        } else {
          print("====item===$item");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SessionPage(item.id, item)),
          );
        }
      } else {
        // No access
        Widget okButton = TextButton(
          child: Text("Got it"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Class unavailable to you"),
          content: Text(
              "You don't have access to this class. Please contact your trainer."),
          actions: [
            okButton,
          ],
        );
        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    } else {
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Can't book into this " + name),
        content: Text(
            "You're currently marked as an inactive client by your trainer. Please contact them to re-activate you."),
        actions: [
          okButton,
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  checkAccess(item) {
    var allow = true;
    if (item.memberships.length > 0) {
      allow = false;
      for (var deb in GlobalData.debits) {
        if (item.memberships.contains(deb.plan)) {
          allow = true;
        }
      }
      for (var cred in GlobalData.packs) {
        if (item.memberships.contains(cred.product)) {
          allow = true;
        }
      }
    }
    if (allow && item.groups.length > 0) {
      allow = false;
      for (var gr in GlobalData.allGroups) {
        if (item.groups.contains(gr.id) &&
            gr.clients.contains(GlobalData.space.client)) {
          allow = true;
        }
        for (var li in GlobalData.space.linked) {
          if (item.groups.contains(gr.id) && gr.clients.contains(li.id)) {
            allow = true;
          }
        }
      }
    }
    return allow;
  }

  tapEvent(item) {
    FirebaseSender.addBookingLog("event_tap", item.id, {
      "name": item.name,
      "date": item.date.toString(),
      "type": item.type,
      "memberships": item.memberships,
      "groups": item.groups,
      "clients": item.clients,
      "capacity": item.max,
    });
    if (GlobalData.space.active) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventPage(item.id, item)),
      );
    } else {
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text("Can't book into this event"),
        content: Text(
            "You're currently marked as an inactive client by your trainer. Please contact them to re-activate you."),
        actions: [
          okButton,
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }
}
