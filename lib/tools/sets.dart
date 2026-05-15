import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'dart:async';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/calendar/running.dart';
import 'package:audioplayers/audioplayers.dart';


class SetsPage extends StatefulWidget {
  final String id;
  final ModelBlock item;
  final int rounds;
  const SetsPage(this.id, this.rounds, this.item);
  @override
  _SetsPageState createState() => _SetsPageState();
}


class _SetsPageState extends State<SetsPage> {


  String status = "start";
  String statusTmp = "";
  int rounds = 0;
  int counter = 0;
  int end = 0;
  var timer;
  var round = 1;
  var block;

  static AudioCache cache = AudioCache();
  AudioPlayer player = AudioPlayer();


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      rounds = widget.rounds;
      block = widget.item;
    });
  }


  displaySubtitle() {
    var label = rounds.toString()+" set";
    if(block.movements.length > 1) {
      label = rounds.toString()+" dropset";
      var pid = block.movements[0].id;
      for(var ex in block.movements) {
        if(ex.id != pid) {
          label = rounds.toString()+" superset";
        }
        pid = ex.id;
      }
    }
    if(rounds > 1) {
      label += "s";
    }

    if(status == "work" || status == "rest") {
      label = "Set "+round.toString()+" of "+rounds.toString();
      if(block.movements.length > 1) {
        label = "Dropset "+round.toString()+" of "+rounds.toString();
        var pid = block.movements[0].id;
        for(var ex in block.movements) {
          if(ex.id != pid) {
            label = "Superset "+round.toString()+" of "+rounds.toString();
          }
          pid = ex.id;
        }
      }
    }

    return label;
  }


  startTimer() {
    setState(() {
      status = "init";
      rounds = widget.rounds;
      counter = 5;
    });
    timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      calculateInit();
    });
  }


  tapFinishSet() {
    if(round < rounds) {
      if(block.movements[0].work > 0) {
        setState(() {
          status = "rest";
          counter = block.movements[0].work;
          end = 0;
        });
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          restDown();
        });
      } else {
        setState(() {
          status = "work";
          round = round+1;
        });
      }
    } else {
      endTimer();
    }
  }


  restDown() {
    var tmp = counter;
    tmp -= 1;
    setState(() {
      counter = tmp;
    });
    if(counter == 0) {
      play('audio/audioend.mp3');
    }
    if(counter == -1) {
      timer.cancel();
      setState(() {
        status = "work";
        round = round+1;
      });
    }
  }


  tapPause() {
    timer.cancel();
    setState(() {
      statusTmp = status;
      status = "pause";
    });
  }


  tapNextSet() {
    timer.cancel();
    setState(() {
      status = "work";
      round = round+1;
    });
  }


  tapContinue() {
    if(statusTmp == "init") {
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        calculateInit();
      });
    } else if(statusTmp == "rest") {
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        restDown();
      });
    }
    setState(() {
      status = statusTmp;
    });
  }


  calculateInit() {
    var tmp = counter;
    tmp -= 1;
    setState(() {
      counter = tmp;
    });
    if(counter < 4 && counter > 0) {
      play('audio/audio1sec.mp3');
    }
    if(counter == 0) {
      timer.cancel();
      startTime();
      play('audio/audiostart.mp3');
    }
  }


  play(file) async {
    //player = await cache.play(file);
    final player = AudioPlayer();
    player.play(UrlSource(file));
  }


  startTime() {
    setState(() {
      status = "work";
    });
  }


  endTimer() {
    setState(() {
      status = "end";
    });
  }


  displayTime() {
    var label = "";
    if(status == "init") {
      label = "0"+counter.toString();
    } else {
      var min = (counter/60).floor();
      var sec = counter-(min*60);
      var add1 = "";
      var add2 = "";
      if(min < 10) {
        add1 = "0";
      }
      if(sec < 10) {
        add2 = "0";
      }
      label = add1+min.toString()+":"+add2+sec.toString();
    }
    return label;
  }


  goBack() {
    if(status != "start") {
      tapPause();
    }
    AlertDialog alert = AlertDialog(
    title: Text("End timer?"),
      content: Text("Do you want to end the timer and leave this screen?"),
      actions: [
        TextButton(
          child: Text("End timer now"),
          onPressed: () {
            if(block.id != "") {
              RunningPage.appState.updateBlock();
            }
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Don't end timer"),
          onPressed: () {
            if(statusTmp != "start") {
              tapContinue();
            }
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


  _getButton() {
    if(block.notes != "" && !block.simple) {
      return (
        IconButton(
          icon: SvgPicture.asset("assets/images/nav/notes.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
          iconSize: 30,
          onPressed: () {
            showNotes();
          },
        )
      );
    } else {
      return Container();
    }
  }


  showNotes() {
    AlertDialog alert = AlertDialog(
    title: Text("Notes"),
      content: Text(block.notes),
      actions: [
        TextButton(
          child: Text("Close"),
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


  @override
  Widget build(BuildContext context) {
  
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.BgColorDark,
        body: MediaQuery(child: Container(
          color: AppColors.TextColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            children: <Widget>[
              Container (
                padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: Container (
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: double.maxFinite,
                  child:Row (
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                        child: Row(
                          children: <Widget> [
                            IconButton(
                              icon: SvgPicture.asset("assets/images/nav/header-back.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
                              iconSize: 30,
                              onPressed: () {
                                goBack();
                              },
                            ),
                            Text(
                              "No Time",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.WhiteColor,
                                fontWeight: FontWeight.w300,
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width-90,
                      ),
                      _getButton(),
                    ]
                  ),
                )
              ),
              
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(70, 0, 20, 50),
                child: Text(
                  displaySubtitle(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.WhiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              
              renderContent(),
              renderButton(),
              
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }


  renderButton() {
    if(status == "init" || status == "rest") {
      return Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: BtnTertiary(label: "Pause timer", clickFn: tapPause)
        )
      );
    } else if(status == "work") {
      return Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: BtnPrimary(label: "Finish this set", clickFn: tapFinishSet)
        )
      );
    } else if(status == "rest") {
      return Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: BtnPrimary(label: "Start next set", clickFn: tapNextSet)
        )
      );
    } else {
      return Container();
    }
  }


  renderContent() {
    if(status == "start") {
      return renderStart();
    } else if(status == "init") {
      return renderInit();
    } else if(status == "work") {
      return renderWork();
    } else if(status == "rest") {
      return renderRest();
    } else if(status == "pause") {
      return renderPause();
    } else if(status == "end") {
      return renderEnd();
    }
  }


  renderStart() {
    return InkWell (
      onTap: () {
        startTimer();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container (
              padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
              child: SvgPicture.asset("assets/images/common/timer-play.svg", width: 150, height: 150)
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Tap to start",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.AvatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          )
        ],
      )
    );
  }


  renderInit() {
    return Column (
      children: [
        Container (
          margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
          padding: EdgeInsets.only(top: 10),
          height: 128,
          width: MediaQuery.of(context).size.width-40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: AppColors.OrangeColor,
          ),
          child: Text(
            displayTime(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.WhiteColor,
              fontWeight: FontWeight.w300,
              fontSize: 84,
            ),
          ),
        ),
        Text(
          "Get ready",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        
      ],
    );
  }


  renderWork() {
    return Column (
      children: [
        renderMovements()
      ],
    );
  }


  renderRest() {
    return Column (
      children: [
        Container (
          margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
          padding: EdgeInsets.only(top: 10),
          height: 128,
          width: MediaQuery.of(context).size.width-40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: AppColors.GreenColor,
          ),
          child: Text(
            displayTime(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.WhiteColor,
              fontWeight: FontWeight.w300,
              fontSize: 84,
            ),
          ),
        ),
        Text(
          "Rest",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }


  renderEnd() {
    return InkWell (
      onTap: () {
        if(block.id != "") {
          RunningPage.appState.updateBlock();
        }
        Navigator.pop(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container (
              padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
              child: SvgPicture.asset("assets/images/common/timer-done.svg", width: 150, height: 150)
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Timer finished\nTap to go back",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.WhiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          )
        ],
      )
    );
  }


  renderPause() {
    return InkWell (
      onTap: () {
        tapContinue();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container (
              padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
              child: SvgPicture.asset("assets/images/common/timer-pause.svg", width: 150, height: 150)
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Timer paused\nTap to resume",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.WhiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          )
        ],
      )
    );
  }


  renderMovements() {
    if(block.id != "") {
      return Container(
        height: MediaQuery.of(context).size.height-250,
        child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: renderEx()
        )
      ));
    } else {
      return Container();
    }
  }


  renderEx() {
    List<Widget> items = [];
    if(block.simple) {
      if(block.notes != "") {
        items.add(
          Container (
            width: MediaQuery.of(context). size. width-40,
            child: Text(
              block.notes,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.WhiteColor,
                fontSize: 14,
              ),
            )
          ),
        );
      }
    } else {
      for(var i=0; i<block.movements.length; i++) {
        var ex = block.movements[i];
        items.add(
          Column(
            children: <Widget> [
              Container (
                margin: EdgeInsets.fromLTRB(0, 18, 0, 0),
                width: MediaQuery.of(context). size. width-40,
                child: Text(
                  ex.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.WhiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container (
                width: MediaQuery.of(context). size. width-40,
                child: Text(
                  HelperTrain.getMovementInfo(ex, block),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.WhiteColor,
                    fontSize: 14,
                  ),
                )
              ),
            ]
          ),
        );
      }
    }
    return items;
  }

}