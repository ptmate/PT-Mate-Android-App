//import 'dart:js_util';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/account/index.dart';
import 'package:ptmate_client/account/invoice.dart';
import 'package:ptmate_client/account/receipt.dart';
import 'package:ptmate_client/calendar/event.dart';
import 'package:ptmate_client/calendar/image.dart';
import 'package:ptmate_client/calendar/index.dart';
import 'package:ptmate_client/calendar/leaderboard.dart';
import 'package:ptmate_client/calendar/results.dart';
import 'package:ptmate_client/calendar/session.dart';
import 'package:ptmate_client/components/post.dart';
import 'package:ptmate_client/health/assessment.dart';
import 'package:ptmate_client/health/habit.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:ptmate_client/home/card.dart';
import 'package:ptmate_client/home/cards.dart';
import 'package:ptmate_client/home/forms.dart';
import 'package:ptmate_client/home/index.dart';
import 'package:ptmate_client/home/new-debit.dart';
import 'package:ptmate_client/home/new-payment.dart';
import 'package:ptmate_client/home/pay-invoice.dart';
import 'package:ptmate_client/home/payments.dart';
import 'package:ptmate_client/init/addtrainer.dart';
import 'package:ptmate_client/init/connect.dart';
import 'package:ptmate_client/init/login-login.dart';
import 'package:ptmate_client/init/login-register.dart';
import 'package:ptmate_client/init/register.dart';
import 'package:ptmate_client/init/request.dart';
import 'package:ptmate_client/init/scanner.dart';
import 'package:ptmate_client/init/trainer.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/messaging/chat.dart';
import 'package:ptmate_client/messaging/index.dart';
import 'package:ptmate_client/nav.dart';
import 'package:ptmate_client/tools/form.dart';
import 'package:ptmate_client/tools/index.dart';
import 'package:ptmate_client/tools/notes.dart';
import 'package:ptmate_client/training/index.dart';
import 'package:ptmate_client/training/plan.dart';
import 'package:ptmate_client/training/program.dart';

class Connector {
  // User data
  static void getUser() {
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        if (data["name"] != null) {
          GlobalUser.name = data["name"];
          GlobalUser.phone = data["phone"];
          GlobalUser.height = data["height"] ?? 0;
          GlobalUser.birth = data["birth"];
          GlobalUser.image = data["image"];
          GlobalUser.lbs = (data["lbs"] is bool ? data["lbs"] : false);
          GlobalUser.country =
              (data["country"] is String ? data["country"] : "au");
          GlobalUI.mobile = (data["mobile"] is String ? data["mobile"] : "");
          HomePage.appState.updateData();
          GlobalUser.reminder =
              (data["reminder"] is bool ? data["reminder"] : true);

          //Emergency contact
          GlobalUser.ecName = (data["ecName"] is String ? data["ecName"] : "");
          GlobalUser.ecPhone =
              (data["ecPhone"] is String ? data["ecPhone"] : "");
          GlobalUser.ecType = (data["ecType"] is int ? data["ecType"] : 99);

          if (data["avatar"] != null) {
            GlobalUser.avatar =
                (data["avatar"] is String ? data["avatar"] : "");
          }

          if (data["trainers"] != null) {
            GlobalUser.spaces = data["trainers"].length;
            data["trainers"].forEach((index, trainer) =>
                ({getSpace(trainer["trainer"], trainer["client"])}));
          }
        }
      } else {
        print("doesnt exist");
      }

      MainPage.appState.updateData();
      LoginLoginPage.appState.updateData();
      LoginRegisterPage.appState.updateData();
      AccountPage.appState.updateData();
    });
  }

  // Training space

  static void getSpace(id, client) {
    var ref = FirebaseDatabase.instance.ref().child("spaces/" + id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        bool active = true;
        bool comments = true;
        bool showBooked = true;
        bool add = true;
        bool community = false;
        bool communityPost = false;
        String welcome = "";
        int welcomeTime = 0;
        double gst = 0;
        bool enterprise = false;
        List newLocations = [];
        List newGroups = [];
        if (data["comments"] != null) {
          comments = (data["comments"] is bool ? data["comments"] : true);
        }
        if (data["showBooked"] != null) {
          showBooked = (data["showBooked"] is bool ? data["showBooked"] : true);
        }
        for (var item in GlobalData.spaces) {
          if (item.id == id) {
            add = false;
          }
        }
        if (data["welcome"] != null) {
          welcome = (data["welcome"] is String ? data["welcome"] : "");
        }
        if (data["welcomeTime"] != null) {
          welcomeTime = (data["welcomeTime"] is int ? data["welcomeTime"] : 0);
        }
        if (data["gst"] != null) {
          var gst1 = data["gst"].toString();
          gst = double.parse(gst1);
        }
        if (data["newLocations"] != null) {
          newLocations =
              (data["newLocations"] is List ? data["newLocations"] : []);
        }
        if (data["newGroups"] != null) {
          newGroups = (data["newGroups"] is List ? data["newGroups"] : []);
        }
        if (add) {
          var status =
              (data["subStatus"] is String ? data["subStatus"] : "active");
          var plan = (data["subPlanId"] is String ? data["subPlanId"] : "");
          var address = (data["invoice1"] is String ? data["invoice1"] : "");
          if (plan == "price_1R3uS7Ad6uNQtfqamRID4K0d" ||
              plan == "price_1R3uT2Ad6uNQtfqa2w2bk3Wb" ||
              status == "trialing") {
            enterprise = true;
          }
          if (address == "") {
            var tmp = (data["address"] is String ? data["address"] : "");
            var arr = tmp.split("||");
            if (arr.length > 3) {
              address = arr[1] + "\n" + arr[2] + ", " + arr[3];
            }
          }
          GlobalData.spaces.add(ModelSpace(
              id,
              (data["owner"] is String ? data["owner"] : "Space"),
              (data["name"] is String ? data["name"] : ""),
              (data["email"] is String ? data["email"] : ""),
              (data["phone"] is String ? data["phone"] : ""),
              (data["image"] is String ? data["image"] : ""),
              client,
              "",
              "",
              (data["stripeConnect"] is String ? data["stripeConnect"] : ""),
              ["", "", "", "", ""],
              [],
              [],
              active,
              comments,
              showBooked,
              (data["allowBooking"] is bool ? data["allowBooking"] : false),
              "",
              "",
              0,
              0,
              (data["community"] is bool ? data["community"] : false),
              (data["communityPost"] is bool ? data["communityPost"] : false),
              (data["theme"] is String ? data["theme"] : "default"),
              (data["pin"] is String ? data["pin"] : ""),
              [],
              false,
              (data["preExercise"] is String ? data["preExercise"] : ""),
              (data["reminder"] is int ? data["reminder"] : 24),
              "",
              [],
              false,
              (data["limitBooking"] is bool ? data["limitBooking"] : false),
              (data["country"] is String ? data["country"] : "au"),
              (data["lbs"] is bool ? data["lbs"] : false),
              "",
              (data["allowRecurring"] is bool ? data["allowRecurring"] : false),
              (data["chargeSessions"] is bool ? data["chargeSessions"] : true),
              false,
              address,
              (data["invoice2"] is String ? data["invoice2"] : ""),
              (data["emailReminder"] is bool ? data["emailReminder"] : false),
              true,
              welcome,
              welcomeTime,
              gst,
              enterprise,
              newLocations,
              newGroups));
          getSpaceToken(GlobalData.spaces[GlobalData.spaces.length - 1]);
          getSpaceClient(
              GlobalData.spaces[GlobalData.spaces.length - 1], client);
          getSpaceForms(
              GlobalData.spaces[GlobalData.spaces.length - 1], client);
          setLimits(
              GlobalData.spaces[GlobalData.spaces.length - 1], status, plan);
          MainPage.appState.updateSpaces();
          LoginLoginPage.appState.updateSpaces();
          LoginRegisterPage.appState.updateData();
          AccountPage.appState.updateData();
        }
      }
    });
  }

  // Space staff

  static void getSpaceStaff() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("spaces/" + GlobalData.space.id + "/staff");
    GlobalData.allStaff = [];
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        data.forEach((index, data) => ({
              GlobalData.allStaff.add(ModelClientChat(
                  (data["id"] is String ? data["id"] : ""),
                  DateTime.now(),
                  (data["name"] is String ? data["name"] : "Staff member"),
                  (data["pushToken"] is String ? data["pushToken"] : "")))
            }));
        Connector.getChats();
        ConnectPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Training space forms

  static void setLimits(space, status, plan) {
    space.showForms = false;
    space.showHabits = false;
    if (status == "active") {
      if (GlobalUI.subsPro.contains(plan)) {
        space.showForms = true;
      }
      if (GlobalUI.subsBus.contains(plan)) {
        space.showForms = true;
        space.showHabits = true;
      }
    } else if (status == "trialing") {
      space.showForms = true;
      space.showHabits = true;
    }
    if (status != "trialing") {
      if (!GlobalUI.subsPro.contains(plan)) {
        space.welcome = "";
      }
    }
  }

  // Training space token

  static void getSpaceToken(space) {
    var ref = FirebaseDatabase.instance.ref().child("users/" + space.id);
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      space.token = (data["pushToken"] is String ? data["pushToken"] : "");
    });
  }

  // Training space client

  static void getSpaceClient(space, client) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("clients/" + space.id + "/" + client);
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      bool active = true;
      List billing = ["", "", "", "", ""];
      List<ModelForm> forms = [];
      //space.forms = [];
      List<ModelSection> sections = [];
      DateTime date = DateTime(1900);
      List linked = [];
      bool del = false;

      if (data["active"] != null) {
        active = (data["active"] is bool ? data["active"] : true);
      }
      if (data["customer"] != null) {
        billing[0] = (data["customer"] is String ? data["customer"] : "");
      }
      if (data["cardId"] != null) {
        billing[1] = (data["cardId"] is String ? data["cardId"] : "");
      }
      if (data["cardBrand"] != null) {
        billing[2] = (data["cardBrand"] is String ? data["cardBrand"] : "");
      }
      if (data["cardLast4"] != null) {
        billing[3] = (data["cardLast4"] is String ? data["cardLast4"] : "");
      }
      if (data["cardExpiry"] != null) {
        billing[4] = (data["cardExpiry"] is String ? data["cardExpiry"] : "");
      }
      space.goal = (data["goal"] is String ? data["goal"] : "");
      GlobalUI.token = (data["pushToken"] is String ? data["pushToken"] : "");
      space.active = active;
      space.billing = billing;

      space.parent = (data["parent"] is String ? data["parent"] : "");
      linked = (data["linked"] is List ? data["linked"] : []);
      space.restricted =
          (data["restricted"] is bool ? data["restricted"] : false);
      space.customer = (data["customer"] is String ? data["customer"] : "");
      if (data["emailReminder"] != null) {
        space.clientEmailReminder =
            (data["emailReminder"] is bool ? data["emailReminder"] : true);
      }

      space.linked = [];
      for (var item in linked) {
        getSpaceProfile(space, item);
      }

      if (data["nutritionId"] != null) {
        space.nutritionId =
            (data["nutritionId"] is String ? data["nutritionId"] : "");
        space.nutritionStatus =
            (data["nutritionStatus"] is String ? data["nutritionStatus"] : "");
        space.nutritionStart =
            (data["nutritionStart"] is int ? data["nutritionStart"] : 0);
        space.nutritionEnd =
            (data["nutritionEnd"] is int ? data["nutritionEnd"] : 0);
      }

      if (data["deleted"] != null) {
        del = (data["deleted"] is String ? data["deleted"] : false);
        if (del && GlobalUI.isSignup) {
          FirebaseDatabase.instance
              .ref()
              .child("clients/" + space.id + "/" + client + "/deleted")
              .remove();
          //GlobalUI.isSignup = false;
        }
      }

      HomePage.appState.updateData();
      HealthPage.appState.updateData();
      AccountPage.appState.updateData();
      FormPage.appState.updateData();
      FormsPage.appState.updateData();
      NewDebitPage.appState.updateClient();
    });
  }

  // Get client forms

  static void getSpaceForms(space, client) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("clients/" + space.id + "/" + client + '/forms');
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value == null
          ? Map()
          : snapshot.snapshot.value as Map;
      space.forms = [];
      List<ModelSection> sections = [];
      DateTime date = DateTime(1900);
      data.forEach((index, data) => ({
            date = DateTime(1900),
            if (data["date"] != null)
              {
                date = DateTime.fromMillisecondsSinceEpoch(
                    data["date"].toInt() * 1000)
              },
            sections = [],
            if (data["sections"] != null)
              {
                data["sections"].forEach((fskey, section) => ({
                      sections.add(ModelSection(
                        fskey,
                        (section["seq"] is int ? section["seq"] : 0),
                        (section["type"] is String ? section["type"] : ""),
                        (section["label"] is String ? section["label"] : ""),
                        (section["num"] is int ? section["num"] : 2),
                        (section["multiple"] is bool
                            ? section["multiple"]
                            : false),
                        (section["answer1"] is bool
                            ? section["answer1"]
                            : false),
                        (section["answer2"] is bool
                            ? section["answer2"]
                            : false),
                        (section["response"] is String
                            ? section["response"]
                            : ""),
                        (section["detail"] is String ? section["detail"] : ""),
                        (section["options"] is List ? section["options"] : []),
                        (section["mandatory"] is bool
                            ? section["mandatory"]
                            : false),
                      ))
                    }))
              },
            sections.sort((a, b) => a.seq.compareTo(b.seq)),
            space.forms.add(ModelForm(
                index,
                (data["name"] is String ? data["name"] : ""),
                date,
                (data["pre"] is bool ? data["pre"] : false),
                (data["version"] is int ? data["version"] : 1),
                (data["uid"] is String ? data["uid"] : GlobalData.space.id),
                (data["lock"] is bool ? data["lock"] : false),
                sections))
          }));

      FormsPage.appState.updateData();
      HomePage.appState.updateData();
      FormPage.appState.updateData();
      FormPage.appState.updateData();
    });
  }

  // Get additional profiles

  static void getSpaceProfile(space, client) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("clients/" + space.id + "/" + client);
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      bool restricted =
          (data["restricted"] is bool ? data["restricted"] : false);
      String avatar = (data["avatar"] is String ? data["avatar"] : "");
      space.linked.add(ModelClient(
          client,
          (data["name"] is String ? data["name"] : "Member"),
          "",
          "",
          "",
          GlobalData.space.client,
          restricted,
          avatar));
    });
  }

  // Training space credits & subs

  //--------------------------------
  static void getSpaceBilling(id, client) {
    try {
      var ref =
          FirebaseDatabase.instance.ref().child("clients/" + id + "/" + client);

      ref.onValue.listen((snapshot) {
        try {
          final rawValue = snapshot.snapshot.value;

          // 1. Safety check: If the snapshot is null, don't erase existing data yet.
          if (rawValue == null || rawValue is! Map) {
            FirebaseSender.addBookingLog("billing_status", "",
                {"warning": "Empty or non-map snapshot received", "id": id});
            return;
          }

          Map data = rawValue;

          // 2. Use temporary lists to ensure we don't clear GlobalData until we have new data ready.
          List<ModelPack> newPacks = [];
          List<ModelDebit> newDebits = [];

          // Handle Credits
          if (data["credits"] != null) {
            data["credits"].forEach((index, pack) {
              try {
                if (pack is Map) {
                  DateTime expiry = DateTime.now();
                  bool expires = false;

                  if (pack["expires"] != null) {
                    expiry = DateTime.fromMillisecondsSinceEpoch(
                        (pack["expires"] * 1000).toInt());
                    expires = true;
                  }

                  newPacks.add(ModelPack(
                    index,
                    (pack["group"] == true),
                    (pack["sessionsPaid"] is int ? pack["sessionsPaid"] : 0),
                    (pack["sessionsTotal"] is int ? pack["sessionsTotal"] : 0),
                    expires,
                    expiry,
                    (pack["account"]?.toString() ?? ""),
                    (pack["name"]?.toString() ?? ""),
                    (pack["product"]?.toString() ?? ""),
                  ));
                }
              } catch (e) {
                print("Error parsing pack $index: $e");
              }
            });
          }

          // Handle Subscriptions
          if (data["subscriptions"] != null) {
            data["subscriptions"].forEach((index, sub) {
              try {
                if (sub is Map) {
                  newDebits.add(ModelDebit(
                    index,
                    (sub["name"]?.toString() ?? "Membership"),
                    (sub["billing"]?.toString() ?? "week"),
                    (sub["interval"] is int ? sub["interval"] : 1),
                    (sub["price"] is num
                        ? (sub["price"] as num).toDouble()
                        : 0.0),
                    DateTime.fromMillisecondsSinceEpoch(
                        (sub["next"] * 1000).toInt()),
                    (sub["group"] != false), // default to true
                    (sub["sessions"] is int ? sub["sessions"] : 0),
                    (sub["sessions11"] is int ? sub["sessions11"] : 0),
                    (sub["status"]?.toString() ?? "active"),
                    (sub["account"]?.toString() ?? ""),
                    (sub["is11"] == true),
                    (sub["done"] is int ? sub["done"] : 0),
                    (sub["done11"] is int ? sub["done11"] : 0),
                    (sub["pause"]?.toString() ?? ""),
                    (sub["plan"]?.toString() ?? ""),
                  ));
                }
              } catch (e) {
                print("Error parsing sub $index: $e");
              }
            });
          }

          // 3. Atomic Assignment: Update the global state only after processing is done.
          GlobalData.packs = newPacks;
          GlobalData.debits = newDebits;

          // 4. Update UI
          ConnectPage.appState.updateData();
          HomePage.appState.updateData();
          AccountPage.appState.updateData();
          ToolsPage.appState.updateData();
        } catch (innerError) {
          print("Internal Billing Error: $innerError");
          FirebaseSender.addBookingLog(
              "billing_error", "", {"error": innerError.toString()});
        }
      }, onError: (error) {
        FirebaseSender.addBookingLog(
            "billing_listener_error", "", {"error": error.toString()});
      });
    } catch (e) {
      print("Setup error: $e");
      FirebaseSender.addBookingLog(
          "new_splash_loading", "", {"setup_error": "$e"});
    }
  }

  // static void getSpaceBilling(id, client) {
  //   try {
  //     var ref =
  //         FirebaseDatabase.instance.ref().child("clients/" + id + "/" + client);
  //     ref.onValue.listen((snapshot) {
  //       Map data = snapshot.snapshot.value as Map;
  //       GlobalData.packs = [];
  //       GlobalData.debits = [];
  //       bool expires = false;
  //       DateTime expiry = DateTime.now();
  //       if (data["credits"] != null) {
  //         data["credits"].forEach((index, pack) => ({
  //               expiry = DateTime.now(),
  //               expires = false,
  //               if (pack["expires"] != null)
  //                 {
  //                   expiry = DateTime.fromMillisecondsSinceEpoch(
  //                       pack["expires"] * 1000),
  //                   expires = true,
  //                 },
  //               GlobalData.packs.add(ModelPack(
  //                 index,
  //                 (pack["group"] is bool ? pack["group"] : false),
  //                 (pack["sessionsPaid"] is int ? pack["sessionsPaid"] : 0),
  //                 (pack["sessionsTotal"] is int ? pack["sessionsTotal"] : 0),
  //                 expires,
  //                 expiry,
  //                 (pack["account"] is String ? pack["account"] : ""),
  //                 (pack["name"] is String ? pack["name"] : ""),
  //                 (pack["product"] is String ? pack["product"] : ""),
  //               )),
  //             }));
  //       }
  //       if (data["subscriptions"] != null) {
  //         data["subscriptions"].forEach((index, sub) => ({
  //               GlobalData.debits.add(ModelDebit(
  //                 index,
  //                 (sub["name"] is String ? sub["name"] : "Membership"),
  //                 (sub["billing"] is String ? sub["billing"] : "week"),
  //                 (sub["interval"] is int ? sub["interval"] : 1),
  //                 sub["price"].toDouble(),
  //                 DateTime.fromMillisecondsSinceEpoch(sub["next"] * 1000),
  //                 (sub["group"] is bool ? sub["group"] : true),
  //                 (sub["sessions"] is int ? sub["sessions"] : 0),
  //                 (sub["sessions11"] is int ? sub["sessions11"] : 0),
  //                 (sub["status"] is String ? sub["status"] : "active"),
  //                 (sub["account"] is String ? sub["account"] : ""),
  //                 (sub["is11"] is bool ? sub["is11"] : false),
  //                 (sub["done"] is int ? sub["done"] : 0),
  //                 (sub["done11"] is int ? sub["done11"] : 0),
  //                 (sub["pause"] is String ? sub["pause"] : ""),
  //                 (sub["plan"] is String ? sub["plan"] : ""),
  //               ))
  //             }));
  //       }
  //       ConnectPage.appState.updateData();
  //       HomePage.appState.updateData();
  //       AccountPage.appState.updateData();
  //       ToolsPage.appState.updateData();
  //     });
  //   } catch (e) {
  //     print("======$e");
  //     FirebaseSender.addBookingLog("new_splash_loading", "", {"error": "$e"});
  //   }
  // }

  // Assessments

  static void getSpaceAssessments(id, client) {
    var ref =
        FirebaseDatabase.instance.ref().child("clients/" + id + "/" + client);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.assessments = [];
        int heart = 0;
        String nutrition = "";
        String image2 = "";
        String image3 = "";
        String image4 = "";

        if (data["assessments"] != null) {
          data["assessments"].forEach((index, assm) => ({
                heart = 0,
                nutrition = "",
                image2 = "",
                image3 = "",
                image4 = "",
                if (assm["heart"] != null) {heart = assm["heart"]},
                if (assm["nutrition"] != null)
                  {nutrition = (assm["nutrition"]).toString()},
                if (assm["image2"] != null)
                  {image2 = (assm["image2"] is String ? assm["image2"] : "")},
                if (assm["image3"] != null)
                  {image3 = (assm["image3"] is String ? assm["image3"] : "")},
                if (assm["image4"] != null)
                  {image4 = (assm["image4"] is String ? assm["image4"] : "")},
                GlobalData.assessments.add(ModelAssessment(
                    index,
                    GlobalUI.dateTime.parse(assm["date"]),
                    (assm["weight"]).toDouble(),
                    (assm["fat"]).toDouble(),
                    heart,
                    assm["image"],
                    assm["notes"],
                    (assm["abdomen"]).toDouble(),
                    (assm["chest"]).toDouble(),
                    (assm["hip"]).toDouble(),
                    (assm["neck"]).toDouble(),
                    (assm["armL"]).toDouble(),
                    (assm["armR"]).toDouble(),
                    (assm["thighL"]).toDouble(),
                    (assm["thighR"]).toDouble(),
                    nutrition,
                    image2,
                    image3,
                    image4,
                    (assm["blood1"] is String ? assm["blood1"] : ""),
                    (assm["blood2"] is String ? assm["blood2"] : ""),
                    (assm["custom"] is String ? assm["custom"] : "")))
              }));
        }
        HomePage.appState.updateData();
        HealthPage.appState.updateData();
        AssessmentPage.appState.updateData();
      }
    });
  }

  // Training sessions

  static void getSessions() {
    var ref =
        FirebaseDatabase.instance.ref().child("sessions/" + GlobalUser.uid);

    DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime cdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime unl = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime locked = GlobalUI.dateTime.parse("01/01/3100 00:00");

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.training = [];
        bool add = true;
        ModelProgram program =
            ModelProgram("", "", "", 0, 0, "", [], false, "");
        List<ModelBlock> blocks = [];
        List<ModelMovement> ex = [];
        List<ModelComment> comments = [];
        bool logResults = true;
        String wtype = "per";
        int cycles = 0;
        String bname = "";
        int time = 0;
        List timeGroup = [];

        String exRepsRounds = "";
        String exWeightRounds = "";
        String exResRepsRounds = "";
        String exResWeightRounds = "";
        List valueSimple = [];
        List amrapSimple = [];
        List scaledSimple = [];
        String unitSimple = "";

        bool bench = false;
        List units = [];
        String unit = "";
        List notes = [];
        String note = "";
        bool simple = false;
        String snotes = "";
        List highfives = [];

        data.forEach((index, data) => ({
              add = true,
              date = GlobalUI.dateTime.parse(data["date"]),
              cdate = GlobalUI.dateTime.parse(data["date"]),
              // Program
              program = ModelProgram("", "", "", 0, 0, "", [], false, ""),
              comments = [],
              blocks = [],
              highfives = [],
              add = true,
              if (data["highfives"] != null) {highfives = data["highfives"]},
              if (data["comments"] != null)
                {
                  data["comments"].forEach((ckey, comm) => ({
                        if (comm["date"] != null)
                          {
                            cdate = DateTime.fromMillisecondsSinceEpoch(
                                comm["date"].toInt() * 1000)
                          },
                        comments.add(ModelComment(
                            ckey,
                            (comm["sender"] is String ? comm["sender"] : ""),
                            cdate,
                            (comm["text"] is String ? comm["text"] : "")))
                      })),
                },
              if (data["workout"] != null)
                {
                  data["workout"].forEach((pkey, prog) => ({
                        bench = false,
                        if (prog["benchmark"] != null)
                          {
                            bench = (prog["benchmark"] is bool
                                ? prog["benchmark"]
                                : false)
                          },
                        (prog["blocks"] is List
                                ? {
                                    for (var i = 0;
                                        i < prog["blocks"].length;
                                        i++)
                                      if (prog["blocks"][i] != null)
                                        i.toString(): prog["blocks"][i]
                                  }
                                : prog["blocks"])
                            .forEach((key, block) => ({
                                  ex = [],
                                  cycles = 0,
                                  bname = "",
                                  logResults = true,
                                  time = 0,
                                  timeGroup = [],
                                  units = [],
                                  unit = "",
                                  notes = [],
                                  note = "",
                                  simple = false,
                                  snotes = "",
                                  valueSimple = [],
                                  amrapSimple = [],
                                  scaledSimple = [],
                                  unitSimple = "reps",
                                  for (var i = 0; i < block["exId"].length; i++)
                                    {
                                      wtype = "per",
                                      if (block["exWeightType"] != null)
                                        {
                                          wtype = (block["exWeightType"][i]
                                                  is String
                                              ? block["exWeightType"][i]
                                              : "kg")
                                        },
                                      exRepsRounds = "",
                                      if (block["exRepsRounds"] != null)
                                        {
                                          if (block["exRepsRounds"].length > i)
                                            {
                                              exRepsRounds =
                                                  (block["exRepsRounds"][i]
                                                          is String
                                                      ? block["exRepsRounds"][i]
                                                      : "")
                                            }
                                        },
                                      exWeightRounds = "",
                                      if (block["exWeightRounds"] != null)
                                        {
                                          if (block["exWeightRounds"].length >
                                              i)
                                            {
                                              exWeightRounds =
                                                  (block["exWeightRounds"][i]
                                                          is String
                                                      ? block["exWeightRounds"]
                                                          [i]
                                                      : "")
                                            }
                                        },
                                      exResRepsRounds = "",
                                      if (block["exResRepsRounds"] != null)
                                        {
                                          if (block["exResRepsRounds"].length >
                                              i)
                                            {
                                              exResRepsRounds =
                                                  (block["exResRepsRounds"][i]
                                                          is String
                                                      ? block["exResRepsRounds"]
                                                          [i]
                                                      : "")
                                            }
                                        },
                                      exResWeightRounds = "",
                                      if (block["exResWeightRounds"] != null)
                                        {
                                          if (block["exResWeightRounds"]
                                                  .length >
                                              i)
                                            {
                                              exResWeightRounds = (block[
                                                          "exResWeightRounds"]
                                                      [i] is String
                                                  ? block["exResWeightRounds"]
                                                      [i]
                                                  : "")
                                            }
                                        },
                                      if (block["timeRes"] != null)
                                        {
                                          time = (block["timeRes"] is int
                                              ? block["timeRes"]
                                              : 0)
                                        },
                                      if (block["timeResGroup"] != null)
                                        {timeGroup = block["timeResGroup"]},
                                      if (block["exUnits"] != null)
                                        {units = block["exUnits"]},
                                      if (units.length > i) {unit = units[i]},
                                      if (block["exNotes"] != null)
                                        {notes = block["exNotes"]},
                                      if (notes.length > i) {note = notes[i]},
                                      ex.add(ModelMovement(
                                        (block["exId"][i] is String
                                            ? block["exId"][i]
                                            : ""),
                                        (block["exName"][i] is String
                                            ? block["exName"][i]
                                            : ""),
                                        (block["exType"][i] is int
                                            ? block["exType"][i]
                                            : 0),
                                        (block["exCat"][i] is int
                                            ? block["exCat"][i]
                                            : 0),
                                        (block["exTool"][i] is int
                                            ? block["exTool"][i]
                                            : 0),
                                        (block["exReps"][i] is int
                                            ? block["exReps"][i]
                                            : 0),
                                        block["exWeight"][i].toDouble(),
                                        (block["exWork"][i] is int
                                            ? block["exWork"][i]
                                            : 0),
                                        (block["exRest"][i] is int
                                            ? block["exRest"][i]
                                            : 0),
                                        block["exResWeight"][i].toDouble(),
                                        (block["exResReps"][i] is int
                                            ? block["exResReps"][i]
                                            : 0),
                                        "",
                                        "",
                                        (block["exImage"][i] is String
                                            ? block["exImage"][i]
                                            : ""),
                                        wtype,
                                        exRepsRounds,
                                        exWeightRounds,
                                        exResRepsRounds,
                                        exResWeightRounds,
                                        "",
                                        "",
                                        unit,
                                        note,
                                      )),
                                    },
                                  if (block["logResults"] != null)
                                    {
                                      logResults = (block["logResults"] is bool
                                          ? block["logResults"]
                                          : true)
                                    },
                                  if (block["simple"] != null)
                                    {
                                      simple = (block["simple"] is bool
                                          ? block["simple"]
                                          : false)
                                    },
                                  if (block["cycles"] != null)
                                    {
                                      cycles = (block["cycles"] is int
                                          ? block["cycles"]
                                          : 1)
                                    },
                                  if (block["name"] != null)
                                    {
                                      bname = (block["name"] is String
                                          ? block["name"]
                                          : "")
                                    },
                                  if (block["notesResSimple"] != null)
                                    {
                                      snotes =
                                          (block["notesResSimple"] is String
                                              ? block["notesResSimple"]
                                              : "")
                                    },
                                  if (block["valueSimple"] != null)
                                    {
                                      valueSimple =
                                          (block["valueSimple"] is List
                                              ? block["valueSimple"]
                                              : [])
                                    },
                                  if (block["amrapSimple"] != null)
                                    {
                                      amrapSimple =
                                          (block["amrapSimple"] is List
                                              ? block["amrapSimple"]
                                              : [])
                                    },
                                  if (block["scaledSimple"] != null)
                                    {
                                      scaledSimple =
                                          (block["scaledSimple"] is List
                                              ? block["scaledSimple"]
                                              : [])
                                    },
                                  if (block["unitSimple"] != null)
                                    {
                                      unitSimple =
                                          (block["unitSimple"] is String
                                              ? block["unitSimple"]
                                              : "reps")
                                    },
                                  blocks.add(ModelBlock(
                                    key,
                                    (block["cat"] is int ? block["cat"] : 0),
                                    bname,
                                    (block["type"] is int ? block["type"] : 0),
                                    (block["rounds"] is int
                                        ? block["rounds"]
                                        : 1),
                                    (block["emom"] is bool
                                        ? block["emom"]
                                        : false),
                                    (block["notes"] is String
                                        ? block["notes"]
                                        : ""),
                                    (block["notesRes"] is String
                                        ? block["notesRes"]
                                        : ""),
                                    ex,
                                    logResults,
                                    cycles,
                                    time,
                                    timeGroup,
                                    simple,
                                    snotes,
                                    valueSimple,
                                    amrapSimple,
                                    scaledSimple,
                                    unitSimple,
                                  ))
                                })),
                        blocks.sort((a, b) => a.id.compareTo(b.id)),
                        program = ModelProgram(
                            pkey,
                            (prog["name"] is String ? prog["name"] : "Program"),
                            (prog["desc"] is String ? prog["desc"] : ""),
                            (prog["time"] is int ? prog["time"] : 1),
                            (prog["exercises"] is int ? prog["exercises"] : 1),
                            (prog["uid"] is String ? prog["uid"] : ""),
                            blocks,
                            bench,
                            (prog["video"] is String ? prog["video"] : ""))
                      })),
                },

              for (var item in GlobalData.training)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.training.add(ModelSession(
                      index,
                      date,
                      "Training Session",
                      (data["duration"] is int ? data["duration"] : 1),
                      [],
                      [],
                      [],
                      (data["trainerName"] is String
                          ? data["trainerName"]
                          : ""),
                      "training",
                      (data["link"] is String ? data["link"] : ""),
                      (data["attendance"] is int ? data["attendance"] : 2),
                      (data["max"] is int ? data["max"] : 0),
                      unl,
                      true,
                      [],
                      comments,
                      program,
                      [],
                      false,
                      locked,
                      "",
                      "",
                      [],
                      [],
                      "training",
                      "",
                      highfives,
                      [],
                      ""))
                }
            }));

        ConnectPage.appState.updateData();
        ResultsPage.appState.updateData();
        TrainingPage.appState.updateData();
        LeaderboardPage.appState.updateData();
        PlanPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Sessions

  static void getSessionsSpace() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("sessions/" + GlobalData.space.id);

    String type = "pt";
    String name = "PT Session";
    DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime cdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime unl = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime locked = GlobalUI.dateTime.parse("01/01/3100 00:00");
    bool add = true;
    bool avail = false;
    List memberships = [];
    List bookings = [];
    List highfives = [];

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.sessions = [];
        Map data = snapshot.snapshot.value as Map;
        ModelProgram program =
            ModelProgram("", "", "", 0, 0, "", [], false, "");
        List<ModelBlock> blocks = [];
        List<ModelMovement> ex = [];
        List<ModelComment> comments = [];
        bool logResults = true;
        List clients = [];
        List invitees = [];
        List waiting = [];
        List rating = [];
        List groups = [];
        List noshows = [];
        String wtype = "per";

        String exRepsRounds = "";
        String exWeightRounds = "";
        String exResRepsRounds = "";
        String exResWeightRounds = "";
        List valueSimple = [];
        List amrapSimple = [];
        List scaledSimple = [];
        String unitSimple = "";

        var rw = "";
        var ww = "";
        bool preview = true;
        bool bench = false;

        var trainer = "";
        var max = 0;
        var cycles = 0;
        String bname = "";
        int time = 0;
        List timeGroup = [];
        List units = [];
        String unit = "";
        List notes = [];
        String note = "";
        String desc = "";
        bool simple = false;
        String snotes = "";
        String location = "";
        String locationName = "";

        data.forEach((index, data) => ({
              print(index),
              if (data["group"] != null)
                {
                  add = true,
                  date = GlobalUI.dateTime.parse(data["date"]),
                  cdate = GlobalUI.dateTime.parse(data["date"]),
                  // Program
                  program = ModelProgram("", "", "", 0, 0, "", [], false, ""),
                  comments = [],
                  blocks = [],
                  add = true,
                  clients = [],
                  invitees = [],
                  waiting = [],
                  rating = [],
                  groups = [],
                  preview = true,
                  avail = false,
                  desc = "",
                  memberships = [],
                  bookings = [],
                  highfives = [],
                  noshows = [],

                  if (data["comments"] != null)
                    {
                      data["comments"].forEach((ckey, comm) => ({
                            if (comm["date"] != null)
                              {
                                cdate = DateTime.fromMillisecondsSinceEpoch(
                                    comm["date"].toInt() * 1000)
                              },
                            comments.add(ModelComment(
                                ckey,
                                (comm["sender"] is String
                                    ? comm["sender"]
                                    : ""),
                                cdate,
                                (comm["text"] is String ? comm["text"] : "")))
                          })),
                    },

                  if (data["clients"] != null) {clients = data["clients"]},
                  if (data["invitees"] != null) {invitees = data["invitees"]},
                  if (data["waiting"] != null) {waiting = data["waiting"]},
                  if (data["groups"] != null) {groups = data["groups"]},

                  if (data["rating"] != null) {rating = data["rating"]},

                  if (data["preview"] != null)
                    {
                      preview =
                          (data["preview"] is bool ? data["preview"] : true)
                    },

                  if (data["availability"] != null)
                    {
                      avail = (data["availability"] is bool
                          ? data["availability"]
                          : false)
                    },
                  if (data["desc"] != null)
                    {desc = (data["desc"] is String ? data["desc"] : "")},

                  if (data["memberships"] != null)
                    {memberships = data["memberships"]},
                  if (data["bookings"] != null) {bookings = data["bookings"]},
                  if (data["highfives"] != null)
                    {highfives = data["highfives"]},
                  if (data["noshows"] != null) {noshows = data["noshows"]},

                  if (data["workout"] != null)
                    {
                      data["workout"].forEach((pkey, prog) => ({
                            bench = false,
                            if (prog["benchmark"] != null)
                              {
                                bench = (prog["benchmark"] is bool
                                    ? prog["benchmark"]
                                    : false)
                              },
                            if (prog["blocks"] != null)
                              (prog["blocks"] is List
                                      ? {
                                          for (var i = 0;
                                              i < prog["blocks"].length;
                                              i++)
                                            if (prog["blocks"][i] != null)
                                              i.toString(): prog["blocks"][i]
                                        }
                                      : prog["blocks"])
                                  .forEach((key, block) => ({
                                        ex = [],
                                        cycles = 0,
                                        bname = "",
                                        logResults = true,
                                        time = 0,
                                        timeGroup = [],
                                        units = [],
                                        unit = "",
                                        notes = [],
                                        note = "",
                                        simple = false,
                                        snotes = "",
                                        valueSimple = [],
                                        amrapSimple = [],
                                        scaledSimple = [],
                                        unitSimple = "reps",
                                        for (var i = 0;
                                            i < block["exId"].length;
                                            i++)
                                          {
                                            rw = "",
                                            ww = "",
                                            if (block["exResRepsGroup"] != null)
                                              {
                                                rw = block["exResRepsGroup"][i]
                                                    .toString()
                                              },
                                            if (block["exResWeightGroup"] !=
                                                null)
                                              {
                                                ww = block["exResWeightGroup"]
                                                        [i]
                                                    .toString()
                                              },
                                            wtype = "per",
                                            if (block["exWeightType"] != null)
                                              {
                                                wtype = (block["exWeightType"]
                                                        [i] is String
                                                    ? block["exWeightType"][i]
                                                    : "kg")
                                              },
                                            exRepsRounds = "",
                                            if (block["exRepsRounds"] != null)
                                              {
                                                if (block["exRepsRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exRepsRounds = (block[
                                                                "exRepsRounds"]
                                                            [i] is String
                                                        ? block["exRepsRounds"]
                                                            [i]
                                                        : "")
                                                  }
                                              },
                                            exWeightRounds = "",
                                            if (block["exWeightRounds"] != null)
                                              {
                                                if (block["exWeightRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exWeightRounds = (block[
                                                                "exWeightRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exWeightRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            exResRepsRounds = "",
                                            if (block["exResRepsRounds"] !=
                                                null)
                                              {
                                                if (block["exResRepsRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exResRepsRounds = (block[
                                                                "exResRepsRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exResRepsRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            exResWeightRounds = "",
                                            if (block["exResWeightRounds"] !=
                                                null)
                                              {
                                                if (block["exResWeightRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exResWeightRounds = (block[
                                                                "exResWeightRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exResWeightRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            if (block["timeRes"] != null)
                                              {
                                                time = (block["timeRes"] is int
                                                    ? block["timeRes"]
                                                    : 0)
                                              },
                                            if (block["timeResGroup"] != null)
                                              {
                                                timeGroup =
                                                    block["timeResGroup"]
                                              },
                                            if (block["exUnits"] != null)
                                              {units = block["exUnits"]},
                                            if (units.length > i)
                                              {unit = units[i]},
                                            if (block["exNotes"] != null)
                                              {notes = block["exNotes"]},
                                            if (notes.length > i)
                                              {note = notes[i]},
                                            ex.add(ModelMovement(
                                              (block["exId"][i] is String
                                                  ? block["exId"][i]
                                                  : ""),
                                              (block["exName"][i] is String
                                                  ? block["exName"][i]
                                                  : ""),
                                              (block["exType"][i] is int
                                                  ? block["exType"][i]
                                                  : 0),
                                              (block["exCat"][i] is int
                                                  ? block["exCat"][i]
                                                  : 0),
                                              (block["exTool"][i] is int
                                                  ? block["exTool"][i]
                                                  : 0),
                                              (block["exReps"][i] is int
                                                  ? block["exReps"][i]
                                                  : 0),
                                              block["exWeight"][i].toDouble(),
                                              (block["exWork"][i] is int
                                                  ? block["exWork"][i]
                                                  : 0),
                                              (block["exRest"][i] is int
                                                  ? block["exRest"][i]
                                                  : 0),
                                              block["exResWeight"][i]
                                                  .toDouble(),
                                              (block["exResReps"][i] is int
                                                  ? block["exResReps"][i]
                                                  : 0),
                                              //block["exResWeightGroup"][i],
                                              //block["exResRepsGroup"][i],
                                              ww,
                                              rw,
                                              (block["exImage"][i] is String
                                                  ? block["exImage"][i]
                                                  : ""),
                                              wtype,
                                              exRepsRounds,
                                              exWeightRounds,
                                              exResRepsRounds,
                                              exResWeightRounds,
                                              "",
                                              "",
                                              unit,
                                              note,
                                            )),
                                          },
                                        if (block["logResults"] != null)
                                          {
                                            logResults =
                                                (block["logResults"] is bool
                                                    ? block["logResults"]
                                                    : true)
                                          },
                                        if (block["simple"] != null)
                                          {
                                            simple = (block["simple"] is bool
                                                ? block["simple"]
                                                : false)
                                          },
                                        if (block["cycles"] != null)
                                          {
                                            cycles = (block["cycles"] is int
                                                ? block["cycles"]
                                                : 1)
                                          },
                                        if (block["name"] != null)
                                          {
                                            bname = (block["name"] is String
                                                ? block["name"]
                                                : "")
                                          },
                                        if (block["notesResSimple"] != null)
                                          {
                                            snotes = (block["notesResSimple"]
                                                    is String
                                                ? block["notesResSimple"]
                                                : "")
                                          },
                                        if (block["valueSimple"] != null)
                                          {
                                            valueSimple =
                                                (block["valueSimple"] is List
                                                    ? block["valueSimple"]
                                                    : [])
                                          },
                                        if (block["amrapSimple"] != null)
                                          {
                                            amrapSimple =
                                                (block["amrapSimple"] is List
                                                    ? block["amrapSimple"]
                                                    : [])
                                          },
                                        if (block["scaledSimple"] != null)
                                          {
                                            scaledSimple =
                                                (block["scaledSimple"] is List
                                                    ? block["scaledSimple"]
                                                    : [])
                                          },
                                        if (block["unitSimple"] != null)
                                          {
                                            unitSimple =
                                                (block["unitSimple"] is String
                                                    ? block["unitSimple"]
                                                    : "reps")
                                          },
                                        blocks.add(ModelBlock(
                                          key,
                                          (block["cat"] is int
                                              ? block["cat"]
                                              : 0),
                                          bname,
                                          (block["type"] is int
                                              ? block["type"]
                                              : 0),
                                          (block["rounds"] is int
                                              ? block["rounds"]
                                              : 1),
                                          (block["emom"] is bool
                                              ? block["emom"]
                                              : false),
                                          (block["notes"] is String
                                              ? block["notes"]
                                              : ""),
                                          (block["notesRes"] is String
                                              ? block["notesRes"]
                                              : ""),
                                          ex,
                                          logResults,
                                          cycles,
                                          time,
                                          timeGroup,
                                          simple,
                                          snotes,
                                          valueSimple,
                                          amrapSimple,
                                          scaledSimple,
                                          unitSimple,
                                        ))
                                      })),
                            blocks.sort((a, b) => a.id.compareTo(b.id)),
                            program = ModelProgram(
                                pkey,
                                (prog["name"] is String
                                    ? prog["name"]
                                    : "Program"),
                                (prog["desc"] is String ? prog["desc"] : ""),
                                (prog["time"] is int ? prog["time"] : 1),
                                (prog["exercises"] is int
                                    ? prog["exercises"]
                                    : 1),
                                (prog["uid"] is String ? prog["uid"] : ""),
                                blocks,
                                bench,
                                (prog["video"] is String ? prog["video"] : ""))
                          })),
                    },

                  // Data
                  if (!data["group"])
                    {
                      type = "pt",
                      name = "PT Session",
                      if (data["client"] != GlobalData.space.client)
                        {add = false},
                      for (var cl in GlobalData.space.linked)
                        {
                          if (data["client"] == cl.id &&
                              date.isAfter(DateTime.now()))
                            {add = true}
                        },
                      if (data["name"] != null && data["name"] != "")
                        {name = data["name"]}
                    }
                  else
                    {
                      type = "group",
                      name = "Class",
                      if (data["client"] != "") {name = data["client"]},
                      if (avail)
                        {
                          name = "1:1 availability",
                          if (data["name"] != null && data["name"] != "")
                            {name = data["name"]}
                        },
                      if (data["invitees"] != null)
                        {
                          add = false,
                          if (data["invitees"]
                              .contains(GlobalData.space.client))
                            {add = true},
                          if (data["clients"] != null)
                            {
                              if (data["clients"]
                                  .contains(GlobalData.space.client))
                                {add = true}
                            },
                          for (var cl in GlobalData.space.linked)
                            {
                              if (data["clients"] != null)
                                {
                                  if (data["clients"].contains(cl.id))
                                    {add = true}
                                },
                              if (data["invitees"] != null)
                                {
                                  if (data["invitees"].contains(cl.id))
                                    {add = true}
                                },
                            },
                        },
                    },

                  unl = GlobalUI.dateTime.parse("01/01/1900 00:00"),
                  if (data["unlocked"] != null)
                    {unl = GlobalUI.dateTime.parse(data["unlocked"])},
                  locked = GlobalUI.dateTime.parse("01/01/3100 00:00"),
                  if (data["locked"] != null)
                    {
                      locked = DateTime.fromMillisecondsSinceEpoch(
                          (data["locked"] * 1000).toInt())
                    },
                  if (data["timestamp"] != null)
                    {
                      date = DateTime.fromMillisecondsSinceEpoch(
                          (data["timestamp"] * 1000).toInt())
                    },
                  for (var item in GlobalData.sessions)
                    {
                      if (item.id == index) {add = false}
                    },

                  max = 0,
                  trainer = "Trainer",
                  if (data["trainerName"] != null)
                    {
                      trainer = (data["trainerName"] is String
                          ? data["trainerName"]
                          : "")
                    },
                  if (data["max"] != null)
                    {max = (data["max"] is int ? data["max"] : 0)},
                  location = "",
                  locationName = "",
                  if (data["location"] != null)
                    {
                      location = data["location"],
                    },
                  if (data["locationName"] != null)
                    {locationName = data["locationName"]},
                  if (add)
                    {
                      GlobalData.sessions.add(ModelSession(
                        index,
                        date,
                        name,
                        (data["duration"] is int ? data["duration"] : 1),
                        clients,
                        invitees,
                        waiting,
                        trainer,
                        type,
                        (data["link"] is String ? data["link"] : ""),
                        (data["attendance"] is int ? data["attendance"] : 2),
                        max,
                        unl,
                        preview,
                        rating,
                        comments,
                        program,
                        groups,
                        avail,
                        locked,
                        desc,
                        (data["template"] is String ? data["template"] : ""),
                        memberships,
                        bookings,
                        location,
                        locationName,
                        highfives,
                        noshows,
                        (data["client"] is String ? data["client"] : ""),
                      ))
                    }
                }
            }));
      }

      ConnectPage.appState.updateData();
      HomePage.appState.updateData();
      CalendarPage.appState.updateData();
      SessionPage.appState.updateData();
      ResultsPage.appState.updateData();
      TrainingPage.appState.updateData();
      LeaderboardPage.appState.updateData();
    });
  }

  // Archive

  static void getSessionsArchive() {
    var ref =
        FirebaseDatabase.instance.ref().child("archive/" + GlobalData.space.id);

    String type = "pt";
    String name = "PT Session";
    DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime cdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
    bool add = true;

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.sessions = [];
        Map data = snapshot.snapshot.value as Map;
        ModelProgram program =
            ModelProgram("", "", "", 0, 0, "", [], false, "");
        List<ModelBlock> blocks = [];
        List<ModelMovement> ex = [];
        List<ModelComment> comments = [];
        bool logResults = true;
        List clients = [];
        String wtype = "per";

        String exRepsRounds = "";
        String exWeightRounds = "";
        String exResRepsRounds = "";
        String exResWeightRounds = "";
        List valueSimple = [];
        List amrapSimple = [];
        List scaledSimple = [];
        String unitSimple = "";

        var rw = "";
        var ww = "";
        bool bench = false;

        var cycles = 0;
        String bname = "";
        int time = 0;
        List timeGroup = [];
        List units = [];
        String unit = "";
        List notes = [];
        String note = "";
        List memberships = [];
        List bookings = [];
        List highfives = [];
        List noshows = [];
        bool simple = false;
        String snotes = "";
        String location = "";
        String locationName = "";

        data.forEach((index, data) => ({
              if (data["group"] != null)
                {
                  add = true,
                  date = GlobalUI.dateTime.parse(data["date"]),
                  cdate = GlobalUI.dateTime.parse(data["date"]),
                  // Program
                  program = ModelProgram("", "", "", 0, 0, "", [], false, ""),
                  comments = [],
                  blocks = [],
                  add = true,
                  clients = [],
                  memberships = [],
                  bookings = [],
                  highfives = [],
                  noshows = [],
                  location = "",
                  locationName = "",

                  if (data["clients"] != null) {clients = data["clients"]},
                  if (data["memberships"] != null)
                    {memberships = data["memberships"]},
                  if (data["bookings"] != null) {bookings = data["bookings"]},
                  if (data["highfives"] != null)
                    {highfives = data["highfives"]},
                  if (data["noshows"] != null) {highfives = data["noshows"]},
                  if (data["location"] != null)
                    {
                      location = data["location"],
                    },
                  if (data["locationName"] != null)
                    {locationName = data["locationName"]},

                  if (data["workout"] != null)
                    {
                      data["workout"].forEach((pkey, prog) => ({
                            bench = false,
                            if (prog["benchmark"] != null)
                              {
                                bench = (prog["benchmark"] is bool
                                    ? prog["benchmark"]
                                    : false)
                              },
                            if (prog["blocks"] != null)
                              (prog["blocks"] is List
                                      ? {
                                          for (var i = 0;
                                              i < prog["blocks"].length;
                                              i++)
                                            if (prog["blocks"][i] != null)
                                              i.toString(): prog["blocks"][i]
                                        }
                                      : prog["blocks"])
                                  .forEach((key, block) => ({
                                        ex = [],
                                        cycles = 0,
                                        bname = "",
                                        logResults = true,
                                        time = 0,
                                        timeGroup = [],
                                        units = [],
                                        unit = "",
                                        notes = [],
                                        note = "",
                                        simple = false,
                                        snotes = "",
                                        valueSimple = [],
                                        amrapSimple = [],
                                        scaledSimple = [],
                                        unitSimple = "reps",
                                        for (var i = 0;
                                            i < block["exId"].length;
                                            i++)
                                          {
                                            rw = "",
                                            ww = "",
                                            if (block["exResRepsGroup"] != null)
                                              {
                                                rw = block["exResRepsGroup"][i]
                                                    .toString()
                                              },
                                            if (block["exResWeightGroup"] !=
                                                null)
                                              {
                                                ww = block["exResWeightGroup"]
                                                        [i]
                                                    .toString()
                                              },
                                            wtype = "per",
                                            if (block["exWeightType"] != null)
                                              {
                                                wtype = (block["exWeightType"]
                                                        [i] is String
                                                    ? block["exWeightType"][i]
                                                    : "kg")
                                              },
                                            exRepsRounds = "",
                                            if (block["exRepsRounds"] != null)
                                              {
                                                if (block["exRepsRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exRepsRounds = (block[
                                                                "exRepsRounds"]
                                                            [i] is String
                                                        ? block["exRepsRounds"]
                                                            [i]
                                                        : "")
                                                  }
                                              },
                                            exWeightRounds = "",
                                            if (block["exWeightRounds"] != null)
                                              {
                                                if (block["exWeightRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exWeightRounds = (block[
                                                                "exWeightRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exWeightRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            exResRepsRounds = "",
                                            if (block["exResRepsRounds"] !=
                                                null)
                                              {
                                                if (block["exResRepsRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exResRepsRounds = (block[
                                                                "exResRepsRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exResRepsRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            exResWeightRounds = "",
                                            if (block["exResWeightRounds"] !=
                                                null)
                                              {
                                                if (block["exResWeightRounds"]
                                                        .length >
                                                    i)
                                                  {
                                                    exResWeightRounds = (block[
                                                                "exResWeightRounds"]
                                                            [i] is String
                                                        ? block[
                                                            "exResWeightRounds"][i]
                                                        : "")
                                                  }
                                              },
                                            if (block["timeRes"] != null)
                                              {
                                                time = (block["timeRes"] is int
                                                    ? block["timeRes"]
                                                    : 0)
                                              },
                                            if (block["timeResGroup"] != null)
                                              {
                                                timeGroup =
                                                    block["timeResGroup"]
                                              },
                                            if (block["exUnits"] != null)
                                              {units = block["exUnits"]},
                                            if (units.length > i)
                                              {unit = units[i]},
                                            if (block["exNotes"] != null)
                                              {notes = block["exNotes"]},
                                            if (notes.length > i)
                                              {note = notes[i]},
                                            ex.add(ModelMovement(
                                              (block["exId"][i] is String
                                                  ? block["exId"][i]
                                                  : ""),
                                              (block["exName"][i] is String
                                                  ? block["exName"][i]
                                                  : ""),
                                              (block["exType"][i] is int
                                                  ? block["exType"][i]
                                                  : 0),
                                              (block["exCat"][i] is int
                                                  ? block["exCat"][i]
                                                  : 0),
                                              (block["exTool"][i] is int
                                                  ? block["exTool"][i]
                                                  : 0),
                                              (block["exReps"][i] is int
                                                  ? block["exReps"][i]
                                                  : 0),
                                              block["exWeight"][i].toDouble(),
                                              (block["exWork"][i] is int
                                                  ? block["exWork"][i]
                                                  : 0),
                                              (block["exRest"][i] is int
                                                  ? block["exRest"][i]
                                                  : 0),
                                              block["exResWeight"][i]
                                                  .toDouble(),
                                              (block["exResReps"][i] is int
                                                  ? block["exResReps"][i]
                                                  : 0),
                                              //block["exResWeightGroup"][i],
                                              //block["exResRepsGroup"][i],
                                              ww,
                                              rw,
                                              (block["exImage"][i] is String
                                                  ? block["exImage"][i]
                                                  : ""),
                                              wtype,
                                              exRepsRounds,
                                              exWeightRounds,
                                              exResRepsRounds,
                                              exResWeightRounds,
                                              "",
                                              "",
                                              unit,
                                              note,
                                            )),
                                          },
                                        if (block["logResults"] != null)
                                          {
                                            logResults =
                                                (block["logResults"] is bool
                                                    ? block["logResults"]
                                                    : true)
                                          },
                                        if (block["simple"] != null)
                                          {
                                            simple = (block["simple"] is bool
                                                ? block["simple"]
                                                : false)
                                          },
                                        if (block["cycles"] != null)
                                          {
                                            cycles = (block["cycles"] is int
                                                ? block["cycles"]
                                                : 1)
                                          },
                                        if (block["name"] != null)
                                          {
                                            bname = (block["name"] is String
                                                ? block["name"]
                                                : "")
                                          },
                                        if (block["notesResSimple"] != null)
                                          {
                                            snotes = (block["notesResSimple"]
                                                    is String
                                                ? block["notesResSimple"]
                                                : "")
                                          },
                                        if (block["valueSimple"] != null)
                                          {
                                            valueSimple =
                                                (block["valueSimple"] is List
                                                    ? block["valueSimple"]
                                                    : [])
                                          },
                                        if (block["amrapSimple"] != null)
                                          {
                                            amrapSimple =
                                                (block["amrapSimple"] is List
                                                    ? block["amrapSimple"]
                                                    : [])
                                          },
                                        if (block["scaledSimple"] != null)
                                          {
                                            scaledSimple =
                                                (block["scaledSimple"] is List
                                                    ? block["scaledSimple"]
                                                    : [])
                                          },
                                        if (block["unitSimple"] != null)
                                          {
                                            unitSimple =
                                                (block["unitSimple"] is String
                                                    ? block["unitSimple"]
                                                    : "reps")
                                          },
                                        blocks.add(ModelBlock(
                                          key,
                                          (block["cat"] is int
                                              ? block["cat"]
                                              : 0),
                                          bname,
                                          (block["type"] is int
                                              ? block["type"]
                                              : 0),
                                          (block["rounds"] is int
                                              ? block["rounds"]
                                              : 1),
                                          (block["emom"] is bool
                                              ? block["emom"]
                                              : false),
                                          (block["notes"] is String
                                              ? block["notes"]
                                              : ""),
                                          (block["notesRes"] is String
                                              ? block["notesRes"]
                                              : ""),
                                          ex,
                                          logResults,
                                          cycles,
                                          time,
                                          timeGroup,
                                          simple,
                                          snotes,
                                          valueSimple,
                                          amrapSimple,
                                          scaledSimple,
                                          unitSimple,
                                        ))
                                      })),
                            blocks.sort((a, b) => a.id.compareTo(b.id)),
                            program = ModelProgram(
                                pkey,
                                (prog["name"] is String
                                    ? prog["name"]
                                    : "Program"),
                                (prog["desc"] is String ? prog["desc"] : ""),
                                (prog["time"] is int ? prog["time"] : 1),
                                (prog["exercises"] is int
                                    ? prog["exercises"]
                                    : 1),
                                (prog["uid"] is String ? prog["uid"] : ""),
                                blocks,
                                bench,
                                (prog["video"] is String ? prog["video"] : ""))
                          })),
                    },

                  // Data
                  if (!data["group"])
                    {
                      type = "pt",
                      name = "PT Session",
                      if (data["client"] != GlobalData.space.client)
                        {add = false}
                    }
                  else
                    {
                      type = "group",
                      name = "Class",
                      if (data["client"] != "") {name = data["client"]},
                    },
                  if (data["timestamp"] != null)
                    {
                      date = DateTime.fromMillisecondsSinceEpoch(
                          (data["timestamp"] * 1000).toInt())
                    },
                  for (var item in GlobalData.archive)
                    {
                      if (item.id == index) {add = false}
                    },

                  if (add)
                    {
                      GlobalData.archive.add(ModelSession(
                        index,
                        date,
                        name,
                        (data["duration"] is int ? data["duration"] : 1),
                        clients,
                        [],
                        [],
                        "",
                        type,
                        (data["link"] is String ? data["link"] : ""),
                        (data["attendance"] is int ? data["attendance"] : 2),
                        0,
                        GlobalUI.dateTime.parse("01/01/1900 00:00"),
                        true,
                        [],
                        [],
                        program,
                        [],
                        false,
                        GlobalUI.dateTime.parse("01/01/3100 00:00"),
                        "",
                        (data["template"] is String ? data["template"] : ""),
                        memberships,
                        bookings,
                        location,
                        locationName,
                        highfives,
                        noshows,
                        (data["client"] is String ? data["client"] : ""),
                      ))
                    }
                }
            }));
        GlobalData.archive.sort((a, b) => b.date.compareTo(a.date));
        ExImagePage.appState.updateData();
      }
    });
  }

  // Events

  static void getEvents() {
    var ref =
        FirebaseDatabase.instance.ref().child("events/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.events = [];
        bool add = true;
        bool bookable = false;
        List clients = [];
        List invitees = [];
        List waiting = [];
        List groups = [];
        DateTime date = DateTime.now().add(Duration(days: 2));
        String location = "";
        String locationName = "";

        data.forEach((index, data) => ({
              add = true,
              bookable = (data["bookable"] is bool ? data["bookable"] : false),
              clients = [],
              invitees = [],
              waiting = [],
              groups = [],
              location = "",
              locationName = "",
              date = GlobalUI.dateTime.parse(data["date"]),
              if (data["timestamp"] != null)
                {
                  date = DateTime.fromMillisecondsSinceEpoch(
                      (data["timestamp"] * 1000).toInt())
                },
              if (data["clients"] != null) {clients = data["clients"]},
              if (data["invitees"] != null) {invitees = data["invitees"]},
              if (data["waiting"] != null) {waiting = data["waiting"]},
              if (data["groups"] != null) {groups = data["groups"]},
              if (data["location"] != null)
                {
                  location = data["location"],
                },
              if (data["locationName"] != null)
                {locationName = data["locationName"]},
              for (var item in GlobalData.events)
                {
                  if (item.id == index) {add = false}
                },
              if (!bookable) {add = false},
              if (add)
                {
                  GlobalData.events.add(ModelSession(
                    index,
                    date,
                    (data["title"] is String ? data["title"] : "Event"),
                    (data["duration"] is int ? data["duration"] : 1),
                    clients,
                    invitees,
                    waiting,
                    "",
                    "event",
                    (data["link"] is String ? data["link"] : ""),
                    (data["attendance"] is int ? data["attendance"] : 2),
                    (data["max"] is int ? data["max"] : 0),
                    GlobalUI.dateTime.parse("01/01/1900 00:00"),
                    true,
                    [],
                    [],
                    ModelProgram("", "", "", 0, 0, "", [], false, ""),
                    groups,
                    false,
                    GlobalUI.dateTime.parse("01/01/3100 00:00"),
                    (data["desc"] is String ? data["desc"] : ""),
                    (data["templateId"] is String ? data["templateId"] : ""),
                    [],
                    [],
                    location,
                    locationName,
                    [],
                    [],
                    "",
                  ))
                }
            }));

        HomePage.appState.updateData();
        CalendarPage.appState.updateData();
        EventPage.appState.updateData();
      }
    });
  }

  // Programs

  static void getPrograms() {
    var ref =
        FirebaseDatabase.instance.ref().child("workouts/" + GlobalUser.uid);
    var ref2 = FirebaseDatabase.instance.ref().child("workouts/");

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.programs = [];
        List<ModelBlock> blocks = [];
        List<ModelMovement> ex = [];
        bool add = true;
        bool logResults = true;
        String wtype = "per";
        bool load = true;
        int cycles = 0;
        String bname = "";

        String exRepsRounds = "";
        String exWeightRounds = "";
        String exResRepsRounds = "";
        String exResWeightRounds = "";
        String exResRepsGroup = "";
        String exResWeightGroup = "";
        List valueSimple = [];
        List amrapSimple = [];
        List scaledSimple = [];
        String unitSimple = "";

        bool bench = false;
        List units = [];
        String unit = "";
        List notes = [];
        String note = "";
        bool simple;
        String snotes;

        data.forEach((index, data) => ({
              blocks = [],
              add = true,
              bench = false,
              if (data["benchmark"] != null)
                {
                  bench =
                      (data["benchmark"] is bool ? data["benchmark"] : false)
                },
              (data["blocks"] is List
                      ? {
                          for (var i = 0; i < data["blocks"].length; i++)
                            if (data["blocks"][i] != null)
                              i.toString(): data["blocks"][i]
                        }
                      : data["blocks"])
                  .forEach((key, block) => ({
                        ex = [],
                        cycles = 0,
                        bname = "",
                        units = [],
                        unit = "",
                        notes = [],
                        note = "",
                        simple = false,
                        snotes = "",
                        valueSimple = [],
                        amrapSimple = [],
                        scaledSimple = [],
                        unitSimple = "reps",
                        if (block is List<dynamic>)
                          {load = false}
                        else
                          {load = true},
                        logResults = true,
                        if (load)
                          {
                            for (var i = 0; i < block["exId"].length; i++)
                              {
                                wtype = "per",
                                if (block["exWeightType"] != null)
                                  {
                                    wtype = (block["exWeightType"][i] is String
                                        ? block["exWeightType"][i]
                                        : "kg")
                                  },
                                exRepsRounds = "",
                                if (block["exRepsRounds"] != null)
                                  {
                                    if (block["exRepsRounds"].length > i)
                                      {
                                        exRepsRounds =
                                            (block["exRepsRounds"][i] is String
                                                ? block["exRepsRounds"][i]
                                                : "")
                                      }
                                  },
                                exWeightRounds = "",
                                if (block["exWeightRounds"] != null)
                                  {
                                    if (block["exWeightRounds"].length > i)
                                      {
                                        exWeightRounds =
                                            (block["exWeightRounds"][i]
                                                    is String
                                                ? block["exWeightRounds"][i]
                                                : "")
                                      }
                                  },
                                exResRepsRounds = "",
                                if (block["exResRepsRounds"] != null)
                                  {
                                    if (block["exResRepsRounds"].length > i)
                                      {
                                        exResRepsRounds =
                                            (block["exResRepsRounds"][i]
                                                    is String
                                                ? block["exResRepsRounds"][i]
                                                : "")
                                      }
                                  },
                                exResWeightRounds = "",
                                if (block["exResWeightRounds"] != null)
                                  {
                                    if (block["exResWeightRounds"].length > i)
                                      {
                                        exResWeightRounds =
                                            (block["exResWeightRounds"][i]
                                                    is String
                                                ? block["exResWeightRounds"][i]
                                                : "")
                                      }
                                  },
                                exResRepsGroup = "",
                                if (block["exResRepsGroup"] != null)
                                  {
                                    if (block["exResRepsGroup"].length > i)
                                      {
                                        exResRepsGroup =
                                            (block["exResRepsGroup"][i]
                                                    is String
                                                ? block["exResRepsGroup"][i]
                                                : "")
                                      }
                                  },
                                exResWeightGroup = "",
                                if (block["exResWeightGroup"] != null)
                                  {
                                    if (block["exResWeightGroup"].length > i)
                                      {
                                        exResRepsGroup =
                                            (block["exResWeightGroup"][i]
                                                    is String
                                                ? block["exResWeightGroup"][i]
                                                : "")
                                      }
                                  },
                                if (block["exUnits"] != null)
                                  {units = block["exUnits"]},
                                if (units.length > i) {unit = units[i]},
                                if (block["exNotes"] != null)
                                  {notes = block["exNotes"]},
                                if (notes.length > i) {note = notes[i]},
                                ex.add(ModelMovement(
                                  (block["exId"][i] is String
                                      ? block["exId"][i]
                                      : ""),
                                  (block["exName"][i] is String
                                      ? block["exName"][i]
                                      : ""),
                                  (block["exType"][i] is int
                                      ? block["exType"][i]
                                      : 0),
                                  (block["exCat"][i] is int
                                      ? block["exCat"][i]
                                      : 0),
                                  (block["exTool"][i] is int
                                      ? block["exTool"][i]
                                      : 0),
                                  (block["exReps"][i] is int
                                      ? block["exReps"][i]
                                      : 0),
                                  block["exWeight"][i].toDouble(),
                                  (block["exWork"][i] is int
                                      ? block["exWork"][i]
                                      : 0),
                                  (block["exRest"][i] is int
                                      ? block["exRest"][i]
                                      : 0),
                                  block["exResWeight"][i].toDouble(),
                                  (block["exResReps"][i] is int
                                      ? block["exResReps"][i]
                                      : 0),
                                  exResWeightGroup,
                                  exResRepsGroup,
                                  (block["exImage"][i] is String
                                      ? block["exImage"][i]
                                      : ""),
                                  wtype,
                                  exRepsRounds,
                                  exWeightRounds,
                                  exResRepsRounds,
                                  exResWeightRounds,
                                  "",
                                  "",
                                  unit,
                                  note,
                                )),
                              },
                            if (block["logResults"] != null)
                              {
                                logResults = (block["logResults"] is bool
                                    ? block["logResults"]
                                    : true)
                              },
                            if (block["simple"] != null)
                              {
                                simple = (block["simple"] is bool
                                    ? block["simple"]
                                    : false)
                              },
                            if (block["cycles"] != null)
                              {
                                cycles = (block["cycles"] is int
                                    ? block["cycles"]
                                    : 1)
                              },
                            if (block["name"] != null)
                              {
                                bname = (block["name"] is String
                                    ? block["name"]
                                    : "")
                              },
                            if (block["notesResSimple"] != null)
                              {
                                snotes = (block["notesResSimple"] is String
                                    ? block["notesResSimple"]
                                    : "")
                              },
                            if (block["valueSimple"] != null)
                              {
                                valueSimple = (block["valueSimple"] is List
                                    ? block["valueSimple"]
                                    : [])
                              },
                            if (block["amrapSimple"] != null)
                              {
                                amrapSimple = (block["amrapSimple"] is List
                                    ? block["amrapSimple"]
                                    : [])
                              },
                            if (block["scaledSimple"] != null)
                              {
                                scaledSimple = (block["scaledSimple"] is List
                                    ? block["scaledSimple"]
                                    : [])
                              },
                            if (block["unitSimple"] != null)
                              {
                                unitSimple = (block["unitSimple"] is String
                                    ? block["unitSimple"]
                                    : "reps")
                              },
                            blocks.add(ModelBlock(
                                key,
                                (block["cat"] is int ? block["cat"] : 0),
                                bname,
                                (block["type"] is int ? block["type"] : 0),
                                (block["rounds"] is int ? block["rounds"] : 1),
                                (block["emom"] is bool ? block["emom"] : false),
                                (block["notes"] is String
                                    ? block["notes"]
                                    : ""),
                                (block["notesRes"] is String
                                    ? block["notesRes"]
                                    : ""),
                                ex,
                                logResults,
                                cycles,
                                0,
                                [],
                                simple,
                                snotes,
                                valueSimple,
                                amrapSimple,
                                scaledSimple,
                                unitSimple))
                          },
                      })),
              blocks.sort((a, b) => a.id.compareTo(b.id)),
              for (var item in GlobalData.programs)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.programs.add(ModelProgram(
                      index,
                      (data["name"] is String ? data["name"] : "Program"),
                      (data["desc"] is String ? data["desc"] : ""),
                      (data["time"] is int ? data["time"] : 1),
                      (data["exercises"] is int ? data["exercises"] : 1),
                      (data["uid"] is String ? data["uid"] : ""),
                      blocks,
                      bench,
                      (data["video"] is String ? data["video"] : "")))
                }
            }));

        ConnectPage.appState.updateData();
        TrainingPage.appState.updateData();
        ProgramPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Products

  static void getProducts() {
    var ref =
        FirebaseDatabase.instance.ref().child("packs/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        HomePage.appState.updateData();
        Map data = snapshot.snapshot.value as Map;
        GlobalData.products = [];
        GlobalData.productsAll = [];
        var add = true;
        var add2 = true;
        var expires = 0;
        var expType = "";
        double price = 0;
        var public = true;
        var desc = "";
        var stock = -1;

        data.forEach((index, data) => ({
              add = true,
              add2 = true,
              public = (data["public"] is bool ? data["public"] : false),
              desc = (data["desc"] is String ? data["desc"] : ""),
              price = data["price"].toDouble(),
              stock = (data["stock"] is int ? data["stock"] : -1),
              for (var item in GlobalData.products)
                {
                  if (item.id == index) {add = false}
                },
              for (var item2 in GlobalData.productsAll)
                {
                  if (item2.id == index) {add2 = false}
                },
              if (!public) {add = false},
              if (add)
                {
                  GlobalData.products.add(ModelProduct(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["type"] is String ? data["type"] : ""),
                      (data["billing"] is String ? data["billing"] : ""),
                      (data["interval"] is int ? data["interval"] : 1),
                      price,
                      (data["stype"] is String ? data["stype"] : "group"),
                      (data["sessions"] is int ? data["sessions"] : 0),
                      (data["sessions11"] is int ? data["sessions11"] : 0),
                      (data["product"] is String ? data["product"] : ""),
                      (data["expires"] is int ? data["expires"] : 12),
                      (data["expType"] is String ? data["expType"] : "months"),
                      desc,
                      stock))
                },
              if (add2)
                {
                  GlobalData.productsAll.add(ModelProduct(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["type"] is String ? data["type"] : ""),
                      (data["billing"] is String ? data["billing"] : ""),
                      (data["interval"] is int ? data["interval"] : 1),
                      price,
                      (data["stype"] is String ? data["stype"] : "group"),
                      (data["sessions"] is int ? data["sessions"] : 0),
                      (data["sessions11"] is int ? data["sessions11"] : 0),
                      (data["product"] is String ? data["product"] : ""),
                      (data["expires"] is int ? data["expires"] : 12),
                      (data["expType"] is String ? data["expType"] : "months"),
                      desc,
                      stock))
                }
            }));
        HomePage.appState.updateData();
      }
    });
  }

  // Payments

  static void getPayments() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("payments/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.payments = [];
        DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
        double amount = 0;
        bool add = true;
        DateTime refund = GlobalUI.dateTime.parse("01/01/1900 00:00");
        String desc = "";

        data.forEach((index, data) => ({
              add = true,
              refund = GlobalUI.dateTime.parse("01/01/1900 00:00"),
              for (var pay in GlobalData.payments)
                {
                  if (pay.id == index) {add = false}
                },
              date = GlobalUI.dateTime.parse(data["date"]),
              if (data["timestamp"] != null)
                {
                  date = DateTime.fromMillisecondsSinceEpoch(
                      (data["timestamp"] * 1000).toInt())
                },
              if (data["refund"] != null && data["refund"] != 0)
                {
                  refund = DateTime.fromMillisecondsSinceEpoch(
                      (data["refund"] * 1000).toInt())
                },
              amount = data["amount"].toDouble(),
              if (data["client"] == GlobalData.space.client && add)
                {
                  GlobalData.payments.add(ModelPayment(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["type"] is String ? data["type"] : ""),
                      (data["last4"] is String ? data["last4"] : ""),
                      date,
                      amount,
                      (data["receipt"] is String ? data["receipt"] : ""),
                      "",
                      (data["desc"] is String ? data["desc"] : ""),
                      refund))
                }
            }));

        GlobalData.payments.sort((a, b) => b.date.compareTo(a.date));
        ConnectPage.appState.updateData();
        HomePage.appState.updateData();
        PaymentsPage.appState.updateData();
        NewPaymentPage.appState.updateClient();
        PayInvoicePage.appState.updateClient();
        ReceiptPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Invoices

  static void getInvoices() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("invoices/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.invoices = [];
        DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
        DateTime due = GlobalUI.dateTime.parse("01/01/1900 00:00");
        double price = 0;
        double gst = 0;
        bool add = true;

        data.forEach((index, data) => ({
              add = true,
              gst = 0,
              for (var inv in GlobalData.invoices)
                {
                  if (inv.id == index) {add = false}
                },
              date = DateTime.fromMillisecondsSinceEpoch(
                  (data["date"] * 1000).toInt()),
              due = DateTime.fromMillisecondsSinceEpoch(
                  (data["due"] * 1000).toInt()),
              price = data["price"].toDouble(),
              if (data["gst"] != null) {gst = data["gst"].toDouble()},
              if (data["client"] == GlobalData.space.client && add)
                {
                  GlobalData.invoices.add(ModelInvoice(
                      index,
                      (data["number"] is String ? data["number"] : ""),
                      (data["client"] is String ? data["client"] : ""),
                      (data["product"] is String ? data["product"] : ""),
                      price,
                      gst,
                      date,
                      due,
                      (data["status"] is String ? data["status"] : ""),
                      (data["notes"] is String ? data["notes"] : ""),
                      (data["account"] is String ? data["account"] : "")))
                }
            }));

        GlobalData.invoices.sort((a, b) => b.date.compareTo(a.date));
        ConnectPage.appState.updateData();
        HomePage.appState.updateData();
        PaymentsPage.appState.updateData();
        InvoicePage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Training plans

  static void getPlans() {
    var ref = FirebaseDatabase.instance.ref().child("plans/" + GlobalUser.uid);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.plans = [];
        List<ModelPlanWeek> weeks = [];
        List<ModelProgram> programs = [];
        List<ModelBlock> blocks = [];
        List<ModelMovement> ex = [];
        bool add = true;
        bool padd = true;
        bool badd = true;
        DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
        bool logResults = true;
        String wtype = "per";
        int cycles = 0;
        String bname = "";

        String exRepsRounds = "";
        String exWeightRounds = "";
        String exResRepsRounds = "";
        String exResWeightRounds = "";
        String exResRepsGroup = "";
        String exResWeightGroup = "";
        List valueSimple = [];
        List amrapSimple = [];
        List scaledSimple = [];
        String unitSimple = "";
        int time = 0;
        List<int> timeGroup = [];

        bool bench = false;
        List units = [];
        String unit = "";
        List notes = [];
        String note = "";
        bool simple = false;
        String snotes = "";

        data.forEach((index, data) => ({
              date = GlobalUI.dateTime.parse("01/01/1900 00:00"),
              add = true,
              weeks = [],
              programs = [],
              if (data["date"] != null)
                {
                  date = GlobalUI.dateTime.parse(data["date"]),
                },
              for (var item in GlobalData.plans)
                {
                  if (item.id == index) {add = false},
                },
              if (data["weeks"] != null)
                {
                  data["weeks"].forEach((wkey, week) => ({
                        weeks.add(ModelPlanWeek(
                          wkey,
                          (week["num"] is int ? week["num"] : 0),
                          (week["name"] is String ? week["name"] : "Week"),
                          (week["day1"] is String ? week["day1"] : ""),
                          (week["day2"] is String ? week["day2"] : ""),
                          (week["day3"] is String ? week["day3"] : ""),
                          (week["day4"] is String ? week["day4"] : ""),
                          (week["day5"] is String ? week["day5"] : ""),
                          (week["day6"] is String ? week["day6"] : ""),
                          (week["day7"] is String ? week["day7"] : ""),
                        ))
                      }))
                },
              weeks.sort((a, b) => a.name.compareTo(b.name)),
              if (data["workouts"] != null)
                {
                  data["workouts"].forEach((pkey, prog) => ({
                        bench = false,
                        if (prog["benchmark"] != null)
                          {
                            bench = (prog["benchmark"] is bool
                                ? prog["benchmark"]
                                : false)
                          },
                        blocks = [],
                        (prog["blocks"] is List
                                ? {
                                    for (var i = 0;
                                        i < prog["blocks"].length;
                                        i++)
                                      if (prog["blocks"][i] != null)
                                        i.toString(): prog["blocks"][i]
                                  }
                                : prog["blocks"])
                            .forEach((bkey, block) => ({
                                  badd = true,
                                  for (var item in blocks)
                                    {
                                      if (item.id == block) {badd = false},
                                    },
                                  ex = [],
                                  logResults = true,
                                  cycles = 0,
                                  bname = "",
                                  time = 0,
                                  timeGroup = [],
                                  units = [],
                                  unit = "",
                                  notes = [],
                                  note = "",
                                  simple = false,
                                  snotes = "",
                                  valueSimple = [],
                                  amrapSimple = [],
                                  scaledSimple = [],
                                  unitSimple = "reps",
                                  for (var i = 0; i < block["exId"].length; i++)
                                    {
                                      wtype = "per",
                                      units = [],
                                      if (block["exWeightType"] != null)
                                        {
                                          wtype = (block["exWeightType"][i]
                                                  is String
                                              ? block["exWeightType"][i]
                                              : "kg")
                                        },
                                      exRepsRounds = "",
                                      if (block["exRepsRounds"] != null)
                                        {
                                          if (block["exRepsRounds"].length > i)
                                            {
                                              exRepsRounds =
                                                  (block["exRepsRounds"][i]
                                                          is String
                                                      ? block["exRepsRounds"][i]
                                                      : "")
                                            }
                                        },
                                      exWeightRounds = "",
                                      if (block["exWeightRounds"] != null)
                                        {
                                          if (block["exWeightRounds"].length >
                                              i)
                                            {
                                              exWeightRounds =
                                                  (block["exWeightRounds"][i]
                                                          is String
                                                      ? block["exWeightRounds"]
                                                          [i]
                                                      : "")
                                            }
                                        },
                                      exResRepsRounds = "",
                                      if (block["exResRepsRounds"] != null)
                                        {
                                          if (block["exResRepsRounds"].length >
                                              i)
                                            {
                                              exResRepsRounds =
                                                  (block["exResRepsRounds"][i]
                                                          is String
                                                      ? block["exResRepsRounds"]
                                                          [i]
                                                      : "")
                                            }
                                        },
                                      exResWeightRounds = "",
                                      if (block["exResWeightRounds"] != null)
                                        {
                                          if (block["exResWeightRounds"]
                                                  .length >
                                              i)
                                            {
                                              exResWeightRounds = (block[
                                                          "exResWeightRounds"]
                                                      [i] is String
                                                  ? block["exResWeightRounds"]
                                                      [i]
                                                  : "")
                                            }
                                        },
                                      exResRepsGroup = "",
                                      if (block["exResRepsGroup"] != null)
                                        {
                                          if (block["exResRepsGroup"].length >
                                              i)
                                            {
                                              exResRepsGroup =
                                                  (block["exResRepsGroup"][i]
                                                          is String
                                                      ? block["exResRepsGroup"]
                                                          [i]
                                                      : "")
                                            }
                                        },
                                      exResWeightGroup = "",
                                      if (block["exResWeightGroup"] != null)
                                        {
                                          if (block["exResWeightGroup"].length >
                                              i)
                                            {
                                              exResRepsGroup = (block[
                                                          "exResWeightGroup"][i]
                                                      is String
                                                  ? block["exResWeightGroup"][i]
                                                  : "")
                                            }
                                        },
                                      if (block["timeRes"] != null)
                                        {
                                          time = (block["timeRes"] is int
                                              ? block["timeRes"]
                                              : 0)
                                        },
                                      if (block["timeResGroup"] != null)
                                        {timeGroup = block["timeResGroup"]},
                                      if (block["exUnits"] != null)
                                        {units = block["exUnits"]},
                                      if (units.length > i) {unit = units[i]},
                                      if (block["exNotes"] != null)
                                        {notes = block["exNotes"]},
                                      if (notes.length > i) {note = notes[i]},
                                      ex.add(ModelMovement(
                                        (block["exId"][i] is String
                                            ? block["exId"][i]
                                            : ""),
                                        (block["exName"][i] is String
                                            ? block["exName"][i]
                                            : ""),
                                        (block["exType"][i] is int
                                            ? block["exType"][i]
                                            : 0),
                                        (block["exCat"][i] is int
                                            ? block["exCat"][i]
                                            : 0),
                                        (block["exTool"][i] is int
                                            ? block["exTool"][i]
                                            : 0),
                                        (block["exReps"][i] is int
                                            ? block["exReps"][i]
                                            : 0),
                                        block["exWeight"][i].toDouble(),
                                        (block["exWork"][i] is int
                                            ? block["exWork"][i]
                                            : 0),
                                        (block["exRest"][i] is int
                                            ? block["exRest"][i]
                                            : 0),
                                        block["exResWeight"][i].toDouble(),
                                        (block["exResReps"][i] is int
                                            ? block["exResReps"][i]
                                            : 0),
                                        exResWeightGroup,
                                        exResRepsGroup,
                                        (block["exImage"][i] is String
                                            ? block["exImage"][i]
                                            : ""),
                                        wtype,
                                        exRepsRounds,
                                        exWeightRounds,
                                        exResRepsRounds,
                                        exResWeightRounds,
                                        "",
                                        "",
                                        unit,
                                        note,
                                      )),
                                    },
                                  if (block["logResults"] != null)
                                    {
                                      logResults = (block["logResults"] is bool
                                          ? block["logResults"]
                                          : true)
                                    },
                                  if (block["simple"] != null)
                                    {
                                      simple = (block["simple"] is bool
                                          ? block["simple"]
                                          : false)
                                    },
                                  if (block["cycles"] != null)
                                    {
                                      cycles = (block["cycles"] is int
                                          ? block["cycles"]
                                          : 1)
                                    },
                                  if (block["name"] != null)
                                    {
                                      bname = (block["name"] is String
                                          ? block["name"]
                                          : "")
                                    },
                                  if (block["notesResSimple"] != null)
                                    {
                                      snotes =
                                          (block["notesResSimple"] is String
                                              ? block["notesResSimple"]
                                              : "")
                                    },
                                  if (block["valueSimple"] != null)
                                    {
                                      valueSimple =
                                          (block["valueSimple"] is List
                                              ? block["valueSimple"]
                                              : [])
                                    },
                                  if (block["amrapSimple"] != null)
                                    {
                                      amrapSimple =
                                          (block["amrapSimple"] is List
                                              ? block["amrapSimple"]
                                              : [])
                                    },
                                  if (block["scaledSimple"] != null)
                                    {
                                      scaledSimple =
                                          (block["scaledSimple"] is List
                                              ? block["scaledSimple"]
                                              : [])
                                    },
                                  if (block["unitSimple"] != null)
                                    {
                                      unitSimple =
                                          (block["unitSimple"] is String
                                              ? block["unitSimple"]
                                              : "reps")
                                    },
                                  if (badd)
                                    {
                                      blocks.add(ModelBlock(
                                          bkey,
                                          (block["cat"] is int
                                              ? block["cat"]
                                              : 0),
                                          bname,
                                          (block["type"] is int
                                              ? block["type"]
                                              : 0),
                                          (block["rounds"] is int
                                              ? block["rounds"]
                                              : 1),
                                          (block["emom"] is bool
                                              ? block["emom"]
                                              : false),
                                          (block["notes"] is String
                                              ? block["notes"]
                                              : ""),
                                          (block["notesRes"] is String
                                              ? block["notesRes"]
                                              : ""),
                                          ex,
                                          logResults,
                                          cycles,
                                          time,
                                          timeGroup,
                                          simple,
                                          snotes,
                                          valueSimple,
                                          amrapSimple,
                                          scaledSimple,
                                          unitSimple))
                                    },
                                })),
                        blocks.sort((a, b) => a.id.compareTo(b.id)),
                        programs.add(ModelProgram(
                            pkey,
                            (prog["name"] is String ? prog["name"] : "Program"),
                            (prog["desc"] is String ? prog["desc"] : ""),
                            (prog["time"] is int ? prog["time"] : 1),
                            (prog["exercises"] is int ? prog["exercises"] : 1),
                            (prog["uid"] is String ? prog["uid"] : ""),
                            blocks,
                            bench,
                            (prog["video"] is String ? prog["video"] : "")))
                      }))
                },
              if (add)
                {
                  GlobalData.plans.add(ModelPlan(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["description"] is String
                          ? data["description"]
                          : ""),
                      date,
                      (data["video"] is String ? data["video"] : ""),
                      (data["sessions"] is int ? data["sessions"] : 0),
                      (data["uid"] is String ? data["uid"] : ""),
                      weeks,
                      programs,
                      []))
                }
            }));

        ConnectPage.appState.updateData();
        TrainingPage.appState.updateData();
        PlanPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Space training plans

  static void getPlansSpace() {
    var ref =
        FirebaseDatabase.instance.ref().child("plans/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.plansSpace = [];
        bool add = true;
        List list = [];

        data.forEach((index, data) => ({
              add = true,
              list = [],
              if (data["sent"] != null) {list = data["sent"]},
              for (var plan in GlobalData.plansSpace)
                {
                  if (plan.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.plansSpace.add(ModelPlan(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["description"] is String
                          ? data["description"]
                          : ""),
                      GlobalUI.dateTime.parse("01/01/1900 00:00"),
                      (data["video"] is String ? data["video"] : ""),
                      (data["sessions"] is int ? data["sessions"] : 0),
                      (data["uid"] is String ? data["uid"] : ""),
                      [],
                      [],
                      list))
                }
            }));

        PlanPage.appState.updateData();
      }
    });
  }

  // Best

  static void getBest() {
    var ref =
        FirebaseDatabase.instance.ref().child("records/" + GlobalUser.uid);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.best = [];
        bool add = true;
        double actual = 0;
        double percent = 0;

        data.forEach((index, data) => ({
              add = true,
              actual = 0,
              percent = 0,
              if (data["actual"] != null) {actual = data["actual"].toDouble()},
              if (data["percent"] != null)
                {percent = data["percent"].toDouble()},
              for (var item in GlobalData.best)
                {
                  if (item.id == index) {add = false}
                },
              if (data["value"] > 0 && add)
                {
                  GlobalData.best.add(ModelBest(
                    (data["id"] is String ? data["id"] : ""),
                    (data["name"] is String ? data["name"] : ""),
                    (data["tool"] is int ? data["tool"] : 0),
                    data["value"].toDouble(),
                    actual,
                    percent,
                    GlobalUI.dateTime.parse(data["date"]),
                    (data["type"] is String ? data["type"] : "kg"),
                  ))
                }
            }));

        ConnectPage.appState.updateData();
        TrainingPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Clients

  static void getClients() {
    var ref =
        FirebaseDatabase.instance.ref().child("clients/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      GlobalData.clients = [];
      Map data = snapshot.snapshot.value as Map;
      bool add = true;
      bool deleted = false;
      var arr = [];
      var name = "Member";
      var avatar = "";

      data.forEach((index, data) => ({
            add = true,
            deleted = false,
            arr = ["", ""],
            name = "Member",
            avatar = "",
            if (data["deleted"] != null)
              {
                deleted = (data["deleted"] is bool ? data["deleted"] : false),
              },
            if (data["avatar"] != null)
              {
                avatar = (data["avatar"] is String ? data["avatar"] : ""),
              },
            for (var item in GlobalData.clients)
              {
                if (item.id == index) {add = false}
              },
            if (data["name"] != null)
              {
                arr = (data["name"] is String ? data["name"] : "Member")
                    .split(" "),
                if (arr.length > 1)
                  {
                    if (arr[1] != "")
                      {name = arr[0] + " " + arr[1][0].toUpperCase()}
                    else
                      {name = arr[0]}
                  }
                else
                  {name = (data["name"] is String ? data["name"] : "Member")}
              },
            if (add && !deleted)
              {
                GlobalData.clients.add(ModelClient(
                    index,
                    name,
                    (data["image"] is String ? data["image"] : ""),
                    (data["pushToken"] is String ? data["pushToken"] : ""),
                    (data["uid"] is String ? data["uid"] : ""),
                    "",
                    false,
                    avatar))
              }
          }));

      ConnectPage.appState.updateData();
    });
  }

  // Trainer chat

  static void getChat() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("messaging/" + GlobalData.space.id + GlobalUser.uid);
    DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
    DateTime mdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
    var client = ModelClientChat(GlobalUser.uid, date, "", "");
    List<ModelMessage> messages = [];
    bool madd = true;

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;

        if (data["dateClient"] != null) {
          date = DateFormat("dd/MM/yyyy HH:mm:ss").parse(data["dateClient"]);
        }
        if (data["timeClient"] != null) {
          date = DateTime.fromMillisecondsSinceEpoch(
              data["timeClient"].toInt() * 1000);
        }

        if (data["messages"] != null) {
          data["messages"].forEach((mkey, mess) => ({
                madd = true,
                for (var msg in messages)
                  {
                    if (msg.id == mkey) {madd = false}
                  },
                if (mess["date"] != null)
                  {
                    mdate =
                        DateFormat("dd/MM/yyyy HH:mm:ss").parse(mess["date"])
                  },
                if (mess["timestamp"] != null)
                  {
                    mdate = DateTime.fromMillisecondsSinceEpoch(
                        (mess["timestamp"] * 1000).toInt())
                  },
                if (madd)
                  {
                    messages.add(ModelMessage(
                      mkey,
                      GlobalData.space.id + GlobalUser.uid,
                      (mess["sender"] is String ? mess["sender"] : ""),
                      (mess["text"] is String ? mess["text"] : ""),
                      (mess["image"] is String ? mess["image"] : ""),
                      mdate,
                      (mess["name"] is String ? mess["name"] : ""),
                    ))
                  }
              }));
        }
        messages.sort((a, b) => a.date.compareTo(b.date));

        client = ModelClientChat(GlobalUser.uid, date, "", "");
        var clients = [];
        clients.add(client);
        GlobalData.chat = ModelChat(GlobalData.space.id + GlobalUser.uid,
            GlobalData.space.name, GlobalData.space.id, [client], [], messages);
      } else {
        FirebaseSender.createChat();
      }

      ConnectPage.appState.updateData();
      Nav.appState.updateData();
      MessagingPage.appState.updateData();
      ChatPage.appState.updateData();
    });
  }

  // Trainer chat

  static void getChats() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("messaging/")
        .orderByChild("client")
        .equalTo(GlobalUser.uid);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.chatsStaff = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        List<ModelMessage> messages = [];
        List<ModelClientChat> clients = [];
        DateTime mdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
        DateTime cdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
        bool madd = true;
        String name = "Staff member";

        data.forEach((index, data) => ({
              messages = [],
              cdate =
                  DateFormat("dd/MM/yyyy HH:mm:ss").parse(data["dateClient"]),
              if (data["timeClient"] != null)
                {
                  cdate = DateTime.fromMillisecondsSinceEpoch(
                      data["timeClient"].toInt() * 1000)
                },
              clients = [ModelClientChat(GlobalUser.uid, cdate, "", "")],
              name = "Staff member",
              if (data["messages"] != null)
                {
                  data["messages"].forEach((mkey, mess) => ({
                        madd = true,
                        for (var msg in messages)
                          {
                            if (msg.id == mkey) {madd = false}
                          },
                        if (mess["date"] != null)
                          {
                            mdate = DateFormat("dd/MM/yyyy HH:mm:ss")
                                .parse(mess["date"])
                          },
                        if (mess["timestamp"] != null)
                          {
                            mdate = DateTime.fromMillisecondsSinceEpoch(
                                mess["timestamp"].toInt() * 1000)
                          },
                        if (madd)
                          {
                            messages.add(ModelMessage(
                              mkey,
                              index,
                              (mess["sender"] is String ? mess["sender"] : ""),
                              (mess["text"] is String ? mess["text"] : ""),
                              (mess["image"] is String ? mess["image"] : ""),
                              mdate,
                              (mess["name"] is String ? mess["name"] : ""),
                            ))
                          }
                      })),
                },
              messages.sort((a, b) => a.date.compareTo(b.date)),
              add = false,
              for (var st in GlobalData.allStaff)
                {
                  if (st.id == data["trainer"]) {add = true, name = st.name}
                },
              for (var item in GlobalData.chats)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.chatsStaff.add(ModelChat(
                      index,
                      name,
                      (data["trainer"] is String ? data["trainer"] : ""),
                      clients,
                      [],
                      messages)),
                },
            }));

        ConnectPage.appState.updateData();
        Nav.appState.updateData();
        MessagingPage.appState.updateData();
        ChatPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Group chats

  static void getChatsGroup() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("messagingGroup/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.chats = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        List<ModelMessage> messages = [];
        List<ModelClientChat> clients = [];
        List<ModelClientChat> staff = [];
        DateTime mdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
        DateTime cdate = GlobalUI.dateTime.parse("01/01/1900 00:00");
        bool madd = true;

        data.forEach((index, data) => ({
              messages = [],
              clients = [],
              staff = [],
              if (data["messages"] != null)
                {
                  data["messages"].forEach((mkey, mess) => ({
                        madd = true,
                        for (var msg in messages)
                          {
                            if (msg.id == mkey) {madd = false}
                          },
                        if (mess["date"] != null)
                          {
                            mdate = DateFormat("dd/MM/yyyy HH:mm:ss")
                                .parse(mess["date"])
                          },
                        if (mess["timestamp"] != null)
                          {
                            mdate = DateTime.fromMillisecondsSinceEpoch(
                                mess["timestamp"].toInt() * 1000)
                          },
                        if (madd)
                          {
                            messages.add(ModelMessage(
                              mkey,
                              index,
                              (mess["sender"] is String ? mess["sender"] : ""),
                              (mess["text"] is String ? mess["text"] : ""),
                              (mess["image"] is String ? mess["image"] : ""),
                              mdate,
                              (mess["name"] is String ? mess["name"] : ""),
                            ))
                          }
                      })),
                },
              messages.sort((a, b) => a.date.compareTo(b.date)),
              if (data["clients"] != null)
                {
                  data["clients"].forEach((ckey, cl) => ({
                        if (cl["date"] != null)
                          {
                            cdate = DateFormat("dd/MM/yyyy HH:mm:ss")
                                .parse(cl["date"])
                          },
                        if (cl["timestamp"] != null)
                          {
                            cdate = DateTime.fromMillisecondsSinceEpoch(
                                (cl["timestamp"] * 1000).toInt())
                          },
                        clients.add(ModelClientChat(ckey, cdate, "", ""))
                      })),
                },
              if (data["staff"] != null)
                {
                  data["staff"].forEach((ckey, cl) => ({
                        if (cl["date"] != null)
                          {
                            cdate = DateFormat("dd/MM/yyyy HH:mm:ss")
                                .parse(cl["date"])
                          },
                        if (cl["timestamp"] != null)
                          {
                            cdate = DateTime.fromMillisecondsSinceEpoch(
                                (cl["timestamp"] * 1000).toInt())
                          },
                        clients.add(ModelClientChat(ckey, cdate, "", ""))
                      })),
                },
              add = false,
              for (var client in clients)
                {
                  if (client.id == GlobalUser.uid) {add = true}
                },
              for (var item in GlobalData.chats)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.chats.add(ModelChat(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      (data["trainer"] is String ? data["trainer"] : ""),
                      clients,
                      staff,
                      messages)),
                },
            }));

        ConnectPage.appState.updateData();
        Nav.appState.updateData();
        MessagingPage.appState.updateData();
        ChatPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Log

  static void getLog() {
    var ref = FirebaseDatabase.instance.ref().child("log/" + GlobalUser.uid);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.logs = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;

        data.forEach((index, data) => ({
              if (data["message"] != null)
                {
                  add = true,
                  for (var item in GlobalData.logs)
                    {
                      if (item.id == index) {add = false}
                    },
                  if (add)
                    {
                      GlobalData.logs.add(ModelLog(
                          index,
                          (data["type"] is String ? data["type"] : ""),
                          (data["title"] is String ? data["title"] : ""),
                          (data["message"] is String ? data["message"] : "")))
                    }
                }
            }));

        MainPage.appState.updateLog();
        ConnectPage.appState.updateData();
        CardPage.appState.updateData();
        CardsPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  static void getLog2() {
    var ref =
        FirebaseDatabase.instance.ref().child("log/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.logs2 = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;

        data.forEach((index, data) => ({
              if (data["message"] != null)
                {
                  add = true,
                  for (var item in GlobalData.logs)
                    {
                      if (item.id == index) {add = false}
                    },
                  if (add)
                    {
                      GlobalData.logs2.add(ModelLog(
                          index,
                          (data["type"] is String ? data["type"] : ""),
                          (data["title"] is String ? data["title"] : ""),
                          (data["message"] is String ? data["message"] : "")))
                    }
                }
            }));

        MainPage.appState.updateLog();
        ConnectPage.appState.updateData();
        CardPage.appState.updateData();
        NewPaymentPage.appState.updateData();
        PayInvoicePage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Notes

  static void getNotes() {
    var ref = FirebaseDatabase.instance.ref().child("notes/" + GlobalUser.uid);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.notes = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;

        data.forEach((index, data) => ({
              add = true,
              for (var item in GlobalData.notes)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.notes.add(ModelNote(
                      index,
                      (data["text"] is String ? data["text"] : ""),
                      DateTime.fromMillisecondsSinceEpoch(
                          (data["date"] * 1000).toInt())))
                }
            }));

        NotesPage.appState.updateData();
      }
    });
  }

  // Locations

  static void getLocations() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("locations/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.locations = [];
        GlobalData.allLocations = [];
        List clients = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        int number = 0;
        GlobalUI.locationsAll = false;

        data.forEach((index, data) => ({
              add = false,
              clients = [],
              if (data["clients"] != null) {clients = data["clients"]},
              if (clients.contains(GlobalData.space.client)) {add = true},
              for (var item in GlobalData.locations)
                {
                  if (item.id == index) {add = false}
                },
              number++,
              if (add)
                {
                  GlobalData.locations.add(ModelLocation(
                      index,
                      (data["name"] is String ? data["name"] : "Location"),
                      clients)),
                },
              GlobalData.allLocations.add(ModelLocation(
                  index,
                  (data["name"] is String ? data["name"] : "Location"),
                  clients)),
            }));
        GlobalData.locations.sort((a, b) => a.name.compareTo(b.name));
        if (GlobalData.locations.length == 1) {
          GlobalUI.location = GlobalData.locations[0].id;
        }
        if (GlobalData.locations.length > 1) {
          var str = "";
          for (var item in GlobalData.locations) {
            str += item.id + ",";
          }
          GlobalUI.location = str;
        }
        if (number == GlobalData.locations.length) {
          GlobalUI.locationsAll = true;
        }
        if (GlobalData.locations.length == 0 && number > 0) {
          GlobalUI.location = "notset";
        }

        ConnectPage.appState.updateData();
        HomePage.appState.updateData();
        CalendarPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Scheduled notifications

  static void getSchedule() {
    var ref = FirebaseDatabase.instance.ref().child("schedule");
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        GlobalData.schedule = [];
        DateTime date = GlobalUI.dateTime.parse("01/01/1900 00:00");
        List tokens = [];
        bool add = true;

        data.forEach((index, data) => ({
              add = true,
              date = GlobalUI.dateTime.parse("01/01/1900 00:00"),
              for (var sch in GlobalData.schedule)
                {
                  if (sch.id == index) {add = false}
                },
              if (data["timestamp"] != null)
                {
                  date = DateTime.fromMillisecondsSinceEpoch(
                      (data["timestamp"] * 1000).toInt()),
                },
              tokens = [],
              if (data["tokens"] != null) {tokens = data["tokens"]},
              if (add)
                {
                  GlobalData.schedule.add(ModelSchedule(
                      index,
                      (data["title"] is String ? data["title"] : ""),
                      (data["desc"] is String ? data["desc"] : ""),
                      (data["type"] is String ? data["type"] : ""),
                      date,
                      tokens,
                      (data["message"] is String ? data["message"] : ""),
                      (data["uid"] is String ? data["uid"] : ""),
                      (data["iid"] is String ? data["iid"] : "")))
                }
            }));

        ConnectPage.appState.updateData();
        SessionPage.appState.updateData();
        EventPage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Client Groups

  static void getGroups() {
    var ref =
        FirebaseDatabase.instance.ref().child("groups/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.groups = [];
        GlobalData.allGroups = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        List clients = [];

        data.forEach((index, data) => ({
              add = false,
              clients = [],
              if (data["clients"] != null) {clients = data["clients"]},
              if (clients.contains(GlobalData.space.client)) {add = true},
              for (var item in GlobalData.groups)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.groups.add(ModelClientGroup(
                      index,
                      (data["name"] is String ? data["name"] : "Group"),
                      (data["clients"] ?? []))),
                },
              GlobalData.allGroups.add(ModelClientGroup(
                  index,
                  (data["name"] is String ? data["name"] : "Group"),
                  (data["clients"] ?? []))),
            }));
      }
    });
  }

  // Community

  static void getCommunity() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.community = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        int seq = 0;

        data.forEach((index, data) => ({
              add = true,
              for (var item in GlobalData.community)
                {
                  if (item.id == index) {add = false}
                },
              seq = ((data["date"] * 1000).toInt() * 10000) - 1,
              if (data["comments"] != null)
                {
                  data["comments"].forEach((cindex, comm) => ({
                        GlobalData.community.add(ModelPost(
                            cindex,
                            (comm["text"] is String ? comm["text"] : ""),
                            (comm["image"] is String ? comm["image"] : ""),
                            DateTime.fromMillisecondsSinceEpoch(
                                (comm["date"] * 1000).toInt()),
                            (comm["author"] is String ? comm["author"] : ""),
                            (comm["reaction1"] is String
                                ? comm["reaction1"]
                                : ""),
                            (comm["reaction2"] is String
                                ? comm["reaction2"]
                                : ""),
                            (comm["reaction3"] is String
                                ? comm["reaction3"]
                                : ""),
                            (comm["reaction4"] is String
                                ? comm["reaction4"]
                                : ""),
                            index,
                            seq,
                            "")),
                        seq--,
                      }))
                },
              if (add)
                {
                  GlobalData.community.add(ModelPost(
                      index,
                      (data["text"] is String ? data["text"] : ""),
                      (data["image"] is String ? data["image"] : ""),
                      DateTime.fromMillisecondsSinceEpoch(
                          (data["date"] * 1000).toInt()),
                      (data["author"] is String ? data["author"] : ""),
                      (data["reaction1"] is String ? data["reaction1"] : ""),
                      (data["reaction2"] is String ? data["reaction2"] : ""),
                      (data["reaction3"] is String ? data["reaction3"] : ""),
                      (data["reaction4"] is String ? data["reaction4"] : ""),
                      "",
                      ((data["date"] * 1000).toInt() * 10000),
                      ""))
                }
            }));
        ConnectPage.appState.updateData();
        PostItem.appState.updateData();
        HomePage.appState.updateData();
      } else {
        ConnectPage.appState.updateData();
      }
    });
  }

  // Habits

  static void getHabits() {
    var ref =
        FirebaseDatabase.instance.ref().child("habits/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.habits = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        double amount = 1;

        data.forEach((index, data) => ({
              add = true,
              amount = data["amount"].toDouble(),
              for (var item in GlobalData.habits)
                {
                  if (item.id == index) {add = false}
                },
              if (add && data["client"] == GlobalData.space.client)
                {
                  GlobalData.habits.add(ModelHabit(
                      index,
                      (data["name"] is String ? data["name"] : "Habit"),
                      (data["client"] is String ? data["client"] : "-"),
                      amount,
                      (data["unit"] is String ? data["unit"] : ""),
                      (data["interval"] is int ? data["interval"] : 1),
                      DateTime.fromMillisecondsSinceEpoch(
                          (data["start"] * 1000).toInt()),
                      DateTime.fromMillisecondsSinceEpoch(
                          (data["end"] * 1000).toInt()),
                      (data["days"] is List ? data["days"] : [])))
                }
            }));

        if (GlobalData.habits.length > 0) {
          var today = GlobalUI.date.format(DateTime.now());
          var dt = GlobalUI.dateTime.parse(today + " 20:00");
          if (dt.isBefore(DateTime.now())) {
            dt = dt.add(Duration(days: 1));
          }
          MainPage.appState.setNotification(
              'Habit Tracker', "Have you logged your habits today?", dt);
          /*for(var i=1; i<7; i++) {
            var dt2 = dt.add(Duration(days: i));
            MainPage.appState.setNotification('Habit Tracker'+i.toString(), "Have you logged your habits today?", dt2);
          }*/
        }

        HomePage.appState.updateData();
        HealthPage.appState.updateData();
        HabitPage.appState.updateData();
      }
    });
  }

  // Documents

  static void getDocuments() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("documents/" + GlobalData.space.id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.documents = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;

        data.forEach((index, data) => ({
              add = true,
              for (var item in GlobalData.documents)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.documents.add(ModelDocument(
                      index,
                      (data["name"] is String ? data["name"] : "Document"),
                      (data["ext"] is String ? data["ext"] : ""),
                      DateTime.fromMillisecondsSinceEpoch(
                          (data["date"] * 1000).toInt())))
                }
            }));

        HomePage.appState.updateData();
        FormsPage.appState.updateData();
      }
    });
  }

  // Recurring session templates

  static void getRecurring() {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("recurring/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.recurring = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;

        data.forEach((index, data) => ({
              add = true,
              for (var item in GlobalData.recurring)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.recurring.add(ModelRecurring(
                      index,
                      (data["clients"] is List ? data["clients"] : []),
                      (data["max"] is int ? data["max"] : 0)))
                }
            }));
      }
    });
    SessionPage.appState.updateData();
  }

  // All trainers

  static void getTrainers() {
    var ref = FirebaseDatabase.instance.ref().child("spaces/");
    ref.onValue.listen((snapshot) {
      GlobalData.allspaces = [];
      Map data = snapshot.snapshot.value as Map;
      bool add = true;
      bool comments = true;
      bool showBooked = true;
      bool active = true;
      String status = "";
      String plan = "";
      String address = "";
      String tmp = "";
      List arr = [];
      String welcome = "";
      int welcomeTime = 0;
      double gst = 0;
      var gst1 = "";
      bool enterprise = false;
      List newLocations = [];
      List newGroups = [];

      data.forEach((index, data) => ({
            comments = true,
            showBooked = true,
            add = true,
            active = true,
            welcome = "",
            welcomeTime = 0,
            gst = 0,
            gst1 = "",
            enterprise = false,
            newLocations = [],
            newGroups = [],
            if (data["comments"] != null)
              {
                comments = (data["comments"] is bool ? data["comments"] : true),
              },
            if (data["showBooked"] != null)
              {
                showBooked =
                    (data["showBooked"] is bool ? data["showBooked"] : true),
              },
            if (data["welcome"] != null)
              {welcome = (data["welcome"] is String ? data["welcome"] : "")},
            if (data["welcomeTime"] != null)
              {
                welcomeTime =
                    (data["welcomeTime"] is int ? data["welcomeTime"] : 0)
              },
            if (data["gst"] != null)
              {gst1 = data["gst"].toString(), gst = double.parse(gst1)},
            if (data["newLocations"] != null)
              {
                newLocations =
                    (data["newLocations"] is List ? data["newLocations"] : [])
              },
            if (data["newGroups"] != null)
              {
                newGroups = (data["newGroups"] is List ? data["newGroups"] : [])
              },
            if (active)
              {
                for (var item in GlobalData.allspaces)
                  {
                    if (item.id == index) {add = false}
                  },
                if (add && data["email"] != null)
                  {
                    status = (data["subStatus"] is String
                        ? data["subStatus"]
                        : "active"),
                    plan =
                        (data["subPlanId"] is String ? data["subPlanId"] : ""),
                    address =
                        (data["invoice1"] is String ? data["invoice1"] : ""),
                    if (plan == "price_1R3uS7Ad6uNQtfqamRID4K0d" ||
                        plan == "price_1R3uT2Ad6uNQtfqa2w2bk3Wb" ||
                        status == "trialing")
                      {enterprise = true},
                    if (address == "")
                      {
                        tmp =
                            (data["address"] is String ? data["address"] : ""),
                        arr = tmp.split("||"),
                        if (arr.length > 3)
                          {
                            address = arr[1] + "\n" + arr[2] + ", " + arr[3],
                          }
                      },
                    GlobalData.allspaces.add(ModelSpace(
                        index,
                        (data["owner"] is String ? data["owner"] : "Space"),
                        (data["name"] is String ? data["name"] : ""),
                        (data["email"] is String ? data["email"] : ""),
                        (data["phone"] is String ? data["phone"] : ""),
                        (data["image"] is String ? data["image"] : ""),
                        "",
                        "",
                        "",
                        (data["stripeConnect"] is String
                            ? data["stripeConnect"]
                            : ""),
                        ["", "", "", "", ""],
                        [],
                        [],
                        active,
                        comments,
                        showBooked,
                        (data["allowBooking"] is bool
                            ? data["allowBooking"]
                            : false),
                        "",
                        "",
                        0,
                        0,
                        (data["community"] is bool ? data["community"] : false),
                        (data["communityPost"] is bool
                            ? data["communityPost"]
                            : false),
                        (data["theme"] is String ? data["theme"] : "default"),
                        (data["pin"] is String ? data["pin"] : ""),
                        [],
                        false,
                        (data["preExercise"] is String
                            ? data["preExercise"]
                            : ""),
                        (data["reminder"] is int ? data["reminder"] : 24),
                        "",
                        [],
                        false,
                        (data["limitBooking"] is bool
                            ? data["limitBooking"]
                            : false),
                        (data["country"] is String ? data["country"] : "au"),
                        (data["lbs"] is bool ? data["lbs"] : false),
                        "",
                        (data["allowRecurring"] is bool
                            ? data["allowRecurring"]
                            : false),
                        (data["chargeSessions"] is bool
                            ? data["chargeSessions"]
                            : true),
                        false,
                        address,
                        (data["invoice2"] is String ? data["invoice2"] : ""),
                        (data["emailReminder"] is bool
                            ? data["emailReminder"]
                            : false),
                        true,
                        welcome,
                        welcomeTime,
                        gst,
                        enterprise,
                        newLocations,
                        newGroups)),
                    setLimits(
                        GlobalData.allspaces[GlobalData.allspaces.length - 1],
                        status,
                        plan),
                    TrainerPage.appState.updateData()
                  }
              }
          }));

      TrainerPage.appState.updateData();
      RequestPage.appState.updateData();
      RegisterPage.appState.updateData();
    });
  }

  static void getTrainerToken(space) {
    var ref = FirebaseDatabase.instance.ref().child("users/" + space);
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      GlobalUI.spaceToken =
          (data["pushToken"] is String ? data["pushToken"] : "");
    });
    AddTrainerPage.appState.updateData();
    ScannerPage.appState.updateData();
    RequestPage.appState.updateData();
  }

  static void checkTrainer(uid) {
    var exists = false;
    var ref = FirebaseDatabase.instance.ref().child("users/" + uid);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        exists = true;
      }
      LoginLoginPage.appState.checkTrainer(exists);
      // LoginRegisterPage.appState.checkTrainer(exists);
    });
  }

  // Check clients

  static void checkClients(id, client) {
    var ref = FirebaseDatabase.instance.ref().child("clients/" + id);

    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      bool deleted = false;

      data.forEach((index, data) => ({
            deleted = false,
            if (data["deleted"] != null)
              {
                deleted = (data["deleted"] is bool ? data["deleted"] : false),
              },
            if (deleted && index == client)
              {
                for (var item in GlobalData.connect)
                  {
                    if (item.client == client)
                      {
                        FirebaseDatabase.instance
                            .ref()
                            .child("/connect/" + item.id)
                            .remove(),
                        GlobalData.connect.remove(item)
                      }
                  }
              }
          }));
      RegisterPage.appState.updateData();
    });
  }

  // Clients

  static void getAllClients(id) {
    var ref = FirebaseDatabase.instance.ref().child("clients/" + id);
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.trainerClients = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        bool deleted = false;
        var arr = [];
        var name = "Member";
        var phone = "";
        var avatar = "";

        data.forEach((index, data) => ({
              add = true,
              deleted = false,
              arr = ["", ""],
              name = "Member",
              phone = "",
              avatar = "",
              if (data["deleted"] != null)
                {
                  deleted = (data["deleted"] is bool ? data["deleted"] : false),
                },
              if (data["avatar"] != null)
                {
                  avatar = (data["avatar"] is String ? data["avatar"] : ""),
                },
              if (data["name"] != null)
                {
                  name = (data["name"] is bool ? data["name"] : "Member"),
                },
              for (var item in GlobalData.trainerClients)
                {
                  if (item.id == index) {add = false}
                },
              if (add)
                {
                  GlobalData.trainerClients.add(ModelClient(
                      index,
                      (data["email"] is String ? data["email"] : ""),
                      (data["phone"] is String ? data["phone"] : ""), //image
                      (data["name"] is String ? data["name"] : ""), //token
                      (data["uid"] is String ? data["uid"] : ""),
                      "",
                      false,
                      avatar))
                }
            }));
      }

      AddTrainerPage.appState.updateData();
      ScannerPage.appState.updateData();
    });
  }

  // Welcome email

  static void sendWelcome() {
    var stime =
        DateTime.now().add(Duration(hours: GlobalData.space.welcomeTime));
    var scheduled = (stime.millisecondsSinceEpoch / 1000).toInt();
    var ref =
        FirebaseDatabase.instance.ref().child("emails/" + GlobalData.space.id);
    var found = false;
    var content = "";
    var subject = "";

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        data.forEach((index, data) => ({
              if (index == GlobalData.space.welcome)
                {
                  found = true,
                  subject = (data["subject"] is String ? data["subject"] : ""),
                  content = (data["content"] is String ? data["content"] : "")
                }
            }));
        if (found) {
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('sendWelcomeV2');
          callable.call(
            <String, dynamic>{
              "sender": GlobalData.space.business,
              "email": GlobalUser.email,
              "subject": subject,
              "content": content,
              "scheduled": scheduled,
            },
          );
        }
      }
    });
  }

  // Client connect

  static void getConnect() {
    var ref = FirebaseDatabase.instance.ref().child("connect/");
    ref.onValue.listen((snapshot) {
      GlobalData.connect = [];
      Map data = snapshot.snapshot.value as Map;
      bool add = true;
      String email = "";

      data.forEach((index, data) => ({
            add = true,
            email = "",
            if (data["email"] != null)
              {
                email = (data["email"] is String ? data["email"] : ""),
              },
            for (var item in GlobalData.connect)
              {
                if (item.id == index) {add = false}
              },
            if (add)
              {
                GlobalData.connect.add(ModelConnect(
                    index,
                    (data["space"] is String ? data["space"] : ""),
                    (data["phone"] is String ? data["phone"] : ""),
                    (data["client"] is String ? data["client"] : ""),
                    email))
              }
          }));
      RegisterPage.appState.updateData();
    });
  }

  // Forms

  static void getForms() {
    var ref =
        FirebaseDatabase.instance.ref().child("forms/" + GlobalData.space.id);

    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        GlobalData.space.forms = [];
        Map data = snapshot.snapshot.value as Map;
        bool add = true;
        List<ModelSection> sections = [];
        bool pre = false;

        data.forEach((index, data) => ({
              pre = (data["pre"] is bool ? data["pre"] : false),
              add = true,
              sections = [],
              for (var item in GlobalData.space.forms)
                {
                  if (item.id == index) {add = false}
                },
              if (!pre) {add = false},
              if (add)
                {
                  if (data["sections"] != null)
                    {
                      data["sections"].forEach((fskey, section) => ({
                            sections.add(ModelSection(
                              fskey,
                              (section["seq"] is int ? section["seq"] : 0),
                              (section["type"] is String
                                  ? section["type"]
                                  : ""),
                              (section["label"] is String
                                  ? section["label"]
                                  : ""),
                              (section["num"] is int ? section["num"] : 2),
                              (section["multiple"] is bool
                                  ? section["multiple"]
                                  : false),
                              (section["answer1"] is bool
                                  ? section["answer1"]
                                  : false),
                              (section["answer2"] is bool
                                  ? section["answer2"]
                                  : false),
                              (section["response"] is String
                                  ? section["response"]
                                  : ""),
                              (section["detail"] is String
                                  ? section["detail"]
                                  : ""),
                              (section["options"] is List
                                  ? section["options"]
                                  : []),
                              (section["mandatory"] is bool
                                  ? section["mandatory"]
                                  : false),
                            ))
                          }))
                    },
                  sections.sort((a, b) => a.seq.compareTo(b.seq)),
                  GlobalData.space.forms.add(ModelForm(
                      index,
                      (data["name"] is String ? data["name"] : ""),
                      DateTime(1900),
                      (data["pre"] is bool ? data["pre"] : false),
                      (data["version"] is int ? data["version"] : 1),
                      (data["uid"] is String
                          ? data["uid"]
                          : GlobalData.space.id),
                      (data["lock"] is bool ? data["lock"] : false),
                      sections))
                }
            }));
      }
    });
  }

  // Movements

  static void getMovements() {
    var ref = FirebaseDatabase.instance.ref().child("exercises/");
    ref.onValue.listen((snapshot) {
      Map data = snapshot.snapshot.value as Map;
      GlobalData.movements = [];
      int cat = 0;
      int type = 0;
      List ids = [];
      List names = [];
      List tools = [];
      List images = [];
      String user = "";
      bool add = true;
      String desc = "";
      String video = "";
      List videos = [];
      List descs = [];
      List units = [];
      String unit = "";

      data.forEach((index, data) => ({
            cat = data["cat"],
            type = data["type"],
            ids = data["subIds"],
            names = data["subTitles"],
            tools = data["subTools"],
            images = data["subImages"],
            user = data["user"],
            videos = [],
            descs = [],
            units = [],
            if (data["subDescs"] != null) {descs = data["subDescs"]},
            if (data["subVideos"] != null) {videos = data["subVideos"]},
            if (data["subUnits"] != null) {units = data["subUnits"]},
            for (var i = 0; i < ids.length; i++)
              {
                add = true,
                desc = "",
                video = "",
                unit = "",
                for (var item in GlobalData.movements)
                  {
                    if (item.id == ids[i]) {add = false}
                  },
                if (videos.length > i) {video = videos[i]},
                if (descs.length > i) {desc = descs[i]},
                if (units.length > i) {unit = units[i]},
                if (add && (user == "admin" || user == GlobalData.space.id))
                  {
                    GlobalData.movements.add(ModelMovement(
                        ids[i],
                        names[i],
                        type,
                        cat,
                        tools[i],
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        "",
                        "",
                        images[i],
                        "kg",
                        "",
                        "",
                        "",
                        "",
                        desc,
                        video,
                        unit,
                        ""))
                  }
              }
          }));
      GlobalData.movements.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // Check updated version

  static void getVersionUpdate() {
    var ref = FirebaseDatabase.instance.ref().child("admin/");
    ref.onValue.listen((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;
        if (data["verAndroidCl"] != null) {
          GlobalUI.appver =
              (data["verAndroidCl"] is String ? data["verAndroidCl"] : "1.0.0");
        }
        if (data["emailImages"] != null) {
          GlobalUI.emailImages =
              (data["emailImages"] is List ? data["emailImages"] : []);
        }
      } else {
        print("doesnt exist");
      }
    });
  }
}
