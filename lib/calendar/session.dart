import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/billing.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/_helper/theme.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_helper/transitions.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/calendar/comments.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-secondary-small.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/card-text.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/list-comment.dart';
import 'package:ptmate_client/components/list-person.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/title-double.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/tools/index.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  const SessionPage(this.id, this.item);
  static _SessionPageState appState = _SessionPageState();
  @override
  _SessionPageState createState() {
    return SessionPage.appState = new _SessionPageState();
  }
}

class _SessionPageState extends State<SessionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String id = "";

  ModelSession item = ModelSession(
      "",
      DateTime.now(),
      "",
      0,
      [],
      [],
      [],
      "",
      "",
      "",
      0,
      0,
      DateTime.now(),
      false,
      [],
      [],
      ModelProgram("", "", "", 0, 0, "", [], false, ""),
      [],
      false,
      DateTime.now(),
      "",
      "",
      [],
      [],
      "",
      "",
      [],
      [],
      "");

  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
    });
  }

  updateData() {
    if (this.mounted) {
      ModelSession tmp = ModelSession(
          "",
          DateTime.now(),
          "",
          0,
          [],
          [],
          [],
          "",
          "",
          "",
          0,
          0,
          DateTime.now(),
          false,
          [],
          [],
          ModelProgram("", "", "", 0, 0, "", [], false, ""),
          [],
          false,
          DateTime.now(),
          "",
          "",
          [],
          [],
          "",
          "",
          [],
          [],
          "");
      for (var sess in GlobalData.sessions) {
        if (sess.id == id) {
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
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.name;
      }
    }
    if (id == GlobalData.space.client) {
      label = "You";
    }
    if (id == GlobalData.space.id) {
      label = GlobalData.space.name;
    }
    for (var st in GlobalData.allStaff) {
      if (id == st.id) {
        label = st.name;
      }
    }
    return label;
  }

  String getClientImage(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
        label = item.image;
      }
    }
    if (id == GlobalData.space.id) {
      label = GlobalData.space.image;
    }
    return label;
  }

  String getClientAvatar(id) {
    var label = "";
    for (var item in GlobalData.clients) {
      if (item.id == id) {
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
    if (_isBooking) return;

    int max = 0;
    max = item.max;
    List clients = [];
    clients = item.clients;
    if (item.unlocked.isBefore(DateTime.now()) &&
        (item.locked.isAfter(DateTime.now()) ||
            GlobalData.space.allowBookings)) {
      if (max == 0 || (max > 0 && clients.length < max)) {
        //updateBooking("add", GlobalData.space.client);
        showRecBooking("add", GlobalData.space.client);
      } else {
        showBookingFull();
      }
    } else {
      showBookingDisabled();
    }
  }

  showRecBooking(type, client) {
    var showAlert = false;
    var trec = ModelRecurring("", [], 0);
    if (GlobalData.space.allowRecurring && item.template != "") {
      for (var rec in GlobalData.recurring) {
        if (rec.id == item.template &&
            !rec.clients.contains(client) &&
            (rec.clients.length < rec.max || rec.max == 0)) {
          showAlert = true;
          trec = rec;
        }
      }
    }
    if (showAlert) {
      AlertDialog alert = AlertDialog(
        title: Text("Book in"),
        content: Text(
            "Do you want to book into this class only or make a recurring booking for this class time for future classes?"),
        actions: [
          TextButton(
            child: Text("This class only"),
            onPressed: () {
              updateBooking("add", client);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Recurring booking"),
            onPressed: () {
              Navigator.of(context).pop();
              updateBooking("add", client);
              updateRecurring("add", client, trec);
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
    } else {
      AlertDialog alert = AlertDialog(
        title: Text("Book in"),
        content: Text("Are you sure you want to book into this class?"),
        actions: [
          TextButton(
            child: Text("Yes, book in"),
            onPressed: () {
              updateBooking("add", client);
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

  showRecCancel(type, client) {
    if (item.locked.isAfter(DateTime.now())) {
      var showAlert = false;
      var trec = ModelRecurring("", [], 0);
      if (GlobalData.space.allowRecurring && item.template != "") {
        for (var rec in GlobalData.recurring) {
          if (rec.id == item.template && rec.clients.contains(client)) {
            showAlert = true;
            trec = rec;
          }
        }
      }
      if (showAlert) {
        AlertDialog alert = AlertDialog(
          title: Text("Cancel booking"),
          content: Text(
              "Do you want to cancel this class only or all recurring bookings for this classes time?"),
          actions: [
            TextButton(
              child: Text("Cancel this booking"),
              onPressed: () {
                updateBooking("remove", client);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel recurring bookings"),
              onPressed: () {
                Navigator.of(context).pop();
                updateBooking("remove", client);
                updateRecurring("remove", client, trec);
              },
            ),
            TextButton(
              child: Text("Do nothing"),
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
      } else {
        updateBooking("remove", client);
      }
    } else {
      showAlertCancel();
    }
  }

  tapCancelBooking() {
    if (_isBooking) return;

    if (item.locked.isAfter(DateTime.now())) {
      var title = "class";
      if (item.availability) {
        title = "session";
      }
      var showAlert = false;
      var trec = ModelRecurring("", [], 0);
      if (GlobalData.space.allowRecurring && item.template != "") {
        for (var rec in GlobalData.recurring) {
          if (rec.id == item.template &&
              rec.clients.contains(GlobalData.space.client)) {
            showAlert = true;
            trec = rec;
          }
        }
      }
      if (showAlert) {
        showRecCancel("remove", GlobalData.space.client);
      } else {
        AlertDialog alert = AlertDialog(
          title: Text("Cancel booking?"),
          content: Text(
              "Are you sure you want to cancel your booking for this " +
                  title +
                  "? "),
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
    } else {
      showAlertCancel();
    }
  }

  showAlertCancel() {
    var title = "class";
    if (item.availability) {
      title = "session";
    }
    AlertDialog alert = AlertDialog(
      title: Text("Bookings locked in"),
      content: Text("Bookings are locked in for this " +
          title +
          ". Please contact your trainer."),
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

  static Future<void> getSpaceBilling(id, client,
      {bool hasRetried = false}) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref("clients/$id/$client").get();

      final raw = snapshot.value;

      /// 🔴 Handle empty snapshot
      if (raw == null || raw is! Map) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"step": "empty snapshot"});

        /// 🔁 Retry only once
        if (!hasRetried) {
          FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
              "", {"retry": "triggered (empty snapshot)"});

          await Future.delayed(const Duration(seconds: 2));
          return getSpaceBilling(id, client, hasRetried: true);
        }

        return;
      }

      Map data = raw;

      /// 🔴 Skip if both null (safety)
      if (data["credits"] == null && data["subscriptions"] == null) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"step": "credits & subscriptions null"});

        /// 🔁 Retry only once
        if (!hasRetried) {
          FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
              "", {"retry": "triggered (both null)"});

          await Future.delayed(const Duration(seconds: 2));
          return getSpaceBilling(id, client, hasRetried: true);
        }

        return;
      }

      /// 🔴 Partial-safe clearing (IMPORTANT)
      bool hasCredits = data["credits"] != null && data["credits"] is Map;
      bool hasSubscriptions =
          data["subscriptions"] != null && data["subscriptions"] is Map;

      if (hasCredits) {
        GlobalData.packs = [];
      }

      if (hasSubscriptions) {
        GlobalData.debits = [];
      }

      bool expires = false;
      DateTime expiry = DateTime.now();

      /// ================== CREDITS ==================
      if (hasCredits) {
        FirebaseSender.addBookingLog(
            "new_splash_loading_membership_screen", "", {"credits": "found"});

        data["credits"].forEach((index, pack) {
          try {
            if (pack == null || pack is! Map) {
              FirebaseSender.addBookingLog(
                  "new_splash_loading_membership_screen",
                  "",
                  {"credits_error": "pack null"});
              return;
            }

            expiry = DateTime.now();
            expires = false;

            if (pack["expires"] != null && pack["expires"] is int) {
              expiry =
                  DateTime.fromMillisecondsSinceEpoch(pack["expires"] * 1000);
              expires = true;
            }

            GlobalData.packs.add(ModelPack(
              index,
              (pack["group"] is bool ? pack["group"] : false),
              (pack["sessionsPaid"] is int ? pack["sessionsPaid"] : 0),
              (pack["sessionsTotal"] is int ? pack["sessionsTotal"] : 0),
              expires,
              expiry,
              (pack["account"] is String ? pack["account"] : ""),
              (pack["name"] is String ? pack["name"] : ""),
              (pack["product"] is String ? pack["product"] : ""),
            ));
          } catch (e) {
            FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
                "", {"credits_error": "$e"});
          }
        });
      } else {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"credits": "null", "hasSubscriptions": hasSubscriptions});
      }

      /// ================== SUBSCRIPTIONS ==================
      if (hasSubscriptions) {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"subscriptions": "found"});

        data["subscriptions"].forEach((index, sub) {
          try {
            if (sub == null || sub is! Map) {
              FirebaseSender.addBookingLog(
                  "new_splash_loading_membership_screen",
                  "",
                  {"subscriptions_error": "sub null"});
              return;
            }

            double price =
                (sub["price"] is num) ? (sub["price"] as num).toDouble() : 0.0;

            DateTime nextDate = DateTime.now();
            if (sub["next"] is int) {
              nextDate =
                  DateTime.fromMillisecondsSinceEpoch(sub["next"] * 1000);
            }

            GlobalData.debits.add(ModelDebit(
              index,
              (sub["name"] is String ? sub["name"] : "Membership"),
              (sub["billing"] is String ? sub["billing"] : "week"),
              (sub["interval"] is int ? sub["interval"] : 1),
              price,
              nextDate,
              (sub["group"] is bool ? sub["group"] : true),
              (sub["sessions"] is int ? sub["sessions"] : 0),
              (sub["sessions11"] is int ? sub["sessions11"] : 0),
              (sub["status"] is String ? sub["status"] : "active"),
              (sub["account"] is String ? sub["account"] : ""),
              (sub["is11"] is bool ? sub["is11"] : false),
              (sub["done"] is int ? sub["done"] : 0),
              (sub["done11"] is int ? sub["done11"] : 0),
              (sub["pause"] is String ? sub["pause"] : ""),
              (sub["plan"] is String ? sub["plan"] : ""),
            ));
          } catch (e) {
            FirebaseSender.addBookingLog("new_splash_loading_membership_screen",
                "", {"subscriptions_error": "$e"});
          }
        });
      } else {
        FirebaseSender.addBookingLog("new_splash_loading_membership_screen", "",
            {"subscriptions": "null", "hasCredits": hasCredits});
      }

      /// ================== UI UPDATE ==================
      ConnectPage.appState.updateData();
      HomePage.appState.updateData();
      AccountPage.appState.updateData();
      ToolsPage.appState.updateData();
    } catch (e) {
      FirebaseSender.addBookingLog(
          "new_splash_loading_membership_screen", "", {"outer_error": "$e"});
    }
  }

  updateBooking(type, client) async {
    setState(() {
      _isBooking = true;
    });
    try {
      await getSpaceBilling(GlobalData.space.id, GlobalData.space.client);
      List clients = [];
      List waiting = [];
      bool show = true;

      waiting = item.waiting;

      var name = item.name;
      if (item.availability) {
        name = "1:1 Availability";
      }

      String msg = "You're now booked in";
      if (type == "add") {
        int num = -10000;
        int sessions = 0;
        int total = -10000;

        // Log start
        FirebaseSender.addBookingLog("add_start", item.id, {
          "client": client,
          "item_date": item.date.toString(),
          "item_name": item.name,
          "availability": item.availability,
          "memberships": item.memberships
        });
        // Check sessions
        if (!item.availability) {
          num = HelperBill.getUnpaid(true, client, item.date, item.memberships);
          for (var deb in GlobalData.debits) {
            if ((item.memberships.length == 0 ||
                    item.memberships.contains(deb.plan)) &&
                deb.pause == "") {
              if (deb.sessions == 0 &&
                  deb.group &&
                  (deb.account == "" || deb.account == client) &&
                  deb.status != "trialing" &&
                  deb.status != "unpaid") {
                num = -10000;
              }
              if (deb.id == "trial" && deb.next.isAfter(DateTime.now())) {
                num = -10000;
              }
            }
          }
        }

        var limit = GlobalData.space.limitBooking;
        if (!limit) {
          num = -10000;
        }

        var endDate = DateTime.now().add(Duration(days: 7));
        for (var deb in GlobalData.debits) {
          if ((item.memberships.length == 0 ||
                  item.memberships.contains(deb.plan)) &&
              deb.pause == "") {
            if (deb.sessions != 0 &&
                deb.group &&
                (deb.account == "" || deb.account == client) &&
                deb.status != "trialing" &&
                deb.status != "unpaid") {
              endDate = deb.next;
            }
          }
        }
        for (var session in GlobalData.sessions) {
          if (session.memberships.length == 0) {
            if (session.clients.contains(GlobalData.space.client) &&
                session.id != item.id &&
                session.date.isAfter(DateTime.now()) &&
                session.date.isBefore(endDate)) {
              sessions += 1;
            }
          }
        }

        if (num != -10000) {
          total = num + sessions;
        }

        var title1 = "class";
        var title2 = "classes";
        if (item.availability) {
          title1 = "session";
          title2 = "sessions";
        }

        if (total < 0) {
          // book in
          for (var cl in item.clients) {
            clients.add(cl);
          }
          clients.add(client);
          var bookings = [];
          for (var cl in item.bookings) {
            bookings.add(cl);
          }
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
          var ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
          bookings.add(client + "||booking||member||" + ts.toString());

          FirebaseSender.bookSession(item.id, clients, "sessions", bookings);
          FirebaseSender.addActivity("booking", GlobalUser.uid + "," + item.id);
          FirebaseSender.sendPushMessage(
              GlobalData.space.token,
              "Session booking",
              cname +
                  " just booked into " +
                  name +
                  " " +
                  HelperCal.getSpecialDate(item.date) +
                  ".",
              "session",
              id,
              []);
          sendEmailConfirmation("booked", cemail, cname);

          // Local Notifications
          HelperCal.addScheduledNotification(item, GlobalData.schedule);

          // Log success
          FirebaseSender.addBookingLog("add_success", item.id, {
            "num": num,
            "sessions": sessions,
            "total": total,
            "limit": limit
          });

          // Update local state to prevent caching issues blocking subsequent bookings
          for (var sess in GlobalData.sessions) {
            if (sess.id == item.id) {
              sess.clients = clients;
            }
          }
        } else {
          var title = "No available credits";
          var desc = "You're booked into " +
              (sessions == 1
                  ? "another " + title1
                  : sessions.toString() + " other " + title2) +
              " and used your " +
              (num == -1
                  ? "available credit"
                  : (-num).toString() + " available credits") +
              ". Please top up your credits or cancel " +
              (sessions == 1 ? "the other" : "another") +
              " booking to be able to book into this " +
              title1 +
              ".";
          if (num >= 0) {
            title = "No available " + title2;
            desc = "You don't have any available " +
                title2 +
                " to book into this " +
                title1 +
                ". Please contact your trainer or purchase another pack of " +
                title2 +
                ".";
          }
          show = false;
          Timer(Duration(milliseconds: 500), () {
            showAlert(title, desc);
          });

          // Log failure
          FirebaseSender.addBookingLog("add_fail", item.id, {
            "num": num,
            "sessions": sessions,
            "total": total,
            "limit": limit
          });
        }
      } else {
        // Log remove
        FirebaseSender.addBookingLog("remove", item.id, {
          "client": client,
          "item_date": item.date.toString(),
          "item_name": item.name
        });
        for (var cl in item.clients) {
          if (cl != client) {
            clients.add(cl);
          }
        }
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
        // If waiting list
        FirebaseSender.sendPushMessage(
            GlobalData.space.token,
            "Session cancelled",
            cname +
                " just cancelled their booking for " +
                name +
                " " +
                HelperCal.getSpecialDate(item.date) +
                ".",
            "session",
            id,
            []);
        sendEmailConfirmation("canceled", cemail, cname);

        var wclient = "";
        if (waiting.length > 0) {
          clients.add(waiting[0]);
          updateWaiting("first", "");
          for (var client in GlobalData.clients) {
            if (client.id == waiting[0] && client.token != "") {
              wclient = client.id;
              FirebaseSender.sendPushMessage(
                  client.token,
                  "You are booked in now",
                  "You are now booked into " +
                      name +
                      " " +
                      HelperCal.getSpecialDate(item.date) +
                      ".",
                  "session",
                  id,
                  []);
              Future.delayed(const Duration(milliseconds: 3000), () {
                HelperCal.addScheduledNotificationWaiting(
                    item, GlobalData.schedule, client);
              });
            }
          }
        }

        msg = "Booking successfully cancelled";
        var bookings = [];
        for (var cl in item.bookings) {
          bookings.add(cl);
        }
        var ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
        bookings.add(client + "||cancellation||member||" + ts.toString());
        if (wclient != "") {
          bookings.add(wclient + "||booking||waiting||" + ts.toString());
        } else {
          HelperCal.removeScheduledNotification(item, GlobalData.schedule);
        }
        FirebaseSender.bookSession(item.id, clients, "sessions", bookings);
        FirebaseSender.addActivity(
            "bookingcancelled", GlobalUser.uid + "," + item.id);

        // Update local state to prevent caching issues blocking subsequent bookings
        for (var sess in GlobalData.sessions) {
          if (sess.id == item.id) {
            sess.clients = clients;
          }
        }
      }

      //FirebaseSender.bookSession(item.id, clients, "sessions");
      // Show message
      if (show) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.GreenColor,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  updateRecurring(type, client, rec) async {
    setState(() {
      _isBooking = true;
    });
    try {
      await getSpaceBilling(GlobalData.space.id, GlobalData.space.client);

      var clients = [];
      if (type == "add") {
        // Check sessions
        int num =
            HelperBill.getUnpaid(true, client, item.date, item.memberships);
        var limit = GlobalData.space.limitBooking;
        if ((num > 0 || (num == 0 && GlobalData.debits.length == 0)) && limit) {
          // Do nothing
        } else {
          // Book in
          for (var cl in rec.clients) {
            clients.add(cl);
          }
          clients.add(client);
          //rec.clients = clients;
          // Add to future sessions
          for (var sess in GlobalData.sessions) {
            var locked = false;
            if (sess.locked.isBefore(DateTime.now()) &&
                !GlobalData.space.allowBookings) {
              locked = true;
            }
            if (sess.template == rec.id &&
                sess.id != item.id &&
                sess.date.isAfter(DateTime.now()) &&
                !sess.clients.contains(client) &&
                !locked) {
              if (sess.max == 0 || sess.max > sess.clients.length) {
                var list = [];
                for (var sc in sess.clients) {
                  list.add(sc);
                }
                list.add(client);
                var bookings = [];
                for (var cl in item.bookings) {
                  bookings.add(cl);
                }
                var ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
                bookings.add(client + "||recurring||member||" + ts.toString());
                FirebaseSender.bookSession(sess.id, list, "sessions", bookings);
                // Local Notifications
                //HelperCal.addScheduledNotification(sess, GlobalData.schedule);
              } else {
                var list = [];
                for (var sc in sess.waiting) {
                  list.add(sc);
                }
                list.add(client);
                FirebaseSender.waitSession(sess.id, list, "sessions");
              }
            }
          }
          // Update recurring
          FirebaseSender.bookSession(rec.id, clients, "recurring", []);
        }
      } else {
        for (var cl in rec.clients) {
          if (cl != client) {
            clients.add(cl);
          }
        }
        for (var sess in GlobalData.sessions) {
          if (sess.template == rec.id &&
              sess.id != item.id &&
              sess.date.isAfter(DateTime.now()) &&
              sess.clients.contains(client) &&
              sess.locked.isAfter(DateTime.now())) {
            var clients1 = [];
            var waiting = [];
            for (var cl in sess.clients) {
              if (cl != client) {
                clients1.add(cl);
              }
            }
            if (sess.waiting.contains(client)) {
              for (var wa in sess.waiting) {
                if (wa != client) {
                  waiting.add(wa);
                }
              }
              FirebaseSender.waitSession(sess.id, waiting, "sessions");
            }
            var bookings = [];
            for (var cl in item.bookings) {
              bookings.add(cl);
            }
            var ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
            bookings
                .add(client + "||cancellationrec||member||" + ts.toString());
            FirebaseSender.bookSession(sess.id, clients1, "sessions", bookings);
            // Local Notifications
            //HelperCal.removeScheduledNotification(sess, GlobalData.schedule);
          }
        }
        // Update recurring
        FirebaseSender.bookSession(rec.id, clients, "recurring", []);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  tapVideo() async {
    await launch(item.program.video);
  }

  showAlert(title, desc) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(desc),
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

  sendEmailConfirmation(type, email, clientName) {
    if (GlobalData.space.emailReminder &&
        GlobalData.space.clientEmailReminder) {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("sendReminderV2");
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

  updateWaiting(type, client) async {
    setState(() {
      _isBooking = true;
    });
    try {
      List clients = [];

      String msg = "You entered the waiting list";
      if (type == "add") {
        for (var cl in item.waiting) {
          clients.add(cl);
        }
        clients.add(client);
      } else if (type == "remove") {
        for (var cl in item.waiting) {
          if (cl != client) {
            clients.add(cl);
          }
        }
        msg = "Removed from waiting list";
      } else {
        for (var cl in item.waiting) {
          clients.add(cl);
        }
        clients.removeAt(0);
        // Push notification here
      }
      FirebaseSender.waitSession(item.id, clients, "sessions");
      // Update local state
      for (var sess in GlobalData.sessions) {
        if (sess.id == item.id) {
          sess.waiting = clients;
        }
      }
      if (type != "first") {
        // Show message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.GreenColor,
          ));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  tapCancelWaiting() {
    AlertDialog alert = AlertDialog(
      title: Text("Leave waiting list?"),
      content: Text(
          "Are you sure you want to leave the waiting list and give up your spot?"),
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

  showBookingFull() {
    var name = "class";
    if (item.availability) {
      name = "session";
    }
    var title = "No available spots";
    var msg = "At this moment there are no available spots for this " +
        name +
        ". Do you want to enter the waiting list and move up if a spot becomes available?";
    if (item.availability) {
      title = "Can't book in";
      msg = "Someone already booked into this " +
          name +
          ". Do you want to enter the waiting list and move up if the spot becomes available?";
    }
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

  showBookingDisabled() {
    var name = "class";
    if (item.availability) {
      name = "session";
    }
    var text = "Bookings for this " +
        name +
        " will open " +
        HelperCal.getSpecialDate(item.unlocked) +
        ". Please come back later to book in.";
    if (item.locked.isBefore(DateTime.now())) {
      text = "Bookings for this " +
          name +
          " are closed. Please contact your trainer to book in.";
    }
    AlertDialog alert = AlertDialog(
      title: Text("Booking not available"),
      content: Text(text),
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

  getSubtitle() {
    var label = HelperCal.getSpecialDate(item.date);
    if (item.locationName != "") {
      DateFormat dateTime = DateFormat("d MMM HH:mm");
      label = dateTime.format(item.date) + " - " + item.locationName;
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 3),
                child: TitleLabelBack(item.name),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
                child: Text(
                  getSubtitle(),
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
                          children: _getContent())))
            ],
          ),
        ),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getContent() {
    var name = "class";
    if (item.availability) {
      name = "session";
    }
    //List items = List();
    List<Widget> items = [];

    bool userBooked = item.clients.contains(GlobalData.space.client);
    bool userWaiting = item.waiting.contains(GlobalData.space.client);
    bool showEveryone = (item.type == "group" && GlobalData.space.showBooked);

    if (showEveryone) {
      items.add(SubtitleLabel("Booked in"));
      if (item.clients.length == 0) {
        items.add(EmptyLabel(
            "", item.availability ? "No booking yet" : "No bookings yet"));
      } else {
        for (var client in item.clients) {
          items.add(ListPerson(getClient(client), "",
              getClientImage(client), "", getClientAvatar(client)));
        }
      }
      if (item.waiting.length > 0) {
        items.add(SubtitleLabel("Waiting list"));
        for (var client in item.waiting) {
          items.add(ListPerson(getClient(client), "On the waiting list",
              getClientImage(client), "", getClientAvatar(client)));
        }
      }
    } else {
      if (userBooked) {
        items.add(SubtitleLabel("Booked in"));
        items.add(ListPerson(getClient(GlobalData.space.client), "",
            getClientImage(GlobalData.space.client), "", getClientAvatar(GlobalData.space.client)));
      } else if (userWaiting) {
        items.add(SubtitleLabel("Waiting list"));
        items.add(ListPerson(getClient(GlobalData.space.client), "On the waiting list",
            getClientImage(GlobalData.space.client), "", getClientAvatar(GlobalData.space.client)));
      }
    }

    if (item.desc != "" ||
        (item.trainer != GlobalData.space.name && item.trainer != "Trainer")) {
      var text = item.desc;
      if (item.desc != "" &&
          item.trainer != GlobalData.space.name &&
          item.trainer != "Trainer") {
        text = item.desc + " - with " + item.trainer;
      } else if (item.desc == "" &&
          item.trainer != GlobalData.space.name &&
          item.trainer != "Trainer") {
        text = "With " + item.trainer;
      }
      items.add(Container(
        width: double.maxFinite,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      ));
    }

    if (item.program.id == "" || !item.preview) {
      items.add(EmptyMessage("empty-programs", "No preview",
          "This " + name + "'s preview is\nnot available at this point."));
    } else {
      item.program.blocks.sort((a, b) => a.id.compareTo(b.id));
      if (item.program.video != "") {
        items.add(Container(
          margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: BtnTertiary(
            label: "Watch video",
            clickFn: tapVideo,
          ),
        ));
      }
      for (var block in item.program.blocks) {
        var subtitle = GlobalUI.cats[block.cat];
        if (block.name != "") {
          subtitle = block.name + " (" + GlobalUI.cats[block.cat] + ")";
        }
        items.add(TitleDoubleLabel(
            GlobalUI.titles[block.type] + HelperTrain.getBlockInfo(block),
            subtitle,
            "session",
            item.id,
            block.id));
        if (!block.simple) {
          for (var ex in block.movements) {
            items.add(InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExImagePage(ex)),
                  );
                },
                child: CardText(HelperTrain.getMovementName(ex, block),
                    HelperTrain.getMovementInfo(ex, block), ex.notes)));
          }
        }
        if (block.notes != "") {
          items.add(Container(
              width: MediaQuery.of(context).size.width - 70,
              padding: EdgeInsets.only(top: 7),
              child: Text(
                block.notes,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: (block.simple ? 15 : 11),
                ),
              )));
        }
      }
    }


    if (GlobalData.space.comments) {
      var highfives = [];
      for (var hf in item.highfives) {
        var ar = hf.split("||");
        if (ar[0] == GlobalData.space.client) {
          var date =
              DateTime.fromMillisecondsSinceEpoch(int.parse(ar[2]) * 1000);
          highfives.add(ModelClientChat(ar[1], date, "", ""));
        }
      }
      if (highfives.length > 0) {
        items.add(SubtitleLabel("Your high fives"));
        for (var hf in highfives) {
          items.add(ListPerson(
              getClient(hf.id),
              "Received " + HelperCal.getSpecialDateBasic(hf.date),
              getClientImage(hf.id),
              "",
              getClientAvatar(hf.id)));
        }
      }

      items.add(SubtitleLabel("Comments"));
      if (item.comments.length == 0) {
        items.add(EmptyLabel("", "No comments yet"));
      } else {
        items.add(Container(height: 20));
        item.comments.sort((b, a) => a.date.compareTo(b.date));
        for (var comment in item.comments) {
          if (comment.sender == GlobalData.space.client ||
              comment.sender == GlobalUser.uid) {
            items.add(InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageRoutes.sharedAxis(
                          () => CommentsPage(item.id, item, comment.id),
                          SharedAxisTransitionType.vertical));
                },
                child: ListComment(
                    getClient(comment.sender),
                    HelperCal.getSpecialDate(comment.date),
                    getClientImage(comment.sender),
                    comment.text,
                    "EDIT",
                    getClientAvatar(comment.sender))));
          } else {
            items.add(ListComment(
                getClient(comment.sender),
                HelperCal.getSpecialDate(comment.date),
                getClientImage(comment.sender),
                comment.text,
                "",
                getClientAvatar(comment.sender)));
          }
        }
        items.add(Container(height: 20));
      }
      if (!GlobalData.space.restricted) {
        items.add(
            BtnSecondarySmall(label: "WRITE A COMMENT", clickFn: tapComment));
      }
    }

    if (item.type == "group") {
      List list1 = [];
      list1 = item.clients;
      List list2 = [];
      list2 = item.waiting;

      if (item.date.isAfter(DateTime.now())) {
        print(GlobalData.space.linked.length);
        if (!GlobalData.space.restricted &&
            GlobalData.space.linked.length == 0) {
          if (list1.contains(GlobalData.space.client)) {
            items.add(Container(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: BtnTertiary(
                    label: _isBooking ? "Processing..." : "CANCEL BOOKING",
                    clickFn: tapCancelBooking)));
          } else if (list2.contains(GlobalData.space.client)) {
            items.add(Container(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: BtnTertiary(
                    label: "LEAVE WAITING LIST", clickFn: tapCancelWaiting)));
          } else {
            items.add(Container(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: BtnPrimary(
                    label: _isBooking ? "Processing..." : "BOOK IN",
                    clickFn: tapBook)));
          }
        } else if (!GlobalData.space.restricted &&
            GlobalData.space.linked.length > 0) {
          items.add(Container(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
              child: BtnPrimary(
                  label: _isBooking ? "Processing..." : "MANAGE BOOKINGS",
                  clickFn: tapManage)));
        }
      }
    }
    return items;
  }

  tapManage() {
    if (_isBooking) return;
    int max = 0;
    max = item.max;
    List clients = [];
    List waiting = [];
    clients = item.clients;
    waiting = item.waiting;
    bool full = true;
    if (item.unlocked.isBefore(DateTime.now()) &&
        (item.locked.isAfter(DateTime.now()) ||
            GlobalData.space.allowBookings)) {
      if (max == 0 || (max > 0 && clients.length < max)) {
        full = false;
      }
    } else {
      showBookingDisabled();
    }

    if (item.unlocked.isBefore(DateTime.now()) &&
        (item.locked.isAfter(DateTime.now()) ||
            GlobalData.space.allowBookings)) {
      List<Widget> items = [];
      if (clients.contains(GlobalData.space.client)) {
        items.add(TextButton(
          child: Text("Cancel your booking"),
          onPressed: () {
            //updateBooking("remove", GlobalData.space.client);
            Navigator.of(context).pop();
            showRecCancel("remove", GlobalData.space.client);
          },
        ));
      } else {
        if (waiting.contains(GlobalData.space.client)) {
          items.add(TextButton(
            child: Text("Remove yourself from waiting list"),
            onPressed: () {
              updateWaiting("remove", GlobalData.space.client);
              Navigator.of(context).pop();
            },
          ));
        } else {
          if (full) {
            items.add(TextButton(
              child: Text("Add yourself to waiting list"),
              onPressed: () {
                updateWaiting("add", GlobalData.space.client);
                Navigator.of(context).pop();
              },
            ));
          } else {
            items.add(TextButton(
              child: Text("Book yourself in"),
              onPressed: () {
                //updateBooking("add", GlobalData.space.client);
                Navigator.of(context).pop();
                showRecBooking("add", GlobalData.space.client);
              },
            ));
          }
        }
      }

      for (var pr in GlobalData.space.linked) {
        if (clients.contains(pr.id)) {
          items.add(TextButton(
            child: Text("Cancel booking for " + pr.name),
            onPressed: () {
              //updateBooking("remove", pr.id);
              Navigator.of(context).pop();
              showRecCancel("remove", pr.id);
            },
          ));
        } else {
          if (waiting.contains(pr.id)) {
            items.add(TextButton(
              child: Text("Remove " + pr.name + " from waiting list"),
              onPressed: () {
                updateWaiting("remove", pr.id);
                Navigator.of(context).pop();
              },
            ));
          } else {
            if (full) {
              items.add(TextButton(
                child: Text("Add " + pr.name + " to waiting list"),
                onPressed: () {
                  updateWaiting("add", pr.id);
                  Navigator.of(context).pop();
                },
              ));
            } else {
              items.add(TextButton(
                child: Text("Book in " + pr.name),
                onPressed: () {
                  //updateBooking("add", pr.id);
                  Navigator.of(context).pop();
                  showRecBooking("add", pr.id);
                },
              ));
            }
          }
        }
      }

      items.add(TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ));

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
