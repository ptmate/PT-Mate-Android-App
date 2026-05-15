import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/_helper/training.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'dart:async';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/calendar/running.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:audioplayers/audio_cache.dart';


class TimerPage extends StatefulWidget {
  final String id;
  final ModelBlock item;
  final String type;
  final int value;
  final List intervals;
  const TimerPage(this.id, this.type, this.value, this.intervals, this.item);
  @override
  _TimerPageState createState() => _TimerPageState();
}


class _TimerPageState extends State<TimerPage> {


  String status = "start";
  String statusTmp = "";
  int value = 0;
  int counter = 0;
  int end = 0;
  var timer;
  List intervals = [];
  var current = 0;
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
      value = widget.value;
      block = widget.item;
    });
  }


  startTimer() {
    setState(() {
      status = "init";
      value = widget.value;
      intervals = widget.intervals;
      counter = 5;
    });
    timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      calculateInit();
    });
  }


  tapPause() {
    timer.cancel();
    setState(() {
      statusTmp = status;
      status = "pause";
    });
  }


  tapContinue() {
    if(statusTmp == "init") {
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        calculateInit();
      });
    } else if(statusTmp == "work") {
      if(widget.type == "countup" || widget.type == "fortime") {
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          countUp();
        });
      } else if(widget.type == "countdown" || widget.type == "amrap") {
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          countDown();
        });
      } else if(widget.type == "tabata" || widget.type == "intervals" || widget.type == "emom") {
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          intDown();
        });
      }
    } else if(statusTmp == "rest") {
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        intDown();
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


  startTime() {
    if(widget.type == "countup" || widget.type == "fortime") {
      setState(() {
        status = "work";
        end = value;
        counter = 0;
      });
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        countUp();
      });
    } else if(widget.type == "countdown" || widget.type == "amrap") {
      setState(() {
        status = "work";
        end = 0;
        counter = value;
      });
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        countDown();
      });
    } else if(widget.type == "tabata" || widget.type == "intervals" || widget.type == "emom") {
      setState(() {
        status = "work";
        end = 0;
        counter = intervals[0];
      });
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        intDown();
      });
    }
  }


  countUp() {
    var tmp = counter;
    tmp += 1;
    setState(() {
      counter = tmp;
    });
    if(counter == end) {
      play('audio/audioend.mp3');
    }
    if(counter == end+1) {
      timer.cancel();
      endTimer();
    }
  }


  countDown() {
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
      endTimer();
    }
  }


  intDown() {
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
      if(widget.type == "emom") {
        checkEmom();
      } else {
        checkInterval();
      }
      
    }
  }


  play(file) async {
    //player = await cache.play(file);
    final player = AudioPlayer();
    player.play(UrlSource(file));
  }


  checkEmom() {
    if(current == intervals.length-1) {
      if(round == value) {
        endTimer();
      } else {
        setState(() {
          status = "work";
          current = 0;
          counter = intervals[0];
          round = round+1;
        });
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          intDown();
        });
      }
    } else {
      setState(() {
        status = "work";
        current = current+1;
        counter = intervals[current];
      });
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        intDown();
      });
    }
  }


  checkInterval() {
    if(status == "work") {
      setState(() {
        status = "rest";
        current = current+1;
        counter = intervals[current];
      });
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        intDown();
      });
    } else {
      if(current == intervals.length-1) {
        if(round == value) {
          endTimer();
        } else {
          setState(() {
            status = "work";
            current = 0;
            counter = intervals[0];
            round = round+1;
          });
          timer = Timer.periodic(new Duration(seconds: 1), (timer) {
            intDown();
          });
        }
      } else {
        setState(() {
          status = "work";
          current = current+1;
          counter = intervals[current];
        });
        timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          intDown();
        });
      }
      
    }
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


  displayTitle() {
    var label = "Count Up";
    if(widget.type == "countdown") {
      label = "Count Down";
    } else if(widget.type == "intervals") {
      label = "Intervals";
    } else if(widget.type == "tabata") {
      label = "Tabata";
    } else if(widget.type == "emom") {
      label = "EMOM";
    } else if(widget.type == "amrap") {
      label = "AMRAP";
    } else if(widget.type == "fortime") {
      label = "For Time";
    }
    return label;
  }


  displaySubtitle() {
    var label = "";
    if(widget.type == "countup" || widget.type == "fortime") {
      label = "Cap: "+HelperCal.getDuration(widget.value, "min");
    } else if(widget.type == "countdown" || widget.type == "amrap") {
      label = "Start time: "+HelperCal.getDuration(widget.value, "min");
    } else if(widget.type == "intervals" || widget.type == "tabata" || widget.type == "emom") {
      label = value.toString()+" round"+(value == 1 ? "" : "s");
      if((status == "work" || status == "rest") && value > 1) {
        label = "Round "+round.toString()+" of "+value.toString();
      }
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
                  child: Row (
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
                              displayTitle(),
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
    if(status == "init" || status == "work" || status == "rest") {
      return Expanded(
        /*child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: BtnTertiary(label: "Pause timer", clickFn: tapPause)
        )*/
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child:  Row(
            children: [
              Container (
                width: MediaQuery.of(context).size.width/2,
                child: BtnTertiary(label: "Pause timer", clickFn: tapPause) 
              ),
              Container (
                width: MediaQuery.of(context).size.width/2,
                child: BtnTertiary(label: "End timer", clickFn: goBack) 
              ),
            ],
          )
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
        Container (
          margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
          padding: EdgeInsets.only(top: 10),
          height: 128,
          width: MediaQuery.of(context).size.width-40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: AppColors.PrimaryColor,
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
          "Work",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.WhiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        renderDots(),
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
        renderDots(),
        renderMovements()
      ],
    );
  }


  renderDots() {
    if(status == "work" || status == "rest") {
      return Row (
        mainAxisAlignment: MainAxisAlignment.center,
        children: renderDot()
      );
    } else {
      return Container();
    }
  }


  renderDot() {
    List<Widget> items = [];
    if(widget.type == "emom") {
      for(var i=0; i<intervals.length; i++) {
        var col = AppColors.WhiteColor;
        if(i.toDouble() > current) {
          col = AppColors.WhiteColor.withOpacity(0.4);
        }
        items.add(
          Container (
            width: 6,
            height: 6,
            margin: EdgeInsets.fromLTRB(5, 15, 5, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: col,
            ),
          )
        );
      }
    } else {
      for(var i=0; i<intervals.length/2; i++) {
        var col = AppColors.WhiteColor;
        if(i.toDouble() > current/2) {
          col = AppColors.WhiteColor.withOpacity(0.4);
        }
        items.add(
          Container (
            width: 6,
            height: 6,
            margin: EdgeInsets.fromLTRB(5, 15, 5, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: col,
            ),
          )
        );
      }
    }
    
    return items;
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
        height: MediaQuery.of(context).size.height-450,
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
        double alpha = 1;
        if(widget.type == "emom" && !block.emom) {
          alpha = 0.4;
          if(i == current) {
            alpha = 1;
          }
        }
        if(widget.type == "intervals" && !block.emom) {
          alpha = 0.4;
          if(i == current/2) {
            alpha = 1;
          }
        }
        if(widget.type == "tabata") {
          alpha = 0.4;
          for(var j=0; j<7; j++) {
            var pos = j*block.movements.length;
            //if(i == current/2) {
            if(i == current/2-pos) {
              alpha = 1;
            }
          }
          
        }
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
                    color: AppColors.WhiteColor.withOpacity(alpha),
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
                    color: AppColors.WhiteColor.withOpacity(alpha),
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