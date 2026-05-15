import 'package:flutter/material.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/components/card-avatar.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/connector.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/init/addtrainer.dart';
import 'package:ptmate_client/init/scanner.dart';


class TrainerPage extends StatefulWidget {
  final bool showLink;
  static _TrainerPageState appState = _TrainerPageState();
  const TrainerPage(this.showLink);
  @override
  _TrainerPageState createState() {
    return TrainerPage.appState = new _TrainerPageState();
  }
}


class _TrainerPageState extends State<TrainerPage> {


  var label = "Search";
  var mode = "field";
  var spaces = [];
  var selected = [];
  bool showLink = false;
  TextEditingController _field = TextEditingController();


  @override
  void initState() {
    super.initState();
    print("loading trainer here");
    Connector.getTrainers();
    setState(() {
      showLink = widget.showLink;
    });
  }


  updateData() {
    if(this.mounted) {
      setState(() {
        spaces = GlobalData.allspaces;
      });
    }
  }


  tapPrimary() {
    if(mode == "field") {
      if(_field.text != "") {
        var string = _field.text.toLowerCase();
        var tmp = [];
        for(var item in spaces) {
          var name = "";
          if(item.name != null) {
            name = item.name;
          }
          var busi = "";
          if(item.business != null) {
            busi = item.business;
          }
          if(item.name != null) {
            if(name.toLowerCase().contains(string) || busi.toLowerCase().contains(string)) {
              tmp.add(item);
            }
          }
          
        }
        setState(() {
          label = "SEARCH AGAIN";
          mode = "results";
          selected = tmp;
        });
      }
    } else {
      setState(() {
        mode = "field";
        label = "SEARCH";
      });
    }
    
  }


  @override
  Widget build(BuildContext context) {
    if(showLink) {
      return renderBack();
    } else {
      return renderInit();
    }
  }


  renderInit() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: MediaQuery(child: Container(
          color: AppColors.bgColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Column (
              children: [
                Container (
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget> [
                      IconButton(
                        icon: SvgPicture.asset("assets/images/nav/header-qr.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerPage()),);
                        },
                      ),
                    ]
                  ),
                ),
                Text(
                  "Let's find your\ntrainer/gym",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 40,
                  ),
                ),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 70),
                  width: double.maxFinite,
                  child: Text(
                    "Search for your training space",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                renderContent(),
                Container (
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: BtnTertiary(label: label, clickFn: tapPrimary)
                )
                
                
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
      )
    );
  }


  renderBack() {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
          child: Column (
            children: [
              Container (
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget> [
                    IconButton(
                      icon: SvgPicture.asset("assets/images/nav/header-back.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset("assets/images/nav/header-qr.svg", width: 30, height: 30, color: AppColors.PrimaryColor,),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerPage()),);
                      },
                    ),
                  ]
                ),
              ),
              Text(
                "Add another\ntrainer or gym",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 40,
                ),
              ),
              Container (
                padding: EdgeInsets.fromLTRB(0, 10, 0, 70),
                width: double.maxFinite,
                child: Text(
                  "Search for your training space",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              
              renderContent(),
              Container (
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: BtnTertiary(label: label, clickFn: tapPrimary)
              )
              
              
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  renderContent() {
    if(mode == "field") {
      return renderSearch();
    } else {
      if(spaces.length == 0) {
        return Container (
          padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: EmptyLabel('', 'No results found\nmatching\n"'+_field.text+'"')
        );
      } else {
        return Column(
          children: renderList(),
        );
      }
    }
  }


  renderSearch() {
    return Container (
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: AppColors.fieldColor,
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        //autofocus: true,
        controller: _field,
        style: TextStyle(color: AppColors.textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'Trainer or gym name',
          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
          labelStyle: TextStyle(color: AppColors.textColor),
        ),
      )
    );
  }


  renderList() {
    List<Widget> items = [];
    for(var item in selected) {
      var label = item.name;
      var sublabel = item.email+"\n"+item.phone;
      if(item.business != null) {
        label = item.business;
        //sublabel = item.name+"\n"+item.email;
      }
      items.add(
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddTrainerPage(item)),);
          },
          child: CardAvatar(label, sublabel, item.image, 60, 24, "")
        )  
      );
    }
    return items;
  }
}
