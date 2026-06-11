import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/variables.dart';

class HelperBill {
  static int getUnpaid(group, id, date, products) {
    var number = 0;
    for (var item in GlobalData.packs) {
      if (products.length == 0 || products.contains(item.product)) {
        if (item.group == group && (item.account == "" || item.account == id)) {
          if (!item.expires || (item.expires && item.expiry.isAfter(date))) {
            var tmp = item.done - item.paid;
            number += tmp;
          }
        }
      }
    }
    DateFormat df = DateFormat("MM/yyyy");
    for (var sub in GlobalData.debits) {
      if (products.length == 0 || products.contains(sub.plan)) {
        var sessions = 0;
        sessions = sub.sessions;
        var tot = sessions;
        if (sub.group &&
            sessions > 0 &&
            sub.status == "active" &&
            sub.pause == "") {
          for (var item in GlobalData.sessions) {
            if ((item.type == "group" && group ||
                    item.type == "pt" && !group) &&
                df.format(DateTime.now()) == df.format(item.date)) {
              tot -= 1;
            }
          }
        }
        if (tot > 0 && sub.group == group) {
          number -= tot;
        }
      }
    }
    for (var sub in GlobalData.debits) {
      if ((products.length == 0 || products.contains(sub.plan)) &&
          sub.pause == "") {
        var sessions = 0;
        sessions = sub.sessions;
        if (sub.group &&
            sessions == 0 &&
            (sub.account == "" || sub.account == id)) {
          number = 0;
        }
      }
    }
    return number;
  }

  static int getAvailable(group, id) {
    var more = 0;
    var num = 0;
    var nump = 0;
    var numt = 0;

    var family = false;
    if (GlobalData.space.linked.length > 0) {
      family = true;
    }

    more = getClientSessionDebit(group, "", !family);
    for (var item in GlobalData.packs) {
      if (!family) {
        // Non family
        if (item.group == group) {
          if (!item.expires ||
              (item.expires && item.expiry.isAfter(DateTime.now()))) {
            nump += item.paid;
            numt += item.done;
          }
        }
      } else {
        // Family main account
        if (item.group == group && item.account == id) {
          if (!item.expires ||
              (item.expires && item.expiry.isAfter(DateTime.now()))) {
            nump += item.paid;
            numt += item.done;
          }
        }
      }
    }
    num = numt - nump;
    num -= more;

    return num;
  }

  static int getClientSessionDebit(group, id, strict) {
    var add = 0;
    var current = DateTime.now();

    var family = false;
    if (GlobalData.space.linked.length > 0) {
      family = true;
    }

    for (var item in GlobalData.debits) {
      current = item.next.add(Duration(days: -7));
      if (item.interval > 1) {
        current = item.next.add(Duration(days: -(7 * item.interval)));
      }
      if (item.cycle == "fortnight") {
        current = item.next.add(Duration(days: -14));
      } else if (item.cycle == "month") {
        current = DateTime(item.next.year, item.next.month - 1, item.next.day);
        //current = item.next.add(Duration(days: -30));
        if (item.interval > 1) {
          current = DateTime(
              item.next.year, item.next.month - item.interval, item.next.day);
        }
      }

      if (family && strict) {
        if (item.group == group &&
            item.next.isAfter(DateTime.now()) &&
            current.isBefore(DateTime.now()) &&
            item.status != "trialing" &&
            item.status != "unpaid" &&
            item.pause == "" &&
            item.account == id) {
          add += item.sessions - item.done;
        }
        // For both
        if (!item.group &&
            !group &&
            item.is11 &&
            item.next.isAfter(DateTime.now()) &&
            current.isBefore(DateTime.now()) &&
            item.status != "trialing" &&
            item.status != "unpaid" &&
            item.pause == "" &&
            item.account == id) {
          add += item.sessions11 - item.done11;
        }
      } else {
        if (item.group == group &&
            item.next.isAfter(DateTime.now()) &&
            current.isBefore(DateTime.now()) &&
            item.status != "trialing" &&
            item.status != "unpaid" &&
            item.pause == "" &&
            (item.account == "" || item.account == id)) {
          add += item.sessions - item.done;
        }
        // For both
        if (!item.group &&
            !group &&
            item.is11 &&
            item.next.isAfter(DateTime.now()) &&
            current.isBefore(DateTime.now()) &&
            item.status != "trialing" &&
            item.status != "unpaid" &&
            item.pause == "" &&
            (item.account == "" || item.account == id)) {
          add += item.sessions11 - item.done11;
        }
      }
    }

    if (add < 0) {
      add = 0;
    }
    return add;
  }

  static bool getPackValid(group) {
    bool valid = false;
    for (var item in GlobalData.packs) {
      if (item.group == group && item.done > 0) {
        valid = true;
      }
    }
    DateFormat df = DateFormat("MM/yyyy");
    for (var sub in GlobalData.debits) {
      var sessions = 0;
      sessions = sub.sessions;
      var tot = sessions;
      if (sub.group && sessions > 0 && sub.pause == "") {
        for (var item in GlobalData.sessions) {
          if ((item.type == "group" && group || item.type == "pt" && !group) &&
              df.format(DateTime.now()) == df.format(item.date)) {
            tot -= 1;
          }
        }
      }
      if (tot > 0 && sub.group == group) {
        valid = true;
      }
    }
    for (var sub in GlobalData.debits) {
      var sessions = 0;
      sessions = sub.sessions;
      if (sub.group && sessions == 0) {
        valid = false;
      }
    }
    return valid;
  }
}
