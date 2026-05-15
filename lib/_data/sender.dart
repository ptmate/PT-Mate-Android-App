import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:package_info/package_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ptmate_client/_data/variables.dart';

class FirebaseSender {
  // Session booking

  static void bookSession(id, clients, type, bookings) {
    if (type == "sessions") {
      var ref = FirebaseDatabase.instance
          .ref()
          .child(type + "/" + GlobalData.space.id + "/" + id);
      ref.update({
        "clients": clients,
        "bookings": bookings,
      });
    } else {
      var ref = FirebaseDatabase.instance
          .ref()
          .child(type + "/" + GlobalData.space.id + "/" + id);
      ref.update({
        "clients": clients,
      });
    }
  }

  // Session waiting list

  static void waitSession(id, clients, type) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child(type + "/" + GlobalData.space.id + "/" + id);
    ref.update({
      "waiting": clients,
    });
  }

  // Rate session

  static void rateSession(id, rating, type) {
    var user = GlobalData.space.id;
    if (type == "training") {
      user = GlobalUser.uid;
    }
    var ref =
        FirebaseDatabase.instance.ref().child("sessions/" + user + "/" + id);
    ref.update({
      "rating": rating,
    });
  }

  // Comment session

  static void addComment(id, text, type) {
    if (type == "training") {
      var key = FirebaseDatabase.instance
          .ref()
          .child("sessions/" + GlobalUser.uid + "/" + id + "/comments")
          .push();
      key.update({
        "sender": GlobalData.space.client,
        "date": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
        "text": text,
      });
    } else {
      var key = FirebaseDatabase.instance
          .ref()
          .child("sessions/" + GlobalData.space.id + "/" + id + "/comments")
          .push();
      key.update({
        "sender": GlobalData.space.client,
        "date": DateTime.now().millisecondsSinceEpoch / 1000,
        "text": text,
      });
    }
  }

  static void updateComment(id, text, type, comment) {
    if (type == "training") {
      var ref = FirebaseDatabase.instance.ref().child(
          "sessions/" + GlobalUser.uid + "/" + id + "/comments/" + comment);
      ref.update({
        "text": text,
      });
    } else {
      var ref = FirebaseDatabase.instance.ref().child("sessions/" +
          GlobalData.space.id +
          "/" +
          id +
          "/comments/" +
          comment);
      ref.update({
        "text": text,
      });
    }
  }

  // Update session results

  static void updateResults(id, type, program, block, reps, weight, time,
      rrounds, wrounds, simple, amrap, valuesimple, scaled) {
    var user = GlobalData.space.id;
    if (type == "training") {
      user = GlobalUser.uid;
    }
    var ref = FirebaseDatabase.instance.ref().child("sessions/" +
        user +
        "/" +
        id +
        "/workout/" +
        program +
        "/blocks/" +
        block);
    if (time == 0) {
      ref.update({
        "exResReps": reps,
        "exResWeight": weight,
        "exResRepsRounds": rrounds,
        "exResWeightRounds": wrounds,
        "notesResSimple": simple,
        "amrapSimple": amrap,
        "valueSimple": valuesimple,
        "scaledSimple": scaled
      });
    } else {
      ref.update({
        "exResReps": reps,
        "exResWeight": weight,
        "exResRepsRounds": rrounds,
        "exResWeightRounds": wrounds,
        "timeRes": time,
        "notesResSimple": simple,
        "amrapSimple": amrap,
        "valueSimple": valuesimple,
        "scaledSimple": scaled
      });
    }
  }

  static void updateResultsGroup(id, program, block, reps, weight, time,
      rrounds, wrounds, simple, amrap, valuesimple, scaled) {
    var ref = FirebaseDatabase.instance.ref().child("sessions/" +
        GlobalData.space.id +
        "/" +
        id +
        "/workout/" +
        program +
        "/blocks/" +
        block);
    if (time.length == 0) {
      ref.update({
        "exResRepsGroup": reps,
        "exResWeightGroup": weight,
        "exResRepsRounds": rrounds,
        "exResWeightRounds": wrounds,
        "notesResSimple": simple,
        "amrapSimple": amrap,
        "valueSimple": valuesimple,
        "scaledSimple": scaled
      });
    } else {
      ref.update({
        "exResRepsGroup": reps,
        "exResWeightGroup": weight,
        "timeResGroup": time,
        "exResRepsRounds": rrounds,
        "exResWeightRounds": wrounds,
        "notesResSimple": simple,
        "amrapSimple": amrap,
        "valueSimple": valuesimple,
        "scaledSimple": scaled
      });
    }
  }

  // Update high fives

  static void updateHighfives(id, highfives) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("sessions/" + GlobalData.space.id + "/" + id);
    ref.update({
      "highfives": highfives,
    });
  }

  // Delete session

  static void deleteSession(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("sessions/" + GlobalUser.uid + "/" + id);
    ref.remove();
  }

  // Delete progrma

  static void deleteProgram(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("workouts/" + GlobalUser.uid + "/" + id);
    ref.remove();
  }

  // Start a plan

  static void startPlan(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("plans/" + GlobalUser.uid + "/" + id);
    ref.update({"date": GlobalUI.dateTime.format(DateTime.now())});
    addActivity("plan", GlobalUser.uid + "," + id);
  }

  // Update plan clients

  static void updatePlanClients(id, sent) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("plans/" + GlobalData.space.id + "/" + id);
    ref.update({
      "sent": sent,
    });
  }

  // Delete plan

  static void deletePlan(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("plans/" + GlobalUser.uid + "/" + id);
    ref.remove();
  }

  // Delete assessment

  static void deleteAssessment(id) {
    var ref = FirebaseDatabase.instance.ref().child("clients/" +
        GlobalData.space.id +
        "/" +
        GlobalData.space.client +
        "/assessments/" +
        id);
    ref.remove();
  }

  // Activity

  static void addActivity(type, data) {
    var key = FirebaseDatabase.instance
        .ref()
        .child("activity/" + GlobalData.space.id)
        .push();
    key.update({
      "type": type,
      "data": data,
      "date": GlobalUI.dateTime.format(DateTime.now())
    });
  }

  // Creat chat

  static void createChat() {
    var key = FirebaseDatabase.instance
        .ref()
        .child("messaging/" + GlobalData.space.id + GlobalUser.uid);
    key.update({
      "id": GlobalData.space.id + GlobalUser.uid,
      "client": GlobalUser.uid,
      "nameClient": GlobalUser.name,
      "nameTrainer": GlobalData.space.name,
      "trainer": GlobalData.space.id,
      "dateTrainer": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      "timeTrainer": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "dateClient": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      "timeClient": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
    });
  }

  // Send chat message

  static void sendChatMessage(id, message, image) {
    var key = FirebaseDatabase.instance.ref().child(id + "/messages").push();
    key.update({
      "sender": GlobalUser.uid,
      "text": message,
      "image": image,
      "name": GlobalUser.name,
      "date": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      "timestamp": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
    });
  }

  // Update chat date

  static void updateChatDate(id, type) {
    if (type == "pt" || type == "staff") {
      var ref = FirebaseDatabase.instance.ref().child("messaging/" + id);
      ref.update({
        "dateClient": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
        "timeClient": DateTime.now().millisecondsSinceEpoch / 1000,
      });
    } else {
      var ref = FirebaseDatabase.instance.ref().child("messagingGroup/" +
          GlobalData.space.id +
          "/" +
          id +
          "/clients/" +
          GlobalUser.uid);
      ref.update({
        "date": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
        "timestamp": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      });
    }
  }

  // Leave a chat

  static void leaveChat(id) {
    var ref = FirebaseDatabase.instance.ref().child("messagingGroup/" +
        GlobalData.space.id +
        "/" +
        id +
        "/clients/" +
        GlobalUser.uid);
    ref.remove();
  }

  // Update best

  static void updateBest(id, name, value, actual, per, tool, unit, type) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("records/" + GlobalUser.uid + "/" + id);
    ref.update({
      "id": id,
      "name": name,
      "value": value,
      "actual": actual,
      "percent": per,
      "tool": tool,
      "unit": unit,
      "type": type,
      "date": DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
    });
  }

  // Update habit

  static void updateHabit(id, days) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("habits/" + GlobalData.space.id + "/" + id);
    ref.update({"days": days});
  }

  // Create or update user

  static void createUser(
      name, phone, birth, height, country, ecName, ecPhone, ecType) {
    bool lbs = false;
    if (country == "us") {
      lbs = true;
    }
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({
      "name": name,
      "email": GlobalUser.email,
      "phone": phone,
      "birth": birth,
      "height": height,
      "image": "",
      "imageDate": GlobalUI.dateTime.format(DateTime.now()),
      "pushToken": "",
      "country": country,
      "lbs": lbs,
      "ecName": ecName,
      "ecPhone": ecPhone,
      "ecType": ecType,
      "uid": GlobalUser.uid,
    });
  }

  static void updateUser(
      name, phone, birth, height, goal, ecName, ecPhone, ecType) {
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({
      "name": name,
      "phone": phone,
      "birth": birth,
      "height": height,
      "ecName": ecName,
      "ecPhone": ecPhone,
      "ecType": ecType,
    });
    for (var space in GlobalData.spaces) {
      if (space.id != "" && space.id != "none") {
        var ref2 = FirebaseDatabase.instance
            .ref()
            .child("clients/" + space.id + "/" + space.client);
        ref2.update({
          "name": name,
          "phone": phone,
          "birth": birth,
          "height": height,
          "goal": goal,
          "ecName": ecName,
          "ecPhone": ecPhone,
          "ecType": ecType,
        });
      }
    }
  }

  static void updateUserSettings(country, lbs, reminder, email) {
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({
      "country": country,
      "lbs": lbs,
      "reminder": reminder,
    });
    for (var space in GlobalData.spaces) {
      var ref2 = FirebaseDatabase.instance
          .ref()
          .child("clients/" + space.id + "/" + space.client);
      ref2.update({
        "country": country,
        "emailReminder": email,
      });
    }
  }

  static void updateUserAvatar(avatar, space) {
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({
      "avatar": avatar,
      "image": "",
    });
    if (space != "") {
      for (var space in GlobalData.spaces) {
        var ref2 = FirebaseDatabase.instance
            .ref()
            .child("clients/" + space.id + "/" + space.client);
        ref2.update({
          "avatar": avatar,
          "image": "",
        });
      }
    }
  }

  static void updateUserToken() {
    if (GlobalData.space.id != "" && GlobalData.space.id != "none") {
      var ref = FirebaseDatabase.instance.ref().child(
          "clients/" + GlobalData.space.id + "/" + GlobalData.space.client);
      ref.update({
        "pushToken": GlobalUser.token,
      });
    }
    var ref2 =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref2.update({
      "pushToken": GlobalUser.token,
    });
  }

  // Delete log

  static void deleteLog(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("log/" + GlobalUser.uid + "/" + id);
    ref.remove();
  }

  static void deleteLog2(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("log/" + GlobalData.space.id + "/" + id);
    ref.remove();
  }

  // Upload image

  static void uploadImage(id, image, name) {
    var storageReference = FirebaseStorage.instance
        .ref()
        .child("images/messaging/" + id + "/" + name + ".jpg");
    storageReference.putFile(image);
  }

  // Update profile image

  static void updateUserImage(image) {
    var date = DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now());
    var storageReference = FirebaseStorage.instance
        .ref()
        .child("images/users/" + GlobalUser.uid + ".jpg");
    storageReference.putFile(image);
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({
      "image": "images/users/" + GlobalUser.uid + ".jpg",
      "imageDate": date,
      "avatar": "",
    });
    for (var item in GlobalData.spaces) {
      if (item.id != "" && item.id != "none") {
        var ref2 = FirebaseDatabase.instance
            .ref()
            .child("clients/" + item.id + "/" + item.client);
        ref2.update({
          "image": "images/users/" + GlobalUser.uid + ".jpg",
          "imageDate": date,
          "avatar": "",
        });
      }
    }
  }

  // Connect to a space

  static void connectSpace(space, id, client, ecName, ecPhone, ecType) {
    if (space.id != "" && space.id != "none") {
      var key = FirebaseDatabase.instance
          .ref()
          .child("/clients/" + space.id + "/" + client);
      if (client == "") {
        key = FirebaseDatabase.instance
            .ref()
            .child("/clients/" + space.id)
            .push();
      }
      var arr = key.path.split("/");
      var id = arr[arr.length - 1];
      key.update({
        "active": true,
        "birth": GlobalUser.birth,
        "email": GlobalUser.email,
        "height": GlobalUser.height,
        "phone": GlobalUser.phone,
        "name": GlobalUser.name,
        "goal": "",
        "image": GlobalUser.image,
        "imageDate": DateFormat("dd/MM/yyyy").format(DateTime.now()),
        "avatar": GlobalUser.avatar,
        "ecName": ecName,
        "ecPhone": ecPhone,
        "ecType": ecType,
        "country": GlobalUser.country,
        "uid": GlobalUser.uid,
        "pushToken": GlobalUser.token
      });
      GlobalData.space.client = id;
      var ref = FirebaseDatabase.instance
          .ref()
          .child("usersClients/" + GlobalUser.uid + "/trainers/" + space.id);
      ref.update({
        "trainer": space.id,
        "client": id,
      });
      var hkey = FirebaseDatabase.instance
          .ref()
          .child("/clients/" + space.id + "/" + key.key! + "/history")
          .push();
      hkey.update({
        "date": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
        "title": "Connected",
        "desc": "Client connected via Android Member App"
      });
      if (client == "") {
        addActivity("newclient", GlobalUser.uid + " " + id);
      } else {
        addActivity("clientconnected", GlobalUser.uid + " " + client);
      }
      //Add to admin list
      var akey =
          FirebaseDatabase.instance.ref().child("/admin/accounts").push();
      akey.update({
        "date": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
        "email": GlobalUser.email,
        "space": space.id
      });
      if (space.id != "") {
        FirebaseDatabase.instance
            .ref()
            .child("/clients/" + space.id + "/" + id + "/deleted")
            .remove();
      }
      //Push notification
      if (GlobalUI.spaceToken != "") {
        FirebaseSender.sendPushMessage(
            GlobalUI.spaceToken,
            "A client connected",
            GlobalUser.name + " just connected with you.",
            "client",
            "", []);
      }
    }
  }

  // Disconnect from a space

  static void disconnectSpace(space) {
    var ref1 = FirebaseDatabase.instance
        .ref()
        .child("clients/" + space.id + "/" + space.client);
    ref1.update({"uid": ""});
    var ref2 = FirebaseDatabase.instance
        .ref()
        .child("usersClients/" + GlobalUser.uid + "/trainers/" + space.id);
    ref2.remove();
    var ref3 = FirebaseDatabase.instance
        .ref()
        .child("messaging/" + space.id + GlobalUser.uid);
    ref3.remove();
  }

  // Create session id

  static String createSessionId() {
    var key = FirebaseDatabase.instance
        .ref()
        .child("/sessions/" + GlobalUser.uid)
        .push();
    var arr = key.path.split("/");
    var id = arr[arr.length - 1];
    return id;
  }

  // Update push token

  static void updateToken(id, token) {
    var ref = FirebaseDatabase.instance.ref().child("usersClients/" + id);
    ref.update({"pushToken": token});
    if (GlobalData.space.id != "" && GlobalData.space.client != "") {
      var ref2 = FirebaseDatabase.instance.ref().child(
          "clients/" + GlobalData.space.id + "/" + GlobalData.space.client);
      ref2.update({"pushToken": token});
    }
  }

  // Create training session

  static void createSession(session) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("sessions/" + GlobalUser.uid + "/" + session.id);
    ref.update({
      "date": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
      "client": "Training Session",
      "clients": [],
      "attendance": 3,
      "duration": session.program.time,
      "group": false,
      "timestamp": (DateTime.now().millisecondsSinceEpoch / 1000),
      "preview": true,
      "max": 0,
      "invitees": [],
      "link": "",
      "waiting": [],
      "unlocked": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
      "rating": [],
      "uid": GlobalUser.uid,
    });
    var ref2 = FirebaseDatabase.instance.ref().child("sessions/" +
        GlobalUser.uid +
        "/" +
        session.id +
        "/workout/" +
        session.program.id);
    ref2.update({
      "benchmark": session.program.benchmark,
      "name": session.program.name,
      "desc": session.program.desc,
      "exercises": session.program.movements,
      "time": session.program.time,
      "session": session.id,
      "video": session.program.video,
      "uid": GlobalUser.uid
    });
    for (var block in session.program.blocks) {
      List exId = [];
      List exName = [];
      List exType = [];
      List exCat = [];
      List exTool = [];
      List exReps = [];
      List exRepsRounds = [];
      List exWeight = [];
      List exWeightRounds = [];
      List exWeightType = [];
      List exWork = [];
      List exRest = [];
      List exImage = [];
      List exUnits = [];
      for (var ex in block.movements) {
        exId.add(ex.id);
        exName.add(ex.name);
        exType.add(ex.type);
        exCat.add(ex.cat);
        exTool.add(ex.tool);
        exReps.add(ex.reps);
        exRepsRounds.add(ex.repsRounds);
        exWeight.add(ex.weight);
        exWeightRounds.add(ex.weightRounds);
        exWeightType.add(ex.weightType);
        exWork.add(ex.work);
        exRest.add(ex.rest);
        exImage.add(ex.image);
        exUnits.add(ex.unit);
      }
      ;
      var ref3 = FirebaseDatabase.instance.ref().child("sessions/" +
          GlobalUser.uid +
          "/" +
          session.id +
          "/workout/" +
          session.program.id +
          "/blocks/" +
          block.id);
      ref3.update({
        "cat": block.cat,
        "emom": block.emom,
        "notes": block.notes,
        "notesRes": block.notesRes,
        "results": false,
        "rounds": block.rounds,
        "type": block.type,
        "exId": exId,
        "exName": exName,
        "exType": exType,
        "exCat": exCat,
        "exTool": exTool,
        "exReps": exReps,
        "exRepsRounds": exRepsRounds,
        "exWeight": exWeight,
        "exWeightRounds": exWeightRounds,
        "exWeightType": exWeightType,
        "exResReps": exReps,
        "exResWeight": exWeight,
        "exWork": exWork,
        "exRest": exRest,
        "exImage": exImage,
        "exResRepsGroup": [""],
        "exResWeightGroup": [""],
        "exUnits": exUnits,
        "logResults": block.logResults,
        "simple": block.simple,
      });
    }
  }

  static void updateAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    var ref =
        FirebaseDatabase.instance.ref().child("usersClients/" + GlobalUser.uid);
    ref.update({"mobile": "Android - App " + version});
  }

  // Create assessment id

  static String createAssessmentId() {
    var key = FirebaseDatabase.instance
        .ref()
        .child("/clients/" +
            GlobalData.space.id +
            "/" +
            GlobalData.space.client +
            "/assessments")
        .push();
    var arr = key.path.split("/");
    var id = arr[arr.length - 1];
    return id;
  }

  // Update assessment

  static void updateAssessment(
      id,
      weight,
      fat,
      heart,
      notes,
      neck,
      chest,
      abdomen,
      hip,
      armL,
      armR,
      thighL,
      thighR,
      image,
      nutrition,
      date,
      blood1,
      blood2,
      custom) {
    var ref = FirebaseDatabase.instance.ref().child("/clients/" +
        GlobalData.space.id +
        "/" +
        GlobalData.space.client +
        "/assessments/" +
        id);
    ref.update({
      "weight": weight,
      "fat": fat,
      "heart": heart,
      "notes": notes,
      "neck": neck,
      "chest": chest,
      "abdomen": abdomen,
      "hip": hip,
      "armL": armL,
      "armR": armR,
      "thighL": thighL,
      "thighR": thighR,
      "image": image,
      "nutrition": nutrition,
      "date": date,
      "blood1": blood1,
      "blood2": blood2,
      "custom": custom,
    });
  }

  // Create post id

  static String createPostId() {
    var key = FirebaseDatabase.instance
        .ref()
        .child("/community/" + GlobalData.space.id)
        .push();
    var arr = key.path.split("/");
    var id = arr[arr.length - 1];
    return id;
  }

  static void createPost(id, text, image) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + id);
    ref.update({
      "author": GlobalData.space.client,
      "text": text,
      "date": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "reaction1": "",
      "reaction2": "",
      "reaction3": "",
      "reaction4": "",
      "image": image,
    });
  }

  // Update post

  static void updatePost(id, text, image) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + id);
    ref.update({"text": text, "image": image});
  }

  // Create reply

  static void createReply(parent, text) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + parent + "/comments/")
        .push();
    ref.update({
      "author": GlobalData.space.client,
      "text": text,
      "date": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "reaction1": "",
      "reaction2": "",
      "reaction3": "",
      "reaction4": "",
      "image": "",
    });
  }

  // Update reply

  static void updateReply(id, parent, text) {
    var ref = FirebaseDatabase.instance.ref().child(
        "community/" + GlobalData.space.id + "/" + parent + "/comments/" + id);
    ref.update({
      "text": text,
    });
  }

  // Create note

  static void createNote(text) {
    var ref =
        FirebaseDatabase.instance.ref().child("notes/" + GlobalUser.uid).push();
    ref.update({
      "text": text,
      "date": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
    });
  }

  // Update note

  static void updateNote(id, text) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("notes/" + GlobalUser.uid + "/" + id);
    ref.update({
      "text": text,
    });
  }

  // Delete note

  static void deleteNote(id) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("notes/" + GlobalUser.uid + "/" + id);
    ref.remove();
  }

  // Delete connect

  static void deleteConnect(id) {
    var ref = FirebaseDatabase.instance.ref().child("connect/" + id);
    ref.remove();
  }

  // Save form response

  static void saveForm(form, sections) {
    var ref = FirebaseDatabase.instance.ref().child("clients/" +
        GlobalData.space.id +
        "/" +
        GlobalData.space.client +
        "/forms/" +
        form.id);
    ref.update({
      "name": form.name,
      "pre": form.pre,
      "date": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "uid": GlobalData.space.id,
      "version": form.version,
    });
    for (var sec in sections) {
      var ref2 = FirebaseDatabase.instance.ref().child("clients/" +
          GlobalData.space.id +
          "/" +
          GlobalData.space.client +
          "/forms/" +
          form.id +
          "/sections/" +
          sec.id);
      if (sec.type != "selection" &&
          sec.type != "yesno" &&
          sec.type != "rating") {
        ref2.update({
          "label": sec.label,
          "response": sec.response,
          "seq": sec.seq,
          "type": sec.type,
          "mandatory": sec.mandatory,
        });
      }
      if (sec.type == "yesno") {
        ref2.update({
          "label": sec.label,
          "response": sec.response,
          "seq": sec.seq,
          "type": sec.type,
          "answer1": sec.answer1,
          "answer2": sec.answer2,
          "detail": sec.detail,
          "mandatory": sec.mandatory,
        });
      }
      if (sec.type == "selection") {
        ref2.update({
          "label": sec.label,
          "response": sec.response,
          "seq": sec.seq,
          "type": sec.type,
          "multiple": sec.multiple,
          "options": sec.options,
          "mandatory": sec.mandatory,
        });
      }
      if (sec.type == "rating") {
        ref2.update({
          "label": sec.label,
          "response": sec.response,
          "seq": sec.seq,
          "type": sec.type,
          "num": sec.num,
          "mandatory": sec.mandatory,
        });
      }
    }
    addActivity("form", GlobalData.space.client + "," + form.id);
  }

  // Log cash payment

  static void saveCashPayment(name, amount) {
    var key = FirebaseDatabase.instance
        .ref()
        .child("/payments/" + GlobalData.space.id)
        .push();
    key.update({
      "uid": GlobalUser.uid,
      "id": key.key,
      "name": name,
      "last4": "",
      "date": GlobalUI.dateTime.format(DateTime.now()),
      "amount": amount,
      "client": GlobalData.space.client,
      "receipt": "",
      "refunds": "",
      "type": "Cash",
      "fee": 0,
      "payer": GlobalUser.uid
    });
  }

  // Update client credits

  static void updateClientCredits(credit, sessions, paid, group, account) {
    if (credit == "") {
      var key = FirebaseDatabase.instance
          .ref()
          .child("/clients/" +
              GlobalData.space.id +
              "/" +
              GlobalData.space.client +
              "/credits/")
          .push();
      key.update({
        "type": "sessions",
        "group": group,
        "sessionsTotal": 0,
        "sessionsPaid": paid,
        "account": account,
      });
    } else {
      var ref = FirebaseDatabase.instance.ref().child("/clients/" +
          GlobalData.space.id +
          "/" +
          GlobalData.space.client +
          "/credits/" +
          credit);
      ref.update({"sessionsTotal": sessions, "sessionsPaid": paid});
    }
  }

  static void updateClientCreditsExpires(
      credit, paid, group, psessions, ppaid, expires, account, name, product) {
    var key = FirebaseDatabase.instance
        .ref()
        .child("/clients/" +
            GlobalData.space.id +
            "/" +
            GlobalData.space.client +
            "/credits/")
        .push();
    key.update({
      "type": "sessions",
      "group": group,
      "sessionsTotal": psessions,
      "sessionsPaid": paid,
      "expires": (expires.millisecondsSinceEpoch / 1000).toInt(),
      "account": account,
      "name": name,
      "product": product
    });
    if (credit != "") {
      var ref = FirebaseDatabase.instance.ref().child("/clients/" +
          GlobalData.space.id +
          "/" +
          GlobalData.space.client +
          "/credits/" +
          credit);
      ref.update({"sessionsPaid": ppaid});
    }
  }

  // Update credit sessions

  static void updateCreditSessions(product, value) {
    var ref = FirebaseDatabase.instance.ref().child("clients/" +
        GlobalData.space.id +
        "/" +
        GlobalData.space.client +
        "/credits/" +
        product);
    ref.update({
      "sessionsPaid": value,
    });
  }

  // Update stock

  static void updateStock(product, stock) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("packs/" + GlobalData.space.id + "/" + product);
    ref.update({
      "stock": stock,
    });
  }

  // Client packs

  static void updateClientPack(pack, done, group, account) {
    if (pack == "") {
      var key = FirebaseDatabase.instance
          .ref()
          .child("clients/" +
              GlobalData.space.id +
              "/" +
              GlobalData.space.client +
              "/credits/")
          .push();
      key.update({
        "sessionsTotal": 1,
        "sessionsPaid": 0,
        "group": group,
        "type": "sessions",
        "account": account
      });
    } else {
      var ref = FirebaseDatabase.instance.ref().child("clients/" +
          GlobalData.space.id +
          "/" +
          GlobalData.space.client +
          "/credits/" +
          pack);
      ref.update({"sessionsTotal": done});
    }
  }

  // Update image

  static void updateImage(id, iid, image, key) {
    var date = DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now());
    var storageReference = FirebaseStorage.instance.ref().child(
        "images/assessments/" + GlobalData.space.id + "/" + iid + ".jpg");
    storageReference.putFile(image);
    var ref = FirebaseDatabase.instance.ref().child("clients/" +
        GlobalData.space.id +
        "/" +
        GlobalData.space.client +
        "/assessments/" +
        id);
    ref.update({
      key: "images/assessments/" + GlobalData.space.id + "/" + iid + ".jpg",
    });
  }

  // Update post image

  static void updatePostImage(id, image) {
    var storageReference = FirebaseStorage.instance
        .ref()
        .child("images/community/" + GlobalData.space.id + "/" + id + ".jpg");
    storageReference.putFile(image);
    var ref = FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + id);
    ref.update({
      "image": "images/community/" + GlobalData.space.id + "/" + id + ".jpg",
    });
  }

  static void deletePost(id, image) {
    FirebaseDatabase.instance
        .ref()
        .child("community/" + GlobalData.space.id + "/" + id)
        .remove();
    if (image != "") {
      FirebaseStorage.instance
          .ref()
          .child("images/community/" + GlobalData.space.id + "/" + id + ".jpg")
          .delete();
    }
  }

  static void deleteReply(parent, id) {
    FirebaseDatabase.instance
        .ref()
        .child("community/" +
            GlobalData.space.id +
            "/" +
            parent +
            "/comments/" +
            id)
        .remove();
  }

  // Update scheduled notification

  static void updateSchedule(
      id, title, desc, type, date, tokens, message, iid) {
    var ref = FirebaseDatabase.instance.ref().child("schedule/" + id);
    ref.update({
      "title": title,
      "desc": desc,
      "type": type,
      "timestamp": (date.millisecondsSinceEpoch / 1000).toInt(),
      "tokens": tokens,
      "message": message,
      "uid": GlobalData.space.id,
      "iid": iid
    });
  }

  // Update location

  static void updateLocation(id, clients) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("locations/" + GlobalData.space.id + "/" + id);
    ref.update({"clients": clients});
  }

  // Update location

  static void updateGroup(id, clients) {
    var ref = FirebaseDatabase.instance
        .ref()
        .child("groups/" + GlobalData.space.id + "/" + id);
    ref.update({"clients": clients});
  }

  // Update nutrition status

  static void updateNutritionStatus(status) {
    var ref = FirebaseDatabase.instance.ref().child(
        "clients/" + GlobalData.space.id + "/" + GlobalData.space.client);
    ref.update({
      "nutritionStatus": status,
    });
  }

  static Future<void> sendPushMessage(
      token, title, body, type, id, tokens) async {
    if (tokens.length == 0) {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendPushV2');
      callable.call(
        <String, dynamic>{
          "token": token,
          "title": title,
          "body": body,
          "type": type,
          "space": GlobalData.space.id,
          "id": id,
        },
      );
    } else {
      if (tokens.length == 1) {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('sendPushV2');
        callable.call(
          <String, dynamic>{
            "token": tokens[0],
            "title": title,
            "body": body,
            "type": type,
            "space": GlobalData.space.id,
            "id": id,
          },
        );
      } else {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('sendPushMultipleV2');
        callable.call(
          <String, dynamic>{
            "tokens": tokens,
            "title": title,
            "body": body,
            "type": type,
            "space": GlobalData.space.id,
            "id": id,
          },
        );
      }
    }
  }

  static void addBookingLog(type, sessionId, data) async {
    try {
      // Guard against missing identifiers
      if (GlobalData.space.id == "" || GlobalUser.uid == "") return;

      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('templogs')
          .child("-Onw8TCpbtU8RqvtQKfm")
          .get();

      if (snapshot.exists) {
        final value = snapshot.value;
        // Direct access is much faster than JSON round-tripping
        if (value is Map && value['isLogEnabled'] == true) {
          FirebaseDatabase.instance
              .ref()
              .child('booking_logs')
              .child(GlobalData.space.id)
              .child('user_logs')
              .child(GlobalUser.uid)
              .push()
              .set({
            "type": type,
            "user_uid": GlobalUser.uid,
            "user_name": GlobalUser.name,
            "user_email": GlobalUser.email,
            "client_id": GlobalData.space.client,
            "session_id": sessionId,
            "timestamp": ServerValue.timestamp,
            "date": DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
            "data": data,
          });
        }
      }
    } catch (e) {
      // Broader catch to ensure zero failure to the caller
      print("Booking Log Error: $e");
    }
  }
}
