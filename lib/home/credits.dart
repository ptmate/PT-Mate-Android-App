import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_helper/billing.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/home/history.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/messaging/chat.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/components/list-text.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/button-action.dart';
import 'package:ptmate_client/components/data.dart';
import 'package:ptmate_client/main.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/tools/index.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage();
  static _CreditsPageState appState = _CreditsPageState();
  @override
  _CreditsPageState createState() {
    return CreditsPage.appState = new _CreditsPageState();
  }
}

class _CreditsPageState extends State<CreditsPage> {
  List<ModelPack> packs = [];
  List<ModelPack> general = [];
  List<ModelDebit> memberships = [];
  List<ModelSession> attended = [];
  List<ModelSession> noshows = [];
  List<ModelSession> booked = [];
  List<ModelSession> waiting = [];
  String client = GlobalData.space.client;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  int avail11 = 0;
  int availgr = 0;
  int unpaid11 = 0;
  int unpaidgr = 0;
  bool sub11 = false;
  bool subgr = false;
  bool enddebit = false;

  @override
  void initState() {
    super.initState();
    getSpaceBilling(GlobalData.space.id, GlobalData.space.client);
    configureData();
  }

  updateData() {
    if (this.mounted) {
      configureData();
    }
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

  configureData() {
    List<ModelPack> tmp = [];
    List<ModelPack> tmp1 = [];
    List<ModelDebit> tmp2 = [];
    var a1 = 0;
    var a2 = 0;
    var u1 = 0;
    var u2 = 0;
    var sgr = false;
    var s11 = false;

    var s = DateTime.now();
    var e = DateTime.now();

    for (var item in GlobalData.packs) {
      if (item.account == "" || item.account == client) {
        if (item.expires && item.expiry.isAfter(DateTime.now())) {
          tmp.add(item);
          if (item.group) {
            a2 += (item.paid - item.done);
          } else {
            a1 += (item.paid - item.done);
          }
        }
        if (!item.expires) {
          if (item.done < item.paid) {
            tmp.add(item);
          } else {
            tmp1.add(item);
          }
          if (item.group) {
            a2 += (item.paid - item.done);
          } else {
            a1 += (item.paid - item.done);
          }
        }
      }
    }
    for (var item in GlobalData.debits) {
      if (item.account == "" || item.account == client) {
        tmp2.add(item);
        if (item.group) {
          a2 += (item.sessions - item.done);
          if (item.is11) {
            a1 += (item.sessions11 - item.done11);
          }
          if (item.sessions == 0) {
            sgr = true;
          }
        } else {
          a1 += (item.sessions - item.done);
          if (item.sessions == 0) {
            s11 = true;
          }
        }
      }
    }
    for (var item in GlobalData.debits) {
      if (item.account == "" || item.account == client) {
        if (item.group && item.sessions == 0) {
          a2 = 999999;
        }
        if (!item.group && item.sessions == 0) {
          a2 = 999999;
        }
      }
    }
    if (a1 < 0) {
      a1 = 0;
      u1 = -a1;
    }
    if (a2 < 0) {
      a2 = 0;
      u2 = -a2;
    }

    var endDate = DateTime.now().add(Duration(days: 7));
    enddebit = false;
    if (GlobalData.debits.length > 0) {
      e = GlobalData.debits[0].next;
      endDate = GlobalData.debits[0].next;
      enddebit = true;
      if (GlobalData.debits[0].cycle == "week") {
        s = GlobalData.debits[0].next
            .subtract(Duration(days: GlobalData.debits[0].interval * 7));
      } else if (GlobalData.debits[0].cycle == "fortnight") {
        s = GlobalData.debits[0].next.subtract(Duration(days: 14));
      } else {
        s = e.subtract(Duration(days: 30 * GlobalData.debits[0].interval));
      }
    } else {
      var s1 = DateFormat("MM/yyyy").format(DateTime.now());
      s = DateFormat("dd/MM/yyyy").parse("01/" + s1);
      e = s.add(Duration(days: 30));
    }

    // Sessions
    List<ModelSession> tmp11 = [];
    List<ModelSession> tmp12 = [];
    List<ModelSession> tmp13 = [];
    List<ModelSession> tmp14 = [];
    for (var item in GlobalData.sessions) {
      if (item.date.isAfter(s) && item.date.isBefore(e)) {
        if (item.date.isBefore(DateTime.now()) &&
            item.attendance == 3 &&
            (item.clients.contains(client) || item.type == "pt")) {
          tmp11.add(item);
        }
        if (item.date.isBefore(DateTime.now()) &&
            item.attendance == 4 &&
            item.type == "pt") {
          tmp12.add(item);
        }
        if (item.date.isBefore(DateTime.now()) &&
            item.noshows.contains(client) &&
            item.type == "group") {
          tmp12.add(item);
        }
        if (item.date.isAfter(DateTime.now()) &&
            (item.clients.contains(client) || item.type == "pt")) {
          tmp13.add(item);
          if (item.date.isBefore(endDate)) {
            if (item.type == "group" && !item.availability) {
              a2--;
            } else {
              if (item.client == client) {
                a1--;
              }
            }
          }
        }
        if (item.date.isAfter(DateTime.now()) &&
            item.waiting.contains(client)) {
          tmp14.add(item);
        }
      }
    }
    setState(() {
      packs = tmp;
      general = tmp1;
      memberships = tmp2;
      attended = tmp11;
      noshows = tmp12;
      booked = tmp13;
      waiting = tmp14;
      availgr = a2;
      avail11 = a1;
      unpaidgr = u2;
      unpaid11 = u1;
      start = s;
      end = e;
      subgr = sgr;
      sub11 = s11;
    });
  }

  tapAttended() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HistoryPage("Attended", attended)),
    );
  }

  tapNoshows() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage("No shows", noshows)),
    );
  }

  tapBooked() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage("Booked", booked)),
    );
  }

  tapWaiting() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HistoryPage("Waiting list", waiting)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TitleLabelBack("Membership"),
              ),
              InkWell(
                onTap: () {
                  if (GlobalData.space.linked.length > 0) {
                    showSelection();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(70, 0, 20, 0),
                  child: Text(
                    _getName(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _getContent()),
                ),
              ),
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

  _getName() {
    var name = GlobalUser.name;
    if (client != GlobalData.space.client) {
      for (var cl in GlobalData.space.linked) {
        if (cl.id == client) {
          name = cl.name;
        }
      }
    }
    return name;
  }

  showSelection() {
    var actions = [
      TextButton(
        child: Text("Yourself"),
        onPressed: () {
          setState(() {
            client = GlobalData.space.client;
          });
          configureData();
          Navigator.of(context).pop();
        },
      ),
    ];
    for (var cl in GlobalData.space.linked) {
      actions.add(TextButton(
        child: Text(cl.name),
        onPressed: () {
          setState(() {
            client = cl.id;
          });
          configureData();
          Navigator.of(context).pop();
        },
      ));
    }
    actions.add(TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ));
    AlertDialog alert = AlertDialog(
      title: Text("View membership"),
      content: Text("Show credits available to"),
      actions: actions,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _getContent() {
    List<Widget> items = [];
    for (var item in memberships) {
      items.add(ListDefault(
          item.name,
          _getSublabel(item),
          _getStatus(item, 'membership'),
          item.group ? GlobalUI.gradients[0] : GlobalUI.gradients[1],
          _getIcon(item),
          false));
    }
    if (packs.length > 0) {
      items.add(SubtitleLabel("Packs with Available credits"));
      for (var item in packs) {
        if (item.expires) {
          if (item.paid > item.done) {
            items.add(ListDefault(
                item.name,
                _getSublabelPack(item),
                _getStatus(item, 'pack'),
                item.group ? GlobalUI.gradients[0] : GlobalUI.gradients[1],
                _getIcon(item),
                false));
          }
        } else {
          items.add(ListDefault(
              "General " + (item.group ? "class" : "1:1") + " credits",
              (item.paid - item.done).toString() +
                  (item.group ? " classes" : " 1:1 sessions") +
                  "\nNever expire",
              "",
              item.group ? GlobalUI.gradients[0] : GlobalUI.gradients[1],
              _getIcon(item),
              false));
        }
      }
    }

    if (memberships.length == 0) {
      items.add(SubtitleLabel("This Month"));
    } else {
      var df = DateFormat("d MMM");
      items.add(SubtitleLabel("Current period: Ending " + df.format(end)));
    }
    items.add(
      BtnAction(
          label1: attended.length.toString() + " attended",
          label2: noshows.length.toString() + " no shows",
          clickFn1: tapAttended,
          clickFn2: tapNoshows),
    );
    items.add(
      BtnAction(
          label1: booked.length.toString() + " booked",
          label2: waiting.length.toString() + " waiting list",
          clickFn1: tapBooked,
          clickFn2: tapWaiting),
    );

    if (unpaidgr > 0 || unpaid11 > 0) {
      items.add(SubtitleLabel("Unpaid classes & sessions"));
    }
    if (unpaidgr > 0) {
      items.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatPage(GlobalData.chat.id, GlobalData.chat, "pt")),
            );
          },
          child: ListText("Classes",
              unpaidgr.toString() + " unpaid\nTap to open the chat")));
    }
    if (unpaid11 > 0) {
      items.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatPage(GlobalData.chat.id, GlobalData.chat, "pt")),
            );
          },
          child: ListText("1:1 sessions",
              unpaid11.toString() + " unpaid\nTap to open the chat")));
    }

    items.add(Container(height: 40));
    items.add(DataLabel("Available classes left",
        (availgr == 999999 ? "Unlimited" : availgr.toString())));
    items.add(DataLabel("Available 1:1 sessions left",
        (avail11 == 999999 ? "Unlimited" : avail11.toString())));

    if (!subgr && !sub11) {
      items.add(Container(height: 10));
      items.add(
        Text(
          "Note: Available sessions are based on your purchased credits (both memberships and packs) minus unpaid sessions and future bookings" +
              (enddebit ? "" : " in the next 7 days") +
              ".",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
        ),
      );
    }

    return items;
  }

  _getSublabel(item) {
    var label = "";
    var type = " sessions";
    var amount = "Unlimited";
    if (item.sessions != 0) {
      amount = item.sessions.toString();
    }
    if (item.sessions == 1) {
      type = " session";
      amount = "1";
    }
    if (item.group) {
      type = " classes";
      if (item.sessions == 1) {
        type = " class";
      }
    }
    var used = "";
    if (item.done > 0) {
      used = " (" + item.done.toString() + " used)";
    }
    var add = "";
    if (item.is11) {
      add = " & " +
          item.sessions11.toString() +
          "session" +
          (item.sessions11 == 1 ? "" : "s");
      if (item.done11 > 0) {
        add = " & " +
            item.sessions11.toString() +
            "session" +
            (item.sessions11 == 1 ? "" : "s") +
            " (" +
            item.done11.toString() +
            " used)";
      }
    }
    label = amount +
        type +
        used +
        add +
        _getFamily(item.account) +
        "\nBilled " +
        item.cycle +
        "ly";
    if (item.interval != 1) {
      label = amount +
          type +
          add +
          _getFamily(item.account) +
          "\nBilled every " +
          item.interval.toString() +
          " " +
          item.cycle +
          "s";
    }
    return label;
  }

  _getIcon(item) {
    var icon = "session-11.svg";
    if (item.group) {
      icon = "session-group.svg";
    }
    return icon;
  }

  _getStatus(item, type) {
    var label = "Active";

    if (type == "membership") {
      if (item.pause != null && item.pause.toString().isNotEmpty) {
        int pauseValue = int.tryParse(item.pause.toString()) ?? 0;

        if (pauseValue > 0) {
          var pause = DateTime.fromMillisecondsSinceEpoch(pauseValue * 1000);
          label = "Paused until ${HelperCal.getSpecialDateBasic(pause)}";
        }
      }

      if (item.status == "trialing") {
        label = "Starts ${HelperCal.getSpecialDateBasic(item.next)}";
      }
    } else {
      if (item.expiry.isBefore(DateTime.now().add(Duration(days: 4)))) {
        label = "Expire soon";
      }
    }

    return label;
  }

  _getSublabelPack(item) {
    var label = "";
    var type = " sessions";
    var amount = item.paid.toString();
    if (item.paid == 1) {
      type = " session";
      amount = "1";
    }
    if (item.group) {
      type = " classes";
      if (item.paid == 1) {
        type = " class";
      }
    }
    var used = "";
    if (item.done > 0) {
      used = " (" + item.done.toString() + " used)";
    }
    label = amount +
        type +
        used +
        _getFamily(item.account) +
        "\nExpire " +
        HelperCal.getSpecialDateBasic(item.expiry);
    return label;
  }

  _getFamily(account) {
    var label = "";
    if (account == "" &&
        (GlobalData.space.linked.length > 0 || GlobalData.space.parent != "")) {
      label = " (All members)";
    }
    return label;
  }
}
