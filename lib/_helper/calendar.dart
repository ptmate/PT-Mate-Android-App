import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';


class HelperCal {

  static String getSpecialDate(date) {
    DateFormat dateTime = DateFormat("EEE, d MMM HH:mm");
    DateFormat time = DateFormat("HH:mm");
    DateTime now = DateTime.now();
    int diff = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    String label = dateTime.format(date);
    if(diff == 0) {
      label = "Today "+time.format(date);
    } else if(diff == 1) {
      label = "Tomorrow "+time.format(date);
    } else if(diff == -1) {
      label = "Yesterday "+time.format(date);
    }
    return label;
  }


  static String getSpecialDateBasic(date) {
    DateFormat dateTime = DateFormat("EEE, d MMM");
    DateTime now = DateTime.now();
    int diff = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    String label = dateTime.format(date);
    if(diff == 0) {
      label = "Today";
    } else if(diff == 1) {
      label = "Tomorrow";
    } else if(diff == -1) {
      label = "Yesterday";
    }
    return label;
  }


  static String getSpecialDateYear(date) {
    DateFormat dateTime = DateFormat("EEE, d MMM yyyy");
    DateTime now = DateTime.now();
    int diff = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    String label = dateTime.format(date);
    if(diff == 0) {
      label = "Today";
    } else if(diff == 1) {
      label = "Tomorrow";
    } else if(diff == -1) {
      label = "Yesterday";
    }
    return label;
  }


  static String getDuration(dur, type) {
    String label = "";
    String unit1 = "h";
    String unit2 = "min";
    int big = (dur/60).floor();
    int small = dur-(big*60);
    if(type == "min")  {
      unit1 = "min";
      unit2 = "sec";
    }
    label = big.toString()+" "+unit1+" "+small.toString()+" "+unit2;
    if(big == 0 && small != 0) {
      label = small.toString()+" "+unit2;
    } else if(big != 0 && small == 0) {
      label = big.toString()+" "+unit1;
    }
    return label;
  }


  static String getDurationShort(dur, type) {
    String label = "";
    String unit1 = "h";
    String unit2 = "min";
    int big = (dur/60).floor();
    int small = dur-(big*60);
    if(type == "min")  {
      unit1 = "min";
      unit2 = "sec";
    }
    label = big.toString()+":"+small.toString()+" "+unit1;
    if(small > 0 && small < 10) {
      label = big.toString()+":0"+small.toString()+" "+unit1;
    }
    if(big == 0 && small != 0) {
      label = small.toString()+" "+unit2;
    } else if(big != 0 && small == 0) {
      label = big.toString()+" "+unit1;
    }
    return label;
  }

  
  static String getTypeImage(type, availability) {
    String label = "session-11.svg";
    if(type == "group" && !availability) {
      label = "session-group.svg";
    } else if(type == "training") {
      label = "session-training.svg";
    } else if(type == "event") {
      label = "session-event.svg";
    }
    return label;
  }


  static String getTypeColor(type, availability) {
    String color = GlobalUI.gradients[1];
    if(type == "group" && !availability) {
      color = GlobalUI.gradients[0];
    } else if(type == "training") {
      color = GlobalUI.gradients[2];
    } else if(type == "event") {
      color = GlobalUI.gradients[3];
    }
    return color;
  }


  static String getNotificationDate(date, hours) {
    DateFormat df = DateFormat("EEE, d MMM");
    var d1 = date.add(Duration(hours: -hours));
    String label = df.format(date);
    var d2 = date.add(Duration(hours: -24));
    if(GlobalUI.date.format(d1) == GlobalUI.date.format(date)) {
      label = "today";
    }
    if(GlobalUI.date.format(d1) == GlobalUI.date.format(d2)) {
      label = "tomorrow";
    }
    return label;
  }


  static void addScheduledNotification(session, schedule) {
    DateTime date = session.date.subtract(Duration(hours: GlobalData.space.reminder));
    DateFormat dtime = DateFormat("HH:mm");
    var found = false;

    if(date.isAfter(DateTime.now()) && GlobalData.space.reminder != 9999 && GlobalUser.reminder) {
      for(var item in schedule) {
        if(item.id == session.id+"-push") {
          found = true;
          var tokens = [];
          for(var t in item.tokens) {
            tokens.add(t);
          }
          tokens.add(GlobalUser.token);
          FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
        }
      }
      if(!found) {
        FirebaseSender.updateSchedule(session.id+"-push", "Session Reminder", 'You are booked in for '+session.name+' '+HelperCal.getNotificationDate(session.date, GlobalData.space.reminder)+' '+dtime.format(session.date)+' h.', "", date, [GlobalUser.token], "push", session.id);
      }

      // Email
      if(GlobalData.space.emailReminder && GlobalData.space.clientEmailReminder) {
        for(var item in schedule) {
          if(item.id == session.id+"-email") {
            found = true;
            var tokens = [];
            for(var t in item.tokens) {
              tokens.add(t);
            }
            tokens.add(GlobalUser.email);
            FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
          }
        }
        if(!found) {
          FirebaseSender.updateSchedule(session.id+"-email", GlobalData.space.business, session.name, HelperCal.getNotificationDate(session.date, GlobalData.space.reminder)+" "+dtime.format(session.date)+' h', date, [GlobalUser.email], "sessionemail", GlobalData.space.id);
        }
      }
    }
  }


  static void addScheduledNotificationWaiting(session, schedule, client) {
    DateTime date = session.date.subtract(Duration(hours: GlobalData.space.reminder));
    DateFormat dtime = DateFormat("HH:mm");
    var found = false;

    if(date.isAfter(DateTime.now()) && GlobalData.space.reminder != 9999) {
      for(var item in schedule) {
        if(item.id == session.id+"-push") {
          found = true;
          var tokens = [];
          for(var t in item.tokens) {
              if(t != GlobalUser.token) {
                tokens.add(t);
              }
            }
          tokens.add(client.token);
          FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
        }
      }
      if(!found) {
        FirebaseSender.updateSchedule(session.id+"-push", "Session Reminder", 'You are booked in for '+session.name+' '+HelperCal.getNotificationDate(session.date, GlobalData.space.reminder)+' '+dtime.format(session.date)+' h.', "", date, [GlobalUser.token], "push", session.id);
      }

      // Email
      if(GlobalData.space.emailReminder && client.emailReminder) {
        for(var item in schedule) {
          if(item.id == session.id+"-email") {
            found = true;
            var tokens = [];
            for(var t in item.tokens) {
              if(t != GlobalUser.email) {
                tokens.add(t);
              }
            }
            tokens.add(client.email);
            FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
          }
        }
        if(!found) {
          FirebaseSender.updateSchedule(session.id+"-email", GlobalData.space.business, session.name, HelperCal.getNotificationDate(session.date, GlobalData.space.reminder)+" "+dtime.format(session.date)+' h', date, [GlobalUser.email], "sessionemail", GlobalData.space.id);
        }
      }
    }
  }


  static void removeScheduledNotification(session, schedule) {
    for(var item in schedule) {
      if(item.id == session.id+"-push") {
        var tokens = [];
        for(var t in item.tokens) {
          if(t != GlobalUser.token) {
            tokens.add(t);
          }
        }
        FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
      }
      if(item.id == session.id+"-email") {
        var tokens = [];
        for(var t in item.tokens) {
          if(t != GlobalUser.email) {
            tokens.add(t);
          }
        }
        FirebaseSender.updateSchedule(item.id, item.title, item.desc, item.type, item.date, tokens, item.message, item.iid);
      }
    }
  }

}
