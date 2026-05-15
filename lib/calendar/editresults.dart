import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/components/toggle.dart';

class EditResultsPage extends StatefulWidget {
  final String id;
  final ModelSession item;
  final ModelBlock block;
  const EditResultsPage(this.id, this.item, this.block);
  static _EditResultsPageState appState = _EditResultsPageState();
  @override
  _EditResultsPageState createState() {
    return EditResultsPage.appState = new _EditResultsPageState();
  }
}

class _EditResultsPageState extends State<EditResultsPage> {
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
  ModelBlock block = ModelBlock("", 0, "", 0, 0, false, "", "", [], true, 0, 0,
      [], false, "", [], [], [], "");
  List<int> reps = [];
  List<double> weight = [];
  List<String> rrounds = [];
  List<String> wrounds = [];
  int mins = 0;
  int secs = 0;
  int amrap1 = 0;
  int amrap2 = 0;

  int current = 0;
  List<TextEditingController> ctrl = [];
  List<TextEditingController> ctrlw = [];
  TextEditingController ctrlAmrap1 = TextEditingController();
  TextEditingController ctrlAmrap2 = TextEditingController();
  TextEditingController ctrlMin = TextEditingController();
  TextEditingController ctrlSec = TextEditingController();
  TextEditingController ctrlSimple = TextEditingController();
  TextEditingController ctrlSimpleValue = TextEditingController();
  List ctrlL1 = [];
  List ctrlL2 = [];
  bool valueScaled = false;

  @override
  void initState() {
    super.initState();
    var cl = 0;
    if (widget.item.type == "group") {
      for (var i = 0; i < widget.item.clients.length; i++) {
        if (widget.item.clients[i] == GlobalData.space.client) {
          cl = i;
        }
      }
    }
    var cs = "";
    //if(widget.block.simple) {
    cs = "";
    var ar = widget.block.notesSimple.split("|");
    if (ar.length > cl) {
      cs = ar[cl];
    }
    //}
    setState(() {
      id = widget.id;
      item = widget.item;
      block = widget.block;
      current = cl;
      ctrlSimple.text = cs;
    });

    ctrl = [];
    ctrlw = [];
    ctrlL1 = [];
    ctrlL2 = [];
    for (var i = 0; i < block.movements.length; i++) {
      ctrl.add(TextEditingController());
      ctrlw.add(TextEditingController());
      ctrl[ctrl.length - 1].text = "0";
      ctrlw[ctrlw.length - 1].text = "0";
      List<TextEditingController> lst = [];
      List<TextEditingController> lst2 = [];
      ctrlL1.add(lst);
      ctrlL2.add(lst2);
      if (block.type == 1 ||
          block.type == 2 ||
          block.type == 4 ||
          block.type == 5) {
        var rounds = block.rounds;
        if (block.type == 5) {
          rounds = block.cycles;
        }
        for (var k = 0; k < rounds; k++) {
          ctrlL1[i].add(TextEditingController());
          ctrlL1[i][k].text = "0";
          ctrlL2[i].add(TextEditingController());
          ctrlL2[i][k].text = "0";
        }
      }
    }

    configureReps();
  }

  configureReps() {
    var cl = current;
    int tmins = 0;
    int tsecs = 0;
    List<int> treps = [];
    List<double> tweight = [];
    List<String> rreps = [];
    List<String> rweight = [];
    var total = 0;
    var a1 = 0;
    var a2 = 0;
    int base = 0;
    if (item.type == "group") {
      if (block.movements[0].resRepsGroup != null) {
        var arr1 = block.movements[0].resRepsGroup.split("-");
        if (arr1.length > cl + 1) {
          base = int.parse(arr1[cl + 1]);
        }
      }
    } else {
      base = block.movements[0].resReps;
    }
    double a11 = 0;
    if (block.movements[0].reps != 0) {
      a11 = ((base).toDouble() / (block.movements[0].reps).toDouble())
          .floorToDouble();
    }
    a1 = a11.toInt();

    // Get AMRAP
    var tr = 0;
    if (block.type == 0) {
      for (var ex1 in block.movements) {
        tr += ex1.reps;
      }
    }

    for (var i = 0; i < block.movements.length; i++) {
      if (!block.simple) {
        var ex = block.movements[i];
        //ctrl[i].text = ex.reps.toString();
        //ctrlw[i].text = ex.weight.toString();
        ctrl[i].text = "0";
        ctrlw[i].text = "0";
        if ((block.rounds > 1 || block.cycles > 1) && block.type != 0) {
          var rounds = block.rounds;
          if (block.type == 5) {
            rounds = block.cycles;
          }
          for (var k = 0; k < rounds; k++) {
            //ctrlL1[i][k].text = ex.reps.toString();
            //ctrlL2[i][k].text = ex.weight.toString();
            ctrlL1[i][k].text = "0";
            ctrlL2[i][k].text = "0";
          }
        }
        if (item.type == "group") {
          if (ex.resRepsGroup != null) {
            var arr1 = ex.resRepsGroup.split("-");
            if (arr1.length > cl) {
              var result = 0;
              if (arr1[cl] != "") {
                result = int.parse(arr1[cl]);
              }
              treps.add(result);
              if (result > a1 * ex.reps) {
                a2 += result - a1 * ex.reps;
              }
            } else {
              /*if(ex.reps != 0) {
                treps.add(ex.reps);
              } else {
                treps.add(ex.reps);
              }*/
              treps.add(0);
            }
          } else {
            //treps.add(ex.reps);
            treps.add(0);
          }
          if (ex.resWeightGroup != null) {
            var arr2 = ex.resWeightGroup.split("-");
            if (arr2.length > cl) {
              if (arr2[cl] != "") {
                tweight.add(double.parse(arr2[cl]));
              } else {
                tweight.add(0);
              }
            } else {
              /*if(ex.weight != 0 && ex.weightType != "per") {
                tweight.add(ex.weight);
              } else {
                tweight.add(ex.weight);
              }*/
              tweight.add(0);
            }
          } else {
            /*if(ex.weight != 0) {
              tweight.add(ex.weight);
            } else {
              tweight.add(ex.weight);
            }*/
            tweight.add(0);
          }
          if (block.timeResGroup != null && block.timeResGroup.length > cl) {
            tmins = (block.timeResGroup[cl] / 60).floor();
            tsecs = block.timeResGroup[cl] - tmins * 60;
          }
          ctrl[i].text = treps[i].toString();
          ctrlw[i].text = tweight[i].toString();
        } else {
          if (ex.resReps != null) {
            treps.add(ex.resReps);
            if (ex.resReps > a1 * ex.resReps) {
              a2 += ex.resReps - a1 * ex.resReps;
            }
          } else {
            /*if(ex.reps != 0) {
              treps.add(ex.reps);
            } else {
              treps.add(ex.reps);
            }*/
            treps.add(0);
          }
          if (ex.resWeight != null) {
            tweight.add(ex.resWeight);
          } else {
            /*if(ex.weight != 0 && ex.weightType != "per") {
              tweight.add(ex.weight);
            } else {
              tweight.add(ex.weight);
            }*/
            tweight.add(0);
          }
          if (block.timeRes != null) {
            tmins = (block.timeRes / 60).floor();
            tsecs = block.timeRes - tmins * 60;
          }
          ctrl[i].text = treps[i].toString();
          ctrlw[i].text = tweight[i].toString();
        }
        // Rounds specific
        if ((block.rounds > 1 || block.cycles > 1) && block.type != 0) {
          var rounds = block.rounds;
          if (block.type == 5) {
            rounds = block.cycles;
          }
          if (ex.resRepsRounds != null && ex.resRepsRounds != "") {
            var ar = ex.resRepsRounds.split('|');
            if ((item.type == "group" && ar.length > cl) ||
                item.type == "pt" ||
                item.type == "training") {
              rreps.add(ar[cl]);
              var arr = ar[cl].split("-");
              ctrl[i].text = arr[0].toString();
              for (var j = 0; j < arr.length; j++) {
                if (arr.length > j && ctrlL1[i].length > j) {
                  ctrlL1[i][j].text = arr[j].toString();
                }
              }
            } else {
              //rreps.add(ar[0]);
              rreps.add("0");
            }
          } else {
            var label = '';
            for (var j = 0; j < rounds; j++) {
              //label += ex.reps.toString()+'-';
              label += "0-";
            }
            rreps.add(label);
          }
          if (ex.resWeightRounds != null && ex.resWeightRounds != "") {
            var ar2 = ex.resWeightRounds.split('|');
            if ((item.type == "group" && ar2.length > cl) ||
                item.type == "pt" ||
                item.type == "training") {
              rweight.add(ar2[cl]);
              var arr2 = ar2[cl].split("-");
              ctrlw[i].text = arr2[0].toString();
              for (var j = 0; j < arr2.length; j++) {
                if (arr2.length > j && ctrlL2[i].length > j) {
                  ctrlL2[i][j].text = arr2[j].toString();
                }
              }
            } else {
              //rweight.add(ar2[0]);
              rweight.add("0");
            }
          } else {
            var label = '';
            for (var j = 0; j < rounds; j++) {
              label += '0-';
            }
            rweight.add(label);
          }
        }
      } else {
        if (block.timeRes != null) {
          tmins = (block.timeRes / 60).floor();
          tsecs = block.timeRes - tmins * 60;
        }
        if (item.type == "group") {
          if (block.timeResGroup != null && block.timeResGroup.length > cl) {
            tmins = (block.timeResGroup[cl] / 60).floor();
            tsecs = block.timeResGroup[cl] - tmins * 60;
          }
        }
      }
    }

    if (block.type == 0) {
      var sum = 0;
      for (var a in treps) {
        sum += a;
      }
      if (sum > 0) {
        a1 = (sum / tr).floor();
        a2 = sum - (a1 * tr);
      }
    }

    setState(() {
      reps = treps;
      weight = tweight;
      mins = tmins;
      secs = tsecs;
      amrap1 = a1;
      amrap2 = a2;
      rrounds = rreps;
      wrounds = rweight;
    });
    ctrlAmrap1.text = a1.toString();
    ctrlAmrap2.text = a2.toString();
    ctrlMin.text = tmins.toString();
    ctrlSec.text = tsecs.toString();
  }

  _updateMin(value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    setState(() {
      mins = val;
    });
  }

  _updateSec(value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    setState(() {
      secs = val;
    });
  }

  _updateReps(pos, value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    if (rrounds[pos] != "") {
      var ar = rrounds[pos].split('-');
      if (ar.length > 1) {
        for (var i = 1; i < ar.length; i++) {
          val += int.parse(ar[i]);
        }
      }
    }
    reps[pos] = val;
  }

  _updateWeight(pos, value) {
    double val = 0;
    if (value != "") {
      val = double.parse(value);
    }
    weight[pos] = val;
  }

  _updateAllReps1(value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }

    if (!block.simple) {
      if (amrap2 != 0 && amrap2 != '') {
        var tr = 0;
        for (var ex1 in block.movements) {
          tr += ex1.reps;
        }
        if (amrap2 > tr) {
          amrap1 = amrap1 + (amrap2 / tr).floor();
          amrap2 = amrap2 % tr;
        }
      }
      var rps = amrap2;
      for (var i = 0; i < block.movements.length; i++) {
        reps[i] = block.movements[i].reps * val;
        if (rps > 0) {
          if (rps > block.movements[i].reps) {
            reps[i] += block.movements[i].reps;
            rps -= block.movements[i].reps;
          } else {
            reps[i] += rps;
            rps = 0;
          }
        }
      }
    }
    amrap1 = val;
  }

  _updateAllReps2(value) {
    int val = 0;
    if (value != "") {
      val = int.parse(value);
    }
    if (!block.simple) {
      if (val != 0 && val != '') {
        var tr = 0;
        for (var ex1 in block.movements) {
          tr += ex1.reps;
        }
        if (val > tr) {
          amrap1 = amrap1 + (val / tr).floor();
          val = val % tr;
        }
      }
      var rps = val;
      for (var i = 0; i < block.movements.length; i++) {
        reps[i] = block.movements[i].reps * amrap1;
        if (rps > 0) {
          if (rps > block.movements[i].reps) {
            reps[i] += block.movements[i].reps;
            rps -= block.movements[i].reps;
          } else {
            reps[i] += rps;
            rps = 0;
          }
        }
      }
    }
    amrap2 = val;
  }

  updateResults() {
    print(block.movements);
    for (var i1 = 0; i1 < block.movements.length; i1++) {
      if (rrounds.length > 0) {
        if (rrounds[i1] != "") {
          var t1 = rrounds[i1];
          if (t1[rrounds[i1].length - 1] == "-") {
            rrounds[i1] = rrounds[i1].substring(0, rrounds[i1].length - 1);
          }
        }
      }
      if (wrounds.length > 0) {
        if (wrounds[i1] != "") {
          var t2 = wrounds[i1];
          if (t2[wrounds[i1].length - 1] == "-") {
            wrounds[i1] = wrounds[i1].substring(0, wrounds[i1].length - 1);
          }
        }
      }
    }

    List amrap = [];
    List valueSimple = [];
    List scaledSimple = [];

    if (block.simple) {
      if (item.type == "group") {
        if (block.amrapSimple.length > current) {
          amrap = block.amrapSimple;
        } else {
          for (var i = block.amrapSimple.length; i < item.clients.length; i++) {
            amrap.add("0");
          }
        }
        amrap[current] = amrap1.toString() + "+" + amrap2.toString();

        if (block.valueSimple.length > current) {
          valueSimple = block.valueSimple;
        } else {
          for (var i = block.valueSimple.length; i < item.clients.length; i++) {
            valueSimple.add(0);
          }
        }
        valueSimple[current] = 0;
        if (ctrlSimpleValue.text != "") {
          valueSimple[current] = double.parse(ctrlSimpleValue.text);
        }

        if (block.scaledSimple.length > current) {
          amrap = block.scaledSimple;
        } else {
          for (var i = block.scaledSimple.length;
              i < item.clients.length;
              i++) {
            scaledSimple.add(false);
          }
        }
        scaledSimple[current] = valueScaled;
      } else {
        amrap = [amrap1.toString() + "+" + amrap2.toString()];
        valueSimple = [0];
        if (ctrlSimpleValue.text != "") {
          valueSimple = [double.parse(ctrlSimpleValue.text)];
        }
        scaledSimple = [valueScaled];
      }
    }

    var nsimple = ctrlSimple.text;

    if (item.type == "group") {
      int cl = current;

      List<String> arReps = [];
      List<String> arWeight = [];
      List time = [];
      List<String> arRepsRounds = [];
      List<String> arWeightRounds = [];
      nsimple = "";

      //if(block.simple) {
      var ar = block.notesSimple.split("|");
      for (var i = 0; i < widget.item.clients.length; i++) {
        if (i != cl && ar.length > i) {
          if (ar[i] == "") {
            nsimple += "-|";
          } else {
            nsimple += ar[i] + "|";
          }
        } else if (i == cl) {
          nsimple += ctrlSimple.text + "|";
        } else if (i != cl && ar.length <= i) {
          nsimple += "-|";
        }
      }
      nsimple = nsimple.substring(0, nsimple.length - 1);
      //}

      if (block.timeResGroup != null) {
        for (var i = 0; i < block.timeResGroup.length; i++) {
          if (i != cl) {
            time.add(block.timeResGroup[i]);
          } else {
            var tm = mins * 60 + secs;
            time.add(tm);
          }
        }
      } else {
        for (var i = 0; i < block.timeResGroup.length; i++) {
          if (i != cl) {
            time.add(0);
          } else {
            var tm = mins * 60 + secs;
            time.add(tm);
          }
        }
      }
      for (var i = 0; i < block.movements.length; i++) {
        var ex = block.movements[i];
        var strr = "";
        var strw = "";
        var strrr = "";
        var strwr = "";

        if (!block.simple) {
          if (ex.resRepsGroup != null && ex.resRepsGroup != "") {
            var arr1 = ex.resRepsGroup.split("-");
            if (arr1[0] == "") {
              arr1.removeAt(0);
            }
            if (arr1.length > cl) {
              arr1[cl] = reps[i].toString();
            } else {
              for (var j = arr1.length - 1; j < cl + 1; j++) {
                arr1.add("0");
                //arr1.add(ex.reps.toString());
              }
              arr1[cl] = reps[i].toString();
            }
            for (var a1 in arr1) {
              strr += "-" + a1;
            }
          } else {
            if (cl > 0) {
              for (var j1 = 0; j1 < cl; j1++) {
                //strr += "-"+ex.reps.toString();
                strr += "-0";
              }
            }
            if (reps.length > i) {
              strr += "-" + reps[i].toString();
              if (cl < item.clients.length - 1) {
                for (var j2 = cl + 1; j2 < item.clients.length; j2++) {
                  strr += "-0";
                  //strr += "-"+ex.reps.toString();
                }
              }
            }
          }
          if (ex.resWeightGroup != null && ex.resWeightGroup != "") {
            var arr2 = ex.resWeightGroup.split("-");
            if (arr2[0] == "") {
              arr2.removeAt(0);
            }
            if (arr2.length > cl) {
              arr2[cl] = weight[i].toString();
            } else {
              for (var j = arr2.length - 1; j < cl + 1; j++) {
                arr2.add("0");
              }
              arr2[cl] = weight[i].toString();
            }
            for (var a2 in arr2) {
              strw += "-" + a2;
            }
          } else {
            if (cl > 0) {
              for (var j1 = 0; j1 < cl; j1++) {
                strw += "-0";
              }
            }
            if (weight.length > i) {
              strw += "-" + weight[i].toString();
              if (cl < item.clients.length - 1) {
                for (var j2 = cl + 1; j2 < item.clients.length; j2++) {
                  strw += "-0";
                }
              }
            }
          }
          if (strr != "") {
            if (strr[0] == "-") {
              strr = strr.substring(1);
            }
          }
          if (strw != "") {
            if (strw[0] == "-") {
              strw = strw.substring(1);
            }
          }
        }
        arReps.add(strr);
        arWeight.add(strw);
        // Rounds

        if ((block.rounds > 1 || block.cycles > 1) &&
            block.type != 0 &&
            !block.simple) {
          var brounds = block.rounds;
          var erounds = "";
          if (block.type == 5) {
            brounds = block.cycles;
          }
          for (var n = 0; n < brounds; n++) {
            erounds += "0-";
          }
          var tmp = erounds.substring(0, erounds.length - 1);
          erounds = tmp;
          if (ex.resRepsRounds != null && ex.resRepsRounds != "") {
            var arr21 = ex.resRepsRounds.split("|");
            arr21.removeLast();
            print(arr21);
            print(rrounds[i]);
            if (arr21.length > cl) {
              if (rrounds[i] != "") {
                arr21[cl] = rrounds[i].toString();
              } else {
                arr21[cl] = "0";
              }
            } else {
              for (var j21 = arr21.length - 1; j21 < cl + 1; j21++) {
                arr21.add("0");
              }
              if (rrounds[i] != "") {
                arr21[cl] = rrounds[i].toString();
              }
            }
            for (var a21 in arr21) {
              strrr += a21 + "|";
            }
          } else {
            for (var j21 = 0; j21 < item.clients.length; j21++) {
              if (rrounds.length > i) {
                if (j21 != cl || rrounds[i] == "") {
                  strrr += erounds + "|";
                } else {
                  strrr += rrounds[i] + "|";
                }
              }
            }
          }

          if (ex.resWeightRounds != null && ex.resWeightRounds != "") {
            var arr22 = ex.resWeightRounds.split("|");
            arr22.removeLast();
            if (arr22.length > cl) {
              if (wrounds[i] != "") {
                arr22[cl] = wrounds[i].toString();
              } else {
                arr22[cl] = "0";
              }
            } else {
              for (var j22 = arr22.length - 1; j22 < cl + 1; j22++) {
                arr22.add("0");
              }
              if (wrounds[i] != "") {
                arr22[cl] = wrounds[i].toString();
              }
            }
            for (var a22 in arr22) {
              strwr += a22 + "|";
            }
          } else {
            for (var j22 = 0; j22 < item.clients.length; j22++) {
              if (wrounds.length > 0) {
                if (j22 != cl || wrounds[i] == "") {
                  strwr += erounds + "|";
                } else {
                  strwr += wrounds[i] + "|";
                }
              }
            }
          }

          arRepsRounds.add(strrr);
          arWeightRounds.add(strwr);
        }
      }

      for (var j = 0; j < block.movements.length; j++) {
        block.movements[j].resRepsGroup = arReps[j];
        block.movements[j].resWeightGroup = arWeight[j];
        if (arRepsRounds.length > 0 && arWeightRounds.length > 0) {
          block.movements[j].resRepsRounds = arRepsRounds[j];
          block.movements[j].resWeightRounds = arWeightRounds[j];
        }
      }
      FirebaseSender.updateResultsGroup(
          id,
          item.program.id,
          block.id,
          arReps,
          arWeight,
          time,
          arRepsRounds,
          arWeightRounds,
          nsimple,
          amrap,
          valueSimple,
          scaledSimple);
    } else {
      int time = mins * 60 + secs;
      if (block.simple) {
        weight = [0];
        reps = [0];
      }
      FirebaseSender.updateResults(
          id,
          item.type,
          item.program.id,
          block.id,
          reps,
          weight,
          time,
          rrounds,
          wrounds,
          nsimple,
          amrap,
          valueSimple,
          scaledSimple);
    }

    if (!block.simple) {
      updateBest();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Results successfully updated"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }

  // Check for best

  updateBest() {
    for (var i = 0; i < block.movements.length; i++) {
      var ex = block.movements[i];
      if (GlobalUI.exToolsWeight.contains(ex.tool)) {
        bool update = true;
        var total = weight[i];
        var actual = weight[i];
        double per = 0;
        String type = "kg";
        if (GlobalData.space.lbs) {
          type = "lb";
        }
        if (ex.weightType != "per") {
          type = ex.weightType;
        }

        if (wrounds.length > i) {
          double vf = 0;
          var wval = wrounds[i].split("-");
          wval.removeLast();
          for (var v in wval) {
            var fin = double.parse(v);
            if (fin > vf) {
              vf = double.parse(v);
            }
          }
          total = vf;
          actual = vf;
        }
        if (ex.weight != 0 && ex.weight != null) {
          if (ex.weightType == "per") {
            total = (100 / ex.weight) * actual;
            per = ex.weight;
          }
        }
        for (var best in GlobalData.best) {
          if (best.id == ex.id) {
            var rval = best.value;
            if ((best.type == "kg" && ex.weightType == "lb") ||
                (best.type == "kg" &&
                    ex.weightType == "per" &&
                    GlobalData.space.lbs)) {
              rval = best.value * GlobalUI.lbsUp;
            }
            if ((best.type == "lb" && ex.weightType == "kg") ||
                (best.type == "lb" &&
                    ex.weightType == "per" &&
                    !GlobalData.space.lbs)) {
              rval = best.value * GlobalUI.lbsDown;
            }
            if (rval > total) {
              update = false;
            } else {
              best.value = total;
              best.type = type;
            }
          }
          if (best.id == ex.id && total < best.value) {
            update = false;
          }
        }
        if (update && GlobalUI.exToolsWeight.contains(ex.tool)) {
          FirebaseSender.updateBest(
              ex.id, ex.name, total, actual, per, ex.tool, ex.unit, type);
        }
      }
    }
  }

  getName() {
    if (item.type != "group") {
      return GlobalUI.titles[block.type] + HelperTrain.getBlockInfo(block);
    } else if (item.type == "training") {
      return "Training";
    } else {
      var label = "Client";
      for (var client in GlobalData.clients) {
        if (client.id == item.clients[current]) {
          label = client.name;
        }
      }
      return label;
    }
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
                child: TitleLabelBack("Results"),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
                child: Text(
                  getName(),
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
                          children: _getContent()))),
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }

  _getContent() {
    List<Widget> items = [];

    //if(block.type == 0 && !block.simple) {
    if (block.type == 0) {
      items.add(
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Text(
            "Rounds and reps",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      );

      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: MediaQuery.of(context).size.width / 2 - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  //controller: TextEditingController(text: amrap1.toString()),
                  controller: ctrlAmrap1,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Rounds',
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    _updateAllReps1(text);
                  },
                )),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              width: MediaQuery.of(context).size.width / 2 - 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                //controller: TextEditingController(text: amrap2.toString()),
                controller: ctrlAmrap2,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Reps',
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) {
                  _updateAllReps2(text);
                },
              ),
            ),
          ],
        ),
      ));
    }

    if (block.type == 5) {
      items.add(
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Text(
            "Completion time",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      );

      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: MediaQuery.of(context).size.width / 2 - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  //controller: TextEditingController(text: mins.toString()),
                  controller: ctrlMin,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Minutes',
                    suffix: Text("min"),
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    _updateMin(text);
                  },
                )),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              width: MediaQuery.of(context).size.width / 2 - 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.fieldColor,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                //controller: TextEditingController(text: secs.toString()),
                controller: ctrlSec,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Seconds',
                  suffix: Text("sec"),
                  suffixStyle: TextStyle(
                      color: AppColors.textColor, fontWeight: FontWeight.w700),
                  labelStyle: TextStyle(color: AppColors.textColor),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) {
                  _updateSec(text);
                },
              ),
            ),
          ],
        ),
      ));
    }

    // MOVEMENTS

    if (!block.simple) {
      for (var i = 0; i < block.movements.length; i++) {
        var item = block.movements[i];
        var show = true;
        if (!GlobalUI.exToolsWeight.contains(item.tool) && block.type == 0) {
          show = false;
        }
        if (show) {
          items.add(
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Text(
                item.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        if (!GlobalUI.exToolsWeight.contains(item.tool) &&
            item.tool != 6 &&
            item.tool != 7 &&
            item.tool != 25 &&
            block.type != 0) {
          items.add(
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                //HelperTrain.getTargetReps(item, block),
                getRepsLabel(block.movements[i]),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.AvatarColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          );
          items.add(
            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  //controller: TextEditingController(text: checkRepsLabel(i)),
                  controller: ctrl[i],
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: getRepsFieldLabel(item, "label"),
                    suffix: Text(getRepsFieldLabel(item, "suffix")),
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    if (block.cycles > 1 ||
                        (block.rounds > 1 &&
                            block.type != 0 &&
                            block.type != 5)) {
                      updateRepsRound(i, 0, text);
                    } else {
                      _updateReps(i, text);
                    }
                  },
                )),
          );
          items.add(Column(children: _checkRounds(block.movements[i], i)));
        } else {
          if ((item.tool == 6 || item.tool == 7 || item.tool == 25) &&
              block.type != 0) {
            items.add(
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                      width: MediaQuery.of(context).size.width - 40,
                      //width: MediaQuery.of(context).size.width / 2 - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: checkRepsLabel(i)),
                        controller: ctrl[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: getRepsFieldLabel(item, "label"),
                          suffix: Text(getRepsFieldLabel(item, "suffix")),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          if (block.cycles > 1 ||
                              (block.rounds > 1 &&
                                  (block.type == 1 || block.type == 4))) {
                            updateRepsRound(i, 0, text);
                          } else {
                            _updateReps(i, text);
                          }
                        },
                      )),
                ],
              ),
            );
            items.add(Column(children: _checkRounds(block.movements[i], i)));
          } else if (item.tool == 27 && block.type != 0) {
            items.add(
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                      width: MediaQuery.of(context).size.width - 40,
                      //width: MediaQuery.of(context).size.width / 2 - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: checkRepsLabel(i)),
                        controller: ctrl[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: getRepsFieldLabel(item, "label"),
                          suffix: Text(getRepsFieldLabel(item, "suffix")),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          if (block.cycles > 1 ||
                              (block.rounds > 1 &&
                                  (block.type == 1 || block.type == 4))) {
                            updateRepsRound(i, 0, text);
                          } else {
                            _updateReps(i, text);
                          }
                        },
                      )),
                ],
              ),
            );
            items.add(Column(children: _checkRounds(block.movements[i], i)));
          } else if (GlobalUI.exToolsWeight.contains(item.tool) &&
              block.type == 0) {
            items.add(
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: AppColors.fieldColor,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: ctrlw[i],
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Weight used',
                      suffix: Text((block.movements[i].weightType == 'per'
                          ? (GlobalData.space.lbs ? "lb" : "kg")
                          : block.movements[i].weightType)),
                      suffixStyle: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700),
                      labelStyle: TextStyle(color: AppColors.textColor),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
                    ],
                    onChanged: (text) {
                      _updateWeight(i, text);
                    },
                  )),
            );
          } else {
            if (block.type != 0) {
              items.add(Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      getRepsLabel(block.movements[i]),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.AvatarColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                    child: Text(
                      getWeightLabel(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.AvatarColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ));
              items.add(
                Row(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                        width: MediaQuery.of(context).size.width / 2 - 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: AppColors.fieldColor,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          //controller: TextEditingController(text: checkRepsLabel(i)),
                          controller: ctrl[i],
                          style: TextStyle(color: AppColors.textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: getRepsFieldLabel(item, "label"),
                            suffix: Text(getRepsFieldLabel(item, "suffix")),
                            suffixStyle: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w700),
                            labelStyle: TextStyle(color: AppColors.textColor),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            if (block.cycles > 1 ||
                                (block.rounds > 1 &&
                                    block.type != 0 &&
                                    block.type != 5)) {
                              updateRepsRound(i, 0, text);
                            } else {
                              _updateReps(i, text);
                            }
                          },
                        )),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      width: MediaQuery.of(context).size.width / 2 - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: checkWeightLabel(i)),
                        controller: ctrlw[i],
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: getWeightFieldLabel(),
                          suffix: Text((block.movements[i].weightType == 'per'
                              ? (GlobalData.space.lbs ? "lbs" : "kg")
                              : block.movements[i].weightType)),
                          suffixStyle: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*'))
                        ],
                        onChanged: (text) {
                          if (block.cycles > 1 ||
                              (block.rounds > 1 &&
                                  (block.type == 1 || block.type == 4))) {
                            updateWeightRound(i, 0, text);
                          } else {
                            _updateWeight(i, text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
              items.add(Column(children: _checkRounds(block.movements[i], i)));
            }
          }
        }
      }
    } else {
      if (block.type != 0 && block.type != 5) {
        items.add(Row(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                width: MediaQuery.of(context).size.width - 40,
                //width: MediaQuery.of(context).size.width / 2 - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: ctrlSimpleValue,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: "Your result",
                    suffix: Text("reps"),
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    /*if(block.cycles > 1 || (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
                      //updateRepsRound(i, 0, text);
                    } else {
                      //_updateReps(i, text);
                    }*/
                  },
                )),
          ],
        ));
      }
    }

    items.add(
      Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: AppColors.fieldColor,
          ),
          child: TextField(
            keyboardType: TextInputType.multiline,
            controller: ctrlSimple,
            style: TextStyle(color: AppColors.textColor),
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Notes",
              hintStyle: TextStyle(color: AppColors.textColor),
            ),
          )),
    );

    if (block.simple) {
      items.add(Container(height: 40));
      items.add(
        InkWell(
          onTap: () {
            setState(() {
              valueScaled = !valueScaled;
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: DataToggle('Scaled', valueScaled),
          ),
        ),
      );
    }

    items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 70, 0, 10),
        child: BtnPrimary(
          label: "UPDATE RESULTS",
          clickFn: updateResults,
        )));

    return items;
  }

  getRepsLabelEx(item) {
    var label = "Reps";
    if (item.tool == 6 || item.tool == 7 || item.tool == 25) {
      label = "Distance";
    } else if (item.tool == 27) {
      label = "Calories";
    } else if (item.tool == 28) {
      label = "Time";
    }
    if (item.unit == "dist") {
      label = "Distance";
    }
    if (item.unit == "cals") {
      label = "Calories";
    }
    if (item.unit == "time") {
      label = "Time";
    }
    return label;
  }

  _checkRounds(ex, number) {
    List<Widget> items = [];
    var rounds = block.rounds;
    //if(block.cycles > 1 || (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
    if ((block.rounds > 1 || block.cycles > 1) && block.type != 0) {
      if (block.type == 5) {
        rounds = block.cycles;
      }
      for (var i = 1; i < rounds; i++) {
        if (!GlobalUI.exToolsWeight.contains(ex.tool)) {
          items.add(Column(children: [
            Container(
              width: MediaQuery.of(context).size.width - 30,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                'Round ' + (i + 1).toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.AvatarColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.fieldColor,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  //controller: TextEditingController(text: getRepsRounds(number, i)),
                  controller: ctrlL1[number][i],
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: getRepsLabelEx(ex),
                    suffix: Text("reps"),
                    suffixStyle: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700),
                    labelStyle: TextStyle(color: AppColors.textColor),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    updateRepsRound(number, i, text);
                  },
                )),
          ]));
        } else {
          items.add(Column(children: [
            Container(
              width: MediaQuery.of(context).size.width - 30,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                'Round ' + (i + 1).toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.AvatarColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: AppColors.fieldColor,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      //controller: TextEditingController(text: getRepsRounds(number, i)),
                      controller: ctrlL1[number][i],
                      style: TextStyle(color: AppColors.textColor),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: getRepsLabelEx(ex),
                        suffix: Text("reps"),
                        suffixStyle: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700),
                        labelStyle: TextStyle(color: AppColors.textColor),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (text) {
                        updateRepsRound(number, i, text);
                      },
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    width: MediaQuery.of(context).size.width / 2 - 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: AppColors.fieldColor,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      //controller: TextEditingController(text: getWeightRounds(number, i)),
                      controller: ctrlL2[number][i],
                      style: TextStyle(color: AppColors.textColor),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Weight',
                        suffix: Text((ex.weightType == 'per'
                            ? (GlobalData.space.lbs ? "lb" : "kg")
                            : ex.weightType)),
                        suffixStyle: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700),
                        labelStyle: TextStyle(color: AppColors.textColor),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
                      ],
                      onChanged: (text) {
                        updateWeightRound(number, i, text);
                      },
                    )),
              ],
            )
          ]));
        }
      }
    }

    return items;
  }

  getRepsLabel(ex) {
    var label = 'Total reps';
    if (ex.tool == 6 || ex.tool == 7 || ex.tool == 25) {
      label = 'Total distance';
    }
    if (ex.tool == 27) {
      label = 'Total calories';
    }
    if (ex.tool == 28) {
      label = 'Total time';
    }
    if (ex.unit == "dist") {
      label = 'Total distance';
    }
    if (ex.unit == "cals") {
      label = 'Total calories';
    }
    if (ex.unit == "time") {
      label = 'Total time';
    }
    if (block.cycles > 1 ||
        (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
      label = 'Round 1';
    }
    return label;
  }

  getWeightLabel() {
    var label = 'Weight used';
    if (block.cycles > 1 ||
        (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
      label = '';
    }
    return label;
  }

  getRepsFieldLabel(ex, type) {
    var label = "Reps";
    if (ex.tool == 6 || ex.tool == 7 || ex.tool == 25) {
      label = 'Distance';
    }
    if (ex.tool == 27) {
      label = 'Calories';
    }
    if (ex.tool == 28) {
      label = 'Time';
    }
    if (ex.unit == "dist") {
      label = 'Distance';
    }
    if (ex.unit == "cals") {
      label = 'Calories';
    }
    if (ex.unit == "time") {
      label = 'Time';
    }
    if (type == "suffix") {
      label = "reps";
      if (ex.tool == 6 || ex.tool == 7 || ex.tool == 25) {
        label = 'm';
      }
      if (ex.tool == 27) {
        label = 'cal';
      }
      if (ex.tool == 28) {
        label = 'sec';
      }
      if (ex.unit == "dist") {
        label = 'm';
      }
      if (ex.unit == "cals") {
        label = 'cal';
      }
      if (ex.unit == "time") {
        label = 'sec';
      }
    }
    return label;
  }

  getWeightFieldLabel() {
    var label = 'Heaviest';
    if (block.cycles > 1 ||
        (block.rounds > 1 && block.type != 0 && block.type != 5)) {
      label = 'Weight';
    }
    return label;
  }

  // Rounds specific

  checkRepsLabel(ex) {
    var label = reps[ex].toString();
    if (block.cycles > 1 ||
        (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
      label = getRepsRounds(ex, 0);
    }
    return label;
  }

  checkWeightLabel(ex) {
    var label = weight[ex].toString();
    if (block.cycles > 1 ||
        (block.rounds > 1 && (block.type == 1 || block.type == 4))) {
      label = getWeightRounds(ex, 0);
    }
    return label;
  }

  getRepsRounds(ex, i) {
    var label = '';
    if (rrounds[ex] != '') {
      var ar = rrounds[ex].split('-');
      if (ar.length > i) {
        label = ar[i];
      }
    }
    return label;
  }

  getWeightRounds(ex, i) {
    var label = '';
    if (wrounds[ex] != '') {
      var ar = wrounds[ex].split('-');
      if (ar.length > i) {
        label = ar[i];
      }
    }
    return label;
  }

  updateRepsRound(ex, i, value) {
    var tmp = rrounds;
    var label = "";
    var rps = 0;
    var ar = [];
    if (tmp[ex] == '') {
      for (var rnd = 0; rnd < block.rounds; rnd++) {
        ar.add(0);
      }
    } else {
      ar = tmp[ex].split('-');
      if (ar.length < i) {
        for (var ia = ar.length - 1; ia < i + 1; ia++) {
          ar.add(0);
        }
      }
    }

    if (ar[ar.length - 1] == '') {
      ar.removeLast();
    }
    if (ar.length < i + 1) {
      for (var j = ar.length; j < i + 1; j++) {
        ar.add("0");
      }
    }
    ar[i] = value;
    for (var a in ar) {
      if (a != '') {
        label += a.toString() + "-";
        rps += int.parse(a);
      } else {
        label += "0-";
      }
    }

    label = label.substring(0, label.length - 1);
    tmp[ex] = label;
    reps[ex] = rps;
    rrounds = tmp;
  }

  updateWeightRound(ex, i, value) {
    var tmp = wrounds;
    var label = "";
    var ar = [];
    double max = 0;
    if (tmp[ex] == '') {
      for (var rnd = 0; rnd < block.rounds; rnd++) {
        ar.add(0);
      }
    } else {
      ar = tmp[ex].split('-');
      if (ar.length < i) {
        for (var ia = ar.length - 1; ia < i + 1; ia++) {
          ar.add(0);
        }
      }
    }
    if (ar[ar.length - 1] == '') {
      ar.removeLast();
    }
    if (ar.length < i + 1) {
      for (var j = ar.length; j < i + 1; j++) {
        ar.add("0");
      }
    }
    ar[i] = value;
    for (var a in ar) {
      if (a != '') {
        label += a.toString() + "-";
        if (double.parse(a) > max) {
          max = double.parse(a);
        }
      } else {
        label += "0-";
      }
    }
    label = label.substring(0, label.length - 1);
    _updateWeight(ex, max.toString());
    tmp[ex] = label;
    wrounds = tmp;
  }
}
