import 'package:flutter/material.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_helper/calendar.dart';


class HelperTrain {


  static String getColor(dur) {
    var color = GlobalUI.gradients[0];
    if (dur > 30 && dur < 46) {
      color = GlobalUI.gradients[1];
    }
    if (dur > 45 && dur < 61) {
      color = GlobalUI.gradients[2];
    }
    if (dur > 60 && dur < 76) {
      color = GlobalUI.gradients[3];
    }
    if (dur > 75) {
      color = "-red";
    }
    return color;
  }


  static String getBlockInfo(block) {
    String label = "";
    if (block.type == 0) {
      label = " - " + HelperCal.getDuration(block.rounds, "min");
    } else if (block.type == 1) {
      label = " - 1 round";
      if (block.rounds > 1) {
        label = " - " + block.rounds.toString() + " rounds";
      }
      if (block.movements[0].work != 60 && block.emom) {
        label += " of " + HelperCal.getDurationShort(block.movements[0].work, "min");
      }
    } else if (block.type == 2) {
      label = " - 1 round";
      if (block.rounds > 1) {
        label = " - " + block.rounds.toString() + " rounds";
      }
      if (block.emom) {
        label += " (" +
            block.movements[0].work.toString() +
            "s / " +
            block.movements[0].rest.toString() +
            "s)";
      }
    } else if (block.type == 3 && block.rounds > 1) {
      label = " - " + block.rounds.toString() + " rounds";
    } else if (block.type == 4 && block.rounds > 1) {
      String name = "sets";
      if (block.movements.length > 1) {
        name = "dropsets";
        String base = block.movements[0].id;
        for (var ex in block.movements) {
          if (ex.id != base) {
            name = "supersets";
          }
        }
      }
      label = " - " + block.rounds.toString() + " " + name;
    } else if (block.type == 5) {
      label = " - " + HelperCal.getDuration(block.rounds, "min") + " cap";
      if(block.cycles > 1) {
        label = " - "+block.cycles.toString()+" rounds in "+HelperCal.getDuration(block.rounds, "min");
      }
    }
    return label;
  }


  static String getMovementName(ex, block) {
    String label = ex.name;
    if(block.type == 1 && !block.emom) {
      label = HelperCal.getDurationShort(ex.work, "min")+": "+ex.name;
    }
    return label;
  }


  static String getMovementInfo(ex, block) {
    String label = "-";
    String unit = " reps";
    if (ex.reps == 1) {
      unit = " rep";
    }
    if (ex.tool == 6 || ex.tool == 7 || ex.tool == 25) {
      unit = " m";
    }
    if (ex.tool == 27) {
      unit = " cal";
    }
    if (ex.tool == 28) {
      unit = " sec";
    }
    if(ex.unit == "dist") {
      unit = " m";
    }
    if(ex.unit == "cals") {
      unit = " cal";
    }
    if(ex.unit == "time") {
      unit = " sec";
    }
    if (ex.reps > 0) {
      label = ex.reps.toString() + unit;
    }

    // New for reps per round
    if(ex.repsRounds != "" && ex.repsRounds != "0" && (block.type == 1 || block.type == 4 || block.type == 5)) {
      label = ex.repsRounds+unit;
    }

    if (ex.weight != 0) {
      var add = "";
      if(ex.weightType != "per") {
        add = " with "+ex.weight.toString()+" "+ex.weightType;
        if(ex.weightRounds != "" && ex.weightRounds != "0" && (block.type == 1 || block.type == 4 || block.type == 5)) {
          add = " with "+ex.weightRounds+" "+ex.weightType;
        }
      } else {
        add = " at " + ex.weight.toString() + "%";
        if(ex.weightRounds != "" && ex.weightRounds != "0" && (block.type == 1 || block.type == 4 || block.type == 5)) {
          add = " at "+ex.weightRounds+" %";
        }
        for (var best in GlobalData.best) {
          if (best.id == ex.id) {
            var val = best.value / 100 * ex.weight;

            if(GlobalData.space.lbs) {
              add += " (" + val.toStringAsFixed(1) + " lb)";
            } else {
              add += " (" + val.toStringAsFixed(1) + " kg)";
            }
          }
        }
      }
      label += add;
    }
    return label;
  }


  static String getResult(ex, number, block) {
    var rnds = block.rounds;
    if(block.type == 5) {
      rnds = block.cycles;
    }
    int reps = ex.resReps ?? 0;
    double weight = ex.resWeight ?? 0;
    if (ex.resRepsGroup != null) {
      var arr = ex.resRepsGroup.split("-");
      arr.removeAt(0);
      if(arr.length > number) {
        reps = int.parse(arr[number]);
      }
    }
    if (ex.resWeightGroup != null) {
      var arr = ex.resWeightGroup.split("-");
      arr.removeAt(0);
      if(arr.length > number) {
        weight = double.parse(arr[number]);
      }
    }

    var unit = " total reps";
    if (reps == 1) {
      unit = " total rep";
    }
    if(ex.tool == 6 || ex.tool == 7 || ex.tool == 25) {
      unit = " m";
    }
    if(ex.tool == 27) {
      unit = " cal";
    }
    if (ex.tool == 28) {
      unit = " sec";
    }
    if(ex.unit == "dist") {
      unit = " m";
    }
    if(ex.unit == "cals") {
      unit = " cal";
    }
    if(ex.unit == "time") {
      unit = " sec";
    }
    String label = reps.toString() + unit;
    if(reps == 0) {
      label = "-";
    }
    if(ex.resRepsRounds != "" && (block.type == 1 || block.type == 4 || block.type == 5) && rnds > 1) {
      var rr = "";
      var ar = ex.resRepsRounds.split("|");
      if(ar.length > number) {
        if(ar[number] != "") {
          rr = ar[number].substring(0, ar[number].length - 1);
        }
      }
      label = rr+unit;
    }

    
    
    if(ex.resWeightRounds != "" && (block.type == 1 || block.type == 4 || block.type == 5) && rnds > 1 && weight > 0) {
      var wr = "";
      var ar2 = ex.resWeightRounds.split("|");
      if(ar2.length > number) {
        if(ar2[number] != "") {
          wr = ar2[number].substring(0, ar2[number].length - 1);
        }
      }

      if(ex.weightType == "per") {

      } else {
        label += " with "+wr+" "+ex.weightType;
      }
    } else {
      if (weight > 0) {
        if(ex.weightType == "per") {
          label += " with "+weight.toStringAsFixed(1)+" "+(GlobalData.space.lbs ? 'lb' : 'kg');
        } else {
          label += " with "+weight.toStringAsFixed(1)+" "+ex.weightType;
        }
      }
    }

    if (weight == 0 && reps == 0) {
      label = "-";
    }
    
    return label;
  }


  static String checkResultsLogged(block, clients, type) {
    int number = 0;
    for (var i = 0; i < clients.length; i++) {
      if (clients[i] == GlobalData.space.client) {
        number = i;
      }
    }
    String label = "RESULTS LOGGED";
    if (type == "group") {
      label = "RESULTS PENDING";
      if (block.movements[0].resRepsGroup != null) {
        var arr = block.movements[0].resRepsGroup.split("-");
        arr.removeAt(0);
        int reps = 0;
        if(arr != null && arr.length > number) {
          int.parse(arr[number]);
        }
        if (reps > 0) {
          label = "RESULTS LOGGEED";
        }
      }
    } else {
      if (block.movements[0].resReps == null ||
          block.movements[0].resReps == 0) {
        label = "RESULTS PENDING";
      }
    }
    if(!block.logResults || !clients.contains(GlobalData.space.client)) {
      label = "";
    }
    return label;
  }


  static String getTargetReps(ex, block) {
    var label = "No target";
    if(ex.reps == 1) {
      label = "Target: 1 rep";
    }
    if(ex.reps > 1) {
      label = "Target: "+ex.reps.toString()+" reps";
      if(block.type == 0 || (block.type != 5 && block.rounds > 1)) {
        label = "Target: "+ex.reps.toString()+" per round";
      }
    }
    if((ex.tool == 6 || ex.tool == 7 || ex.tool == 25) && ex.reps > 0) {
      label = "Target: "+ex.reps.toString()+" m";
    }
    if (ex.tool == 27) {
      label = "Target: "+ex.reps.toString()+" cal";
    }
    if (ex.tool == 28) {
      label = "Target: "+ex.reps.toString()+" sec";
    }
    if(ex.unit == "dist") {
      label = "Target: "+ex.reps.toString()+" m";
    }
    if(ex.unit == "cals") {
      label = "Target: "+ex.reps.toString()+" cal";
    }
    if(ex.unit == "time") {
      label = "Target: "+ex.reps.toString()+" sec";
    }
    if(ex.reps == 0) {
      label = "No target";
    }
    return label;
  }


  static String getTargetWeight(ex) {
    var label = "No target";
    if(ex.weight > 0) {
      label = "Target: "+ex.weight.toString()+"%";
      if(ex.weightType != "per") {
        label = "Target: "+ex.weight.toString()+" "+ex.weightType;
      }
    }
    return label;
  }


  static int getPlanCompletion(plan) {
    var end = plan.date.add(Duration(days: plan.weeks.length*7+15));
    var start = plan.date.subtract(Duration(days: 1));
    var number = 0;
    for(var item in GlobalData.training) {
      for(var prog in plan.programs) {
        if(prog.id == item.program.id && item.attendance == 3 && item.date.isAfter(start) && item.date.isBefore(end)) {
          number += 1;
        }
      }
    }
    var total = ((number.toDouble()/(plan.programs.length).toDouble())*100).ceilToDouble();
    return total.toInt();
  }


  static String getPlanStatus(date, program) {
    var label = "pending";
    for(var item in GlobalData.training) {
      if(item.date.isAfter(date) && item.date.isBefore(DateTime.now()) && item.program.id == program) {
          label = "done";
      }
    }
    return label;
  }


  static ModelProgram getNextPlan(plan) {
    var program = plan.programs[0];
    var current = "done";
    
    for(var week in plan.weeks) {
      var days = [week.day1, week.day2, week.day3, week.day4, week.day5, week.day6, week.day7];
      
      for(var i=0; i<7; i++) {
        var arr = days[i].split(",");
        arr.removeAt(0);
        for( var prog in arr) {
          var status = HelperTrain.getPlanStatus(plan.date, prog);
          if(current == "done" && status == "pending") {
            for(var item in plan.programs) {
              if(item.id == prog) {
                program = item;
              }
            }
          }
          current = status;
        }
      }
        
    }
    return program;
  }

}
